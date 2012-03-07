#!/usr/bin/perl

use Mail::IMAPClient;
use MIME::Base64;

$imap = create_imap_client( 'imap.googlemail.com', $ARGV[0] );

$imap->append_file($ARGV[1], $ARGV[2]);

$imap->logout;


sub create_imap_client {
    my ( $host, $user, $password ) = @_;

    my $imap;

    my $port = $to_imaps ? "993" : "143";
    my $authuser = $user;

    my $authmech = "XOAUTH";

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
        Debug  => (1),
        Buffer => (4096),
        Ssl    => (1)
    );

    $imap->Server($host);
    $imap->connect;
    return $imap if ( !$imap->IsConnected );

    $imap->Authmechanism($authmech);
    $imap->Authcallback( \&plainauth ) if $authmech eq "PLAIN";
    $imap->Authcallback( \&xoauth ) if $authmech eq "XOAUTH";

    $imap->User($user);
    $imap->{AUTHUSER} = $authuser;
    $imap->Password($password);

    $imap->login();

    return $imap;
}

sub xoauth() {
    my $code = shift;
    my $imap = shift;

    use Net::OAuth;
    use URI::Escape;
    use MIME::Base64;
    use Digest::MD5 qw(md5_base64);

    my $domain = 'example.com';
    my $consumer_key = $domain;
    my $consumer_secret = 'Knk59U3TRaDdEjg2hAspLvpz';
    my $username = $imap->User();
    my $request_url = 'https://mail.google.com/mail/b/'.$username.'@'.$domain.'/imap/';

    my $oauth = Net::OAuth->request('consumer')->new(
        consumer_key => $consumer_key,
        consumer_secret => $consumer_secret,
        request_url => $request_url,
        request_method => 'GET',
        signature_method => 'HMAC-SHA1',
        timestamp => time(),
        nonce => md5_base64(time()),
        extra_params => {
            'xoauth_requestor_id' => $username.'@'.$domain,
        },
    );

    $oauth->sign;

    my $sig = $oauth->to_authorization_header;
    $sig =~ s/^OAuth/'GET '.$oauth->request_url.'?xoauth_requestor_id='.uri_escape($username.'@'.$domain)/e;
    return encode_base64($sig, '');
}

sub plainauth() {
    my ( $code, $imap ) = @_;

    my $string = sprintf( "%s\x00%s\x00%s", $imap->User, $imap->{AUTHUSER}, $imap->Password );
    return encode_base64( "$string", "" );
}

