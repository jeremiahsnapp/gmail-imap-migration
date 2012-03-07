#!/bin/bash

if [ "$2" == 'last' ]
then
    file=~/migration_logs/$1/`ls -t1 /root/migration_logs/$1/|head -n1`
else
    file=$1
fi

#\
#xargs -I{} grep -Z -A1 '\+ Copying msg #{}' $file`

detected_errors=`awk '/Detected .* errors/{print $2}' $file`

failed_email_count=`perl -ne 'print $1,"\n" if /^(?:\+ Copying msg #|Copied msg id \[)(\d+)/' < $file | \
uniq -c | \
awk '{if ($1 == 1) print $2}' | wc -l`

failed_email=`perl -ne 'print $1,"\n" if /^(?:\+ Copying msg #|Copied msg id \[)(\d+)/' < $file | \
uniq -c | awk '{if ($1 == 1) print $2}' | sort | uniq | \
xargs -I{} grep -A1 '\+ Copying msg #{}:' $file`

echo "$file"
echo "$detected_errors errors detected by imapsync"
echo "$failed_email_count email failed to copy"
echo "$failed_email"
