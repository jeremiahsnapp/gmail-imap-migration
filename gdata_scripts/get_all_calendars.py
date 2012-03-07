#!/usr/bin/python

# reference: http://code.google.com/apis/calendar/data/2.0/developers_guide_python.html

try:
  from xml.etree import ElementTree
except ImportError:
  from elementtree import ElementTree
import gdata.calendar.data
import gdata.calendar.client
import gdata.acl.data
import atom.data
import time

import sys

client = gdata.calendar.client.CalendarClient(source='yourCo-yourAppName-v1')
client.ClientLogin('gdata_user', 'gdata_user_password', client.source);

username = sys.argv[1]

def PrintUserCalendars(calendar_client):
  feed = calendar_client.GetCalendarsFeed(uri='https://www.google.com/calendar/feeds/' + username + '@example.com/allcalendars/full')
  print feed.title.text
  for calendar in feed.entry:
    print '\t%s. %s' % (calendar.title.text,)

#    !!! we need to get the individual calendar's ACL feed URI from the calendar xml metadata
#    the ACL feed URI is contained in a link element where rel="http://schemas.google.com/acl/2007#accessControlList".
#    These links have the form https://www.google.com/calendar/feeds/<calendarId>/acl/full.
#    reference: http://code.google.com/apis/calendar/data/2.0/developers_guide_python.html#RetrieveAcl

#    feed = calendar_client.GetCalendarAclFeed(uri='??????????')
#    for acl in acl_feed.entry:
#        print '{0:>60} ({1}) is {2}'.format(acl.scope.value, acl.scope.type, acl.role.value)

PrintUserCalendars(client)
