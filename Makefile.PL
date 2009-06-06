use inc::Module::Install 0.78;

author 'Tomas Doran (t0m) <bobtfish@bobtfish.net>';
name 'Presentation-Quanto_PerlLuaJQuery_MySQLStats';
all_from('lib/Presentation/Quanto-PerlLuaJQuery_MySQLStats.pm');
license 'perl';

requires 'YAML';
requires 'namespace::autoclean';
requires 'Method::Signatures::Simple';
requires 'File::Slurp';
requires 'Moose';
requires 'MooseX::Types';
requires 'MooseX::Getopt';
requires 'Pod::S5' => '0.08';
requires 'Syntax::Highlight::Engine::Kate' => '0.04';
requires 'File::ShareDir' => '1.00';

install_share 'share';

auto_install;

postamble(<<EOF);
install ::
\t/usr/bin/env perl lib/Presentation/Quanto-PerlLuaJQuery_MySQLStats.pm --install_slides
EOF

if ($Module::Install::AUTHOR) {
    darwin_check_no_resource_forks();
}

WriteAll();

sub darwin_check_no_resource_forks {
    if ($^O eq 'darwin') {
        my $osx_ver = `/usr/bin/sw_vers -productVersion`;
        chomp $osx_ver;

        # TAR on 10.4 wants COPY_EXTENDED_ATTRIBUTES_DISABLE
        # On 10.5 (Leopard) it wants COPYFILE_DISABLE
        my $attr = $osx_ver eq '10.5' ? 'COPYFILE_DISABLE' : 'COPY_EXTENDED_ATTRIBUTES_DISABLE';

        makemaker_args(dist => { PREOP => qq{\@if [ "\$\$$attr" != "true" ]; then}.
                                          qq{ echo "You must set the ENV variable $attr to true,"; }.
                                          ' echo "to avoid getting resource forks in your dist."; exit 255; fi' });
        }
}

