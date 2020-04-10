(lang dune 2.4)

(name OpenAPI)

(generate_opam_files true)

(source (github Ninjapouet/openapi))
(bug_reports "https://github.com/Ninjapouet/openapi/issues")

(package
 (name OpenAPI)
 (synopsis "OpenAPI tools")
 (depends
  (ppx_deriving (>= 4.4.1))
  (ppx_protocol_conv (>= 5.1.0))
  (fmt (>= 0.8.8))
  (ezjsonm (>= 1.1.0)))
 (tags ("openapi" "api"))
 (license "Apache 2.0")
 (authors "Julien Blond <julien.blond@gmail.com>")
)
