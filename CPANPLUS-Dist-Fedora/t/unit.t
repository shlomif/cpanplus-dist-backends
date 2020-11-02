#!/usr/bin/env perl

use strict;
use warnings;
use Carp::Always;
use Test::More tests => 4;

use CPANPLUS::Configure;
use CPANPLUS::Backend;
use CPANPLUS::Dist;
use CPANPLUS::Dist::MM;
use CPANPLUS::Internals::Constants;
use Data::Dumper;
use CPANPLUS::Error;
use CPANPLUS::Internals::Constants;
use Cwd;
use Config;
use Data::Dumper;
use File::Basename ();
use File::Spec     ();

# use CPANPLUS::Dist::Fedora ();
use CPANPLUS::Dist::Base ();
use CPANPLUS::Backend    ();

$ENV{'PERL_MM_USE_DEFAULT'} = 1;
my $cpanb   = CPANPLUS::Backend->new or die;
my $cb      = $cpanb;
my $ModName = "Acme::Gosub";
my $mt      = $cb->module_tree;
my $at      = $cb->author_tree;
my $conf    = $cpanb->configure_object();

$cb->_callbacks->send_test_report( sub { 0 } );
$conf->set_conf( cpantest                  => 0 );
$conf->set_conf( allow_build_interactivity => 0 );
my $Mod = $cb->module_tree($ModName);

# TEST
ok( scalar keys %$mt, "Module tree has entries" );

# TEST
ok( scalar keys %$at, "Author tree has entries" );
my %formats  = map { $_ => $_ } CPANPLUS::Dist->dist_types;
my $conf_obj = $cpanb->configure_object;
ok( IS_CONFOBJ->( conf => $conf_obj ), "Configure object found" );
$conf->set_conf( dist_type => 'CPANPLUS::Dist::Base' );
my $opts = {};
$cpanb->reload_indices() if $opts->{'flushcache'};
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

    # my $obj = CPANPLUS::Dist::Fedora->new( module => $mod, );
    my $obj = CPANPLUS::Dist::Base->new( module => $mod, );
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
    # is( $obj->_get_spec_perl_exe(), 'perl', "_get_spec_perl_exe()" );

    # $obj->init();
    # $obj->parent->status( $obj->status );
    # $obj->create();
    $obj->prepare();

    my $target = 'create';

    # TEST
    {
        local $CPANPLUS::Dist::Fedora::_testme = 1;
        like(
            do
            {
                # eval {
                {
                    $obj->create(
                        prereq_target => $target,
                        target        => $target,
                    );
                };
                $@->{text};
            },
            qr#^BuildRequires:\s*perl\(Carp\)$#ms,
            "BuildRequires",
        );
    }
}
