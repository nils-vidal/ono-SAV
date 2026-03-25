type extern_func = Kdo.Symbolic.Extern_func.extern_func

let print_i32 (n : Kdo.Symbolic.I32.t) : unit Kdo.Symbolic.Choice.t =
  print_endline "test de affiche\n";
  Logs.app (fun m -> m "%a" Kdo.Symbolic.I32.pp n);
  Kdo.Symbolic.Choice.return ()

let i32_symbol () : Kdo.Symbolic.I32.t Kdo.Symbolic.Choice.t =
  Kdo.Symbolic.Choice.with_new_symbol (Smtml.Ty.Ty_bitv 32)
    Kdo.Symbolic.I32.symbol

let ask_for_a_value () : Kdo.Symbolic.I64.t Kdo.Symbolic.Choice.t =
  print_string "Entrez la valuer de a: ";
  let entry = read_int () in
  Kdo.Symbolic.Choice.return (Kdo.Symbolic.I64.of_int entry)

let ask_for_b_value () : Kdo.Symbolic.I64.t Kdo.Symbolic.Choice.t =
  print_string "Entrez la valuer de b: ";
  let entry = read_int () in
  Kdo.Symbolic.Choice.return (Kdo.Symbolic.I64.of_int entry)

let ask_for_c_value () : Kdo.Symbolic.I64.t Kdo.Symbolic.Choice.t =
  print_string "Entrez la valuer de c: ";
  let entry = read_int () in
  Kdo.Symbolic.Choice.return (Kdo.Symbolic.I64.of_int entry)

let ask_for_d_value () : Kdo.Symbolic.I64.t Kdo.Symbolic.Choice.t =
  print_string "Entrez la valuer de d: ";
  let entry = read_int () in
  Kdo.Symbolic.Choice.return (Kdo.Symbolic.I64.of_int entry)

let i64_symbol () : Kdo.Symbolic.I64.t Kdo.Symbolic.Choice.t =
  Kdo.Symbolic.Choice.with_new_symbol (Smtml.Ty.Ty_bitv 64)
    Kdo.Symbolic.I64.symbol

let m =
  let open Kdo.Symbolic.Extern_func in
  let open Kdo.Symbolic.Extern_func.Syntax in
  let functions =
    [
      ("print_i32", Extern_func (i32 ^->. unit, print_i32));
      ("i32_symbol", Extern_func (unit ^->. i32, i32_symbol));
      ("ask_for_a_value", Extern_func (unit ^->. i64, ask_for_a_value));
      ("ask_for_b_value", Extern_func (unit ^->. i64, ask_for_b_value));
      ("ask_for_c_value", Extern_func (unit ^->. i64, ask_for_c_value));
      ("ask_for_d_value", Extern_func (unit ^->. i64, ask_for_d_value));
      ("i64_symbol", Extern_func (unit ^->. i64, i64_symbol));
    ]
  in
  {
    Kdo.Extern.Module.functions;
    func_type = Kdo.Symbolic.Extern_func.extern_type;
  }
