#!/usr/bin/perl
binmode STDOUT, ":utf8";
binmode STDIN, ":utf8";

use FindBin;
use lib "$FindBin::Bin/../classes/";
use lib "$FindBin::Bin/../../dumping_tools/classes/";

use utf8;
use Encode;
use Config;
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Mediawiki::Mediawiki;

# get the params
my $host = "";
my $path = "";
my @categories;
my $explorationDepth = 1;
my $readFromStdin;
my $namespace;

## Get console line arguments
GetOptions('host=s' => \$host, 
	   'path=s' => \$path,
	   'explorationDepth=s' => \$explorationDepth,
	   'readFromStdin' => \$readFromStdin,
	   'category=s' => \@categories,
	   'namespace=s' => \$namespace,
	   );

if (!$host || ( !scalar(@categories) && !$readFromStdin) ) {
    print "usage: ./listCategoryEntries.pl --host=my.wiki.org [--category=mycat] [--readFromStdin] [--path=w] [--explorationDepth=1] [--namespace=0]\n";
    exit;
}

# readFromStdin
if ($readFromStdin) {
    while (my $category = <STDIN>) {
        $category =~ s/\n//;
        push(@categories, $category);
    }
}

# Site
my $site = Mediawiki::Mediawiki->new();
$site->hostname($host);
$site->path($path);

# Go over the category list
my %entries;
foreach my $category (@categories) {

    unless (Encode::is_utf8($category)) {
	$category = decode_utf8($category);
    }

    foreach my $entry ($site->listCategoryEntries($category, $explorationDepth, $namespace)) {
	$entry =~ s/ /_/g;
	$entries{$entry} = $entry;
    }
}

# Print to the output
foreach my $entry (keys(%entries)) {

    unless (Encode::is_utf8($entry)) {
	$entry = decode_utf8($entry);
    }

    print $entry."\n";
}

exit;
