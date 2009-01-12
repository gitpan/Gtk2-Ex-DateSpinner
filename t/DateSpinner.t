#!/usr/bin/perl

# Copyright 2007, 2008, 2009 Kevin Ryde

# This file is part of Gtk2-Ex-DateSpinner.
#
# Gtk2-Ex-DateSpinner is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Gtk2-Ex-DateSpinner is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Gtk2-Ex-DateSpinner.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
use Gtk2::Ex::DateSpinner;
use Test::More tests => 6;


my $want_version = 2;
ok ($Gtk2::Ex::DateSpinner::VERSION >= $want_version, 'VERSION variable');
ok (Gtk2::Ex::DateSpinner->VERSION  >= $want_version, 'VERSION class method');
Gtk2::Ex::DateSpinner->VERSION ($want_version);
ok (! eval { Gtk2::Ex::DateSpinner->VERSION ($want_version + 1000) },
    'VERSION demand beyond current');

require Gtk2;
diag ("Perl-Gtk2 version ",Gtk2->VERSION);
diag ("Perl-Glib version ",Glib->VERSION);
diag ("Compiled against Glib version ",
      Glib::MAJOR_VERSION(), ".",
      Glib::MINOR_VERSION(), ".",
      Glib::MICRO_VERSION(), ".");
diag ("Running on       Glib version ",
      Glib::major_version(), ".",
      Glib::minor_version(), ".",
      Glib::micro_version(), ".");
diag ("Compiled against Gtk version ",
      Gtk2::MAJOR_VERSION(), ".",
      Gtk2::MINOR_VERSION(), ".",
      Gtk2::MICRO_VERSION(), ".");
diag ("Running on       Gtk version ",
      Gtk2::major_version(), ".",
      Gtk2::minor_version(), ".",
      Gtk2::micro_version(), ".");

# no circular reference between the datespinner and the spinbuttons
# within it
{
  my $datespinner = Gtk2::Ex::DateSpinner->new;
  ok ($datespinner->VERSION  >= $want_version, 'VERSION object method');
  $datespinner->VERSION ($want_version);

  require Scalar::Util;
  Scalar::Util::weaken ($datespinner);
  is ($datespinner, undef, 'should be garbage collected when weakened');
}

SKIP: {
  eval { require Test::Weaken }
    or skip 1, "Test::Weaken not available: $@";

  my @weaken = Test::Weaken::poof(sub {
                                    [ Gtk2::Ex::DateSpinner->new ]
                                  });
  is ($weaken[0], 0, 'Test::Weaken deep garbage collection');
  require Data::Dumper;
  # show how many sub-objects examined, and what if anything was left over
  diag (Data::Dumper->Dump([\@weaken],['Test-Weaken']));
}

exit 0;
