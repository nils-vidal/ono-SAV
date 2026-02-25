(* The `ono concrete` command. *)

open Cmdliner
open Ono_cli

let x =
  let info2 = Arg.info [ "seed" ] in
  Arg.value (Arg.opt Arg.int 0 info2)

let steps =
  let info3 = Arg.info [ "steps" ] in
  Arg.value (Arg.opt Arg.int 0 info3)

let info = Cmd.info "concrete" ~exits

let term =
  let open Term.Syntax in
  let+ () = setup_log and+ source_file = source_file and+ seed = x and+ steps = steps in
  Ono.Concrete_driver.run ~source_file ~seed ~steps |> function
  | Ok () -> Ok ()
  | Error e -> Error (`Msg (Kdo.R.err_to_string e))

let cmd : Ono_cli.outcome Cmd.t = Cmd.v info term
