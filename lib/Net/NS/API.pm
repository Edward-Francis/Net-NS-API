package Net::NS::API;

use Moose;
use namespace::autoclean;

# IMPORTS

use URI;
use Carp;
use HTTP::Tiny  ();
use XML::LibXML ();
use MIME::Base64 qw(encode_base64);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);

# VERSION

our $VERSION = '0.01';


# ATTRIBUTES

has 'username' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'password' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has '_client' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_client',
);


# ROLES

with qw(
    Net::NS::API::ActueleVertrekTijden
    Net::NS::API::StationsV2
    Net::NS::API::Storingen
    Net::NS::API::TreinPlanner
);


# PRIVATE METHODS


sub _make_request {
    my ( $self, $method, $path, %args ) = @_;

    my $uri = URI->new('http://webservices.ns.nl');
    $uri->path($path);

    # FIXME: lets log something

    my $response = $self->_client->request( $method, $uri );
    my $content  = $response->{content};
    my $encoding = $response->{headers}->{'content-encoding'};
    my $xml_string;


    if ( $encoding && $encoding eq 'gzip' ) {
        gunzip \$content => \$xml_string
            or croak sprintf( 'Failed to gunzip content: %s', $GunzipError );
    }

    $xml_string //= $content;


    my $dom = $self->_xml_document_from_string($xml_string);

    # FIXME: what if xml cannot be read....

    # FIXME: do error handling

    return $dom;
}


sub _xml_document_from_string {
    return XML::LibXML->load_xml( string => $_[1], encoding => 'UTF-8' );
}


# BUILDERS

sub _build_client {
    my $self = $_[0];

    my $credentials = sprintf( '%s:%s', $self->username, $self->password );
    my $authorization = sprintf 'Basic %s', encode_base64( $credentials, '' );

    return HTTP::Tiny->new(
        default_headers => {
            'Authorization'   => $authorization,
            'Accept'          => 'text/xml; charset=UTF-8',
            'Accept-Encoding' => 'gzip',
            'User-Agent' =>
                'Net-NS-API (https://github.com/Edward-Francis/Net-NS-API)',
        },

    );
}

=head1 NAME

Net::NS::API - The great new Net::NS::API!

=head1 VERSION

Version 0.01

=head1 DESCRIPTION

=head1 SYNOPSIS

FIXME

Perhaps a little code snippet.

    use Net::NS::API;

    my $api = Net::NS::API->new( username => $username, password => $password );
    
FIXME

=head1 METHODS

FIXME

=head1 ATTRIBUTES

=over 

=item username (required)

=item password (required)

=back

=head1 AUTHOR

Edward Francis, C<edwardafrancis@gmail.com>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-ns-api at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-NS-API>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::NS::API

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-NS-API>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-NS-API>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Net-NS-API>

=item * Search CPAN

L<https://metacpan.org/release/Net-NS-API>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Edward Francis.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1;
