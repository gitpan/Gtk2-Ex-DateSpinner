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
use Gtk2::Ex::DateSpinner;
use Gtk2::Ex::DateSpinner::PopupForEntry;
use Gtk2::Ex::DateSpinner::CellRenderer;
use Test::More;

use constant DEBUG => 1;

# seem to need a DISPLAY initialized in gtk 2.16 or get a slew of warnings
# creating a Gtk2::Ex::DateSpinner
Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
Gtk2->init_check
  or plan skip_all => "due to no DISPLAY available";

# Test::Weaken 3 for "contents"
my $have_test_weaken = eval "use Test::Weaken 3; 1";
if (! $have_test_weaken) {
  plan skip_all => "due to Test::Weaken 3 not available -- $@";
}
diag ("Test::Weaken version ", Test::Weaken->VERSION);

plan tests => 6;

SKIP: { eval 'use Test::NoWarnings; 1'
          or skip 'Test::NoWarnings not available', 1; }

require Gtk2;
diag ("Perl-Gtk2    version ",Gtk2->VERSION);
diag ("Perl-Glib    version ",Glib->VERSION);
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
sub contents_container {
  my ($ref) = @_;
  require Scalar::Util;
  (Scalar::Util::blessed ($ref) && $ref->isa('Gtk2::Container'))
    or return;
  if (DEBUG) { Test::More::diag ("contents ",ref $ref); }
  return $ref->get_children;
}
# taking either a Gtk2::Window or an array whose first element is one
sub destructor_destroy {
  my ($ref) = @_;
  if (ref $ref eq 'ARRAY') {
    $ref = $ref->[0];
  }
  $ref->destroy;

  # iterate to make WidgetCursor go unbusy
  main_iterations();
}

#------------------------------------------------------------------------------
# DateSpinner

diag "DateSpinner";
{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub { return Gtk2::Ex::DateSpinner->new },
       contents => \&contents_container,
     });
  is ($leaks, undef, 'DateSpinner deep garbage collection');
  if ($leaks) {
    diag "Test-Weaken ", explain $leaks;
  }
}

#------------------------------------------------------------------------------
# DateSpinner::PopupForEntry

diag "PopupForEntry";

{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub { return Gtk2::Ex::DateSpinner::PopupForEntry->new },
       destructor => \&destructor_destroy,
       contents => \&contents_container,
     });
  is ($leaks, undef, 'PopupForEntry garbage collection');
  if ($leaks) {
    diag "Test-Weaken ", explain $leaks;
  }
}

#------------------------------------------------------------------------------
# DateSpinner::CellRenderer

{
  my $leaks = Test::Weaken::leaks
    (sub { Gtk2::Ex::DateSpinner::CellRenderer->new });
  is ($leaks, undef, 'CellRenderer garbage collection');
  if ($leaks) {
    diag "Test-Weaken ", explain $leaks;
  }
}

{
  my $toplevel = Gtk2::Window->new ('toplevel');
  my $renderer = Gtk2::Ex::DateSpinner::CellRenderer->new (editable => 1);

  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         my $event = Gtk2::Gdk::Event->new ('button-press');
         my $rect = Gtk2::Gdk::Rectangle->new (0, 0, 100, 100);
         my $editable = $renderer->start_editing
           ($event, $toplevel, "0", $rect, $rect, ['selected']);
         isa_ok ($editable, 'Gtk2::CellEditable', 'start_editing return');
         $toplevel->add ($editable);
         return $editable;
       },
       destructor => sub {
         my ($editable) = @_;
         $toplevel->remove ($editable);
         main_iterations (); # for idle handler hack for Gtk2 1.202
       },
       contents => \&contents_container,
     });
  is ($leaks, undef, 'CellRenderer garbage collection -- after start_editing');
  if ($leaks) {
    diag "Test-Weaken ", explain $leaks;
  }

  $toplevel->destroy;
}


exit 0;
