#!/bin/sh

CTAG=""
TAGS=$(git tag --sort=committerdate | sort -Vr)

gitismerge () {
    local sha="$1"
    msha=$(git rev-list -1 --merges ${sha}~1..${sha})
    [ -z "$msha" ] && return 1
    return 0
}

checktaginhead() {
  git merge-base --is-ancestor $1 HEAD || return 1

  # Most recent tag with a commit in our branch
  CTAG=$2
  # Commits since tag
  COMMIT_COUNT=$(git log $CTAG..HEAD --oneline | wc -l)
  
  return 0
}

for TAG in $TAGS
do
  if [ -n "$TAG" ]; then
    if gitismerge $TAG; then
	REF="$TAG~1"
    else
	REF="$TAG"
    fi
    checktaginhead $REF $TAG && break
  fi
done

if [ -z "$CTAG" ]; then
  CTAG="0.0.0"
  COMMIT_COUNT=$(git log --oneline | wc -l)
fi

HEAD_HASH=$(git log --pretty=format:'%h' -n 1)

echo "$CTAG+$COMMIT_COUNT ($HEAD_HASH)"

exit 0
