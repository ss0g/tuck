module App_test : Tuck.App = struct
    let main ~tuck_env:_ =
        print_endline "Hello world!"
end

let () =
    Logs.set_reporter (Logs_fmt.reporter ());
    Logs.set_level (Some Info);
    Printexc.record_backtrace true;

    module _ = Tuck.Start_app(App_test)
