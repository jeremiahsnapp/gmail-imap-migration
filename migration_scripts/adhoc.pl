#!/usr/bin/perl

my $username = $ARGV[0];
my $migration_type = $ARGV[1];
my $migration_dry = $ARGV[2];


unless ( -e "../adhoc_logs/$username" ) {
    system("mkdir -p ../adhoc_logs/$username");
}

my $log_counter = 1;
while ( -e "../adhoc_logs/$username/$username.$log_counter" ) {
    $log_counter++;
}

open( STDOUT, '>', "../adhoc_logs/$username/$username.$log_counter" ) or die "Can't redirect STDOUT: $!";
open( STDERR, ">&STDOUT" ) or die "Can't dup STDOUT: $!";

print `date`;

# imapsync
system('./adhoc_migrate_email.pl "firstuser@gmail.com" "' . $username . '" ' . $migration_type . ' ' . $migration_dry);

print `date`;
