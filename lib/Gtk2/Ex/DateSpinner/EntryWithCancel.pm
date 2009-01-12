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

package Gtk2::Ex::DateSpinner::EntryWithCancel;
use strict;
use warnings;
use Gtk2;

our $VERSION = 2;

use constant DEBUG => 0;

use Glib::Object::Subclass
  'Gtk2::Entry',
  signals => { activate        => \&_do_activate,
               editing_done    => \&_do_editing_done,
               cancel => { param_types   => [],
                           return_type   => undef,
                           flags         => [ 'action','run-last' ],
                           class_closure => \&_do_cancel,
                         },
             },
  interfaces => [ 'Gtk2::CellEditable' ],
  properties => [ Glib::ParamSpec->boolean
                  ('editing-cancelled',
                   'editing-cancelled',
                   'True if editing was cancelled with Escape rather than activated with Return etc.',
                   0, # default
                   Glib::G_PARAM_READWRITE) ];

# In GtkCellRendererText and the GtkEntry it creates the cancel is noticed
# by gtk_cell_editable_key_press_event() installed on key-press-event.  Here
# it's through key bindings, in the interests of possible configurability.
#
# FIXME: Up and Down are specific to moving between view cells to end an
# edit, rather than an "edit with cancel" as such.  Would it be better for
# DateSpinner::CellRenderer to give its created entry a widget name and
# establish bindings that way?
#
Gtk2::Rc->parse_string (<<'HERE');
binding "Gtk2__Ex__DateSpinner__EntryWithCancel_keys" {
  bind "Escape" { "cancel" () }
  bind "Up"     { "activate" () }
  bind "Down"   { "activate" () }
}
# priority level "gtk" treating this as widget level default, for overriding
# by application or user RC
class "Gtk2__Ex__DateSpinner__EntryWithCancel"
  binding:gtk "Gtk2__Ex__DateSpinner__EntryWithCancel_keys"
HERE

# if (DEBUG) {
#   *SET_PROPERTY = sub {
#     my ($self, $pspec, $newval) = @_;
#     if (DEBUG) { print "EntryWithCancel: SET_PROPERTY ",$pspec->get_name,
#                    " ",(defined $newval ? $newval : 'undef'),"\n"; }
#     $self->{$pspec->get_name} = $newval;
#   };
# }

# gtk_cell_editable_start_editing(), cf. gtk_entry_start_editing()
#
sub START_EDITING {
  my ($self, $event) = @_;
  if (DEBUG) { print "EntryWithCancel: START_EDITING\n"; }
  $self->set ('editing-cancelled', 0);
  $self->{'editing_active'} = 1;
}

# 'editing-done' class closure, from GtkCellEditable interface
sub _do_editing_done {
  my ($self) = @_;
  $self->{'editing_active'} = 0;
  return $self->signal_chain_from_overridden;
}

# like gtk_cell_editable_entry_activated()
#
# In GtkEntry gtk_cell_editable_entry_activated() and
# gtk_cell_editable_key_press_event() are as a signal connections on self.
# Is there a reason for that?  Seems easier to test a flag for when to act
# rather than connect and disconnect.
#
sub _do_activate {
  my ($self) = @_;
  if (DEBUG) { print "EntryWithCancel: _do_activate\n"; }
  $self->set ('editing-cancelled', 0);
  _emit_editing_done ($self, 0);
  return $self->signal_chain_from_overridden;
}

sub cancel {
  my ($self) = @_;
  $self->signal_emit ('cancel');
}

# 'cancel' class closure
sub _do_cancel {
  my ($self) = @_;
  if (DEBUG) { print "EntryWithCancel: cancel signal\n"; }
  $self->set ('editing-cancelled', 1);
  _emit_editing_done ($self, 1); # if active
}

sub _emit_editing_done {
  my ($self, $cancelled) = @_;
  if ($self->{'editing_active'}) {
    $self->editing_done;
    $self->remove_widget;
  }
}

1;
__END__

=head1 NAME

Gtk2::Ex::DateSpinner::EntryWithCancel -- Gtk2::Entry with a cancelled property

=head1 SYNOPSIS

 use Gtk2::Ex::DateSpinner::EntryWithCancel;
 my $entry = Gtk2::Ex::DateSpinner::EntryWithCancel->new;

 $entry->signal_connect ('editing-done',
                         sub {
                           if ($entry->get('editing-cancelled'))
                             ...
                         });

=head1 WIDGET HIERARCHY

C<Gtk2::Ex::DateSpinner::EntryWithCancel> is a subclass of C<Gtk2::Entry>.

    Gtk2::Widget
      Gtk2::Entry
        Gtk2::Ex::DateSpinner::EntryWithCancel

And implements the interface

    Gtk2::CellEditable

=head1 DESCRIPTION

B<Caution: This is internals of C<Gtk2::Ex::DateSpinner::CellRenderer>.  If
ends up with a use beyond that then it'll be split out and renamed.>

C<EntryWithCancel> extends C<Gtk2::Entry> to have an "editing-cancelled"
flag set when editing through the C<Gtk2::CellEditable> interface.  Ending
by an Escape key press or C<cancel> action sets the flag.

C<Gtk2::Entry> already has such a flag (mis-spelt C<editing_canceled>) but
doesn't make it publicly available.  Is that right?  At any rate this
subclass gets the desired effect.

=head1 FUNCTIONS

=over 4

=item C<< $entry = Gtk2::Ex::DateSpinner::EntryWithCancel->new (key=>value,...) >>

Create and return a new EntryWithCancel object.  Optional key/value pairs
set initial properties as per C<< Glib::Object->new >>.  Eg.

    my $entry = Gtk2::Ex::DateSpinner::EntryWithCancel->new (xalign => 0.5);

=item C<< $entry->cancel () >>

Emit the C<cancel> action signal (see L</SIGNALS> below), thus performing
that action.

=back

=head1 PROPERTIES

=over 4

=item C<editing-cancelled> (boolean, default false)

Cleared by C<start_editing> (the C<Gtk2::CellEditable> func) and then set to
true or false under an Escape (keypress) or C<activate> (C<Gtk2::Widget>
signal).  C<editing-done> handlers (the C<Gtk2::CellEditable> signal) can
then consult the value.

=back

=head1 SIGNALS

=over 4

=item C<cancel> (action, no parameters)

Perform the cancel action, which is to set C<editing-cancelled> property,
and if editing is active from a C<start_editing> then emit C<editing-done>
and C<remove-widget>.

The C<Escape> key binding runs this signal.

=back

=head1 SEE ALSO

L<Gtk2::Entry>, L<Glib::Object>

=head1 HOME PAGE

L<http://www.geocities.com/user42_kevin/gtk2-ex-datespinner/index.html>

=head1 LICENSE

Gtk2-Ex-DateSpinner is Copyright 2008, 2009 Kevin Ryde

Gtk2-Ex-DateSpinner is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

Gtk2-Ex-DateSpinner is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Gtk2-Ex-DateSpinner.  If not, see <http://www.gnu.org/licenses/>.

=cut

#
# Unused:
#
# This induces a cancel action in a GtkEntry, but there's no apparent way to
# get the editing_canceled field.
#
# package Gtk2::Ex::EntryBits;
# use strict;
# use warnings;
# 
# sub cancel {
#   my ($entry) = @_;
#   my $event = Gtk2::Gdk::Event->new('key-press');
#   $event->keyval (Gtk2::Gdk->keyval_from_name ('Escape'));
#   $entry->signal_emit ('key_press_event', $event);
# }
# 

