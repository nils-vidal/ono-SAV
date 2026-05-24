let buffer = Buffer.create 1024
let init () = Buffer.clear buffer
let on_read_int _ = ()
let sleep seconds = Unix.sleepf seconds

let print_cell alive = Buffer.add_string buffer (if alive then "🌸" else "☠️")

let newline () = Buffer.add_char buffer '\n'

let clear_screen () =
  print_string "\027[H\027[J\n";
  Buffer.output_buffer stdout buffer;
  flush stdout;
  Buffer.clear buffer

let cleanup () =
  Buffer.output_buffer stdout buffer;
  flush stdout;
  Buffer.clear buffer
