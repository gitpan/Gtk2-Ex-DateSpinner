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
use Gtk2::Ex::DateSpinner::CellRenderer;
use Test::More tests => 8;


my $want_version = 4;
ok ($Gtk2::Ex::DateSpinner::CellRenderer::VERSION >= $want_version,
    'VERSION variable');
ok (Gtk2::Ex::DateSpinner::CellRenderer->VERSION  >= $want_version,
    'VERSION class method');
ok (eval { Gtk2::Ex::DateSpinner::CellRenderer->VERSION($want_version); 1 },
    "VERSION class check $want_version");
ok (! eval { Gtk2::Ex::DateSpinner::CellRenderer->VERSION($want_version + 1000); 1 },
    "VERSION class check " . ($want_version + 1000));

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

sub main_iterations {
  my $count = 0;
  while (Gtk2->events_pending) {
    $count++;
    Gtk2->main_iteration_do (0);
  }
  diag "main_iterations(): ran $count events/iterations\n";
}


#-----------------------------------------------------------------------------
# plain creation

{
  my $renderer = Gtk2::Ex::DateSpinner::CellRenderer->new;
  ok ($renderer->VERSION >= $want_version, 'VERSION object method');
  $renderer->VERSION ($want_version);

  require Scalar::Util;
  Scalar::Util::weaken ($renderer);
  is ($renderer, undef, 'should be garbage collected when weakened');
}

#-----------------------------------------------------------------------------
# start_editing return object

Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
my $have_display = Gtk2->init_check;

SKIP: {
  $have_display or skip 'no DISPLAY available', 2;

  my $toplevel = Gtk2::Window->new ('toplevel');

  my $renderer = Gtk2::Ex::DateSpinner::CellRenderer->new (editable => 1);
  my $event = Gtk2::Gdk::Event->new ('button-press');
  my $rect = Gtk2::Gdk::Rectangle->new (0, 0, 100, 100);
  my $editable = $renderer->start_editing
    ($event, $toplevel, "0", $rect, $rect, ['selected']);
  isa_ok ($editable, 'Gtk2::CellEditable',
          'start_editing return');
  $toplevel->add ($editable);
  $toplevel->remove ($editable);
  main_iterations (); # for idle handler hack

  require Scalar::Util;
  Scalar::Util::weaken ($editable);
  is ($editable, undef, 'editable should be garbage collected when weakened');

  $toplevel->destroy;
}

exit 0;
