#!/bin/bash
#crude little startup script for django web server
#NOT FOR PRODUCTION GRADE SYSTEMS!!
#get the latest files selectively from the git repo:
/bin/cd /opt/deploy/terraform-poc-django-app/
/bin/git pull
/bin/cp midnight/midnight/settings.py /opt/midnight/midnight/settings.py 
/bin/cp  midnight/polls/views.py  /opt/midnight/polls/views.py 
/bin/cp midnight/polls/urls.py /opt/midnight/polls/urls.py 
/bin/cp  midnight/polls/models.py /opt/midnight/polls/models.py
/bin/cp  midnight/polls/apps.py /opt/midnight/polls/apps.py 
#Jump into the Django dir and start a virtualenv
cd /opt/midnight
source midnight/bin/activate
/bin/python3 /opt/midnight/manage.py runserver 0.0.0.0:80
