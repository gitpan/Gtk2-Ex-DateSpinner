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

package Gtk2::Ex::DateSpinner;
use 5.008;
use strict;
use warnings;
use Date::Calc;
use Gtk2;

our $VERSION = 6;

use constant DEBUG => 0;

use Glib::Object::Subclass
  'Gtk2::HBox',
  properties => [Glib::ParamSpec->string
                 ('value',
                  'value',
                  'ISO format date string like 2008-07-25.',
                  '2000-01-01',
                  Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->{'value'} = '2000-01-01';

  my $year_adj = Gtk2::Adjustment->new (2000,    # initial
                                        0, 9999, # range
                                        1,       # step increment
                                        10,      # page_increment
                                        0);      # page_size (not applicable)
  my $year = $self->{'year'} = Gtk2::SpinButton->new ($year_adj, 1, 0);
  $year->show;
  $self->pack_start ($year, 0,0,0);

  my $month_adj = Gtk2::Adjustment->new (1,      # initial
                                         0, 99,  # range
                                         1,      # step_increment
                                         1,      # page_increment
                                         0);     # page_size (not applicable)
  my $month = $self->{'month'} = Gtk2::SpinButton->new ($month_adj, 1, 0);
  $month->show;
  $self->pack_start ($month, 0,0,0);

  my $day_adj = Gtk2::Adjustment->new (1,      # initial
                                       0, 99,  # range
                                       1,      # step_increment
                                       1,      # page_increment
                                       0);     # page_size (not applicable)
  my $day = $self->{'day'} = Gtk2::SpinButton->new ($day_adj, 1, 0);
  $day->show;
  $self->pack_start ($day, 0,0,0);

  my $dow = $self->{'dayofweek_label'} = Gtk2::Label->new;
  $dow->show;
  $self->pack_start ($dow, 0,0,0);

  $year->signal_connect  (value_changed => \&_update);
  $month->signal_connect (value_changed => \&_update);
  $day->signal_connect   (value_changed => \&_update);
  _update ($year);
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;  # per default GET_PROPERTY

  if ($pname eq 'value') {
    my ($year, $month, $day) = split /-/, $newval;
    $self->{'year'}->set_value ($year);
    $self->{'month'}->set_value ($month);
    $self->{'day'}->set_value ($day);
  }
}

sub _update {
  my ($spin) = @_;
  my $self = $spin->parent;

  if ($self->{'update_in_progress'}) { return; }
  local $self->{'update_in_progress'} = 1;

  my $year_spin = $self->{'year'};
  my $month_spin = $self->{'month'};
  my $day_spin = $self->{'day'};

  my $year  = $year_spin->get_value;
  my $month = $month_spin->get_value;
  my $day   = $day_spin->get_value;
  if (DEBUG) { print "DateSpinner update $year, $month, $day\n"; }

  ($year, $month, $day) = Date::Calc::Add_Delta_YMD
    (2000, 1, 1, $year-2000, $month-1, $day-1);

  $year_spin->set_value ($year);
  $month_spin->set_value ($month);
  $day_spin->set_value ($day);

  # Prefer strftime over Date::Calc's localized names, on the basis that
  # strftime will probably know more languages, and setlocale() is done
  # automatically when perl starts.
  #
  # The modules end up required for the initial value when a DateSpinner is
  # created, but deferring them until that time might let you load the
  # module without yet dragging in the other big stuff.
  #
  require POSIX;
  require I18N::Langinfo;
  require Encode;
  my $wday = Date::Calc::Day_of_Week ($year, $month, $day); # 1=Mon,7=Sun,...
  my $str = POSIX::strftime (' %a ', 0,0,0, 1,1,100, $wday%7);# 0=Sun,1=Mon,..
  my $charset = I18N::Langinfo::langinfo (I18N::Langinfo::CODESET());
  $str = Encode::decode ($charset, $str);
  $self->{'dayofweek_label'}->set_text ($str);

  my $value = sprintf ('%04d-%02d-%02d', $year, $month, $day);
  if ($value ne $self->{'value'}) {
    $self->{'value'} = $value;
    $self->notify('value');
  }
}

sub get_value {
  my ($self) = @_;
  return $self->{'value'};
}

sub set_today {
  my ($self) = @_;
  my ($year, $month, $day) = Date::Calc::Today();
  $self->set (value => sprintf ('%04d-%02d-%02d', $year, $month, $day));
}

1;
__END__

=head1 NAME

Gtk2::Ex::DateSpinner -- year/month/day date entry using SpinButtons

=head1 SYNOPSIS

 use Gtk2::Ex::DateSpinner;
 my $ds = Gtk2::Ex::DateSpinner->new (value => '2008-06-14');

=head1 WIDGET HIERARCHY

C<Gtk2::Ex::DateSpinner> is (currently) a subclass of C<Gtk2::HBox>, though
it's probably not a good idea to rely on that.

    Gtk2::Widget
      Gtk2::Container
        Gtk2::Box
          Gtk2::HBox
            Gtk2::Ex::DateSpinner

=head1 DESCRIPTION

C<Gtk2::Ex::DateSpinner> displays and changes a date in year, month, day
format using three C<Gtk2::SpinButton> fields.  The day of the week is shown
to the right.

        +------+   +----+   +----+
        | 2008 |^  |  6 |^  | 14 |^   Sat
        +------+v  +----+v  +----+v

There's lots ways to enter/display a date.  This style is good for clicking
to a nearby date, but also allows a date to be typed in if a long way away.

If a click or entered value takes the day outside the days in the month then
it wraps around to the next or previous month.  Likewise the month wraps
around to the next or previous year.  The day of the week display updates
once you press enter or tab when typing in a number.

Day of the week and date normalization calculations use C<Date::Calc> so
they're not limited to the system C<time_t> (which may be as little as 1970
to 2038 on a 32-bit system).  The day name uses C<POSIX::strftime> and gets
the usual C<LC_TIME> localizations established at Perl startup or Gtk
initialization.

=head1 FUNCTIONS

=over 4

=item C<< $ds = Gtk2::Ex::DateSpinner->new (key=>value,...) >>

Create and return a new DateSpinner widget.  Optional key/value pairs set
initial properties per C<< Glib::Object->new >>.  Eg.

    my $ds = Gtk2::Ex::DateSpinner->new (value => '2008-06-14');

=item C<< $ds->set_today >>

Set the C<value> in C<$ds> to today's date (today in the local timezone).

=back

=head1 PROPERTIES

=over 4

=item C<value> (string, default "2000-01-01")

The current date value, as an ISO format "YYYY-MM-DD" string.  When you read
this the day and month are always "normalized", so MM is 01 to 12 and DD is
01 to 28,29,30 or 31, however many days in the particular month.

The default 1 January 2000 is meant to be fairly useless and you should set
it to something that makes sense for the particular application.

There's very limited validation on the C<value> string, so don't set
garbage.

=back

=head1 SEE ALSO

L<Gtk2::Ex::DateSpinner::CellRenderer>, L<Date::Calc>, L<Gtk2::Calendar>,
L<Gtk2::SpinButton>, L<Gtk2::Ex::CalendarButton>, L<Gtk2::Ex::DateRange>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/gtk2-ex-datespinner/index.html>

=head1 LICENSE

Gtk2-Ex-DateSpinner is Copyright 2008, 2009, 2010 Kevin Ryde

Gtk2-Ex-DateSpinner is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

Gtk2-Ex-DateSpinner is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Gtk2-Ex-DateSpinner.  If not, see L<http://www.gnu.org/licenses/>.

=cut
