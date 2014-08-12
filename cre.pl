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
  exit ($exit || 0);
}

# }}}
#-----------------------------------------------------------------------------
# parse command line options {{{

my @regexps;

my $result = GetOptions(
  'e=s@'          => \@regexps,
  'ignore-case|i' => \$ignore_case,
  'bright|b'      => sub { $brightness = "bold" },
  'dark|d'        => sub { $brightness = "" },
  'h|help'        => \$help,
);

if ($help || !$result || (@regexps == 0 && @ARGV == 0)) {
  usage($result ? 0 : 1);
}

if (@regexps == 0) {
  # @ARGV > 1
  push @regexps, shift @ARGV;
}

if (@regexps > @colours) {
  # TODO: how to allow more than 6 patterns?
  printf STDERR "Can't (currently) handle more than %d patterns\n",
                scalar @colours;
  usage(1);
}

# }}}
#-----------------------------------------------------------------------------

# XXX: we're sure that @regexps <= @colours
my @pairs = map { [$regexps[$_], $colours[$_]] } 0 .. $#regexps;

my @named_re_groups = map { sprintf "(?<%s>%s)", $_->[1], $_->[0] } @pairs;
my $re = join "|", @named_re_groups;
$re = ($ignore_case) ? qr/$re/i : qr/$re/;

while (<>) {
  s/$re/my ($c) = keys %+; color($c, $brightness) . $+{$c} . color('reset')/eg;
  print;
}

#-----------------------------------------------------------------------------
# vim:ft=perl:foldmethod=marker
