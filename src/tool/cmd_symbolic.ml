(* The `ono symbolic` command. *)

open Cmdliner
open Ono_cli

let info = Cmd.info "symbolic" ~exits

let contraint_cmd =
  let info = Arg.info [ "contraint" ] in
  Arg.value (Arg.opt Arg.int (-1) info)

let l =
  let info = Arg.info [ "height" ] in
  Arg.value (Arg.opt Arg.int 3 info)

let h =
  let info = Arg.info [ "width" ] in
  Arg.value (Arg.opt Arg.int 3 info)

let term =
  let open Term.Syntax in
  let+ () = setup_log
  and+ source_file = source_file
  and+ contrainte = contraint_cmd
  and+ largeur = l
  and+ hauteur = h in
  Ono.Symbolic_driver.run ~source_file ~contrainte ~largeur ~hauteur |> function
  | Ok () -> Ok ()
  | Error e -> Error (`Msg (Kdo.R.err_to_string e))

let cmd : Ono_cli.outcome Cmd.t = Cmd.v info term
