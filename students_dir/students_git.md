---
layout: page
title: Basic git commands
date: 13-07-2017
---


To clone an existing git repository: 
```shell
git clone https://github.com/nicojourdain/BUILD_CONFIG_NEMO_2.git
```

Then, to update the content of your directory (i.e. if there have been changes in the cloned git repository):
```shell
git pull
```

To know what is the ID of the last commit (version) on your machine, you can look at files in .git/logs or type:
```shell
git rev-parse HEAD
```

To shift to a given commit:
```shell
git checkout 3e9803dff8099997b647b715f76e485ec94ec1e3  ## adapt ID
```


