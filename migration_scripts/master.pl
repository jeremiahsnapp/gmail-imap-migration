#!/usr/bin/perl

my $username = $ARGV[0];
my $migration_type = $ARGV[1];
my $migration_dry = $ARGV[2];


unless ( -e "../migration_logs/$username" ) {
    system("mkdir -p ../migration_logs/$username");
}

my $log_counter = 1;
while ( -e "../migration_logs/$username/$username.$log_counter" ) {
    $log_counter++;
}

open( STDOUT, '>', "../migration_logs/$username/$username.$log_counter" ) or die "Can't redirect STDOUT: $!";
open( STDERR, ">&STDOUT" ) or die "Can't dup STDOUT: $!";

print `date`;

# imapsync
system('../migrate_email.pl "' . $username . '" "' . $username . '" ' . $migration_type . ' ' . $migration_dry);

print `date`;
