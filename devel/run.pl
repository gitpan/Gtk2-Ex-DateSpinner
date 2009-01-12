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
use Gtk2 '-init';
use Gtk2::Ex::DateSpinner;

my $toplevel = Gtk2::Window->new('toplevel');
$toplevel->signal_connect (destroy => sub { Gtk2->main_quit; });

my $vbox = Gtk2::VBox->new;
$toplevel->add ($vbox);

my $datespinner = Gtk2::Ex::DateSpinner->new;
$vbox->pack_start ($datespinner, 0,0,0);

my $hbox = Gtk2::HBox->new;
$vbox->pack_start ($hbox, 0,0,0);

my $quit = Gtk2::Button->new_with_label ('Quit');
$quit->signal_connect (clicked => sub { $toplevel->destroy; });
$hbox->pack_start ($quit, 0,0,0);

$toplevel->show_all;
Gtk2->main;
exit 0;
