package Catalyst::Plugin::Hooks;

use strict;
use warnings;

use NEXT;
use Carp;

our $VERSION = '0.01';

sub add_hook {
}

my %actions;
@actions{ qw(
    handle_request
    prepare
    prepare_request
    prepare_connection
    prepare_query_parameters
    prepare_headers
    prepare_cookies
    prepare_path
    prepare_body
    prepare_body_parameters
    prepare_parameters
    prepare_uploads
    prepare_action
    dispatch
    finalize
    finalize_uploads
    finalize_error
    finalize_headers
    finalize_cookies
    finalize_body
) } = ();

for my $action ( keys %actions ) {
    no strict 'refs';
    *{"add_". $action ."_hook"} = sub {
        my ( $c, $hook ) = @_;
        croak "add_". $action ."_hook( CODE )" unless ref $hook eq "CODE";
        __PACKAGE__->initialize_action( $action )
            unless $action->{initialized};

        push @{ $actions{$action}->{before} }, $hook;
    };
    *{"add_before_". $action ."_hook"} = \*{"add_". $action ."_hook"};

    *{"add_after_". $action ."_hook"} = sub {
        my ( $c, $hook ) = @_;
        croak "add_after_". $action ."_hook( CODE )" unless ref $hook eq "CODE";
        __PACKAGE__->initialize_action( $action )
            unless $action->{initialized};

        push @{ $actions{$action}->{after} }, $hook;
    };
}

sub initialize_action {
    my ( $self, $action ) = @_;

    no strict 'refs';
    eval q/ sub /. $action .q/ {
        my $c = shift;

        for my $hook ( @{ $actions{'/. $action .q/'}->{before} } ) {
            $hook->( $c, @_ );
        }
        $c->NEXT::/. $action .q/(@_);
        for my $hook ( @{ $actions{'/. $action .q/'}->{after} } ) {
            $hook->( $c, @_ );
        }
    } /;
    die $@ if $@;
    $actions{ $action }->{initialized} = 1;
}

1

__END__

=head1 NAME

Catalyst::Plugin::Hooks - Add hooks to Catalyst engine actions

=head1 SYNOPSIS

In MyApp.pm:

  use Catalyst qw(
    -Debug
    Hooks
  );

In Some model:

  sub new {
    my $self = shift;
    my ( $c ) = @_;

    $self->NEXT::new( @_ );

    open my $filehandle, "> foo.log";

    $c->add_after_finalize_hook( sub {
        $filehandle->flush();
    }

    return $self;
  }


=head1 DESCRIPTION

Implements hooks on Catalyst's engine actions. See L<Catalyst::Manual::Internals>
for when the different actions are called. This is usefull for when you
want some code run after all actions for a request are completed. Let's say
you want to flush your log after the request is done. You can achieve this by
calling
C<$c->add_after_finalize_hook( sub { warn "Request done, time to cleanup"; $fh->flush } );

=head2 METHODS

All of these methods are currently hookable:

    handle_request
    prepare
    prepare_request
    prepare_connection
    prepare_query_parameters
    prepare_headers
    prepare_cookies
    prepare_path
    prepare_body
    prepare_body_parameters
    prepare_parameters
    prepare_uploads
    prepare_action
    dispatch
    finalize
    finalize_uploads
    finalize_error
    finalize_headers
    finalize_cookies
    finalize_body

To add a I<before> hook, call
  $c->add_ <method name> _hook( sub { some code } );>

To add an I<after> hook, call
  $c->add_after_ <method name> _hook( sub { some code } );>

C<< $c->add_before_ <method name> _hook >> is an alias to C<< $c->add_ <method name> _hook >>.

=head1 SEE ALSO

L<Catalyst>,
L<Catalyst::Manual::Internals>

=head1 AUTHOR

Berik Visschers <berikv@xs4all.nl>

=cut
