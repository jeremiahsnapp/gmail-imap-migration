#!/usr/bin/python

# reference: http://code.google.com/googleapps/domain/gdata_provisioning_api_v2.0_reference_python.html

import gdata.apps.service
import sys

service = gdata.apps.service.AppsService(email='gdata_user@example.com', domain='example.com', password='')
service.ProgrammaticLogin()

username = sys.argv[1]

try:
    service.RestoreUser(username)
except Exception, e:
    print "Failed to restore user %s because %s" % (username, e.reason)
