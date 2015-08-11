#!/usr/bin/env perl
use utf8;
use strict;
use Encode;
use Encode::Guess;

use open ':std', ':encoding(UTF-8)';

if (not @ARGV) {
    print
'USAGE:
  fix_meta.pl file "name::artist::title"
RETURN:
  artist::title

Add to your .liq file:
-------8<-------8<-----
def fix_meta(m) =
  s = list.hd(
      get_process_lines(
          "fix_meta.pl " ^ quote (m["filename"] ^"::"^ m["artist"] ^"::"^ m["title"]) ))
  s = string.split(separator=\'::\', s)
  artist = list.nth(s, 0)
  title = list.nth(s, 1)
  [ ("title", title), ("artist", artist)]
end

s = map_metadata(fix_meta, s)
------->8------->8-----
';
}

# Return (artist, title) base on input (file, artist, title)
# If no artist and no title than try return title from filename.
#
sub tag_encode {
    my ($filename, $a, $t) = @_;
    if ($a =~m/^\s*$/ &&
	$t =~m/^\s*$/) {

	$filename=~s|^(.*/)?(.*)|$2|s; # strip path
	$filename=~s|\.\w{1,4}$||; # strip file ext

	$filename = 'Unknown' if ($filename =~/^\s*$/);

        my ($f_artist, $f_title);

	if ($filename =~m/(.*?) [—-] (.*)/) {
	    ($f_artist, $f_title) = ($1, $2);
	} elsif (($f_artist, $f_title) = $filename =~m/(.*?)\s*-\s*(.*)/) {
	    ($f_artist, $f_title) = ($1, $2);
	} else {
            ($f_artist, $f_title) = ('', $filename);
        }
        return ($f_artist, $f_title);
    }

    $t = 'Unknown' if ($t =~/^\s*$/);

    # first try detect as JP or utf8
    my $decoder = guess_encoding("$a $t", qw/euc-jp shiftjis/);
    if (ref($decoder)) {
	($a, $t) = ($decoder->decode($a), $decoder->decode($t));
    } else {
	# force as cp1251 if not utf and not jp
	($a, $t) = (decode('cp1251', $a), decode('cp1251', $t));
    }
    # make sure title presented
    return ($a, $t);
}

my $arg = $ARGV[0];
chomp($arg);

# liquidsoap give meta in utf8. need latin1
Encode::from_to ($arg, "UTF-8", "iso-8859-1");

my ($filename, $artist, $title) = split('::', $arg);

($artist, $title) = tag_encode $filename, $artist, $title;

print  $artist . '::' . $title . "\n";
