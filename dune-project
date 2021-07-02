(lang dune 2.7)

(name dream-livereload)

(documentation "https://tmattio.github.io/dream-livereload/")

(source
 (github tmattio/dream-livereload))

(license MIT)

(authors "Thibaut Mattio")

(maintainers "Thibaut Mattio")

(generate_opam_files true)

(package
 (name dream-livereload)
 (synopsis "Live reloading for Dream applications")
 (description "Live reloading for Dream applications")
 (depends
  (ocaml
   (>= 4.08.0))
  dune
  dream
  (lambdasoup
   (>= 0.6.1))
  lwt_ppx
  (odoc :with-doc)))
