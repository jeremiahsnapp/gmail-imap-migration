#!/usr/bin/perl

use LWP::UserAgent;

    use Net::OAuth;
    use URI::Escape;
    use MIME::Base64;
    use Digest::MD5 qw(md5_base64);

    my $domain = 'example.com';
    my $consumer_key = $domain;
    my $consumer_secret = 'Knk59U3TRaDdEjg2hAspLvpz';
    my $username = $ARGV[0];
    my $request_url = 'https://apps-apis.google.com/a/feeds/emailsettings/2.0/'.$domain.'/'.$username.'/imap';

    my $oauth_request = Net::OAuth->request('consumer')->new(
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

    $oauth_request->sign;





my $ua = LWP::UserAgent->new;
#$ua->default_header('Content-type' => 'application/atom+xml');
$ua->default_header('Authorization' => $oauth_request->to_authorization_header);

my $oauth_response = $ua->get($request_url . '?xoauth_requestor_id=' . $username . '@' . $domain);

print "IMAP: ",$username," ",$1,"\n" if $oauth_response->as_string =~ /name='enable' value='(.*)'/;
