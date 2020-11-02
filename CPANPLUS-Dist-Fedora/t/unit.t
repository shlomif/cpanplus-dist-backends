#!/usr/bin/env perl

use strict;
use warnings;
use Carp::Always;
use Test::More tests => 9;

use CPANPLUS::Backend      ();
use CPANPLUS::Dist::Fedora ();
use CPANPLUS::Internals::Constants;

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

# TEST
ok( IS_CONFOBJ->( conf => $conf_obj ), "Configure object found" );
$conf_obj->set_conf( dist_type => 'CPANPLUS::Dist::Fedora' );
my $opts = {};
$cpanb->reload_indices() if $opts->{'flushcache'};

if (0)
{
    ok( $cpanb->reload_indices( 0 ? ( update_source => 0, ) : (), ),
        "Rebuilding trees" );
}
{
    my $set_conf = $opts->{'set-config'} || {};
    while ( my ( $key, $val ) = each %$set_conf )
    {
        $conf_obj->set_conf( $key => $val );
    }
}
{
    my $set_prog = $opts->{'set-program'} || {};
    while ( my ( $key, $val ) = each %$set_prog )
    {
        $conf_obj->set_program( $key => $val );
    }
}
{
    my %map = (
        verbose  => 'verbose',
        force    => 'force',
        skiptest => 'skiptest',
        makefile => 'prefer_makefile'
    );

    ### set config options from arguments
    while ( my ( $key, $val ) = each %map )
    {
        my $bool =
            exists $opts->{$key}
            ? $opts->{$key}
            : $conf_obj->get_conf($val);
        $conf_obj->set_conf( $val => $bool );
    }
}
{
    # TEST
    ok( $mod->fetch, "Fetching module to " . $mod->status->fetch );

    # TEST
    ok( $mod->extract, "Extracting module to " . $mod->status->extract );
    {
        my $dist = $mod->dist( target => TARGET_INIT );

        # TEST
        ok( $dist, "Dist created with target => " . TARGET_INIT );

        # TEST
        ok( !$dist->status->prepared, "   Prepare was not run" );
    }

    my $obj = CPANPLUS::Dist::Fedora->new( module => $mod, );

    die "\$obj module is falsey" if not $mod;

    # TEST
    is( $obj->_get_spec_perl_exe(), 'perl', "_get_spec_perl_exe()" );

    # TEST
    like(
        do
        {
            local $CPANPLUS::Dist::Fedora::_testme = 1;
            eval { $obj->prepare(); };
            my $Err = $@;
            ref($Err) ? $Err->{text} : $Err;
        },
        qr#^BuildRequires:\s*perl\(Carp\)$#ms,
        "BuildRequires",
    );
}
