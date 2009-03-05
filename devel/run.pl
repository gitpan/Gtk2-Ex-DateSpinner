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

use FindBin;
my $progname = $FindBin::Script;

my $toplevel = Gtk2::Window->new('toplevel');
$toplevel->signal_connect (destroy => sub {
                             print "$progname: destroy\n";
                             Gtk2->main_quit;
                           });

my $vbox = Gtk2::VBox->new;
$toplevel->add ($vbox);

my $datespinner = Gtk2::Ex::DateSpinner->new;
$datespinner->signal_connect ('notify::value' => sub {
                                my ($obj, $pspec) = @_;
                                my $pname = $pspec->get_name;
                                my $value = $obj->get($pname);
                                print "$progname: notify:value now $value\n";
                              });
$vbox->pack_start ($datespinner, 0,0,0);

my $entry = Gtk2::Entry->new;
$vbox->pack_start ($entry, 1, 1, 0);
$entry->signal_connect (activate => sub {
                          my $str = $entry->get_text;
                          print "$progname: set datespinner value '$str'\n";
                          $datespinner->set (value => $str);
                        });

my $hbox = Gtk2::HBox->new;
$vbox->pack_start ($hbox, 0,0,0);

my $quit = Gtk2::Button->new_from_stock ('gtk-quit');
$quit->signal_connect (clicked => sub { $toplevel->destroy; });
$hbox->pack_start ($quit, 0,0,0);

$toplevel->show_all;
Gtk2->main;
exit 0;
