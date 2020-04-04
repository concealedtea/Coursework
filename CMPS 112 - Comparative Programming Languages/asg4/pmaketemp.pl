#!/usr/bin/perl
# Author: Adam Henry, adlhenry@ucsc.edu
# $Id: make.pl,v 1.9 2014-10-19 19:56:00-07 - - $
use strict;
use warnings;
use Getopt::Std;

# Program name
$0 =~ s/^.\///;

# Exit status
my $exit_status = 0;
END {exit $exit_status}

# Define hash tables.
my %macros;
my %targets;

# Collect the user options.
my %options;
getopts ('dnf:', \%options);

# Record target hierarchy.
my @target_array;

# Populates the macro table.
sub macro_hash {
  for (keys %macros) {
    while ($macros{$_} =~ s/\$\{([^}]+)\}/$macros{$1}/) {
    }
    $macros{$_} =~ s/^\s+|\s+$|\s{2,}|#(.*)//g;
    $macros{$_} =~ s|\$\$|\$|g;
  }
}

# Macro-swaps the target table.
sub macro_swap {
  for my $trgt (keys %targets) {
    $_ = $targets{$trgt}{'deps'};
    my @deps;
    if (defined) {
      while (s/\$\{([^}]+)\}/$macros{$1}/) {
      }
      @deps = split;
    }
    $targets{$trgt}{'deps'} = \@deps;
    for (@{$targets{$trgt}{'cmds'}}) {
      while ($_ =~ s/\$\{([^}]+)\}/$macros{$1}/) {
      }
      $_ =~ s|\$\$|\$|g;
    }
  }
}

# Return file modification time.
sub mtime {
  my @filestat = stat $_[0];
  return $filestat[9];
}

# Execute target commands.
sub exe_cmds {
  my ($trgt, $t_name) = @_;
  $trgt =~ s/%/$t_name/;
  my $dep1 = ${$targets{$_[0]}{'deps'}}[0];
  $dep1 =~ s/%/$t_name/ if defined $dep1;
  for (@{$targets{$_[0]}{'cmds'}}) {
    my $cmd_line = $_;
    my $exit_ignore = 0;
    if ($cmd_line =~ s/^-\s//) {
      $exit_ignore = 1;
    }
    $cmd_line =~ s/\$</$dep1/g;
    $cmd_line =~ s/\$@/$trgt/g;
    print "$cmd_line\n";
    system ($cmd_line) if not defined $options{'n'};
    my $term_signal = $? & 0x7F;
    my $core_dumped = $? & 0x80;
    my $exit_stat = ($? >> 8) & 0xFF;
    if ($exit_stat != 0) {
      printf "%s: %s[%s] Error %d%s\n", $0, 
      $exit_ignore ? '' : '*** ', $trgt, 
      $exit_stat, $exit_ignore ? ' (ignored)' : '';
      if (!$exit_ignore) {
        exit 2;
      } else {
        $exit_status = $exit_stat;
      }
    }
  }
}

# Seek wild-card targets.
sub pre_build {
  my $trgt = $_[0];
  my @trgt_def = split /\./;
  my $t_name = $trgt_def[0];
  my $trgt_ext = $trgt_def[1];
  for (@target_array) {
    if ($_ eq $trgt) {
      target_build ($_, $t_name);
      return;
    }
    if (defined $trgt_ext && $_ eq "%.$trgt_ext") {
      target_build ("%.$trgt_ext", $t_name);
      return;
    }
  }
}

# Make a target.
sub target_build {
  my $exe = 0;
  my ($trgt, $t_name) = @_;
  $trgt =~ s/%/$t_name/;
  my $t_mtime = mtime ($trgt);
  if (not defined $t_mtime) {
    $exe = 1;
    $t_mtime = 0;
    if (defined $options{'d'}) {
      print "$trgt: file does not exist, rebuild $trgt\n";
    }
  }
  for (@{$targets{$_[0]}{'deps'}}) {
    my $dep = $_;
    $dep =~ s/%/$t_name/;
    my $d_mtime = mtime ($dep);
    if (not defined $d_mtime) {
      pre_build ($dep);
      next;
    }
    if ($t_mtime != 0 && $t_mtime < $d_mtime) {
      $exe = 1;
      if (defined $options{'d'}) {
        print "$trgt: file is obsolete with dependenency $dep, 
        rebuild $trgt\n";
      }
    }
  }
  exe_cmds ($_[0], $t_name) if $exe == 1;
}

# Set the makefile.
my $makefile = './Makefile';
$makefile = $options{'f'} if defined $options{'f'};

# Extract the macro table.
open (my $mfile, "<", "$makefile") or die "$makefile: $!";
while (<$mfile>) {
  if (/(^[A-Z]+)\s*=/) {
    chomp;
    my @macrodef = split /\s*=\s*/;
    $macros{$1} = $macrodef[1];
  }
}
close $mfile;

# Populate the macro table.
macro_hash();

# Extract the target table.
open ($mfile, "<", "$makefile") or die "$makefile: $!";
my $cmds_ref;
while (<$mfile>) {
  next if (/^#|^ifeq|^endif|^include|^[A-Z]/);
  # Command line.
  if (/^\t/) {
    $_ =~ s/\t|\n//g;
    push (@$cmds_ref, $_);
    next;
  }
  # Target specification.
  if (/(\S+)\s*:/) {
    chomp;
    my @cmds;
    $cmds_ref = \@cmds;
    my @depsdef = split /\s*:\s*/;
    my $deps = $depsdef[1];
    my $p = {'deps' => $deps, 'cmds' => $cmds_ref};
    my $trgt = $1;
    $trgt =~ s/\$\{([^}]+)\}/$macros{$1}/;
    if (not defined $targets{$trgt}) {
      $targets{$trgt} = $p;
      push (@target_array, $trgt);
    } elsif ($targets{$trgt}{'deps'} eq $deps) {
        $targets{$trgt}{'cmds'} = $cmds_ref;
    }
  }
}
close $mfile;

# Macro-swap the target table.
macro_swap();

# Execute specified targets.
$ARGV[0] = $target_array[0] if not defined $ARGV[0];
for (@ARGV) {
  pre_build ($_);
}

# Debug function
sub debug_print {
    print "\n====== MACROS ======\n";
    print "$_ = $macros{$_}\n" for keys %macros;
    print "\n====== TARGETS =======\n";
    for my $trgt (keys %targets) {
      print "\n$trgt :";
      print " $_" for @{$targets{$trgt}{'deps'}};
      print "\n";
      print "\t$_\n" for @{$targets{$trgt}{'cmds'}};
    }
}
debug_print() if defined $options{'d'};