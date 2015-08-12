use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => "Liquidsoap::Fixmeta",
    VERSION      => v1.1,
    AUTHOR       => 'Ononos',

    EXE_FILES => ['./fix_meta.pl'],

    PREREQ_PM => {
        'Encode::Guess' => 0,
    },

    "TEST_REQUIRES" => {
        'Net::Telnet' => '3.04',
    }
);
