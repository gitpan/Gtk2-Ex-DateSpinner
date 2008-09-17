#!/usr/bin/perl

# Copyright 2007, 2008 Kevin Ryde

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

use Gtk2;
use Test::More tests => 3;


ok ($Gtk2::Ex::DateSpinner::VERSION >= 1);
ok (Gtk2::Ex::DateSpinner->VERSION  >= 1);

{
 SKIP: {
    if (! Gtk2->init_check) { skip 'due to no DISPLAY available', 1; }

    # no circular reference between the datespinner and the spinbuttons
    # within it
    {
      my $datespinner = Gtk2::Ex::DateSpinner->new;
      require Scalar::Util;
      Scalar::Util::weaken ($datespinner);
      is ($datespinner, undef, 'should be garbage collected when weakened');
    }
  }
}

exit 0;
