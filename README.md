# Parent-Frame-Length Storage Isolation for Third-Party Storage

# Overview

Patches to Chromium 83/Brave 1.12.48 to implement a [proposed storage policy](https://github.com/privacycg/proposals/issues/18).

Known to build when applied to chromium commit `faf34a95a93ff46eb36000dab45cf66e58048b0f` (for use with building brave-core commit `cd7b03a17000114d25a6b8f5971ee6817ef6ad7d`, or brave-core branch `page-graph`).

# Usage

The *page-length* storage policy is triggered via a new CLI flag: `--ephemeral-frame-storage`.

By **also** using the additional CLI flags `--efs-top-origin` and `--efs-persist`, the alternate *site-keyed* policy can be enabled.

# Example Crawl Data

Example PageGraph data collected from parallel crawls using the above policies (and permissive/blocking baseline policies) across 3.4k pages from the Tranco 1k top sites are available: [iteration 1](https://drive.google.com/file/d/11sCXF4nGQrYxN-BX4Rru8R0DQtPvDLfi/view?usp=sharing), [iteration 2](https://drive.google.com/file/d/15b3JYfhC_ZQbL2Fpcux3c9D4ic2i9YYo/view?usp=sharing).

