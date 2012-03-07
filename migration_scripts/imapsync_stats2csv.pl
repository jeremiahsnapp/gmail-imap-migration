#!/usr/bin/perl

use File::Basename;

$filename = $ARGV[0];

open( FH, '<', "$filename");

while (<FH>) {

($account, $run) = ($1, $2) if basename($filename) =~ /(.*)\.(\d+)/;

$msgs_transferred = $1 if /^Messages transferred .*:\s+(\d+)/;

$msgs_skipped = $1 if /^Messages skipped .*:\s+(\d+)/;

$msgs_deleted1 = $1 if /^Messages deleted on host1.*:\s+(\d+)/;

$msgs_deleted2 = $1 if /^Messages deleted on host2.*:\s+(\d+)/;

$bytes_skipped = $1 if /^Total bytes skipped .*:\s+(\d+)/;

$bytes_error = $1 if /^Total bytes error .*:\s+(\d+)/;

$bytes_transferred = $1 if /^Total bytes transferred .*:\s+(\d+)/;

$time = $1 if /^Time .*:\s+(\d+)/;

$rate = $1 if /^Average bandwith rate .*:\s+(\d+)/;

$errors = $1 if /^Detected (\d+) errors/;

}

print join(',', $account, $run, $msgs_transferred, $msgs_skipped, $msgs_deleted1, $msgs_deleted2, $bytes_skipped, $bytes_error, $bytes_transferred, $time, $rate, $errors), "\n";
