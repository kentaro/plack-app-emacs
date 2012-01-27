package Plack::App::Emacs;
use 5.008008;
use strict;
use warnings;
use parent qw(Plack::Component);
use Plack::Request;
use Encode;
use JSON::PP;

our $VERSION = '0.01';

sub prepare_app {
    my $self = shift;
    $self->{emacsclient} ||= 'emacsclient';
    $self;
}

sub call {
    my ($self, $env) = @_;
    my $req = Plack::Request->new($env);
    my $json = JSON::PP->new->ascii
        ->allow_singlequote->allow_blessed->allow_nonref;
    my $str = $json->encode({
        uri => $env->{PATH_INFO}||'',
        method => $req->method,
        headers => [split( /\n/, $req->headers->as_string)],
        content => $req->content,
    });
    $str =~ s!"!\\x22!g;

    my $command = sprintf q{%s -ne '(plack:handle "%s")'},
        $self->{emacsclient},
        encode($self->{encoding} || 'utf8', $str);

    open(my $f, "$command|");
    binmode $f, ':utf8';
    my $out = <$f>;
    close $f;
    my $res = $json->decode(eval($out));
    $res->[2][0] = encode_utf8 $res->[2][0] if $res;
    $res || [500, ['Content-Type' => 'text/plain'], ['Internal Server Error']];
}

1;
__END__

=encoding utf8

=head1 NAME

Plack::App::Emacs - blah blah blah

=head1 SYNOPSIS

  use Plack::App::Emacs;

=head1 DESCRIPTION

Plack::App::Emacs is

=head1 AUTHOR

Kentaro Kuribayashi E<lt>kentarok@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Kentaro Kuribayashi

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
