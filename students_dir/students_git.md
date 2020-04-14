---
layout: page
title: Basic git commands
date: 13-07-2017
---

Here are provided a few basic git commands.

# Cloning and updating an existing git repository

To clone an existing git repository: 
```shell
git clone https://github.com/nicojourdain/BUILD_CONFIG_NEMO_2.git
```

Then, to update the content of your directory (i.e. if there have been changes in the cloned git repository):
```shell
git pull
```

# Developing in a git environment (basic)

Here we assume that there is only one branch, the _master_ branch, e.g. if you are the only developer of a simple repository.

To add one or all files to the git version control system:
```shell
git add [file_name]
git add -A
```

To attribute a revision hash (ID) when you have changed a file or all the files that are followed by git:
```shell
git commit -m 'explain what has been changed here' [file_name]
git commit -m 'explain what has been changed here' --all
```
At this stage, the revision is saved on your local computer, but not on the platform where your git repository is centralized (e.g. GitHub, GitLab,...).

To put save your latest on this platform:
```shell
git push
```

To see which files have been added to git and which ones have been modified:
```shell
git status
```

To know what is the revision hash (ID) of previous commits on your machine, you can look at files in .git/logs or type:
```shell
git log --oneline
```

To retrieve a single file from a previous commit:
```shell
git checkout [revision_hash] [file_name]
```

To shift the entire git repository to a previous commit:
```shell
git checkout [revision_hash]
```

Then, you can go back to the master branch with:
```shell
git checkout master
```


