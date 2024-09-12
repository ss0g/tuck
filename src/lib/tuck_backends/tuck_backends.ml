(* TODO: what does a backend need to do and have? *)
module type backend = sig
    val accept_frame : Tuck.Buffer.t -> unit
end

(* TODO: constrain to backend type when ready *)
module Wayland = Tuck_wayland
