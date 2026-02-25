(* The `ono concrete` command. *)

open Cmdliner
open Ono_cli

let seed_term =
  let info = Arg.info [ "seed" ] in
  Arg.value (Arg.opt Arg.int 0 info)

let steps =
  let info = Arg.info [ "steps" ] in
  Arg.value (Arg.opt Arg.int 0 info)

let max_printed = 
  let info = Arg.info [ "n_printed" ] in
  Arg.value (Arg.opt Arg.int 0 info)

let info = Cmd.info "concrete" ~exits

let term =
  let open Term.Syntax in
  let+ () = setup_log
  and+ source_file = source_file
  and+ seed = seed_term
  and+ steps = steps
  and+ m_print = max_printed in
  Ono.Concrete_driver.run ~source_file ~seed ~steps ~m_print |> function
  | Ok () -> Ok ()
  | Error e -> Error (`Msg (Kdo.R.err_to_string e))

let cmd : Ono_cli.outcome Cmd.t = Cmd.v info term
