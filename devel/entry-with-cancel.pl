#!/usr/bin/perl

# Copyright 2009 Kevin Ryde

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
use Gtk2 '-init';
use Gtk2::Ex::DateSpinner::EntryWithCancel;

use FindBin;
my $progname = $FindBin::Script;

# Gtk2::Rc->parse_string (<<HERE);
# binding "my_keys" {
#   bind "<ctrl>x" { "move-cursor" (logical-positions, -1, 0) }
# }
# class "GtkEntry" binding "my_keys"
# HERE

if (Gtk2::BindingSet->can('find')) {
  my $bindingset = Gtk2::BindingSet->find
    ('Gtk2__Ex__DateSpinner__EntryWithCancel_keys');
  print "$progname: find bindingset gives ",($bindingset||'false'),"\n";
}

my $entry = Gtk2::Ex::DateSpinner::EntryWithCancel->new;

if (Gtk2::BindingSet->can('find')) {
  my $bindingset = Gtk2::BindingSet->find
    ('Gtk2__Ex__DateSpinner__EntryWithCancel_keys');
  print "$progname: find bindingset gives ",($bindingset||'false'),"\n";
  if ($bindingset) {
    print "  name ",$bindingset->name,"\n";
  }
}

my $toplevel = Gtk2::Window->new('toplevel');
$toplevel->signal_connect (destroy => sub { Gtk2->main_quit; });

my $vbox = Gtk2::VBox->new;
$toplevel->add ($vbox);

print "$progname: entry name ",$entry->get_name,"\n";
$vbox->pack_start ($entry, 0,0,0);
$entry->signal_connect (cancel => sub { print "$progname: cancel\n"; });
$entry->signal_connect (activate => sub { print "$progname: activate\n"; });
$entry->signal_connect
  (key_press_event => sub {
     my ($entry, $event) = @_;
     print "$progname: keycode ", $event->hardware_keycode,
       " group ", $event->group, "\n";
     return 0; # Gtk2::EVENT_PROPAGATE
   });

my $keyval_left = Gtk2::Gdk->keyval_from_name('Escape');

{
  my $button = Gtk2::Button->new_with_label ("keyval left");
  $button->signal_connect
    (clicked => sub {
       Glib::Timeout->add
           (3000, sub {
              print __FILE__,": keyval left\n";
              $entry->bindings_activate ($keyval_left, []);
              return 0;
            });
     });
  $vbox->pack_start ($button, 0,0,0);
}
{
  my $button = Gtk2::Button->new_with_label ("cancel method");
  $button->signal_connect
    (clicked => sub { $entry->cancel });
  $vbox->pack_start ($button, 0,0,0);
}

$toplevel->show_all;
Gtk2->main;
exit 0;
