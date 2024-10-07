open Eio.Std
open Wayland

type t = {
    eio_env : Eio_unix.Stdenv.base;
    switch : Switch.t;
    reg : Registry.t;
    compositor : (Wayland_proto.Wl_compositor.t, [ `V4 ], [ `Client ]) Proxy.t;
    xdg_wm_base :
        (Wayland_protocols.Xdg_shell_proto.Xdg_wm_base.t,
        [ `V1 ],
        [ `Client ]) Proxy.t;
}
