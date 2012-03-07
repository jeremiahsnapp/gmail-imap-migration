#!/usr/bin/python

# reference: http://code.google.com/googleapps/domain/gdata_provisioning_api_v2.0_reference_python.html

import gdata.apps.service

service = gdata.apps.service.AppsService(email='gdata_user@example.com', domain='example.com', password='')
service.ProgrammaticLogin()

users_feed = service.RetrieveAllUsers()
#users_feed = service.RetrievePageOfUsers(start_username=None)

for user in users_feed.entry:
    username = user.login.user_name.lower()
    print username
