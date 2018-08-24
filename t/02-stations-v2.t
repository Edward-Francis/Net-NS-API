use Net::NS::API       ();
use Test::Mock::Simple ();
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


my $mock = Test::Mock::Simple->new( module => 'HTTP::Tiny' );
$mock->add( request => sub { { content => $xml, headers => {} } } );
ok $mock, 'HTTP::Tiny method mocked';


my $api = Net::NS::API->new( username => 'user', password => 'password' );
isa_ok $api, 'Net::NS::API';


my $stations = $api->stations_v2;
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
