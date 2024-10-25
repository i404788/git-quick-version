#!/bin/sh

# Check if current commit is a tag
CTAG="$(git tag --points-at HEAD)"
COMMIT_COUNT=0

if [ -z "$CTAG" ]; then
  # Current commit is not a tag
  # So let's find a suitable tag
  
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
        # If the tag is on a merge
	# we want to use the remote parent commit (^2)
        # so upstream branches can also use it
        checktaginhead "$TAG^2" $TAG && break
      else
	checktaginhead $TAG $TAG && break
      fi
    fi
  done
fi

# No suitable tag found, use default version
if [ -z "$CTAG" ]; then
  CTAG="0.0"
  COMMIT_COUNT=$(git log --oneline | wc -l)
fi

HEAD_HASH=$(git log --pretty=format:'%h' -n 1)

if [ $COMMIT_COUNT == "0" ]; then
  echo "$CTAG"
else
 echo "$CTAG+$COMMIT_COUNT ($HEAD_HASH)"
fi

exit 0
