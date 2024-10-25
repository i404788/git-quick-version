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
    COMMIT_COUNT=$(git log $CTAG..HEAD --oneline | wc -l | xargs)
    
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
  COMMIT_COUNT=$(git log --oneline | wc -l | xargs)
fi

HEAD_HASH=$(git log --pretty=format:'%h' -n 1)

# export CTAG
# export COMMIT_COUNT
# export HEAD_HASH

human_format() 
{
  if [ $COMMIT_COUNT = "0" ]; then
   echo "$CTAG ($HEAD_HASH)"
  else
   echo "$CTAG+$COMMIT_COUNT ($HEAD_HASH)"
  fi
}

rfc3986_format()
{
  if [ $COMMIT_COUNT = "0" ]; then
   echo "$CTAG"
  else
   echo "$CTAG.$COMMIT_COUNT-$HEAD_HASH"
  fi
}

OUTPUT_FORMATS="rfc3986, human"
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "quick-version - A small unix/sh script to get a reasonable version for the current git HEAD"
      echo " "
      echo "options:"
      echo "-h, --help                show brief help"
      echo "-o <output format>        specify the output format ($OUTPUT_FORMATS)"
      exit 0
      ;;
    -o)
      shift
      if test $# -gt 0; then
        if [ $1 = "rfc3986" ]; then 
          # RFC3986
          rfc3986_format
          exit 0
        elif [ $1 = "human" ]; then
          # Human readable (original format)  
          human_format
          exit 0
        else
          echo "Output format not defined: $1 (valid: $OUTPUT_FORMATS)"
          exit 1
        fi
      else
        echo "Missing output format (valid: $OUTPUT_FORMATS)"
        exit 1
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

human_format
exit 0
