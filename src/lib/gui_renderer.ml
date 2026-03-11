open Tsdl

let cell_size = 16
let window = ref None
let renderer = ref None
let grid_w = ref 40
let grid_h = ref 30
let cursor_col = ref 0
let cursor_row = ref 0

let sdl_check = function
  | Error (`Msg e) -> failwith (Printf.sprintf "SDL error: %s" e)
  | Ok v -> v

let init_gui () =
  sdl_check (Sdl.init Sdl.Init.video);
  let w = !grid_w * cell_size in
  let h = !grid_h * cell_size in
  let win =
    sdl_check (Sdl.create_window ~w ~h "Game of Life" Sdl.Window.shown)
  in
  let ren =
    sdl_check
      (Sdl.create_renderer ~flags:Sdl.Renderer.(accelerated + presentvsync) win)
  in
  window := Some win;
  renderer := Some ren

let ensure_init () = match !renderer with Some _ -> () | None -> init_gui ()

let get_renderer () =
  ensure_init ();
  match !renderer with
  | Some r -> r
  | None -> failwith "SDL renderer not initialized"

let clear_screen () =
  let r = get_renderer () in
  sdl_check (Sdl.set_render_draw_color r 0 0 0 255);
  sdl_check (Sdl.render_clear r);
  cursor_col := 0;
  cursor_row := 0

let print_cell alive =
  let r = get_renderer () in
  if alive then sdl_check (Sdl.set_render_draw_color r 255 183 197 255)
    (* pink for alive *)
  else sdl_check (Sdl.set_render_draw_color r 30 30 30 255);
  (* dark for dead *)
  let rect =
    Sdl.Rect.create ~x:(!cursor_col * cell_size) ~y:(!cursor_row * cell_size)
      ~w:cell_size ~h:cell_size
  in
  sdl_check (Sdl.render_fill_rect r (Some rect));
  cursor_col := !cursor_col + 1

let newline () =
  cursor_col := 0;
  cursor_row := !cursor_row + 1

let present () =
  let r = get_renderer () in
  Sdl.render_present r;
  cursor_col := 0;
  cursor_row := 0

let pump_events () =
  let e = Sdl.Event.create () in
  while Sdl.poll_event (Some e) do
    if Sdl.Event.(get e typ = quit) then (
      (match !renderer with Some r -> Sdl.destroy_renderer r | None -> ());
      (match !window with Some w -> Sdl.destroy_window w | None -> ());
      Sdl.quit ();
      exit 0)
  done

let cleanup () =
  (match !renderer with Some r -> Sdl.destroy_renderer r | None -> ());
  (match !window with Some w -> Sdl.destroy_window w | None -> ());
  Sdl.quit ()
