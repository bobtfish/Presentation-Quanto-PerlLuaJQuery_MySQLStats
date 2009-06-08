package # Hide from PAUSE
   Presentation::Quanto_PerlLuaJQuery_MySQLStats;
use Pod::S5;
use File::ShareDir qw/dist_dir/;
use Moose;
use MooseX::Types::Moose qw/Str Bool/;
use Method::Signatures::Simple;
use File::Slurp qw/read_file/;
use File::Temp qw/tempfile/;
use YAML qw/Load/;
use namespace::autoclean;

with 'MooseX::Getopt';

has pod_filename => ( isa => Str, is => 'ro', lazy_build => 1 );

method _build_pod_filename {
    my $fn = $0;
    $fn =~ s/\.p[lm]/.pod/;
    return $fn;
}

method _html_filename {
    $self->_s5_dir . '/index.html';
}

method _slurp_pod {
    my $file = read_file($self->pod_filename);
    return $file;
}

has install_slides => ( isa => Bool, default => 0, is => 'ro' );
has in_browser => ( isa => Bool, default => 0, is => 'ro');
has browser => ( isa => Str, default => 'firefox', lazy => 1,
    predicate => 'has_browser', is => 'ro',
);

method run {
    $self->_do_install_slides if $self->install_slides;
    if ($self->has_browser || $self->in_browser) {
        exec($self->browser, $self->_slides_uri);
    }
    else {
        print $self->_slides_uri . "\n";
    }
}

method _do_install_slides {
    my $filename = $self->_html_filename;
    my $fh;
    open($fh, '>', $filename) or die;
    print $fh $self->_build_slides;
    close($fh);
    return $filename;
}

method _build_slides {
    my $dh = do { no strict 'refs'; \*{blessed($self)."::DATA"} }; # eww
    my $p = do { local $/; Load(<$dh>) }; # Slurpy
    my $s5 = Pod::S5->new(%$p);
    my $pod = $self->_slurp_pod;
    return $self->_change_location($s5->process($self->_slurp_pod));
}

method _slides_uri {
    my $filename = $self->_html_filename;
    return "file://$filename";
}

method _dist_name {
    my $dist = ref($self);
    $dist =~ s/::/-/g;
    return $dist;
}

method _s5_dir {
    dist_dir($self->_dist_name);
}

sub _change_location {
    my ($self, $text) = @_;
    my $s5_dir = $self->_s5_dir();
    $text =~ s#(href|src)="ui/#$1="file://$s5_dir/ui/#g;
    return $text;
}

__PACKAGE__->meta->make_immutable;
__PACKAGE__->new_with_options->run unless caller;
1;

__DATA__
---
theme: default
author: Tomas Doran
creation: 20090610
where: BCS
company: state51
name: Quanto - MySQLProxy query aggregator

