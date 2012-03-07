#!/usr/bin/python

# reference: http://code.google.com/googleapps/domain/email_settings/developers_guide_protocol.html

import gdata.apps.emailsettings.client
import sys

client = gdata.apps.emailsettings.client.EmailSettingsClient(domain='example.com')
client.ClientLogin(email='gdata_user@example.com', password='', source='your-apps')

username = sys.argv[1]
imapenable = sys.argv[2]

client.UpdateImap(username, imapenable)
