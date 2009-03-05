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


# Usage: perl screenshot.pl [outputfile.png]
#
# Draw a datespinner write it to the given output file in PNG format.
# The default output file is /tmp/screenshot.png

use strict;
use warnings;
use POSIX;
use Gtk2 '-init';
use Gtk2::Ex::DateSpinner;

use File::Basename;
my $progname = basename($0);

my $output_filename = (@ARGV >= 1 ? $ARGV[0] : '/tmp/screenshot.png');

my $toplevel = Gtk2::Window->new('toplevel');
$toplevel->signal_connect (destroy => sub { Gtk2->main_quit });

my $datespinner = Gtk2::Ex::DateSpinner->new;
$datespinner->set_today;
$toplevel->add ($datespinner);

Glib::Timeout->add
  (2000,
   sub {
     my $window = $toplevel->window;
     my ($width, $height) = $window->get_size;
     my $pixbuf = Gtk2::Gdk::Pixbuf->get_from_drawable ($window,
                                                        undef, # colormap
                                                        0,0, 0,0,
                                                        $width, $height);
     $pixbuf->save
       ($output_filename, 'png',
        'tEXt::Title'         => 'DateSpinner Screenshot',
        'tEXt::Author'        => 'Kevin Ryde',
        'tEXt::Copyright'     => 'Copyright 2008, 2009 Kevin Ryde',
        'tEXt::Creation Time' => POSIX::strftime ("%a, %d %b %Y %H:%M:%S %z",
                                                  localtime(time)),
        'tEXt::Description'   => 'A sample screenshot of a Gtk2::Ex::DateSpinner',
        'tEXt::Software'      => "Generated by $progname",
        'tEXt::Homepage'      => 'http://www.geocities.com/user42_kevin/gtk2-ex-datespinner/index.html',
       );
     Gtk2->main_quit;
     return 0; # stop timer
   });

$toplevel->show_all;
Gtk2->main;
exit 0
