use Net::NS::API ();
use Test::Most tests => 4;

my $xml = <<EOF;
<ActueleVertrekTijden>
    <VertrekkendeTrein>
        <RitNummer>835</RitNummer>
        <VertrekTijd>2018-08-14T10:05:00+0200</VertrekTijd>
        <EindBestemming>Maastricht</EindBestemming>
        <TreinSoort>Intercity</TreinSoort>
        <RouteTekst>Amstel, Utrecht C, Eindhoven</RouteTekst>
        <Vervoerder>NS</Vervoerder>
        <VertrekSpoor wijziging="true">5b</VertrekSpoor>        
    </VertrekkendeTrein>
</ActueleVertrekTijden>
EOF


my $api = Net::NS::API->new;
isa_ok $api, 'Net::NS::API';


my $xml_document = $api->_xml_document_from_string( $xml );
isa_ok $xml_document, 'XML::LibXML::Document';


my $avt = $api->_format_actuele_vertrek_tijden($xml_document);
ok $avt, 'avt data returned';

my @expected = (
    {    #
        comment                   => undef,
        delay_text                => undef,
        delay_time                => undef,
        departure_platform        => '5b',
        departure_platform_change => 1,
        departure_time            => '2018-08-14T10:05:00+0200',
        destination               => 'Maastricht',
        route_description         => 'Amstel, Utrecht C, Eindhoven',
        train_carrier             => 'NS',
        train_id                  => 835,
        train_type                => 'Intercity',
        travel_tip                => undef,
    }
);

cmp_deeply $avt, \@expected, 'avt data formmatted correctly';

done_testing;
