package Net::NS::API::ActueleVertrekTijden;

use Moose::Role;

# IMPORTS
use Carp;


requires '_make_request';


# METHDOS

sub actuele_vertrek_tijden {
    my ( $self, %args ) = @_;

    my $station = $args{station}
        or croak 'actuele_vertrek_tijden requires arguement `station`';

    my $xml = $self->_make_request( 'GET', 'ns-api-avt', station => $station );
    my $data = $self->_format_actuele_vertrek_tijden($xml);
    return $data;
}


# PRIVATE METHDOS

sub _format_actuele_vertrek_tijden {
    my ( $self, $dom ) = @_;

    my @avt;

    for ( $dom->findnodes('//VertrekkendeTrein') ) {


        my $platform = $_->find('.//VertrekSpoor')->[0];
        my $change = $platform->getAttribute('wijziging') eq 'true' ? 1 : 0;

        my %avt = (
            comments           => [],
            delay_text         => $_->findvalue('.//VertrekVertragingTekst'),
            delay_time         => $_->findvalue('.//VertrekVertraging'),
            departure_platform => $platform->textContent,
            departure_platform_change => $change,
            departure_time            => $_->findvalue('.//VertrekTijd'),
            destination               => $_->findvalue('.//EindBestemming'),
            route_description         => $_->findvalue('.//RouteTekst'),
            train_carrier             => $_->findvalue('.//Vervoerder'),
            train_id                  => $_->findvalue('.//RitNummer'),
            train_type                => $_->findvalue('.//TreinSoort'),
            travel_tip                => $_->findvalue('.//ReisTip'),

        );


        for ( $_->findnodes('.//Opmerkingen/Opmerking') ) {

            my $comments = $_->textContent;

            # remove additional whitespace from the beginning and end
            $comments =~ s/^\s+//;
            $comments =~ s/\s+$//;

            push @{ $avt{comments} }, $comments;
        }


        # replace empty strings with undef
        for ( keys %avt ) {
            $avt{$_} = undef if $avt{$_} eq '';
        }

        push @avt, \%avt;
    }


    return \@avt;
}

1;
