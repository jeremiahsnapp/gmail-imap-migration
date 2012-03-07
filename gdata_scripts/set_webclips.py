#!/usr/bin/python

# reference: http://code.google.com/googleapps/domain/email_settings/developers_guide_protocol.html

import gdata.apps.emailsettings.client
import sys

client = gdata.apps.emailsettings.client.EmailSettingsClient(domain='example.com')
client.ClientLogin(email='gdata_user@example.com', password='', source='your-apps')

username = sys.argv[1]
webclipenable = sys.argv[2]

try:
    client.UpdateWebclip(username, webclipenable)
    print "Set webclips to %s for %s" % (webclipenable, username)
except Exception, e:
    print "Failed to set webclips to %s for %s because %s" % (webclipenable, username, e.reason)
