use Net::NS::API       ();
use Test::Mock::Simple ();
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
        <Opmerkingen>
            <Opmerking>Rijdt via een andere route</Opmerking>
        </Opmerkingen>
    </VertrekkendeTrein>
</ActueleVertrekTijden>
EOF


my $mock = Test::Mock::Simple->new( module => 'HTTP::Tiny' );
$mock->add( request => sub { { content => $xml, headers => {} } } );
ok $mock, 'HTTP::Tiny method mocked';


my $api = Net::NS::API->new( username => 'user', password => 'password' );
isa_ok $api, 'Net::NS::API';


my $avt = $api->actuele_vertrek_tijden( station => 'Utrecht' );
ok $avt, 'avt data returned';


my @expected = (
    {    #
        comments                  => ['Rijdt via een andere route'],
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
