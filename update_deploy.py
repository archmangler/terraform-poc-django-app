#!/bin/python
#little ci/cd component to check for updates in the django site repo
#and trigger a reboot of the node, forcing an update!
#seems a little drastic, but here we demonstrate the concept of 
#immutable, disposable servers and stateless dumb web frontends 
#
import subprocess
import git

def git_pull():
 g = git.cmd.Git(git_dir) 
 g.pull()

git_pull()
