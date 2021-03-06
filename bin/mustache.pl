#!/usr/bin/env perl
# Original: https://github.com/defunkt/mustache/blob/master/bin/mustache

use strict;
use warnings;
use autodie;

use Template::Mustache;
use YAML::Syck;

my ($self, $args) = @_;
my @args = $args ? @$args : @ARGV;
my $cli_opt = shift @args || '-h';

if ($cli_opt eq "-h" and -t STDIN) {
    print "Usage: mustache FILE ...\n";
    print "`perldoc mustache` for more usage info.\n";
}
else {
    my $doc = join('', <>);
    if($doc =~ /^(\s*---(.+)---\s*)/isg) {
        my $yml = $2;
        $doc =~ s/\Q$1\E//g; # remove YAML data block, quote metachars
        $yml =~ s/^\s+|\s+$//g; # trim whitespace
        $yml = Load($yml);
        print Template::Mustache->render($doc, $yml);
    }
    else {
        print Template::Mustache->render($doc);
    }
}

=head1 NAME

mustache.pl - Command line frontend for mustache logic-less templates.

  Usage: mustache.pl FILE ...

See mustache(1) or http://mustache.github.com/mustache.1.html for more details.

=head1 RECIPES

Examples:

  $ mustache.pl data.yml template.mustache
  $ cat data.yml | mustache.pl - template.mustache
  $ cat data.yml template.mustache | mustache.pl

=cut
