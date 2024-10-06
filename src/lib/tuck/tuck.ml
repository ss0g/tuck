open Eio.Std
open Wayland

module Buffer = Buffer
module Tuck_env = Tuck_env

module type App = sig
    val main : tuck_env:Tuck_env.t -> unit
end

(* TODO make this event-loop agnostic? *)
module Start_app (A : App) = struct
    let () =
        Eio_main.run @@ fun env ->
            Switch.run @@ fun sw ->
                let transport = Unix_transport.connect ~sw ~net:env#net () in
                let display = Client.connect ~sw transport in
                let reg = Registry.of_display display in
                let compositor =
                    Registry.bind reg (new Wayland_client.Wl_compositor.v4) in
                let tuck_env : Tuck_env.t = {
                    eio_env = env;
                    switch = sw;
                    reg;
                    compositor;
                } in
                A.main ~tuck_env
end

