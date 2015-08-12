#!/usr/bin/env perl
use utf8;
use strict;
use Encode;
use Encode::Guess;
use charnames ':full';

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

sub is_sane_utf8($;$)
{
  my $string = shift;

  my $re_bit = join "|", map { Encode::encode("utf8",chr($_)) } (127..255);

  # regexp in scalar context with 'g', meaning this loop will run for
  # each match.  Should only have to run it once, but will redo if
  # the failing case turns out to be allowed in %allowed.
  while ($string =~ /($re_bit)/o)
  {
    # work out what the double encoded string was
    my $bytes = $1;

    my $index = $+[0] - length($bytes);
    my $codes = join '', map { sprintf '<%00x>', ord($_) } split //, $bytes;

    # what character does that represent?
    my $char = Encode::decode("utf8",$bytes);
    my $ord  = ord($char);
    my $hex  = sprintf '%00x', $ord;
    $char = charnames::viacode($ord);

    return 0;
  }

  return 1;
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

my ($filename, $artist, $title) = split('::', $arg);

# liquidsoap give meta in utf8. need latin1
unless (is_sane_utf8(qq{$artist $title})) {
    Encode::from_to ($artist, "UTF-8", "iso-8859-1");
    Encode::from_to ($title, "UTF-8", "iso-8859-1");
}
#Encode::from_to ($arg, "UTF-8", "iso-8859-1");

($artist, $title) = tag_encode $filename, $artist, $title;

print  $artist . '::' . $title . "\n";
