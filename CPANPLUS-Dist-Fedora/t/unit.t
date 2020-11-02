#!/usr/bin/env perl

use strict;
use warnings;
use Carp::Always;
use Test::More tests => 9;

use CPANPLUS::Backend;
use CPANPLUS::Dist::Fedora;
use CPANPLUS::Internals::Constants;

use CPANPLUS::Backend ();

$ENV{'PERL_MM_USE_DEFAULT'} = 1;
my $cpanb   = CPANPLUS::Backend->new or die;
my $ModName = "Acme::Gosub";
my $conf    = $cpanb->configure_object();

$cpanb->_callbacks->send_test_report( sub { 0 } );
$conf->set_conf( cpantest                  => 0 );
$conf->set_conf( allow_build_interactivity => 0 );
my $Mod = $cpanb->module_tree($ModName);

# TEST
ok( $Mod, "Loaded object for: " . $Mod->name );

# TEST
ok(
    CPANPLUS::Dist::Fedora->format_available,
    "CPANPLUS::Dist::Fedora Format is available"
);

my $conf_obj = $cpanb->configure_object;

# TEST
ok( IS_CONFOBJ->( conf => $conf_obj ), "Configure object found" );
$conf->set_conf( dist_type => 'CPANPLUS::Dist::Fedora' );
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
        $conf->set_conf( $key => $val );
    }
}
{
    my $set_prog = $opts->{'set-program'} || {};
    while ( my ( $key, $val ) = each %$set_prog )
    {
        $conf->set_program( $key => $val );
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
            : $conf->get_conf($val);
        $conf->set_conf( $val => $bool );
    }
}
{
    #my $mod = $cpanb->parse_module( module => 'Acme::Gosub' );
    my $mod = $Mod;
    die if not $mod;

    # TEST
    ok( $Mod->fetch, "Fetching module to " . $Mod->status->fetch );

    # TEST
    ok( $Mod->extract, "Extracting module to " . $Mod->status->extract );
    {
        my $dist = $Mod->dist( target => TARGET_INIT );

        # TEST
        ok( $dist, "Dist created with target => " . TARGET_INIT );

        # TEST
        ok( !$dist->status->prepared, "   Prepare was not run" );
    }

    my $obj = CPANPLUS::Dist::Fedora->new( module => $mod, );

    die "\$obj module is falsey" if not $mod;

    # my $obj = $mod->status->dist;

    # $obj->create();
    # die if not $obj->parent;
    # die if not $obj->status;
    # die if not $obj->status->dist;
    # die if not $obj->status->dist_cpan;

    # $obj->parent->status( $obj->status );

    # $obj->status->create();

    # TEST
    is( $obj->_get_spec_perl_exe(), 'perl', "_get_spec_perl_exe()" );

    # $obj->init();
    # $obj->parent->status( $obj->status );
    # TEST
    {
        local $CPANPLUS::Dist::Fedora::_testme = 1;
        like(
            do
            {
                eval { $obj->prepare(); };
                my $Err = $@;
                ref($Err) ? $Err->{text} : $Err;
            },
            qr#^BuildRequires:\s*perl\(Carp\)$#ms,
            "BuildRequires",
        );
    }
}
