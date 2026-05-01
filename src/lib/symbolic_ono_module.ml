type extern_func = Kdo.Symbolic.Extern_func.extern_func

let numero_contrainte = ref 0

let print_i32 (n : Kdo.Symbolic.I32.t) : unit Kdo.Symbolic.Choice.t =
  Logs.app (fun m -> m "%a" Kdo.Symbolic.I32.pp n);
  Kdo.Symbolic.Choice.return ()

let mutation_factor () : Kdo.Symbolic.I32.t Kdo.Symbolic.Choice.t =
  let upperBound = 10000 in
  let random_int = Random.int upperBound in
  Kdo.Symbolic.Choice.return (Kdo.Symbolic.I32.of_int random_int)

let i32_symbol () : Kdo.Symbolic.I32.t Kdo.Symbolic.Choice.t =
  Kdo.Symbolic.Choice.with_new_symbol (Smtml.Ty.Ty_bitv 32)
    Kdo.Symbolic.I32.symbol

let sym_cell () : Kdo.Symbolic.I32.t Kdo.Symbolic.Choice.t =
  let open Kdo.Symbolic.Choice in
  let open Kdo.Symbolic.I32 in
  let* sym = with_new_symbol (Smtml.Ty.Ty_bitv 32) symbol in
  let* () = assume (le_u sym (of_int 1)) None in
  let* () = assume (ge_u sym (of_int 0)) None in
  return sym

let ask_for_a_value () : Kdo.Symbolic.I64.t Kdo.Symbolic.Choice.t =
  print_string "Entrez la valuer de a: ";
  let entry = read_int () in
  Kdo.Symbolic.Choice.return (Kdo.Symbolic.I32.of_int entry)

let ask_for_b_value () : Kdo.Symbolic.I32.t Kdo.Symbolic.Choice.t =
  print_string "Entrez la valuer de b: ";
  let entry = read_int () in
  Kdo.Symbolic.Choice.return (Kdo.Symbolic.I32.of_int entry)

let ask_for_c_value () : Kdo.Symbolic.I32.t Kdo.Symbolic.Choice.t =
  print_string "Entrez la valuer de c: ";
  let entry = read_int () in
  Kdo.Symbolic.Choice.return (Kdo.Symbolic.I32.of_int entry)

let ask_for_d_value () : Kdo.Symbolic.I32.t Kdo.Symbolic.Choice.t =
  print_string "Entrez la valuer de d: ";
  let entry = read_int () in
  Kdo.Symbolic.Choice.return (Kdo.Symbolic.I32.of_int entry)

let i64_symbol () : Kdo.Symbolic.I64.t Kdo.Symbolic.Choice.t =
  Kdo.Symbolic.Choice.with_new_symbol (Smtml.Ty.Ty_bitv 64)
    Kdo.Symbolic.I64.symbol

let get_num_contrainte () : Kdo.Symbolic.I32.t Kdo.Symbolic.Choice.t =
  if !numero_contrainte < 0 then
    failwith "Le numéro de contrainte doit être compris entre 0 et 10"
  else Kdo.Symbolic.Choice.return (Kdo.Symbolic.I32.of_int !numero_contrainte)

let m =
  let open Kdo.Symbolic.Extern_func in
  let open Kdo.Symbolic.Extern_func.Syntax in
  let functions =
    [
      ("print_i32", Extern_func (i32 ^->. unit, print_i32));
      ("i32_symbol", Extern_func (unit ^->. i32, i32_symbol));
      ("sym_cell", Extern_func (unit ^->. i32, sym_cell));
      ("mutation_factor", Extern_func (unit ^->. i32, mutation_factor));
      ("ask_for_a_value", Extern_func (unit ^->. i32, ask_for_a_value));
      ("ask_for_b_value", Extern_func (unit ^->. i32, ask_for_b_value));
      ("ask_for_c_value", Extern_func (unit ^->. i32, ask_for_c_value));
      ("ask_for_d_value", Extern_func (unit ^->. i32, ask_for_d_value));
      ("i64_symbol", Extern_func (unit ^->. i64, i64_symbol));
      ("get_num_contrainte", Extern_func (unit ^->. i32, get_num_contrainte));
    ]
  in
  {
    Kdo.Extern.Module.functions;
    func_type = Kdo.Symbolic.Extern_func.extern_type;
  }
