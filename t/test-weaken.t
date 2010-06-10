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
use Gtk2::Ex::DateSpinner;
use Gtk2::Ex::DateSpinner::PopupForEntry;
use Gtk2::Ex::DateSpinner::CellRenderer;
use Test::More;

BEGIN {
  # seem to need a DISPLAY initialized in gtk 2.16 or get a slew of warnings
  # creating a Gtk2::Ex::DateSpinner
  Gtk2->disable_setlocale;  # leave LC_NUMERIC alone for version nums
  Gtk2->init_check
    or plan skip_all => "due to no DISPLAY available";

  # Test::Weaken 3 for "contents"
  my $have_test_weaken = eval "use Test::Weaken 3;
                               use Test::Weaken::Gtk2;
                               1";
  if (! $have_test_weaken) {
    plan skip_all => "due to Test::Weaken 3 and/or Test::Weaken::Gtk2 not available -- $@";
  }
  diag ("Test::Weaken version ", Test::Weaken->VERSION);

  plan tests => 6;

 SKIP: { eval 'use Test::NoWarnings; 1'
           or skip 'Test::NoWarnings not available', 1; }
}

use lib 't';
use MyTestHelpers;

require Gtk2;
MyTestHelpers::glib_gtk_versions();

#------------------------------------------------------------------------------
# DateSpinner

diag "DateSpinner";
{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub { return Gtk2::Ex::DateSpinner->new },
       contents => \&Test::Weaken::Gtk2::contents_container,
     });
  is ($leaks, undef, 'DateSpinner deep garbage collection');
  if ($leaks && defined &explain) {
    diag "Test-Weaken ", explain $leaks;
  }
}

#------------------------------------------------------------------------------
# DateSpinner::PopupForEntry

diag "PopupForEntry";

{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub { return Gtk2::Ex::DateSpinner::PopupForEntry->new },
       destructor => \&Test::Weaken::Gtk2::destructor_destroy,
       contents => \&Test::Weaken::Gtk2::contents_container,
     });
  is ($leaks, undef, 'PopupForEntry garbage collection');
  if ($leaks && defined &explain) {
    diag "Test-Weaken ", explain $leaks;
  }
}

#------------------------------------------------------------------------------
# DateSpinner::CellRenderer

{
  my $leaks = Test::Weaken::leaks
    (sub { Gtk2::Ex::DateSpinner::CellRenderer->new });
  is ($leaks, undef, 'CellRenderer garbage collection');
  if ($leaks && defined &explain) {
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
         # iterate for idle handler hack for Gtk2 1.202
         MyTestHelpers::main_iterations();
       },
       contents => \&Test::Weaken::Gtk2::contents_container,
     });
  is ($leaks, undef, 'CellRenderer garbage collection -- after start_editing');
  if ($leaks && defined &explain) {
    diag "Test-Weaken ", explain $leaks;
  }

  $toplevel->destroy;
}


exit 0;
