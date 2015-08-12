set("log.file.path","liquidsoap.log")
set("server.telnet",true)

# fix meta
def fix_meta(m) =
  s = list.hd(
      get_process_lines(
          "./fix_meta.pl " ^ quote (m["filename"] ^"::"^ m["artist"] ^"::"^ m["title"]) ))
  s = string.split(separator='::', s)
  artist = list.nth(s, 0)
  title = list.nth(s, 1)
  [ ("title", title), ("artist", artist)]
end

# A function that show meta
def show_meta(s) =
  title = s["title"]
  artist = s["artist"]
  filename = s["filename"]
  
  print("title: " ^ title ^ " artist: " ^ artist ^ " filename:" ^ filename)
end

#s = mksafe(playlist("playlist.pls"))

s = request.queue(id="r")
s = mksafe(s)
s = audio_to_stereo(s)          # ensure stream is stereo
s = map_metadata(fix_meta, s)
s = on_metadata(show_meta, s)

output.file(%vorbis,"/dev/null", s)
#out(s)
