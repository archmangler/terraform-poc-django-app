#!/bin/python3
#little ci/cd component to check for updates in the django site repo
#and trigger a reboot of the node, forcing an update!
#seems a little drastic, but here we demonstrate the concept of
#immutable, disposable servers and stateless dumb web frontends
#traiano@gmail.com
#

import subprocess
import git
from git import Repo

def git_pull(git_dir):
 g = git.cmd.Git(git_dir)
 g.pull()

def harakiri():
 #apply a DROP rule to port 80 resulting in this server being terminated by the AWS ASG.
 drop_rule="/sbin/iptables -I INPUT 1 -i eth0 -p tcp --dport 80 -j DROP"
 subprocess.call(["/sbin/iptables", "-I", "INPUT", "1", "-i", "eth0", "-p", "tcp", "--dport", "80", "-j", "DROP"])

git_dir="/opt/deploy/terraform-poc-django-app"
repo = Repo(git_dir)
assert not repo.bare
diff = repo.git.diff()
content_count=0
for line in diff:
 content_count+=1
if(content_count>0):
 print("changes: "+diff)
 harakiri()
else:
 print("No changes.")
