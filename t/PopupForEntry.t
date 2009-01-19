#!/usr/bin/perl

# Copyright 2008, 2009 Kevin Ryde

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
use Gtk2::Ex::DateSpinner::PopupForEntry;
use Test::More tests => 3;


my $want_version = 3;
ok ($Gtk2::Ex::DateSpinner::PopupForEntry::VERSION >= $want_version,
    'VERSION variable');
ok (Gtk2::Ex::DateSpinner::PopupForEntry->VERSION >= $want_version,
    'VERSION class method');
Gtk2::Ex::DateSpinner::PopupForEntry->VERSION ($want_version);
ok (! eval { Gtk2::Ex::DateSpinner::PopupForEntry->VERSION ($want_version + 1000) },
   'VERSION demand beyond current');

exit 0;
