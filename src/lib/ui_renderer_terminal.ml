let init () = ()
let on_read_int _ = ()
let sleep seconds = Unix.sleepf seconds

let print_cell alive =
  Printf.printf "%s%!" (if alive then "🌸" else "☠️");
  Unix.sleepf 0.00005

let newline () = Printf.printf "\n%!"
let clear_screen () = Printf.printf "\027[H\027[J%!"
let cleanup () = ()
