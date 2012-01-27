use lib qw/lib/;
use Plack::Builder;
use Plack::App::Emacs;

builder {
    mount "/" => Plack::App::Emacs->new;
};
