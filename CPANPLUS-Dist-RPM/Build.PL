#!perl
#
# This file is part of CPANPLUS::Dist::Fedora.
# Copyright (c) 2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new (
    module_name         => 'CPANPLUS::Dist::RPM',
    dist_author         => 'Chris Weyl <cweyl@alumni.drew.edu>',
    license             => 'perl',
    add_to_cleanup => [
        'CPANPLUS-Dist-RPM-*', 'MANIFEST.bak',
        map { ( '*/' x $_ ) . '*~' } 0..5 ],
    script_files   => [ ],
    build_requires => {
        'Test::More'           => 0,
    },
    requires       => {
        'Cwd'                  => 0,
        'CPANPLUS'             => 0,
        'CPANPLUS::Dist::Base' => 0,
        'CPANPLUS::Error'      => 0,
        'File::Basename'       => 0,
        'File::Copy'           => 0,
        'IPC::Cmd'             => 0,
        'Pod::POM'             => 0,
        'Pod::POM::View::Text' => 0,
        'POSIX'                => 0,
        'Text::Wrap'           => 0,
        'Template'             => 0,
        'perl'                 => '5.008',
    },
    recommends     => {
        'Test::Pod'           => 0,
        'Test::Pod::Coverage' => 0,
    },
    create_makefile_pl => "traditional",
);

$builder->create_build_script();
