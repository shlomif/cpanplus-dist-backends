#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 2;

# use CPANPLUS::Dist::Fedora ();
use CPANPLUS::Dist::Base ();
use CPANPLUS::Backend      ();

$ENV{'PERL_MM_USE_DEFAULT'} = 1;
my $cpanb   = CPANPLUS::Backend->new or die;
my %formats = map { $_ => $_ } CPANPLUS::Dist->dist_types;
my $conf    = $cpanb->configure_object();
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
    my $mod = $cpanb->parse_module( module => 'Acme::Gosub' );
    die if not $mod;
    # my $obj = CPANPLUS::Dist::Fedora->new( module => $mod, );
    my $obj = CPANPLUS::Dist::Base->new( module => $mod, );
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
