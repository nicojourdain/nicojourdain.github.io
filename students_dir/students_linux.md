---
layout: page
title: Simple Linux commands
date: 27-01-2016
---

To get information about most Linux commands (e.g. cp, ls, ...) and options, use the man command, e.g. :
```shell
man cp
man ls
```

To know what is the current directory:
```shell
pwd
```

To know what is your login:
```shell
whoami
```

To know what is in a directory :
```shell
ls            ## displays content of current directory
ls -al        ## list in alphabetic order
ls -lrt       ## list from oldest to most recent
ls -1         ## list containing file/directory names only
ls dir1       ## displays content of directory dir1 
ls *.m        ## displays all files with a name ending as ".m"
ls toto*      ## displays all files with a name starting as "toto" 
ls [a-f]*     ## displays all files with a name starting with a letter between a and f
```

Changing directory :
```shell
cd /home/bob/dir1       ## go into directory /home/bob/dir1
cd ..                   ## go into parent directory
cd -                    ## go into previous directory
cd                      ## go into base directory (i.e. your home directory)
cd ~/dir1               ## go into dir1 that is located in your base directory 
```

Copy files or directories :
```shell
cp file1 file2        ## file2 is created as a copy of file1
cp -p file1 file2     ## copy while keeping read/write/execute permission unchanged
cp -r dir1 dir2       ## (recursive copy): directory dir2 is created as a copy of dir1 
```

Move a file to another directory or rename a file:
```shell
mv dir1/file1 dir2    ## file1 is moved from directory dir1 into directory dir2
mv file1 file2        ## file1 is renamed as file2
```

Remove a file:
```shell
rm file1
rm -i file1    ## asks for confirmation (y/n)
rm -f file1    ## (force): remove without asking for confirmation (usually set by default)
rm -rf dir1    ## remove dir1 and all files in dir1 (TO USE WITH CARE !)
```

Create a directory:
```shell
mkdir dir1
```

Remove an empty directory:
```shell
rmdir dir1
```

Create a link to a file or directory (usually in order to avoid numerous copies of a single large file):
```shell
ln -s -v ../../data_file.nc            ## link is called dat_file.nc
ln -s -v ../../data_file.nc toto.nc    ## link is called toto.nc
```

Look for a character pattern (e.g. "bobby") in an ASCII file (e.g. any fortran, python, matlab script) :
```shell
grep "bobby" file1  ## print all lines with pattern "bobby" in file1
grep "bobby" *.f90  ## print all lines with pattern "bobby" in files with a f90 extension
ls -al | grep "bobby" ## only keep lines with pattern "bobby" in the ls result
ls -al | grep -v "bobby" ## the lines containing "bobby" are not displayed in ls result
```

Display the content of an ASCII file (e.g. any fortran, python, matlab script) :
```shell
cat file1
more file1     ## displays little by little (space bar to go further and "q" to quit) 
head -20 file1 ## displays the 20 first lines
tail -20 file1 ## displays the 20 last lines
tail -f file1  ## displays last lines of file1 even while it is being written
ls -al |more      ## use the more command on the result of the ls command
ls -al | tail -2  ## displays the last two lines of the result of the ls command
```

To count the words, lines or characters in an ASCII file or in the result of a command line:
```shell
wc -l file1   ## nb of lines in file1
wc -c file1   ## nb of characters in file1
wc -w file1   ## nb of words in file1
ls -al dir1/*.f90 |wc -l  ## gives the number of fortran files located in directory dir1
```

To edit an ASCII file (e.g. any fortran, python, matlab script) there are several options (see online documentations), e.g. :
```shell
nano file1
gedit file1 &
emacs file1 &
vi file1  
```

To obtain the history of previous command lines:
```shell
history            ## to get the full history
history | grep cp  ## to get the list of cp commands in the history
history | tail -5  ## to get the last 5 command lines    
```

To redirect the results of a command line into an ASCII file called toto.log:
```shell
ls -al > toto.log    ## toto.log is created (or overwritten if it existed) 
                     ## and contains the result of the ls command.
ls -al >> toto.log   ## Same as above, except that the result is written 
                     ## at the end of toto.log if it already exists. 
```

Modify read (r), write (w) and execute (x) properties of a file for you (u), the rest of the group (g), others (o) or all (a):
```shell
chmod a+r file    ## gives reading right to everybody
chmod go-w file   ## removes writing rights to users from the group and other users
chmod +x file     ## gives executing rights to everybody
chmod u+x file    ## you obtain executing rights for this file
```

To check space usage and file sizes:
```shell
du -hs file1   ## displays size of file file1
du -hs dir1    ## displays total size of directory dir1 (including files therein)
df .           ## displays usage and available space for current disk
df             ## displays usage and available space for every mounted disk
```

To check/kill current process and memory usage:
```shell
top
top -u username    ## as top but only for user "username" 
ps                 ## displays your own running processes
kill -9 P_ID       ## kills running process of ID P_ID (ID obtained through top or ps)
```

To know the date and time:
```shell
date
```

To update a file date:
```shell
touch file1
```

To find your IP address (4 numbers giving the address of your host), try on of these commands:
```shell
/sbin/ifconfig
ip addr show
```
or visit [monippublique.com](http://www.monippublique.com).

To find the server name associated with an IP address ("your_IP"), you can try one of these commands:
```shell
nslookup your_IP
hostname
```

To connect to a remote host, try one of these :
```shell
ssh -Y login@your_IP      # replace "login" and "your_IP" with, e.g. bob and 132.37.121.137
ssh -Y login@server_name  # replace "server_name", e.g. machine.univ.fr
```

To copy files between your machine and a remote host, you can use one of these:
```shell
scp -p loal_file login@server_name:/usr/home/dir/.  # or vice versa
scp -rp local_dir login@server_name:/usr/home/dir/. # or vice versa
rsync -av loal_file login@server_name:/usr/home/dir/. # or vice versa
```
