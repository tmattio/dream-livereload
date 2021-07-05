# Dream Live Reload

[![Actions Status](https://github.com/tmattio/dream-livereload/workflows/CI/badge.svg)](https://github.com/tmattio/dream-livereload/actions)

Live reloading for Dream applications.

## Usage

Add the `Dream_livereload` middleware and route to your [Dream](https://github.com/aantron/dream) application:

```ocaml
let () =
  Dream.run
  @@ Dream.logger
  @@ Dream_livereload.inject_script ()    (* <-- *)
  @@ Dream.router [
    Dream.get "/" (fun _ -> Dream.html "Hello World!");
    Dream_livereload.route ();            (* <-- *)
  ]
  @@ Dream.not_found
```

and `dream-livereload` to `dune`:

<pre><code>(executable
 (name my_app)
 (libraries dream <b>dream-livereload</b>))
</code></pre>

This does two things:

1. The middleware injects a script into the HTML documents sent by your application (HTTP responses with the `Content-Type: text/html`). The script opens a WebSocket connection to the server. When the connection is lost, the script tries to re-connect for 10 seconds, and upon a successfull re-connection, refreshes the current page.
2. The route is the HTTP endpoint used for the WebSocket connection. It does nothing but hold open the WebSocket connection.

This allows automating part of your workflow: when you rebuild your project and start a new instance of your server, the client will automatically detect it and refresh the page.

To automate your workflow completely, you can use a script to automatically rebuild and restart your server on filesystem changes:

```bash
#!/usr/bin/env bash

source_dirs="lib bin"
args=${*:-"bin/server.exe"}
cmd="dune exec ${args}"

function sigint_handler() {
  kill "$(jobs -pr)"
  exit 1
}

trap sigint_handler SIGINT

while true; do
  dune build
  $cmd &
  fswatch -r -1 $source_dirs
  printf "\nRestarting server.exe due to filesystem change\n"
  kill "$(jobs -pr)"
done
```

This will watch the directories `bin/` and `lib/` and restart the server at `bin/server.exe` on any changes.
