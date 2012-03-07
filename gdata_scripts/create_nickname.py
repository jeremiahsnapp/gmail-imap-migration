#!/usr/bin/python

# reference: http://code.google.com/googleapps/domain/gdata_provisioning_api_v2.0_reference_python.html

import gdata.apps.service
import sys

username = sys.argv[1]
nickname = sys.argv[2]

print "Creating nickname %s for user %s" % (nickname, username)

service = gdata.apps.service.AppsService(email='gdata_user@example.com', domain='example.com', password='')
service.ProgrammaticLogin()

try:
    service.CreateNickname(username, nickname)
    print "Created nickname %s for user %s" % (nickname, username)
except Exception, e:
    print "Failed to create nickname %s for user %s because %s" % (nickname, username, e.reason)
