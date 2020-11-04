# git-quick-version
A small immutable unix/sh script to get a reasonable version for the current git HEAD. No changes to workflow or repository required.

Will output a version in format: `{tag}+{commit_count} ({short_hash})`

It will take the most recent tag which has a commit in the current log. The `commit_count` will be all commits between the `tag` and the `short_hash`.

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

Try it out:
```
curl -s https://raw.githubusercontent.com/i404788/git-quick-version/master/quick-version.sh | sh
```

## Assumptions/Goals
You use `git tag` *sometimes*.

Your version can be any ASCII printable-string. Some protocols might have character constraints, this is not meant for that.

You want your version to be easily readable & accurate with *near-zero* effort and/or overhead.

Your git log is usually chronological.

## Theory of Operation 
There are some edge-cases which aren't yet covered (or are minimally covered).

### No tags in the log 
Currently it will just show `0.0+{log_size} ({hash})`

Checkout at `f5a44ca005c4ced88b9b7118db6164f4f1caa639` to see this in action.
> `quick-version` will give `0.0+0 (f5a44ca)`

### Tag finding algorithm

Normally, if `develop` merged into `master` and `master` is then the release tag, the `develop` branch has no knowledge of this tag and only knows it's transitive parents. Resulting in `develop` having an out-of-date version even though it was the cause of the tag.

We have fixed this by checking if `$TAG^2` is in the current log, **this means that after a tag is created the last remote (develop) commit before the merge will have the same non-hash version.**
This feature is put in place so it requires minimal upkeep to get accurate versions on an upstream branch.

Note that tags on non-merge commits will still work the same way as usual see `1.4+0` & `1.2+1`. This means that a rebase or merge back can still be useful or necessary to get the versioning you want.

Consider the example shown below.

```
  * Merge3 (develop)		# 1.4+1-\  |`master` is merged back into `develop` to gain the `1.4` tag
 /|					 |-|If this wasn't a merge the version would still be `1.2+2`
* | Release3 (master, tag: 1.4)	# 1.4+0-/
| |
* | Merge2			# 1.3+1--\
|\|					 |-----|1.3+1 is a direct descendant of `1.3` and does not have a tag
| * Dev2			# 1.2+1--|---\
| |					 |    \  |1.2+1 gets tag from the merged `Dev1`
* | Release2 (tag: 1.3)		# 1.3+0--/     |-|`Dev1` gets the tag from `1.2`
| |					      /
* | Merge1 (tag: 1.2)		# 1.2+0------/
|\|					    /
| * Dev1			# 1.2+0----/
|/
* Release1 (tag: 1.1)		# 1.1+0
```

