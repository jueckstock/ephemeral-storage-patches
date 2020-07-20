#!/bin/sh

PATCH_ROOT=$(dirname $0)

for path in $(git status -uno -s | grep "^ M " | cut -c4-); do
  NAME=$(echo "$path" | sed "s/\//-/g")
  git diff "$path" > "$PATCH_ROOT/$NAME.patch"
done
cat .git/HEAD >"$PATCH_ROOT/chromium_commit.txt"
