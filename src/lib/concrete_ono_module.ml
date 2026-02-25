type extern_func = Kdo.Concrete.Extern_func.extern_func

let step_number = ref 1

let read_step () : (Kdo.Concrete.I32.t, _) Result.t =
  Ok (Kdo.Concrete.I32.of_int !step_number)

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
  Unix.sleepf seconds_float;
  Ok ()

let print_cell (cell_id : Kdo.Concrete.I32.t) : (unit, _) Result.t =
  let alive = Kdo.Concrete.I32.to_int cell_id <> 0 in
  Printf.printf "%s%!" (if alive then "🌸" else "☠️");
  Unix.sleepf 0.00005;
  Ok ()

let newline () : (unit, _) Result.t =
  Printf.printf "\n%!";
  Ok ()

let clear_screen () : (unit, _) Result.t =
  Printf.printf "\027[H\027[J%!";
  Ok ()

let read_int () : (Kdo.Concrete.I64.t, _) Result.t =
  let input = read_int () in
  let i64 = Int64.of_int input in
  Ok (Kdo.Concrete.I64.of_int64 i64)

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
      ("read_int", Extern_func (unit ^->. i64, read_int));
      ("read_step", Extern_func (unit ^->. i32, read_step));
    ]
  in
  {
    Kdo.Extern.Module.functions;
    func_type = Kdo.Concrete.Extern_func.extern_type;
  }
