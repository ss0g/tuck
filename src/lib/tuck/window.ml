open Wayland
open Wayland.Wayland_client

type t = {
    shm : [ `V1 ] Wl_shm.t;
    surface : [ `V4 ] Wl_surface.t;
    mutable width : int;
    mutable height : int;
}

let create ~tuck_env ?(width = 640) ?(height = 480) () =
    let shm = Registry.bind tuck_env#reg @@ object
        inherit [_] Wl_shm.v1
        method on_format _ ~format:_ = ()
    end in
    let surface = Wl_compositor.create_surface tuck_env#compositor @@ object
        inherit [_] Wl_surface.v1
        method on_enter _ ~output:_ = ()
        method on_leave _ ~output:_ = ()
        method on_preferred_buffer_scale _ ~factor:_ = ()
        method on_preferred_buffer_transform _ ~transform:_ = ()
    end in
    { shm; surface; width; height }
