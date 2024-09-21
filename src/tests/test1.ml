let () =
    Logs.set_reporter (Logs_fmt.reporter ());
    Logs.set_level (Some Info);
    Printexc.record_backtrace true;
    Eio_main.run @@ fun env ->
        Tuck.App.main ~net:env#net

