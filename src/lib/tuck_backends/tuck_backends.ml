module type backend = sig
    val temp : 'a
end

(* TODO: constrain to backend type when ready *)
module Wayland = Tuck_wayland

