#!/bin/bash
#crude little startup script for django web server
#NOT FOR PRODUCTION GRADE SYSTEMS!!
cd /opt/midnight
source midnight/bin/activate
/bin/python3 /opt/midnight/manage.py runserver 0.0.0.0:80
