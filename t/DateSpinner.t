#!/usr/bin/perl

# Copyright 2008, 2009, 2010 Kevin Ryde

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
use Test::More tests => 9;

use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin,'inc');
use MyTestHelpers;
use Test::Weaken::Gtk2;

SKIP: { eval 'use Test::NoWarnings; 1'
          or skip 'Test::NoWarnings not available', 1; }

require Gtk2::Ex::DateSpinner;

my $want_version = 6;
{
  is ($Gtk2::Ex::DateSpinner::VERSION, $want_version, 'VERSION variable');
  is (Gtk2::Ex::DateSpinner->VERSION,  $want_version, 'VERSION class method');
  ok (eval { Gtk2::Ex::DateSpinner->VERSION($want_version); 1 },
      "VERSION class check $want_version");

  my $check_version = $want_version + 1000;
  ok (! eval{Gtk2::Ex::DateSpinner->VERSION($check_version); 1},
      "VERSION class check $check_version");
}

require Gtk2;
MyTestHelpers::glib_gtk_versions();

#------------------------------------------------------------------------------
# weakening
#
# no circular reference between the datespinner and the spinbuttons
# within it

Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
my $have_display = Gtk2->init_check;

SKIP: {
  # seem to need a DISPLAY initialized in gtk 2.16 or get a slew of warnings
  # creating a Gtk2::Ex::DateSpinner
  $have_display
    or skip "due to no DISPLAY available", 4;

  my $datespinner = Gtk2::Ex::DateSpinner->new;

  ok ($datespinner->VERSION >= $want_version, 'VERSION object method');
  ok (eval { $datespinner->VERSION($want_version); 1 },
      "VERSION object check $want_version");
  my $check_version = $want_version + 1000;
  ok (! eval { $datespinner->VERSION($check_version); 1 },
      "VERSION object check $check_version");

  require Scalar::Util;
  Scalar::Util::weaken ($datespinner);
  is ($datespinner, undef, 'should be garbage collected when weakened');
}

exit 0;
