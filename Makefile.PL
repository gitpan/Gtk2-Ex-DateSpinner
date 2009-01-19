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

WriteMakefile
  (NAME         => 'Gtk2-Ex-DateSpinner',
   ABSTRACT     => 'Date entry widget using spin buttons.',
   VERSION_FROM => 'lib/Gtk2/Ex/DateSpinner.pm',
   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,

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
recommends:
    Test::Pod: 1.00
    Test::Weaken: 0
no_index:
    directory:
        - devel
resources:
    homepage: http://www.geocities.com/user42_kevin/gtk2-ex-datespinner/index.html
    license: http://www.gnu.org/licenses/#GPL
HERE
  );


package MY;
use strict;
use warnings;

sub postamble {
  print "MY::postamble extras ...\n";
  return <<'MAKE_FRAG';

DateSpinner.html: lib/Gtk2/Ex/DateSpinner.pm Makefile
	-perl -MPod::Simple::HTML -e Pod::Simple::HTML::go \
	  lib/Gtk2/Ex/DateSpinner.pm \
	| sed 's!http://search.cpan.org/perldoc?Gtk2%3A%3A\([^"%]*\)"!http://gtk2-perl.sourceforge.net/doc/pod/Gtk2/\1.html"!' \
	  >DateSpinner.html

myman:
	mv MANIFEST MANIFEST.old
	touch SIGNATURE
	(make manifest 2>&1; diff -u MANIFEST.old MANIFEST) |less

LINT_FILES = $(TO_INST_PM) t/*.t examples/*.pl devel/*.pl
lint:
	for i in $(LINT_FILES); do perl -MO=Lint $$i; done
	podchecker $(LINT_FILES)
pc:
	perlcritic $(LINT_FILES)
unused:
	for i in $(LINT_FILES); do perl -Mwarnings::unused -I lib $$i; done

mydist:
	make dist COMPRESS='gzip --force --best'
	make copyright-years-check
	rm -rf mydist.tmp
	mkdir mydist.tmp
	(cd mydist.tmp; \
	 tar xfz ../$(DISTVNAME).tar.gz; \
	 cd $(DISTVNAME); \
	perl -e '!eval{require YAML} || YAML::LoadFile("META.yml")' \
	 && echo YAML reads ok; \
	perl -e '!eval{require YAML::Tiny} || YAML::Tiny->read("META.yml")' \
	 && echo YAML::Tiny reads ok; \
	cpansign -v; \
	perl Makefile.PL SIGN=0; \
	make debug-constants-check; \
	)
	rm -rf mydist.tmp

# find files in the dist with mod times this year, but without this year in
# the copyright line
copyright-years-check:
	year=`date +%Y`; \
	tar tvfz $(DISTVNAME).tar.gz \
	| grep $$year- \
	| sed 's:^.*$(DISTVNAME)/::' \
	| (result=0; \
	  while read i; do \
	    case $$i in \
	      '' | */ \
	      | debian/changelog | debian/compat \
	      | t/pod.t \
	      | COPYING | MANIFEST* | SIGNATURE | META.yml) \
	      continue ;; \
	    esac; \
	    if test -e "$(srcdir)/$$i"; then f="$(srcdir)/$$i"; \
	    else f="$$i"; fi; \
	    if ! grep -q "Copyright.*$$year" $$f; then \
	      echo "$$i":"1: this file"; \
	      grep Copyright $$f; \
	      result=1; \
	    fi; \
	  done; \
	  exit $$result)

debug-constants-check:
	if egrep -n 'DEBUG => [^0]' $(TO_INST_PM); then exit 1; else exit 0; fi

diff-prev:
	rm -rf diff.tmp
	mkdir diff.tmp
	cd diff.tmp \
	&& tar xfz ../$(NAME)-`expr $(VERSION) - 1`.tar.gz \
	&& tar xfz ../$(NAME)-$(VERSION).tar.gz
	-cd diff.tmp; diff -ur $(NAME)-`expr $(VERSION) - 1` \
	                       $(NAME)-$(VERSION) >tree.diff
	-less diff.tmp/tree.diff
	rm -rf diff.tmp

MAKE_FRAG
}
