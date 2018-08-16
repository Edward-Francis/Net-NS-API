use Net::NS::API ();
use Test::Most tests => 4;


my $xml = <<EOF;
<Stations>
  <Station>
    <Code>HT</Code>
    <Type>knooppuntIntercitystation</Type>
    <Namen>
      <Kort>H'bosch</Kort>
      <Middel>'s-Hertogenbosch</Middel>
      <Lang>'s-Hertogenbosch</Lang>
    </Namen>
    <Land>NL</Land>
    <UICCode>8400319</UICCode>
    <Lat>51.690556</Lat>
    <Lon>5.293611</Lon>
    <Synoniemen>
      <Synoniem>Hertogenbosch ('s)</Synoniem>
      <Synoniem>Den Bosch</Synoniem>
    </Synoniemen>
  </Station>
</Stations>
EOF


my $api = Net::NS::API->new;
isa_ok $api, 'Net::NS::API';


my $xml_document = $api->_xml_document_from_string($xml);
isa_ok $xml_document, 'XML::LibXML::Document';


my $stations = $api->_format_stations_v2($xml_document);
ok $stations, 'stations data returned';


my @expected = (
    {    #
        abbr_name     => q{H'bosch},
        code          => 'HT',
        country_code  => 'NL',
        full_name     => q{'s-Hertogenbosch},
        latitude      => 51.690556,
        longitude     => 5.293611,
        short_name    => q{'s-Hertogenbosch},
        synonym_names => [ q{Hertogenbosch ('s)}, q{Den Bosch} ],
        type          => 'knooppuntIntercitystation',
        uic_code      => 8400319,
    }
);

cmp_deeply $stations, \@expected, 'stations v2 data formatted correctly';

done_testing;
