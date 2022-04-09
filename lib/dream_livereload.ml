let default_script ?(retry_interval_ms = 500) ?(max_retry_ms = 10000)
    ?(route = "/_livereload") () =
  Printf.sprintf
    {js|
var socketUrl = "ws://" + location.host + "%s"
var s = new WebSocket(socketUrl);

s.onopen = function(even) {
  console.log("WebSocket connection open.");
};

s.onclose = function(even) {
  console.log("WebSocket connection closed.");
  const innerMs = %i;
  const maxMs = %i;
  const maxAttempts = Math.round(maxMs / innerMs);
  let attempts = 0;
  function reload() {
    attempts++;
    if(attempts > maxAttempts) {
      console.error("Could not reconnect to dev server.");
      return;
    }

    s2 = new WebSocket(socketUrl);

    s2.onerror = function(event) {
      setTimeout(reload, innerMs);
    };

    s2.onopen = function(event) {
      location.reload();
    };
  };
  reload();
};

s.onerror = function(event) {
  console.error("WebSocket error observed:", event);
};
|js}
    route retry_interval_ms max_retry_ms

let inject_script ?(script = default_script ()) ()
    (next_handler : Dream.request -> Dream.response Lwt.t)
    (request : Dream.request) : Dream.response Lwt.t =
  let%lwt response = next_handler request in
  match Dream.header response "Content-Type" with
  | Some "text/html" | Some "text/html; charset=utf-8" -> (
      let%lwt body = Dream.body response in
      let soup =
        Markup.string body
        |> Markup.parse_html ~context:`Document
        |> Markup.signals |> Soup.from_signals
      in
      let open Soup.Infix in
      match soup $? "head" with
      | None -> Lwt.return response
      | Some head ->
          Soup.create_element "script" ~inner_text:script
          |> Soup.append_child head;
          Dream.set_body response (Soup.to_string soup);
          Lwt.return response)
  | _ -> Lwt.return response

let route ?(path = "/_livereload") () =
  Dream.get path (fun _ ->
      Dream.websocket (fun socket ->
          Lwt.bind (Dream.receive socket) (fun _ ->
              Dream.close_websocket socket)))

let router = Dream.router [ route () ]
let scope prefix middlewares = Dream.scope prefix middlewares [ route () ]
