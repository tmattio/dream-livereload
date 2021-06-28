# Dream Livereload

[![Actions Status](https://github.com/tmattio/dream-livereload/workflows/CI/badge.svg)](https://github.com/tmattio/dream-livereload/actions)

Live reloading for Dream applications.

## Usage

The main use case is to add the `Dream_livereload` middleware and route to your Dream application:

```ocaml
let () =
  Dream.run
  @@ Dream.logger
  @@ Dream_livereload.inject_script ()
  @@ Dream.router [
    Dream.get "/" (fun _ -> Dream.html "Hello World!");
    Dream_livereload.route ();
  ]
  @@ Dream.not_found
```

This will do two things:

1. The middleware will inject a script in the HTML documents send by your applications (HTTP response with the `text/html` `Content-Type`). The script tries to open a connection to the server and keep it open. When the connection is lost, the script will try to re-connect for 10 seconds, and upon a successfull re-connection, will refresh the current page.
2. The route is the HTTP endpoint used for the WebSocket connection. It does nothing but open a WebSocket connection.

This allows to automate parts of your workflows: when you rebuild your project, stop the previous instance of your server and start a new one, the client will automatically detect it and refresh the page.

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
