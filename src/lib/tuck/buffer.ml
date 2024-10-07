open Wayland.Wayland_client

type data = (int32, Bigarray.int32_elt, Bigarray.c_layout) Bigarray.Array2.t
type t = ([ `V1 ] Wl_buffer.t) * data

