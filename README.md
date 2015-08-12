# Metadata fixer for liquidsoap

[![Build Status][travis-image]][travis-url]

Audio metadata encode.
Support cp1251, utf8, euc-jp shiftjis.
If no metadata - generate from filename



Install fix_meta.pl

```shell
git clone https://github.com/ononos/liquidsoap-metadata-fix && cd liquidsoap-metadata-fix
curl -L https://cpanmin.us | perl - --sudo App::cpanminus
sudo cpanm -v -i .
```

Or just copy script `fix_meta.pl` to your path

Add to your liquidsoap config:

```
def fix_meta(m) =
  s = list.hd(
      get_process_lines(
          "fix_meta.pl " ^ quote (m["filename"] ^"::"^ m["artist"] ^"::"^ m["title"]) ))
  s = string.split(separator='::', s)
  artist = list.nth(s, 0)
  title = list.nth(s, 1)
  [ ("title", title), ("artist", artist)]
end

# map metadata
stream = map_metadata(fix_meta, stream)
```

[travis-url]: https://travis-ci.org/ononos/liquidsoap-metadata-fix
[travis-image]: http://img.shields.io/travis/ononos/liquidsoap-metadata-fix
