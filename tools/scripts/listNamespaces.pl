#!/usr/bin/perl
binmode STDOUT, ":utf8";
binmode STDIN, ":utf8";

use utf8;
use lib "../";
use lib "../classes/";

use Config;
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Mediawiki::Mediawiki;

# log
use Log::Log4perl;
Log::Log4perl->init("../conf/log4perl");
my $logger = Log::Log4perl->get_logger("listNamespaces.pl");

# get the params
my $host = "";
my $path = "";
my $username = "";
my $password = "";

## Get console line arguments
GetOptions('host=s' => \$host, 
	   'path=s' => \$path,
	   'username=s' => \$username,
	   'password=s' => \$password
	   );

if (!$host) {
    print "usage: ./listNamespaces.pl --host=my.wiki.org [--path=w] [--username=foo] [--password=bar]\n";
    exit;
}

my $site = Mediawiki::Mediawiki->new();
$site->hostname($host);
$site->path($path);
$site->logger($logger);
if ($username) {
    $site->user($username);
    $site->password($password);
}
$site->setup();

my %namespaces = $site->namespaces();

foreach my $code (keys(%namespaces)) {
    print $code."\t".$namespaces{$code}."\n";
}

exit;
