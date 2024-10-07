open Eio.Std
open Wayland
open Wayland_protocols.Xdg_shell_client

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
                    Registry.bind reg (new Wayland_client.Wl_compositor.v4)
                in
                let xdg_wm_base = Registry.bind reg @@ object
                    inherit [_] Xdg_wm_base.v1
                    method on_ping = Xdg_wm_base.pong
                end in
                let tuck_env : Tuck_env.t = {
                    eio_env = env;
                    switch = sw;
                    reg;
                    compositor;
                    xdg_wm_base;
                } in
                A.main ~tuck_env
end

