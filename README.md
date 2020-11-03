# git-quick-version
A small immutable unix/sh script to get a reasonable version for the current git HEAD. No changes to workflow or repository required.

Will output a version in format: `{tag}-{commit_count}-{short_hash}`
It will take the most recent tag which has a commit in the current log.

Toy example of version at each commit:
```
* Release (tag: 1.1)    # "1.1+0 (c5c5c5c5)"
|
* Merge Commit #3	# "1.1-rc+2  (e5e5e5e)"
|\
| * Fix bugs 		# "1.1-rc1+1 (a5a5a5a)"
| |
| * RC1 (tag: 1.1-rc1)  # "1.1-rc1+0 (b5b5b5b)"
| |
| * Add feature		# "1.0+1 (f5f5f5f)"
|/
* Release (tag: 1.0)    # "1.0+0 (d5d5d5d)"
```

## Assumptions/Goals
You use `git tag` *sometimes*.

Your version can be any ASCII printable-string. Some protocols might have character constraints, this is not meant for that.

You want your version to be easily readable & accurate with *near-zero* effort and/or overhead.

Your git log is usually chronological.

## Edge-cases
There are some edge-cases which aren't yet covered (or are minimally covered).

### There are no tags in the log
Currently it will just show `0.0.0+{log_size} ({hash})`

### The tagged commit is not available on an upstream branch
Consider the example shown below.
Even though the `develop` merged into `master` is the release tag, the `develop` branch has no knowledge of this tag and only knows it's transitive parents.
So the versions for `develop` will all be `1.1+N ({hash})`.

While this case could technically be accounted for, there is no efficient way to do it (afaik).
And if we do, we will limit the freedom of the maintainer which is in conflict with our goals. 

```
  * Dev (develop)		# 1.3+1 ({hash})
 /|
* Release (master, tag: 1.3)	# 1.3+0 ({hash})
|\|
| * Dev				# 1.1+2 ({hash})
| |
* | Release (tag: 1.2)		# 1.2+0 ({hash})
|\|
| * Dev				# 1.1+1 ({hash})
|/
* Release (tag: 1.1)		# 1.1+0 ({hash})
```

