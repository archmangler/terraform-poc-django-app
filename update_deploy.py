#!/bin/python3
#to be run from cron.
#little ci/cd component to check for updates in the django site repo
#and trigger a termination of the node, forcing an updated node
#to replace it.
#NOTE: Seems a little drastic, but here we demonstrate the concept of
#immutable, disposable servers and stateless dumb web frontends
#termination is triggered by firewalling port 80 - the ELB
#then declares instance as unhealthy , and the ASG policy replaces it.
#traiano@gmail.com
#commit 1
#commit 2

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
