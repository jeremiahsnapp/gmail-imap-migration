#!/usr/bin/perl

my $user1 = $ARGV[0];
my $user2 = $ARGV[1];
my $migration_type = $ARGV[2];
my $migration_dry = $ARGV[3];

my $imapsync_args = <<END;
--host1 email.example.com --ssl1 --authuser1 admin --user1 "$user1" --passfile1 zimbrapass \\
--host2 imap.gmail.com --ssl2 --authmech2 XOAUTH --user2 "$user2" --passfile2 zimbrapass \\
--nosyncacls --syncinternaldates \\
END

if ($migration_type eq 'justlogin') {

    # just test login authentication to both servers
    $imapsync_args .= <<END;
--justlogin
END
}
else {
    # !!!!! i really need to test that the following ssh command doesn't crash and if it does then abort this script
    my @root_folders = `ssh zimbra\@192.168.1.5 zmmailbox -z -m "$user1" gaf`; 

    my @excludes;
    for (@root_folders) { 
        if ( /\s+(?:conv|mess|cont)\s+.*\s+\/(.*)\s+\(.*\@example\.com:.*\)/ || /\s+cont\s+.*\s+\/(.*)/ ) {
            my $root_folder = $1;
            $root_folder =~ s/\$/\\\$/g;
            $root_folder =~ s/&/&-/g;
            push (@excludes, "--exclude \"^\Q$root_folder\$\E|^\Q$root_folder\/\E\"")
        }
    }
    my $excludes_string = join (" \\\n", @excludes);
    # --skipsize
    # Don't take message size into account.
    # consider --skipsize to avoid duplicate messages
    # when running syncs more than one time per mailbox

    # --allowsizemismatch
    # allow RFC822.SIZE != fetched msg size
    # consider also --skipsize to avoid duplicate messages
    # when running syncs more than one time per mailbox

    # --useheader
    # Use this header to compare messages on both sides.
    # Ex: Message-ID or Subject or Date.
    # I added Date as a header to match so imapsync wouldn't skip over email that don't have a Message-Id header

    # --split1
    # --split2
    # split the requests in several parts on the server.
    # <int> is the number of messages handled per request.
    # default is like --split1 1000

    # --fastio1
    # --fastio2
    # use fastio

    # --buffersize
    # sets the size of a block of I/O

    # --nofoldersizes
    # Do not calculate the size of each folder in bytes
    # and message counts. Default is to calculate them.

    # some errors were saying "Write failed 'Broken pipe'" so I added these parameters to see if imapsync just needs to reconnect to the imap servers
    # --reconnectretry1 <int>: reconnect if connection is lost up to <int> times
    # --reconnectretry2 <int>: reconnect if connection is lost up to <int> times

    # --exclude
    # exclude folders that match the regex
    # this is used to exclude contacts folders (which are visible via imap), shared folders, and the 'Chats' folder
    # it is also used to exclude Zimbra's 'Junk' and 'Junk E-mail' folders since we don't need to migrate spam
    # especially since it mysteriously gets deleted from Google's Spam folder about 24 hours after migration anyway

    # --regextrans2
    # convert Zimbra folder names to Google labels
    # this also makes sure Zimbra trash gets migrated to a folder/label instead of Google's trash since it
    # mysteriously gets deleted from Google's Trash folder about 24 hours after migration anyway
    # removes INBOX from beginning of INBOX subfolder names
    # removes all whitespace at the beginning of a folder name
    # removes excess whitespace
    # removes ^ characters

    # --maxsize 35678178  :  skip messages larger than 35678178 bytes
    # With Gmail, you can send and receive messages up to 25 megabytes (MB) in size.
    # In practice, 35678178 was one of the smallest email that Google refused to migrate so I chose it rather than assume the 25MB limit.

    # --regexmess   <regex>  : Apply the whole regex to each message before transfer.
    # 's/\000/ /g' # to replace null by space.
    # without this some email will fail to migrate


    $imapsync_args .= <<END;
--useheader Message-Id \\
--useheader Date \\
--skipsize \\
--split1 3000 \\
--split2 3000 \\
--fastio1 \\
--fastio2 \\
--buffersize 8192000 \\
--nofoldersizes \\
--reconnectretry1 1 \\
--reconnectretry2 1 \\
--exclude "^\QChats\$\E|^\QChats\/\E|^\QJunk\$\E|^\QJunk E-mail\$\E" \\
$excludes_string \\
--regextrans2 's/^Drafts\$/\\[Gmail\\]\\/Drafts/' \\
--regextrans2 's/^Sent\$/\\[Gmail\\]\\/Sent Mail/' \\
--regextrans2 's/^Trash\$/Zimbra Trash/' \\
--regextrans2 's/^Trash\\//Zimbra Trash\\//' \\
--regextrans2 's/^INBOX\\///' \\
--regextrans2 's/^\\s+//g' \\
--regextrans2 's/\\/\\s+/\\//g' \\
--regextrans2 's/\\s{2,}/ /g' \\
--regextrans2 's/\\^//g' \\
--maxsize 35678178 \\
--allowsizemismatch \\
--regexmess 's/\\000/ /g'
END

}

if ($migration_type eq 'delete') {
    chomp ($imapsync_args);

    # --delete2 : delete messages on the destination imap server that are not on the source server.
    # --uidexpunge2 : uidexpunge messages on the destination imap server that are not on the source server, requires --delete2

    $imapsync_args .= ' --delete2 --uidexpunge2';
}

if ($migration_type eq 'justfolders') {
    chomp ($imapsync_args);

    # --justfolders
    # only migrate folder structure

    $imapsync_args .= ' --justfolders';
}

if ($migration_dry eq 'dry') {
    chomp ($imapsync_args);

    # --dry
    # perform a dry run; don't actually migrate anything
    $imapsync_args .= ' --dry';
}

#print $imapsync_args;
#exit;

system ('../imapsync/imapsync '.$imapsync_args);
