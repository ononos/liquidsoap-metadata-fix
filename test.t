#!/usr/bin/perl

use strict;
use warnings;

use Test::More qw( no_plan );
use Net::Telnet;
use Data::Dumper;

BEGIN { use_ok('Encode::Guess'); }

use constant LIQUIDSOAP => 'liquidsoap ./test.liq';

# spawn liquidsoap
my ( $pid, $liquidsoap_fh );
$pid = open( $liquidsoap_fh, LIQUIDSOAP . " |" );

ok( $pid, 'Start liquidsoap' );

if ( !$pid ) {
    die "Can't fork: $!";
}

sleep 1;

# connect with telnet to it
my $telnet = new Net::Telnet( Timeout => 10, Errmode => 'die', Port => 1234 );

$telnet->open(
    Host => 'localhost',
    Port => '1234'
);

my @files = (
    {
        file   => './music/Gary-Moore_-_Parisian-Walkways.mp3',
        artist => 'Гарри Мур',
        title  => 'Парижские тротуары',
        code   => 'cp1251'
    },
    {
        file   => './music/OTT_-_The-Queen-of-All-Everything.mp3',
        artist => 'OTT',
        title  => '02_Ott - The Queen of All Everything',
        code   => 'latin'
    },
    {
        file   => './music/combinatia.mp3',
        artist => 'a',
        title  => 't',
        code   => 'utf8'
    }
);

sub liquidsoap {
    my $cmd = shift;

    $telnet->print($cmd);
    return $telnet->waitfor(q'/END$/');
}

foreach my $it (@files) {
    my ( $filename, $expect_artist, $expect_title, $coding ) =
      ( $it->{file}, $it->{artist}, $it->{title}, $it->{code} );

    liquidsoap( "r.push " . $filename );

    sleep 1;

    my ( $output, $end ) = liquidsoap('/dev/null.metadata');

    my ( $artist, $title );

    foreach ( split /\n/, $output ) {
        if (m/artist="(.*)"/) {
            $artist = $1;
        }
        elsif (m/title="(.*)"/) {
            $title = $1;
        }
    }

    my $expected_tag = $expect_artist . ' ' . $expect_title;
    my $tag          = $artist . ' ' . $title;

    is( $tag, $expected_tag, qq{"meta encoded "${coding}" in "$filename"} );

    # clear queue
    liquidsoap('/dev/null.skip');
}

# stop liquidsoap
kill 9, $pid;
