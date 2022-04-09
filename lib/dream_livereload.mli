(** Dream Live Reload implements live reloading for Dream applications.

    It works by injecting a script in the HTML pages sent to clients that will
    initiate a WebSocket.

    When the server restarts, the WebSocket connection is lost, at which point,
    the client will try to reconnect every 500ms for 5s. If within these 5s the
    client is able to reconnect to the server, it will trigger a reload of the
    page.*)

val default_script :
  ?retry_interval_ms:int -> ?max_retry_ms:int -> ?route:string -> unit -> string
(** Default live reloading script used if no custom script is provided.

    [retry_interval_ms] defaults to defaults to 500ms, [max_retry_ms] defaults
    to 10000ms and the default [route] is ["/_livereload"]. *)

val inject_script : ?script:string -> unit -> Dream.middleware
(** A middleware that injects the live reloading script in an HTML document. *)

val route : ?path:string -> unit -> Dream.route
(** The route for the live reloading endpoint.

    [path] defaults to ["/_livereload"]. Make sure this is the same as the
    endpoint of the WebSocket if you provided a custom script to
    [inject_script]. *)

val router : Dream.handler
(** A Dream router that contains [route]. *)

val scope : string -> Dream.middleware list -> Dream.route
(** Helper function to scope the live reloading routes with a prefix and a list
    of middlewares. *)
