package Template::Mustache::Generator;

use strict;
use base 'Exporter';

use CGI ();
use Data::Dumper ();

our @EXPORT_OK = qw/ build /;

sub inspect
{
    my $dumper = Data::Dumper->new([@_]);
    $dumper->Terse(1);
    $dumper->Useqq(1);

    return trim($dumper->Dump());
}

sub trim
{
    my ($string) = @_;
    $string =~ s/^ \s* | \s* $//mgx;
    return $string;
}

sub evalable
{
    return qq'(@_)'
}

sub call
{
    my ($name, @args) = @_;
    $Template::Mustache::Generator::{$name}->(@args);
}

use namespace::clean;

sub text
{
    my $string = inspect(@_);
    return $string;
}

sub etag
{
    my $name = inspect(@_);
    return evalable("CGI::escapeHTML(\$ctx->get($name))");
}

sub utag
{
    my $name = inspect(@_);
    return evalable("\$ctx->get($name)")
}

sub partial
{
    my $name = inspect(shift);
    my $indent = inspect(shift);
    return evalable("\$ctx->partial($name, $indent)");
}

sub block
{
    my @parts = map { call(@$_) } @_;
    return join(' . ', @parts);
}

sub section
{
    my ($name, $block) = @_;
    $name = inspect($name);
    my $content = build($block);

    my $fetch   = '$v = $ctx->get(' . $name . ')';
    my $map     = '$ctx->push($_); $v = ' . $content . '; $ctx->pop(); $v';
    my $array   = '@{ref $v eq "ARRAY" ? $v : [$v || ()]}';

    return evalable(qq'defined($fetch) && join "", map { $map } $array');
}

sub inverted
{
    my ($name, $block) = @_;
    $name = inspect($name);
    my $content = build($block);

    my $fetch   = '$v = $ctx->get(' . $name . ')';
    my $block   = '$ctx->push($_); $v = ' . $content . '; $ctx->pop(); $v';
    my $val     = '@{ref $v eq "ARRAY" ? $v : [$v || ()]}';

    return evalable(qq'defined($fetch) && ($val) ? "" : do { $block }');
}

sub build
{
    my ($block) = @_;
    return qq'@{[ call(@$block) ]}'
}

1;