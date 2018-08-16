package Net::NS::API::Storingen;

use Moose::Role;

use Carp;

requires '_make_request';


# METHDOS

sub storingen {
    my ( $self, %args ) = @_;

    my $actual = $args{actual}
        or croak 'storingen requires arguement `actual`';


    # FIXME:
    # Set correct url
    my $xml = $self->_make_request(
        'GET', 'url',
        actual    => $actual,
        station   => $args{station},
        unplanned => $args{unplanned},
    );
    my $data = $self->_format_stations_v2($xml);
    return $data;
}


# PRIVATE METHDOS


sub _format_storingen {
    my ( $self, $dom ) = @_;

    my $unplanned = $dom->findnodes('//Ongepland/Storing');
    my $planned   = $dom->findnodes('//Gepland/Storing');

    my %storingen = (
        planned   => $self->_format_storing($planned),
        unplanned => $self->_format_storing($unplanned),
    );

    return \%storingen;
}


sub _format_storing {
    my ( $self, $nodelist ) = @_;

    my @problems;

    use DDP;

    for ( @{$nodelist} ) {

        my %storing = (
            id      => $_->findvalue('.//id'),
            route   => $_->findvalue('.//Traject'),
            reason  => $_->findvalue('.//Reden'),
            message => $_->findvalue('.//Bericht'),
            period  => $_->findvalue('.//Periode'),
            advice  => $_->findvalue('.//Advies'),
            date    => $_->findvalue('.//Datum'),
        );

        push @problems, \%storing;
    }

    return \@problems;
}

1;
