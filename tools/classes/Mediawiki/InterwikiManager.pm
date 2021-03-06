package Mediawiki::InterwikiManager;

use strict;
use warnings;
use Data::Dumper;
use XML::Simple;
use LWP::UserAgent;
use XML::DOM;
use DBI;

my $logger;
my %interwikis = ( "ckb" => 42, "kbd" => 42, "ltg" => 42, "ace" => 42, "frr" => 42, "pcd" => 42, "rue" => 42, "bjn" => 42 );

sub new {
    my $class = shift;
    my $self = {};

    bless($self, $class);

    return $self;
}

sub readFromWeb {
    my $self = shift;
    my $host = shift || "";
    my $path = shift || "";
    my @nodes;

    my $ua = LWP::UserAgent->new();
    my $parser = new XML::DOM::Parser (LWP_UserAgent => $ua);

    my $url = "http://".$host."/".($path ? $path."/" : "")."api.php?action=sitematrix&format=xml";
    my $doc; eval { $doc = $parser->parsefile($url); };
    
    if ($doc) {
	@nodes = (@{$doc->getElementsByTagName("special")}, @{$doc->getElementsByTagName("language")});
	foreach my $node (@nodes) {
	    my $code = $node->getAttributeNode("code")->getValue();
	    $interwikis{$code} = 42;
	}
    } else {
	$url = "http://".$host."/".($path ? $path."/" : "")."api.php?action=query&meta=siteinfo&siprop=interwikimap&format=xml";
	$doc = $parser->parsefile($url);
	
	@nodes = (@{$doc->getElementsByTagName("iw")});
	foreach my $node (@nodes) {
	    my $code = $node->getAttributeNode("prefix")->getValue();
	    $interwikis{$code} = 42;
	}
    }
}

sub writeToDatabase {
    my $self = shift;
    my $database = shift;
    my $username = shift;
    my $password = shift;
    my $host = shift || "";
    my $port = shift || "";

    my $dsn = "DBI:mysql:$database;host=$host:$port";
    my $dbh;
    my $req;
    my $sth;

    $dbh = DBI->connect($dsn, $username, $password) or die ("Unable to connect to the database.");

    $req = "TRUNCATE interwiki";
    $sth = $dbh->prepare($req)  or die ("Unable to prepare request.");
    $sth->execute() or die ("Unable to execute request.");    

    foreach my $interwiki (keys(%interwikis)) {
        $req = "INSERT INTO interwiki (iw_prefix, iw_url) VALUES ('$interwiki', 'http://$interwiki.wikipedia.org')";
	$sth = $dbh->prepare($req)  or die ("Unable to prepare request.");
	$sth->execute() or die ("Unable to execute request.");    
    }
}

# loggin
sub logger {
    my $self = shift;
    if (@_) { $logger = shift }
    return $logger;
}

sub log {
    my $self = shift;
    return unless $logger;
    my ($method, $text) = @_;
    $logger->$method($text);
}

1;
