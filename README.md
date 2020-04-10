# openapi
The OpenAPI package provides an interface to the OpenAPI 3.0.3 definition (aka [Swagger](https://swagger.io/specification/)).

# Installation
This package isn't published to `opam` yet, so it must be installed from source by cloning the repository and do a manual installation:
    
    $ git clone https://github.com/Ninjapouet/openapi.git
    $ cd openapi
    $ opam install .

# Documentation
Documentation isn't published yet but the API can be generated from sources:

    $ dune build @doc

and available in `_build/default/_doc/_html/index.html`. By the way, the API is quite simple and export the OpenAPI data types along with their corresponding `make` functions to build them.

# Related Work
The [ocaml-swagger](https://github.com/andrenth/ocaml-swagger) allows to generate OCaml code from a Swagger file and its implementation provides an OpenAPI 2.0 binding. However, the project aims the code generation based on existing Swagger file and not generating new ones. Thus, the OpenAPI isn't exported and only the code generation feature is proposed. Although it's perfectly sound for the [kubecaml](https://github.com/andrenth/kubecaml) project in mind, it doesn't fulfill this OpenAPI purpose. Contributing to [ocaml-swagger](https://github.com/andrenth/ocaml-swagger) was the first idea but there are design issues that seems difficult to match:
- the OpenAPI version proposed is 2.0 and the cost effort to add the support to 3.0.3 is not clear to me;
- the reference or object types from OpenAPI is more like C unions which cannot be handled simply with the underlying tool [atdgen](https://github.com/ahrefs/atd) and the way it's handled in [ocaml-swagger](https://github.com/andrenth/ocaml-swagger) breaks the objects invariants. This is not a problem for the latter use but it is for this OpenAPI project.
- As a consequence of the previous point, we use more flexible ppx tools like [ppx_protocol_conv](https://github.com/andersfugmann/ppx_protocol_conv) to generate JSON conversions which leads to a big gap between the two projects.
- Code generation is also in mind for this OpenAPI project but with a strategy quite different than [ocaml-swagger](https://github.com/andrenth/ocaml-swagger), particularly on path template management where the `By_xxx` module generation is a "no go" for our needs and I don't know to to manage this without breaking a lot of stuff in [ocaml-swagger](https://github.com/andrenth/ocaml-swagger).

# Roadmap

## Features
- [X] OpenAPI data types
- [X] OpenAPI IO
- [ ] Code generation
- [ ] Documentation
- [ ] OpenAPI Invariants

## Versioning
A 0.1 version will be released soon after a bit more testing. 0.x versions up to 1.0 will add code generation and documentation. Invariants will be added later.
