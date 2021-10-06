#!/usr/bin/env perl

# Parts of this file have been copy+pasted+changed from the testsuite
# of https://metacpan.org/pod/CPANPLUS and from cpan2dist - thanks!

use strict;
use warnings;

use Test::More;

if ( not( $ENV{'TEST_CPANPLUS_FEDORA'} ) )
{
    plan skip_all => "TEST_CPANPLUS_FEDORA is not set. Skipping.";
}
else
{
    plan tests => 13;
}

use CPANPLUS::Backend      ();
use CPANPLUS::Dist::Fedora ();

$ENV{'PERL_MM_USE_DEFAULT'} = 1;
my $cpanb    = CPANPLUS::Backend->new or die;
my $ModName  = "Acme::Gosub";
my $conf_obj = $cpanb->configure_object();

$cpanb->_callbacks->send_test_report( sub { 0 } );
$conf_obj->set_conf( cpantest                  => 0 );
$conf_obj->set_conf( allow_build_interactivity => 0 );
my $mod = $cpanb->module_tree($ModName);

# TEST
ok( $mod, "Loaded object for: " . $mod->name );

# TEST
ok(
    CPANPLUS::Dist::Fedora->format_available,
    "CPANPLUS::Dist::Fedora Format is available"
);

$conf_obj->set_conf( dist_type => 'CPANPLUS::Dist::Fedora' );
{
    # TEST
    ok( $mod->fetch, "Fetching module to " . $mod->status->fetch );

    # TEST
    ok( $mod->extract, "Extracting module to " . $mod->status->extract );

    my $needed_preparation_for_obj_prepare = sub {
        my $TARGET_INIT = 'init';
        my $dist        = $mod->dist( target => $TARGET_INIT );

        # TEST
        ok( $dist, "Dist created with target => " . $TARGET_INIT );

        # TEST
        ok( !$dist->status->prepared, "   Prepare was not run" );
    };

    $needed_preparation_for_obj_prepare->();

    my $obj = CPANPLUS::Dist::Fedora->new( module => $mod, );

    die "\$obj module is falsey" if not $mod;

    # TEST
    is( $obj->_get_spec_perl_exe(), 'perl', "_get_spec_perl_exe()" );

    my $spec_text = do
    {
        local $CPANPLUS::Dist::Fedora::_testme = 1;
        eval { $obj->prepare(); };
        my $Err = $@;
        ref($Err) ? $Err->{text} : $Err;
    };

    # TEST
    like( $spec_text, qr#^BuildRequires:\s*perl\(Carp\)$#ms, "BuildRequires", );

    # TEST
    like( $spec_text, qr#\n\n%build\nperl Makefile\.PL#ms, "spec", );

    # TEST
    unlike( $spec_text, qr#^%buildperl#ms, "buildperl absence in spec", );

    # TEST
    like( $spec_text, qr#\n\n%install\n%\{make_install\}\n#ms, "install", );

    # TEST
    like( $spec_text, qr#\n\n%files\n%doc #ms, "files", );

    # TEST
    like( $spec_text, qr#^Source:\s+https://cpan\.metacpan\.org/authors/id/#ms,
        "metacpan", );
}
