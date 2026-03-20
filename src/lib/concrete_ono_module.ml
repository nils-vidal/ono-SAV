type extern_func = Kdo.Concrete.Extern_func.extern_func

let step_number = ref 0
let number_line_printed : int ref = ref 0
let path_to_file : string ref = ref ""
let data_from_file : int list ref = ref []
let index_of_data = ref 0
let x_of_data = ref 0
let y_of_data = ref 0

exception InternalError of string

let read_step () : (Kdo.Concrete.I32.t, _) Result.t =
  Ok (Kdo.Concrete.I32.of_int !step_number)

let read_number_line_to_print () : (Kdo.Concrete.I32.t, _) Result.t =
  Ok (Kdo.Concrete.I32.of_int !number_line_printed)

let print_i32 (n : Kdo.Concrete.I32.t) : (unit, _) Result.t =
  Logs.app (fun m -> m "%a" Kdo.Concrete.I32.pp n);
  Ok ()

let print_i64 (n : Kdo.Concrete.I64.t) : (unit, _) Result.t =
  Logs.app (fun m -> m "%a" Kdo.Concrete.I64.pp n);
  Ok ()

let random_i32 () : (Kdo.Concrete.I32.t, _) Result.t =
  let random_int = Random.int32 Int32.max_int in
  Ok (Kdo.Concrete.I32.of_int32 random_int)

let random_i32_bounded (upperBound : Kdo.Concrete.I32.t) :
    (Kdo.Concrete.I32.t, _) Result.t =
  let upperBound = Kdo.Concrete.I32.to_int upperBound |> Int32.of_int in
  let random_int = Random.int32 upperBound in
  Ok (Kdo.Concrete.I32.of_int32 random_int)

let sleep (seconds : Kdo.Concrete.F32.t) : (unit, _) Result.t =
  let seconds_float = Kdo.Concrete.F32.to_float seconds in
  Ui_renderer.sleep seconds_float;
  Ok ()

let print_cell (cell_id : Kdo.Concrete.I32.t) : (unit, _) Result.t =
  let alive = Kdo.Concrete.I32.to_int cell_id <> 0 in
  Ui_renderer.print_cell alive;
  Ok ()

let newline () : (unit, _) Result.t =
  Ui_renderer.newline ();
  Ok ()

let clear_screen () : (unit, _) Result.t =
  Ui_renderer.clear_screen ();
  Ok ()

let read_int () : (Kdo.Concrete.I32.t, _) Result.t =
  let input = read_int () in
  Ui_renderer.on_read_int input;
  Ok (Kdo.Concrete.I32.of_int input)

let init_needed () : (Kdo.Concrete.I32.t, _) Result.t =
  if !path_to_file = "" then Ok (Kdo.Concrete.I32.of_int 0)
    (* 0 si il n'y a rien a faire *)
  else Ok (Kdo.Concrete.I32.of_int 1)
(* 1 si on doit initialiser *)

let ask_for_width () : (unit, _) Result.t = 
  print_string "Entrez la largeur du plateau : "; 
  Ok () 

let ask_for_height () : (unit, _) Result.t = 
  print_string "Entrez la hauteur du plateau : "; 
  Ok ()

let init () : (unit, _) Result.t =
  if !path_to_file = "" then
    raise (InternalError "impossible d'initialiser, aucun chemin n'est précisé")
  else (*traitement de l'initialisation*)
    let file = open_in !path_to_file in
    try
      let first_line = input_line file in
      let x_y = String.split_on_char ',' first_line in
      let max_x = int_of_string (List.hd x_y) in
      x_of_data := max_x;
      y_of_data := int_of_string (List.nth x_y 1);

      for _x = 0 to max_x - 1 do
        let line = input_line file in
        for y = 0 to String.length line - 1 do
          data_from_file := !data_from_file @ [ int_of_char line.[y] - 48 ]
          (* on retire -48 à la valeur pour avoir le vrai numéro, pas son code ascii *)
        done
      done;

      close_in file;
      Ok ()
    with e -> raise (InternalError (Printexc.to_string e))

(*let load_file () : (Kdo.)*)
let load_next_point () : (Kdo.Concrete.I32.t * Kdo.Concrete.I32.t, _) Result.t =
  let open Kdo.Concrete.I32 in
  if !index_of_data >= List.length !data_from_file then
    Ok (of_int (-1), of_int 0)
  else
    let value = List.nth !data_from_file !index_of_data in
    let return = Ok (of_int !index_of_data, of_int value) in
    index_of_data := !index_of_data + 1;
    return

let get_dim () : (Kdo.Concrete.I32.t * Kdo.Concrete.I32.t, _) Result.t =
  let open Kdo.Concrete.I32 in
  Ok (of_int !x_of_data, of_int !y_of_data)

let m =
  let open Kdo.Concrete.Extern_func in
  let open Kdo.Concrete.Extern_func.Syntax in
  let functions =
    [
      ("print_i32", Extern_func (i32 ^->. unit, print_i32));
      ("print_i64", Extern_func (i64 ^->. unit, print_i64));
      ("random_i32", Extern_func (unit ^->. i32, random_i32));
      ("sleep", Extern_func (f32 ^->. unit, sleep));
      ("print_cell", Extern_func (i32 ^->. unit, print_cell));
      ("newline", Extern_func (unit ^->. unit, newline));
      ("clear_screen", Extern_func (unit ^->. unit, clear_screen));
      ("random_i32_bounded", Extern_func (i32 ^->. i32, random_i32_bounded));
      ("read_int", Extern_func (unit ^->. i32, read_int));
      ("read_step", Extern_func (unit ^->. i32, read_step));
      ( "read_number_line_to_print",
        Extern_func (unit ^->. i32, read_number_line_to_print) );
      ("init_needed", Extern_func (unit ^->. i32, init_needed));
      ("init", Extern_func (unit ^->. unit, init));
      ("load_next_point", Extern_func (unit ^->.. (i32, i32), load_next_point));
      ("get_dim", Extern_func (unit ^->.. (i32, i32), get_dim));
      ("ask_for_width", Extern_func (unit ^->. unit, ask_for_width));
      ("ask_for_height", Extern_func (unit ^->. unit, ask_for_height));
    ]
  in
  {
    Kdo.Extern.Module.functions;
    func_type = Kdo.Concrete.Extern_func.extern_type;
  }
