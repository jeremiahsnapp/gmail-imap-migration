#!/usr/bin/perl

use Mail::IMAPClient;
use MIME::Base64;


$to_authuser = 'admin';
$to_authuser_password = '';

$imap = create_imap_client( '192.168.1.5', $ARGV[0] );

$imap->select($ARGV[1]);

$msg_string = $imap->message_string($ARGV[2]);

print $msg_string;

$imap->logout;


sub create_imap_client {
    my ( $host, $user, $password ) = @_;

    my $imap;

    my $port = $to_imaps ? "993" : "143";
    my $authuser = $user;

    my $authmech = "PLAIN";

    # if the imap server allows for admin access to user accounts then set $authuser and $password to an imap account with admin rights
    if ( $to_authuser && $to_authuser_password ) {
        $authuser = $to_authuser;
        $password = $to_authuser_password;
    }

    $imap = Mail::IMAPClient->new(
        Clear  => (20),
        Port   => (993),
        Uid    => (1),
        Peek   => (1),
        Debug  => (0),
        Buffer => (4096),
        Ssl    => (1)
    );

    $imap->Server($host);
    $imap->connect;
    return $imap if ( !$imap->IsConnected );

    $imap->Authmechanism($authmech);
    $imap->Authcallback( \&plainauth ) if $authmech eq "PLAIN";

    $imap->User($user);
    $imap->{AUTHUSER} = $authuser;
    $imap->Password($password);

    $imap->login();

    return $imap;
}

sub plainauth() {
    my ( $code, $imap ) = @_;

    my $string = sprintf( "%s\x00%s\x00%s", $imap->User, $imap->{AUTHUSER}, $imap->Password );
    return encode_base64( "$string", "" );
}

