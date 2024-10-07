open Eio.Std
open Wayland
open Wayland.Wayland_client
open Wayland_protocols.Xdg_shell_client

type t = {
    shm : [ `V1 ] Wl_shm.t;
    surface : [ `V4 ] Wl_surface.t;
    mutable width : int;
    mutable height : int;
}

let create ~(tuck_env:Tuck_env.t) ?(width = 640) ?(height = 480) () =
    let shm = Registry.bind tuck_env.reg @@ object
        inherit [_] Wl_shm.v1
        method on_format _ ~format:_ = ()
    end in
    let surface = Wl_compositor.create_surface tuck_env.compositor @@ object
        inherit [_] Wl_surface.v1
        method on_enter _ ~output:_ = ()
        method on_leave _ ~output:_ = ()
        method on_preferred_buffer_scale _ ~factor:_ = ()
        method on_preferred_buffer_transform _ ~transform:_ = ()
    end in
    { shm; surface; width; height }

let configure ~(tuck_env:Tuck_env.t) t ?(title = "Window") () =
    let configured, set_configured = Promise.create () in
    let xdg_surface = Xdg_wm_base.get_xdg_surface
    tuck_env.xdg_wm_base
    ~surface:t.surface
    @@ object
        inherit [_] Xdg_surface.v1
        method on_configure proxy ~serial =
            Xdg_surface.ack_configure proxy ~serial;
            if not (Promise.is_resolved configured) then
                Promise.resolve set_configured ()
    end in
    let toplevel = Xdg_surface.get_toplevel xdg_surface @@ object
        inherit [_] Xdg_toplevel.v1
        method on_configure_bounds _ ~width:_ ~height:_ = ()
        method on_configure _ ~width ~height ~states:_ =
            t.width <- if width = 0l then 640 else Int32.to_int width;
            t.height <- if height = 0l then 480 else Int32.to_int height;
        method on_close _ =
            Logs.info (fun f -> f "Window closed - exiting!");
            (* Client.stop client *)
        method on_wm_capabilities _ ~capabilities:_ = ()
    end in
    Xdg_toplevel.set_title toplevel ~title;
    Wl_surface.commit t.surface;
    Promise.await configured

let get_buffer t : Tuck.Buffer.t =
    let size = t.width * t.height in
    let pool, data = Shm.with_memory_fd ~size (fun fd ->
        let pool = Wl_shm.create_pool t.shm (new Wl_shm_pool.v1) ~fd ~size:(Int32.of_int size) in
        let ba = Unix.map_file fd Bigarray.Int32 Bigarray.c_layout true [| t.height; t.width |] in
        pool, Bigarray.array2_of_genarray ba
    ) in
    let buffer = Wl_shm_pool.create_buffer pool
    ~offset:0l
    ~width:(Int32.of_int t.width)
    ~height:(Int32.of_int t.height)
    ~stride:(Int32.of_int t.width)
    ~format:Wl_shm.Format.Xrgb8888
    @@ object
        inherit [_] Wl_buffer.v1
        method on_release = Wl_buffer.destroy
    end in
    (buffer, data)
