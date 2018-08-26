#!/usr/bin/perl

#-----------------------------------------------------------------------------

use warnings;
use strict;
use Term::ANSIColor;
use Getopt::Long;

#-----------------------------------------------------------------------------

my @colours = qw(red green yellow blue magenta cyan);
my $brightness = "bold"; # "bold" or ""
my $ignore_case = 0;
my $help = 0;

#-----------------------------------------------------------------------------
# usage() {{{

sub usage {
  my ($exit) = @_;

  printf "Usage:\n";
  printf "  %s [options] regexp [file ...]\n", (split m[/], $0)[-1];
  printf "  %s [options] -e re1 -e re2 ... [file ...]\n", (split m[/], $0)[-1];
  printf "\n";
  printf "Recognized options:\n";
  printf "  -b, --bright        use bright colours for highlighting (default)\n";
  printf "  -d, --dark          use dark colours for highlighting\n";
  printf "  -i, --ignore-case   case-insensitive match\n";
  printf "\n";
  printf "In place of `-e regexp', a specific colours are also accepted:\n";
  printf "  --red=regexp         --blue=regexp\n";
  printf "  --green=regexp       --magenta=regexp\n";
  printf "  --yellow=regexp      --cyan=regexp\n";
  printf "Each colour can be specified multiple times.\n";
  exit ($exit || 0);
}

# }}}
#-----------------------------------------------------------------------------
# parse command line options {{{

my @regexps;

sub check_re($) {
  my ($re) = @_;

  eval { qr/$re/ };
  die "Invalid regexp: $re\n" if $@;
}
my $cs = 0; # automatic colour selector

my $result = GetOptions(
  'e=s'       => sub { check_re $_[1]; push @regexps, [$_[1], $colours[($cs++) % @colours]]; },
  'red=s'     => sub { check_re $_[1]; push @regexps, [$_[1], "$_[0]"]; },
  'green=s'   => sub { check_re $_[1]; push @regexps, [$_[1], "$_[0]"]; },
  'yellow=s'  => sub { check_re $_[1]; push @regexps, [$_[1], "$_[0]"]; },
  'blue=s'    => sub { check_re $_[1]; push @regexps, [$_[1], "$_[0]"]; },
  'magenta=s' => sub { check_re $_[1]; push @regexps, [$_[1], "$_[0]"]; },
  'cyan=s'    => sub { check_re $_[1]; push @regexps, [$_[1], "$_[0]"]; },
  'ignore-case|i' => \$ignore_case,
  'bright|b'      => sub { $brightness = "bold" },
  'dark|d'        => sub { $brightness = "" },
  'h|help'        => \$help,
);

if ($help || !$result || (@regexps == 0 && @ARGV == 0)) {
  if ($result) {
    usage(0);
  } else {
    select STDERR;
    usage(1);
  }
}

if (@regexps == 0) {
  # @ARGV > 1
  push @regexps, ["red", shift @ARGV];
}

# }}}
#-----------------------------------------------------------------------------

# format string will have structure: "(((%s)|%s)|%s)"
my $re_format = ("(" x @regexps) . (join ")|", ("%s") x @regexps) . ")";
my $re = sprintf $re_format, map { $_->[0] } @regexps;
$re = ($ignore_case) ? qr/$re/i : qr/$re/;

# an array with regexp colours (indices match capture groups numbers, so
# $rec[0] stays unused and the first regexp is the last element)
my @rec = (undef, reverse map { $_->[1] } @regexps);

sub match_colour() {
  # find the last capture group that represents passed regexps that is
  # defined; it's defined latest, so it's the inner-most, i.e. most specific
  # at least `$-[1]' will be defined, since it covers the whole match
  my $i = $#rec;
  --$i until defined $-[$i];

  return color($rec[$i], $brightness) .
         substr($_, $-[$i], $+[$i] - $-[$i]) .
         color("reset");
}

while (<>) {
  s/$re/match_colour()/eg;
  print;
}

#-----------------------------------------------------------------------------
# vim:ft=perl:foldmethod=marker
