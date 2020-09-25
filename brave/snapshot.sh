#!/bin/sh

PATCH_ROOT=$(dirname $0)

for patch in "$PATCH_ROOT"/*.patch; do
	rawname=$(basename $patch)
	cookedname=$(echo "${rawname%.patch}" | sed 's/-/\//g')
	git diff "$cookedname" > "$patch"
done
cat .git/HEAD >"$PATCH_ROOT/brave_commit.txt"
