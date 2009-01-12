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
use Gtk2::Ex::DateSpinner::EntryWithCancel;
use Test::More tests => 15;


my $want_version = 2;
ok ($Gtk2::Ex::DateSpinner::EntryWithCancel::VERSION >= $want_version,
    'VERSION variable');
ok (Gtk2::Ex::DateSpinner::EntryWithCancel->VERSION >= $want_version,
    'VERSION class method');
Gtk2::Ex::DateSpinner::EntryWithCancel->VERSION ($want_version);
ok (! eval { Gtk2::Ex::DateSpinner::EntryWithCancel->VERSION ($want_version + 1000) },
    'VERSION demand beyond current');

{
  my $entry = Gtk2::Ex::DateSpinner::EntryWithCancel->new;
  $entry->set('editing-cancelled', 1);
  $entry->activate;
  ok (! $entry->get('editing-cancelled'),
      'activate() not a cancel');

  ok ($entry->signal_query ('cancel'),
     'cancel signal exists');

  $entry->set('editing-cancelled', 0);
  $entry->cancel;
  ok ($entry->get('editing-cancelled'),
      'cancel() sets cancelled flag');

  $entry->set('editing-cancelled', 0);
  $entry->signal_emit ('cancel');
  ok ($entry->get('editing-cancelled'),
      'cancel signal sets cancelled flag');

  my $saw_editing_done;
  $entry->signal_connect (editing_done => sub { $saw_editing_done = 1 });
  my $saw_remove_widget;
  $entry->signal_connect (remove_widget => sub { $saw_remove_widget = 1 });

  $entry->start_editing (undef);
  $saw_editing_done = 0;
  $saw_remove_widget = 0;
  $entry->set('editing-cancelled', 1);
  $entry->activate;
  is ($saw_editing_done, 1,
      'activate during editing emits editing-done');
  is ($saw_editing_done, 1,
      'activate during editing emits remove-widget');
  ok (! $entry->get('editing-cancelled'),
      'activate during editing clears editing-cancelled property');


  $entry->start_editing (undef);
  $saw_editing_done = 0;
  $saw_remove_widget = 0;
  $entry->set('editing-cancelled', 0);
  $entry->cancel;
  is ($saw_editing_done, 1,
      'cancel during editing emits editing-done');
  is ($saw_editing_done, 1,
      'cancel during editing emits remove-widget');
  ok ($entry->get('editing-cancelled'),
      'cancel during editing sets editing-cancelled property');

  $saw_editing_done = 0;
  $saw_remove_widget = 0;
  $entry->cancel;
  is ($saw_editing_done, 0,
      "cancel outside editing doesn't emit editing-done");
  is ($saw_editing_done, 0,
      "cancel outside editing doesn't emit remove-widget");
}

exit 0;
