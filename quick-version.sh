#!/bin/sh

CTAG=""
TAGS=$(git tag --sort=committerdate | sort -Vr)

for TAG in $TAGS
do
  if [ -n "$TAG" ]; then
    if git merge-base --is-ancestor $TAG~1 HEAD; then
      # Most recent tag with a commit in our branch
      CTAG=$TAG
      # Commits since tag
      COMMIT_COUNT=$(git log $CTAG..HEAD --oneline | wc -l)
      break
    fi
  fi
done

if [ -z "$CTAG" ]; then
  CTAG="0.0.0"
  COMMIT_COUNT=$(git log --oneline | wc -l)
fi

HEAD_HASH=$(git log --pretty=format:'%h' -n 1)

echo "$CTAG+$COMMIT_COUNT ($HEAD_HASH)"

exit 0
