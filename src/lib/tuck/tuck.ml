module Buffer = Buffer

module type App = sig
    val main : Eio_unix.Stdenv.base -> unit
end

module Start_app (A : App) = struct
    let () = Eio_main.run A.main
end

