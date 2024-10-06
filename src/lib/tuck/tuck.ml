open Eio.Std

module Buffer = Buffer

module type App = sig
    val main : Eio_unix.Stdenv.base -> Eio.Switch.t -> unit
end

(* TODO make this event-loop agnostic? *)
module Start_app (A : App) = struct
    let () = Eio_main.run @@ fun env -> Switch.run @@ fun sw -> A.main env sw
end

