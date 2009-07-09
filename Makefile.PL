#!/usr/bin/perl

# Copyright 2007, 2008, 2009 Kevin Ryde

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

use 5.008;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use lib 'inc';
use MyMakeMakerExtras;

WriteMakefile
  (NAME         => 'Gtk2-Ex-DateSpinner',
   ABSTRACT     => 'Date entry widget using spin buttons.',
   VERSION_FROM => 'lib/Gtk2/Ex/DateSpinner.pm',
   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,
   MIN_PERL_VERSION => '5.008',

   PREREQ_PM    => {
                    # 5.0 for new style Add_Delta_YMD() probably,
                    # otherwise at least 4.1 for bug fix in Add_Delta_YMD(),
                    # otherwise at least 4.0 for Today() func
                    'Date::Calc' => '5.0',

                    # version 1.180 for EntryWithCancel to override
                    # superclass GInterface
                    'Gtk2' => '1.180',

                    'Glib::Ex::SignalIds' => 0,
                    'Gtk2::Ex::WidgetBits' => 0,
                   },
   clean        => { FILES => "DateSpinner.html" },

   EXTRA_META => <<'HERE',
optional_features:
    maximum_tests:
        description: Have "make test" do as much as possible.
        requires:
            Test::Weaken: 3
            Test::Pod: 1.00
            Test::NoWarnings: 0
            Parse::CPAN::Meta: 0
            Test::DistManifest: 0
            Test::YAML::Meta: 0
            YAML: 0
            YAML::Syck: 0
            YAML::Tiny: 0
            YAML::XS: 0
no_index:
    directory:
        - devel
        - inc
        - t
resources:
    homepage: http://user42.tuxfamily.org/gtk2-ex-datespinner/index.html
    license: http://www.gnu.org/licenses/gpl.html
HERE
  );

#------------------------------------------------------------------------------
package MY;
sub postamble {
  my ($makemaker) = @_;
  return MyMakeMakerExtras::postamble ($makemaker) . <<'HERE';

#----------------------------------------------------------------------------
# extras from MY::postamble()

DateSpinner.html: lib/Gtk2/Ex/DateSpinner.pm Makefile
	-perl -MPod::Simple::HTML -e Pod::Simple::HTML::go \
	  lib/Gtk2/Ex/DateSpinner.pm \
	| sed 's!http://search.cpan.org/perldoc?Gtk2%3A%3A\([^"%]*\)"!http://gtk2-perl.sourceforge.net/doc/pod/Gtk2/\1.html"!' \
	  >DateSpinner.html

mydist:
	make dist COMPRESS='gzip --force --best'
	make copyright-years-check
	rm -rf mydist.tmp
	mkdir mydist.tmp
	(cd mydist.tmp; \
	 tar xfz ../$(DISTVNAME).tar.gz; \
	 cd $(DISTVNAME); \
	cpansign -v; \
	perl Makefile.PL SIGN=0; \
	make debug-constants-check; \
	)
	rm -rf mydist.tmp

HERE
}
