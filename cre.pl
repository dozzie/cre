#!/usr/bin/perl

#-----------------------------------------------------------------------------

use warnings;
use strict;
use Term::ANSIColor;

#-----------------------------------------------------------------------------

my @colours = qw(red green yellow blue magenta cyan);
my $bright = 1;
my $ignore_case = 0;

#-----------------------------------------------------------------------------
# usage() {{{

sub usage {
  my ($exit) = @_;

  printf "Usage: %s [options] regexp [file ...]\n", (split m[/], $0)[-1];
  # -b, --bright
  # -d, --dark
  # -i, --ignore-case
  exit ($exit || 0);
}

# }}}
#-----------------------------------------------------------------------------
# parse command line options {{{

my @regexps;
my @files;

for (my $i = 0; $i < @ARGV; ++$i) {
  if ($ARGV[$i] eq '--') {
    @ARGV = @ARGV[$i + 1 .. $#ARGV];
    last;
  }
  if ($ARGV[$i] !~ /^-/) {
    push @files, $ARGV[$i];
    next;
  }

  # $ARGV[$i] =~ /^-/

  if ($ARGV[$i] eq '-e') {
    if (++$i >= @ARGV) {
      printf STDERR "Missing argument to -e\n";
      usage(1);
    }
    push @regexps, $ARGV[$i];
  } elsif ($ARGV[$i] eq '-i' || $ARGV[$i] eq '--ignore-case') {
    $ignore_case = 1;
  } elsif ($ARGV[$i] eq '-b' || $ARGV[$i] eq '--bright') {
    $bright = 1;
  } elsif ($ARGV[$i] eq '-d' || $ARGV[$i] eq '--dark') {
    $bright = 0;
  } elsif ($ARGV[$i] eq '-h' || $ARGV[$i] eq '--help') {
    usage();
  } else { # unknown option
    printf STDERR "Unknown option: %s\n", $ARGV[$i];
    usage(1);
  }
}

if (@regexps == 0) {
  if (@files == 0) {
    usage();
  } else {
    push @regexps, shift @files;
  }
}

if (@regexps > @colours) {
  # TODO: how to allow more than 6 patterns?
  printf STDERR "Can't (currently) handle more than %d patterns\n",
                scalar @colours;
  usage(1);
}

@ARGV = @files; # for `<>' operator to work

# }}}
#-----------------------------------------------------------------------------

if ($bright) {
  # add "bright_" prefix
  $_ = "bright_$_" for @colours;
}

# XXX: we're sure that @regexps <= @colours
my @pairs = map { [$regexps[$_], $colours[$_]] } 0 .. $#regexps;

my @named_re_groups = map { sprintf "(?<%s>%s)", $_->[1], $_->[0] } @pairs;
my $re = join "|", @named_re_groups;
$re = ($ignore_case) ? qr/$re/i : qr/$re/;

while (<>) {
  s/$re/my ($c) = keys %+; color($c) . $+{$c} . color('reset')/eg;
  print;
}

#-----------------------------------------------------------------------------
# vim:ft=perl:foldmethod=marker
