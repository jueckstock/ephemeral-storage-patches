# Ephemeral/Split-Key Storage Experiment Patches

## Overview

Patches for Chromium to implement a [proposed storage policy](https://github.com/privacycg/proposals/issues/18).

Initially based off of a Brave branch (Chrome 83 based).  Moving to vanilla Chromium 84 asap.

This has been tested on a patched build of Brave using a [test harness](https://github.com/jueckstock/storage-tests) that covers `localStorage`, cookies set by JS API, and cookies set by HTTP request/response.  The correct/anticipated isolation behavior was observed.

## Concept

On sub-frame navigation to URLs whose "site URL" (i.e., scheme and eTLD+1 hostname) do not match that of the root-frame's last committed URL, augment the new `SiteInstance` by decorating its defining site URL (e.g., `http://example.com`) with a distinct prefix containing a GUID-shaped/sized isolation key (e.g., `http://esp---{{32-hex-chars}}---example.com`.  

By using the root-frame's last committed navigation's unique/unguessable token as the isolation key, we achieve top-frame-document-lifetime split-key isolation on 3rd-party subframes.  If we instead use, e.g., the MD5 of the root document's site URL, we get top-document-eTLD+1 split-key isolation on 3rd-party subframes.  

Other policies are possible by constructing a different isolation key, naturally.  In any case, the augmented `SiteInstance` is configured to be in-memory only, leaving no persistance across browser restarts.


## Files Modified

* `content/browser/frame_host/frame_tree_node.h`
    * modify the `FrameTreeNode` class to contain a `base::Optional<base::UnguessableToken>` with getter/setter
* `content/browser/frame_host/render_frame_host_manager.cc`
    * `RenderFrameHostManager::GetFrameHostForNavigation(...)`
        * part 1: if our frame is the root frame and the request is in state 5 (the last state we see in this path), stash that nav request's unique token into our frame tree node using the setter added above
        * part 2: if our frame is (A) a subframe and (B) different-eTLD+1-site than the root, combine the root-document's environmental key (nav token) to the eTLD+1 in the sub-frame's site URL before passing this on as extra information ("alt-site") to ...
    * `RenderFrameHostManager::GetSiteInstanceForNavigationRequest(...)`
	* add an optional `GURL` pointer argument (default = `nullptr`) for "alt-site" and pass it to `GetSiteInstanceForNavigation(...)` in place of the "correct" site URL (if it's there)
* `content/browser/child_process_security_policy_impl.cc`
    * `ChildProcessSecurityPolicyImpl::CanAccessDataForOrigin(...)`
        * if the `actual_process_lock` URL contains our magic site-URL prefix (`esp---{{GUID}}---`), strip that out before performing URL comparisons to do process matching (since the incoming navigation URL doesn't have the ephemeral key embedded in its hostname and so cannot match the lock URL as-is)
* `chrome/browser/chrome_content_browser_client.cc`
    * `ChromeContentBrowserClient::GetStoragePartitionConfigForSite(...)`
        * if the site-url has an `esp---{{GUID}}---` prefix, create a custom/in-memory partition keyed by this decorated site-url (otherwise, use the default)
    * `ChromeContentBrowserClient::GetStoragePartitionIdForSite(...)`
        * add a logic branch to use the site-url as the partition-id if it contains an `esp---{{GUID}}---` prefix (which gets around some SessionStorageNamespace DCHECKs)

