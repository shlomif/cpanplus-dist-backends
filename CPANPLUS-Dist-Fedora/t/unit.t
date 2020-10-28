#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;

use CPANPLUS::Dist::Fedora ();
use CPANPLUS::Backend      ();

my $cpanb = CPANPLUS::Backend->new;
{
    my $obj = CPANPLUS::Dist::Fedora->new(
        module => $cpanb->module_tree('Acme::Gosub'), );

    # TEST
    is( $obj->_get_spec_perl_exe(), 'perl', "_get_spec_perl_exe()" );
}
