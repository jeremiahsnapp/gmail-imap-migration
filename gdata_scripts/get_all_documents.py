#!/usr/bin/python

# reference: http://code.google.com/apis/documents/docs/3.0/developers_guide_python.html

import gdata.docs.data
import gdata.docs.client
import sys

client = gdata.docs.client.DocsClient(source='yourCo-yourAppName-v1')
client.ClientLogin('gdata_user', 'gdata_user_password', client.source);

username = sys.argv[1]


def PrintEntries(entries):
  print '\n'
  for entry in entries:
    print '{0:<15} {1}'.format(entry.GetResourceType(), entry.title.text.encode('UTF-8'))
    acl_feed = client.GetResourceAcl(entry)
    for acl in acl_feed.entry:
        print '{0:>60} ({1}) is {2}'.format(acl.scope.value, acl.scope.type, acl.role.value)

entries =  client.GetAllResources(uri='/feeds/' + username + '@example.com/private/full')
PrintEntries(entries)
