open Protocol_conv_jsonm

(* *)

let id x = x


type json = Ezjsonm.value

let json_to_jsonm = id
let json_of_jsonm_exn = id
let json_of_jsonm json = Ok json

(* OpenAPI *)
type 'a map = (string * 'a) list

let map_to_jsonm : ('a -> json) ->  (string * 'a) list -> json = fun map l ->
  `O (List.map (fun (k, v) -> (k, map v)) l)

let map_of_jsonm_exn : (json -> 'a) -> json -> 'a map = fun map json ->
  match json with
  | `O l -> List.map (fun (k, v) -> (k, map v)) l
  | _ ->
    let err = Jsonm.make_error ~value:json "map_of_jsonm" in
    raise (Jsonm.Protocol_error err)

let map_of_jsonm : (json -> 'a) -> json -> ('a map, Jsonm.error) result =
  fun a_of_json j ->
  match map_of_jsonm_exn a_of_json j with
  | res -> Ok res
  | exception Jsonm.Protocol_error e -> Error e

type typ = [
  | `integer
  | `number
  | `string
  | `boolean
]
[@@deriving protocol ~driver:(module Jsonm)]

type format = [
  | `int32
  | `int64
  | `float
  | `double
  | `byte
  | `binary
  | `date
  | `date_time [@name "date-time"]
  | `password
]
[@@deriving protocol ~driver:(module Jsonm)]


module Reference = struct
  type 'a t = Ref of string | Object of 'a

  let to_jsonm : ('a -> json) -> 'a t -> json = fun a_to_jsonm v ->
    match v with
    | Ref s -> `O ["$ref", `String s]
    | Object a -> a_to_jsonm a

  let of_jsonm_exn : (json -> 'a) -> json -> 'a t = fun a_of_jsonm json ->
    match json with
    | `O ["$ref", `String s] -> Ref s
    | a -> Object (a_of_jsonm a)

  let of_jsonm a_of_jsonm v =
    match of_jsonm_exn a_of_jsonm v with
    | res -> Ok res
    | exception Jsonm.Protocol_error e -> Error e
end

module Schema = struct
  type t = {
    title : string [@default ""];
    multipleOf : int option;
    maximum : int option;
    exclusiveMaximum : int option;
    minimum : int option;
    exclusiveMinimum : int option;
    maxLength : int option;
    minLength : int option;
    pattern : string option;
    maxItems : int option;
    minItems : int option;
    uniqueItems : bool [@default true];
    maxProperties : int option;
    minProperties : int option;
    required : string list [@default []];
    enum : string list [@default []];
    typ : typ option [@key "type"];
    allOf : t Reference.t option;
    oneOf : t Reference.t option;
    anyOf : t Reference.t option;
    not : t Reference.t option;
    items : t Reference.t option;
    properties : t map [@default []];
    additionalProperties : t Reference.t option;
    description : string [@default ""];
    format : format option;
    default : json option;
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Contact = struct
  type t = {
    name : string [@main];
    url : string [@default ""];
    email : string [@default ""];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module License = struct
  type t = {
    name : string [@main];
    url : string [@default ""];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Info = struct
  type t = {
    title : string [@main];
    description : string [@default ""];
    termsOfService : string [@default ""];
    contact : Contact.t option;
    license : License.t option;
    version : string;
  }[@@deriving make, protocol ~driver:(module Jsonm)]

end

module ExternalDocumentation = struct
  type t = {
    description : string [@default ""];
    url : string [@main];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end



module Server = struct

  module Variable = struct
    type t = {
      enum : string list;
      default : string;
      description : string [@default ""];
    }[@@deriving make, protocol ~driver:(module Jsonm)]
  end

  type t = {
    url : string [@main];
    description : string [@default ""];
    variables : Variable.t map [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]

end

module Example = struct
  type t = {
    summary : string [@main];
    description : string [@default ""];
    value : json option;
    externalValue : string [@default ""];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

type style = [
  | `matrix
  | `label
  | `form
  | `simple
  | `spaceDelimited
  | `pipeDelimited
  | `deepObject
][@@deriving protocol ~driver:(module Jsonm)]


module rec MediaType : sig
  type t = {
    schema : Schema.t Reference.t [@main];
    example : json option;
    examples : Example.t Reference.t map [@default []];
    encoding : Encoding.t map [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end = struct
  type t = {
    schema : Schema.t Reference.t [@main];
    example : json option;
    examples : Example.t Reference.t map [@default []];
    encoding : Encoding.t map [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

and Header : sig
  type t = {
    description : string [@default ""];
    required : bool;
    deprecated : bool;
    allowEmptyValue : bool [@default false];
    style : style option;
    explode : bool [@default false];
    allowReserved : bool [@default false];
    schema : Schema.t Reference.t;
    example : json option;
    examples : Example.t Reference.t map [@default []];
    content : MediaType.t map [@default []];
  }[@@deriving  make, protocol ~driver:(module Jsonm)]
end = struct
  type t = {
    description : string [@default ""];
    required : bool;
    deprecated : bool;
    allowEmptyValue : bool [@default false];
    style : style option;
    explode : bool [@default false];
    allowReserved : bool [@default false];
    schema : Schema.t Reference.t;
    example : json option;
    examples : Example.t Reference.t map [@default []];
    content : MediaType.t map [@default []];
  }[@@deriving  make, protocol ~driver:(module Jsonm)]
end

and Encoding : sig
  type t = {
    contentType : string;
    headers : Header.t Reference.t map [@default []];
    style : style option;
    explode : bool [@default true];
    allowReserved : bool [@default false];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end = struct
  type t = {
    contentType : string;
    headers : Header.t Reference.t map [@default []];
    style : style option;
    explode : bool [@default true];
    allowReserved : bool [@default false];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Parameter = struct
  type t = {
    name : string [@main];
    location : [`query|`header|`path|`cookie] [@key "in"];
    description : string [@default ""];
    required : bool;
    deprecated : bool;
    allowEmptyValue : bool [@default false];
    style : [`form|`simple] [@default `simple];
    explode : bool [@default false];
    allowReserved : bool [@default false];
    schema : Schema.t Reference.t;
    example : json option;
    examples : Example.t Reference.t map [@default []];
    content : MediaType.t map [@default []];
  }[@@deriving  make, protocol ~driver:(module Jsonm)]
end

module Link = struct
  type t = {
    operationRef : string [@default ""];
    operationId : string [@default ""];
    parameters : json map [@default []];
    requestBody : json option;
    description : string [@default ""];
    server : Server.t option;
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end


module Response = struct
  type t = {
    description : string [@main];
    headers : Header.t Reference.t map [@default []];
    content : MediaType.t map [@default []];
    links : Link.t Reference.t map [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module RequestBody = struct
  type t = {
    description : string [@default ""];
    content : MediaType.t map [@main];
    required : bool [@default false];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Responses = struct
  type t = Response.t Reference.t map
  [@@deriving protocol ~driver:(module Jsonm)]
end



module OAuthFlow = struct
  type t = {
    authorizationUrl : string;
    tokenUrl : string;
    refreshUrl : string;
    scopes : string map [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module OAuthFlows = struct
  type t = {
    implicit : OAuthFlow.t option;
    password : OAuthFlow.t option;
    clientCredentials : OAuthFlow.t option;
    authorizationCode : OAuthFlow.t option;
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Security = struct

  module Scheme = struct
    type t = {
      typ : string [@key "type"];
      description : string [@default ""];
      name : string;
      location : [`query|`header|`cookie] option [@key "in"];
      scheme : string;
      bearerFormat : string;
      flows : OAuthFlows.t;
      openIdConnectUrl : string;
    }[@@deriving make, protocol ~driver:(module Jsonm)]
  end

  module Requirement = struct
    type t = string list map
    [@@deriving protocol ~driver:(module Jsonm)]
  end
end

module rec Path : sig
  type t = {
    reference : string [@key "$ref"][@default ""];
    summary : string [@default ""];
    description : string [@default ""];
    get : Operation.t option;
    put : Operation.t option;
    post : Operation.t option;
    delete : Operation.t option;
    options : Operation.t option;
    head : Operation.t option;
    patch : Operation.t option;
    trace : Operation.t option;
    servers : Server.t list [@default []];
    parameters : Parameter.t Reference.t list [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end = struct
  type t = {
    reference : string [@key "$ref"][@default ""];
    summary : string [@default ""];
    description : string [@default ""];
    get : Operation.t option;
    put : Operation.t option;
    post : Operation.t option;
    delete : Operation.t option;
    options : Operation.t option;
    head : Operation.t option;
    patch : Operation.t option;
    trace : Operation.t option;
    servers : Server.t list [@default []];
    parameters : Parameter.t Reference.t list [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

and Callback : sig
  type t = string * Path.t
  [@@deriving protocol ~driver:(module Jsonm)]
end = struct
  type t = string * Path.t

  let to_jsonm : t -> json = fun (s, p) -> `O [s, Path.to_jsonm p]
  let of_jsonm_exn : json -> t = function
    | `O [s, p] -> (s, Path.of_jsonm_exn p)
    | value ->
      let err = Jsonm.make_error ~value "Callback.of_jsonm" in
      raise (Jsonm.Protocol_error err)
  let of_jsonm : json -> (t, Jsonm.error) result = fun json ->
    match of_jsonm_exn json with
    | v -> Ok v
    | exception Jsonm.Protocol_error e -> Error e
end

and Operation : sig
  type t = {
    tags : string list [@default []];
    summary : string [@default ""];
    description : string [@default ""];
    externalDocs : ExternalDocumentation.t option;
    operationId : string;
    parameters : Parameter.t Reference.t list [@default []];
    requestBody : RequestBody.t Reference.t option;
    responses : Response.t Reference.t map;
    callbacks : Callback.t Reference.t map [@default []];
    deprecated : bool [@default false];
    security : Security.Requirement.t list [@default []];
    servers : Server.t list [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end = struct
  type t = {
    tags : string list [@default []];
    summary : string [@default ""];
    description : string [@default ""];
    externalDocs : ExternalDocumentation.t option;
    operationId : string;
    parameters : Parameter.t Reference.t list [@default []];
    requestBody : RequestBody.t Reference.t option;
    responses : Response.t Reference.t map;
    callbacks : Callback.t Reference.t map [@default []];
    deprecated : bool [@default false];
    security : Security.Requirement.t list [@default []];
    servers : Server.t list [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end



module Components = struct
  type t = {
    schemas : Schema.t Reference.t map [@default []];
    responses : Response.t Reference.t map [@default []];
    parameters : Parameter.t Reference.t map [@default []];
    examples : Example.t Reference.t map [@default []];
    requestBodies : RequestBody.t Reference.t map [@default []];
    headers : Header.t Reference.t map [@default []];
    securitySchemes : Security.Scheme.t Reference.t map [@default []];
    links : Link.t Reference.t map [@default []];
    callbacks : Callback.t Reference.t map [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Tag = struct
  type t = {
    name : string [@main];
    description : string [@default ""];
    externalDocs : ExternalDocumentation.t option;
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module OpenAPI = struct
  type t = {
    openapi : string [@main];
    info : Info.t;
    paths : Path.t map;
    servers : Server.t list [@default []];
    components : Components.t option;
    security : Security.Requirement.t list [@default []];
    tags : Tag.t list [@default []];
    externalDocs : ExternalDocumentation.t option;
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

include OpenAPI

(* let pp_base : ?minify:bool -> t Fmt.t = fun ?minify ppf t -> *)
