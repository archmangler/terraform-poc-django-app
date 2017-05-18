#!/bin/python
#little ci/cd component to check for updates in the django site repo
#and trigger a reboot of the node, forcing an update!
#seems a little drastic, but here we demonstrate the concept of 
#immutable, disposable servers and stateless dumb web frontends 
#
import subprocess
import git
from git import Repo

def git_pull(git_dir):
 g = git.cmd.Git(git_dir) 
 g.pull()

git_dir="/Users/traianowelcome/Desktop/output/dcos_deployers/generic-autoscaling-server/autoscaling/sanity"
repo = Repo(git_dir)
assert not repo.bare
diff = repo.git.diff('HEAD~1..HEAD', name_only=True)
if(diff):
 print(diff)
 git_pull(git_dir)
else:
 print("No changes.")
