#!/bin/bash

if [ "$2" = "true" ]
then
    ssh zimbra\@192.168.1.5 zmprov ma "$1" zimbraMailForwardingAddress "$1"@pilot.example.com zimbraPrefMailLocalDeliveryDisabled TRUE
else
    ssh zimbra\@192.168.1.5 zmprov ma "$1" zimbraMailForwardingAddress \"\" zimbraPrefMailLocalDeliveryDisabled FALSE
fi
