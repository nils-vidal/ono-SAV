let read_int_call_count = ref 0
let init () = read_int_call_count := 0

let on_read_int input =
  let n = !read_int_call_count in
  read_int_call_count := n + 1;
  match n with
  | 0 -> Gui_renderer.grid_h := input
  | 1 ->
      Gui_renderer.grid_w := input;
      Gui_renderer.init_gui ()
  | _ -> ()

let sleep seconds =
  Gui_renderer.pump_events ();
  Gui_renderer.present ();
  Unix.sleepf seconds

let print_cell alive = Gui_renderer.print_cell alive
let newline () = Gui_renderer.newline ()
let clear_screen () = Gui_renderer.clear_screen ()
let cleanup () = Gui_renderer.cleanup ()
