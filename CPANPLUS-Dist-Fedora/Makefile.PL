#!perl
#
# This file is part of CPANPLUS::Dist::Fedora.
# Copyright (c) 2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

BEGIN { require 5.008; }
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'CPANPLUS::Dist::Fedora',
    AUTHOR              => 'Shlomi Fish <shlomif@cpan.org>',
    VERSION_FROM        => 'lib/CPANPLUS/Dist/Fedora.pm',
    ABSTRACT_FROM       => 'lib/CPANPLUS/Dist/Fedora.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'CPANPLUS'             => 0,
        'File::Slurp'          => 0,
        'IPC::Cmd'             => 0,
        'Pod::POM'             => 0,
        'Pod::POM::View::Text' => 0,
        'POSIX'                => 0,
        'Readonly'             => 0,
        'Test::More'           => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => [
                'CPANPLUS-Dist-Fedora-*', 'MANIFEST.bak',
                map { ( '*/' x $_ ) . '*~' } 0..5
        ] },
);
