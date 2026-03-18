type impl = {
  init : unit -> unit;
  on_read_int : int -> unit;
  sleep : float -> unit;
  print_cell : bool -> unit;
  newline : unit -> unit;
  clear_screen : unit -> unit;
  cleanup : unit -> unit;
}

let gui_impl =
  {
    init = Ui_renderer_gui.init;
    on_read_int = Ui_renderer_gui.on_read_int;
    sleep = Ui_renderer_gui.sleep;
    print_cell = Ui_renderer_gui.print_cell;
    newline = Ui_renderer_gui.newline;
    clear_screen = Ui_renderer_gui.clear_screen;
    cleanup = Ui_renderer_gui.cleanup;
  }

let terminal_impl =
  {
    init = Ui_renderer_terminal.init;
    on_read_int = Ui_renderer_terminal.on_read_int;
    sleep = Ui_renderer_terminal.sleep;
    print_cell = Ui_renderer_terminal.print_cell;
    newline = Ui_renderer_terminal.newline;
    clear_screen = Ui_renderer_terminal.clear_screen;
    cleanup = Ui_renderer_terminal.cleanup;
  }

let current : impl ref = ref terminal_impl

let set_mode ~use_gui =
  current := if use_gui then gui_impl else terminal_impl;
  !current.init ()

let on_read_int input = !current.on_read_int input
let sleep seconds = !current.sleep seconds
let print_cell alive = !current.print_cell alive
let newline () = !current.newline ()
let clear_screen () = !current.clear_screen ()
let cleanup () = !current.cleanup ()
