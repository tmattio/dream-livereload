(** Main entry point for our application. *)

let () =
  Dream.run ~error_handler:Dream.debug_error_handler
  @@ Dream.logger
  @@ Dream_livereload.inject_script ()
  @@ Dream.router
       [
         Dream.get "/" (fun _ -> Dream.html "Hello World!");
         Dream_livereload.route ();
       ]
