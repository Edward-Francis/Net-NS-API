#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Net::NS::API' ) || print "Bail out!\n";
}

diag( "Testing Net::NS::API $Net::NS::API::VERSION, Perl $], $^X" );
