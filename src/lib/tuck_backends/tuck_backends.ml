(* TODO: what does a backend need to do and have? *)
module type backend = sig
    val accept_frame : Tuck.Buffer.t -> unit
    val rebuild_zone : int -> int -> Tuck.Buffer.t -> unit (* might only work with wayland? *)
end

(* TODO: constrain to backend type when ready *)
module Wayland : backend = Tuck_wayland
