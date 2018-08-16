package Net::NS::API::StationsV2;

use Moose::Role;


requires '_make_request';


# METHDOS

sub stations_v2 {
    my ( $self, %args ) = @_;
    # FIXME:
    # Set correct url
    my $xml = $self->_make_request( 'GET', 'url' );
    my $data = $self->_format_stations_v2($xml);
    return $data;
}


# PRIVATE METHDOS


sub _format_stations_v2 {
    my ( $self, $dom ) = @_;

    my @stations;

    for ( $dom->findnodes('//Station') ) {

        my %station = (
            code         => $_->findvalue('.//Code'),
            type         => $_->findvalue('.//Type'),
            country_code => $_->findvalue('.//Land'),
            uic_code     => $_->findvalue('.//UICCode'),
            latitude     => $_->findvalue('.//Lat'),
            longitude    => $_->findvalue('.//Lon'),
            abbr_name    => $_->findvalue('.//Namen/Kort'),
            full_name    => $_->findvalue('.//Namen/Middel'),
            short_name   => $_->findvalue('.//Namen/Lang'),
        );

        if ( $_->exists('.//Synoniemen') ) {
            $station{synonym_names} = [ map { $_->textContent }
                    $_->findnodes('.//Synoniemen/Synoniem') ];
        }

        push @stations, \%station;
    }

    return \@stations;
}


1;
