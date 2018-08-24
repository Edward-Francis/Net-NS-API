use Net::NS::API ();
use Test::Most tests => 4;

my $xml = <<EOF;
<Storingen>
  <Ongepland>
    <Storing>
      <id>prio-13345</id>
      <Traject>'s-Hertogenbosch-Nijmegen</Traject>
      <Reden>beperkingen op last van de politie</Reden>
      <Bericht></Bericht>
      <Datum>2010-12-16T11:16:00+0100</Datum>
    </Storing>
  </Ongepland>
  <Gepland>
    <Storing>
      <id>2010_almo_wp_18_19dec</id>
      <Traject>Almere Oostvaarders-Weesp/Naarden-Bussum</Traject>
      <Periode>zaterdag 18 en zondag 19 december</Periode>
      <Reden>Limited train service.</Reden>
      <Advies>Use an alternative train or bus.</Advies>
      <Bericht></Bericht>
    </Storing>
  </Gepland>
</Storingen>
EOF


my $api = Net::NS::API->new( username => 'user', password => 'password' );
isa_ok $api, 'Net::NS::API';


my $xml_document = $api->_xml_document_from_string($xml);
isa_ok $xml_document, 'XML::LibXML::Document';


my $storingen = $api->_format_storingen($xml_document);
ok $storingen, 'storingen data returned';


my %expected = (
    unplanned => [
        {   id      => 'prio-13345',
            route   => q{'s-Hertogenbosch-Nijmegen},
            reason  => 'beperkingen op last van de politie',
            message => '',
            date    => '2010-12-16T11:16:00+0100',
            advice  => '',
            period  => '',
        }
    ],
    planned => [
        {   id      => '2010_almo_wp_18_19dec',
            route   => 'Almere Oostvaarders-Weesp/Naarden-Bussum',
            period  => 'zaterdag 18 en zondag 19 december',
            reason  => 'Limited train service.',
            advice  => 'Use an alternative train or bus.',
            message => '',
            date    => '',
        }
    ],
);

cmp_deeply $storingen, \%expected, 'storingen data formmatted correctly';

done_testing;
