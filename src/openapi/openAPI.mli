(** OpenAPI datatypes

    This library allows to build OpenAPI structures in order to share
    API using REST-based tools.
*)

open Protocol_conv_jsonm

type json = Jsonm.t
[@@deriving protocol ~driver:(module Jsonm)]

type 'a map = (string * 'a) list
[@@deriving protocol ~driver:(module Jsonm)]

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

module Reference :
sig
  type 'a t = Ref of string | Object of 'a
  [@@deriving protocol ~driver:(module Jsonm)]
end

module Schema :
sig
  type t = private {
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

module Contact :
sig
  type t = private {
    name : string [@main];
    url : string [@default ""];
    email : string [@default ""];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module License :
sig
  type t = private {
    name : string [@main];
    url : string [@default ""];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Info :
sig
  type t = private {
    title : string [@main];
    description : string [@default ""];
    termsOfService : string [@default ""];
    contact : Contact.t option;
    license : License.t option;
    version : string;
  }[@@deriving make, protocol ~driver:(module Jsonm)]

end

module Server :
sig

  module Variable :
  sig
    type t = private {
      enum : string list;
      default : string;
      description : string [@default ""];
    }[@@deriving make, protocol ~driver:(module Jsonm)]
  end

  type t = private {
    url : string [@main];
    description : string [@default ""];
    variables : Variable.t map [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]

end

module Example :
sig
  type t = private {
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

module rec MediaType :
sig
  type t = private {
    schema : Schema.t Reference.t [@main];
    example : json option;
    examples : Example.t Reference.t map [@default []];
    encoding : Encoding.t map [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

and Header :
sig
  type t = private {
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

and Encoding :
sig
  type t = private {
    contentType : string;
    headers : Header.t Reference.t map [@default []];
    style : style option;
    explode : bool [@default true];
    allowReserved : bool [@default false];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Parameter :
sig
  type t = private {
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

module ExternalDocumentation :
sig
  type t = private {
    description : string [@default ""];
    url : string [@main];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module RequestBody :
sig
  type t = private {
    description : string [@default ""];
    content : MediaType.t map [@main];
    required : bool [@default false];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Link :
sig
  type t = private {
    operationRef : string [@default ""];
    operationId : string [@default ""];
    parameters : json map [@default []];
    requestBody : json option;
    description : string [@default ""];
    server : Server.t option;
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Response :
sig
  type t = {
    description : string [@main];
    headers : Header.t Reference.t map [@default []];
    content : MediaType.t map [@default []];
    links : Link.t Reference.t map [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module OAuthFlow :
sig
  type t = private {
    authorizationUrl : string;
    tokenUrl : string;
    refreshUrl : string;
    scopes : string map [@default []];
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module OAuthFlows :
sig
  type t = private {
    implicit : OAuthFlow.t option;
    password : OAuthFlow.t option;
    clientCredentials : OAuthFlow.t option;
    authorizationCode : OAuthFlow.t option;
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module Security :
sig

  module Scheme :
  sig
    type t = private {
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

  module Requirement :
  sig
    type t = string list map
    [@@deriving protocol ~driver:(module Jsonm)]
  end
end

module rec Path :
sig
  type t = private {
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

and Callback :
sig
  type t = string * Path.t
  [@@deriving protocol ~driver:(module Jsonm)]
end

and Operation :
sig
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

module Components :
sig
  type t = private {
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

module Tag :
sig
  type t = private {
    name : string [@main];
    description : string [@default ""];
    externalDocs : ExternalDocumentation.t option;
  }[@@deriving make, protocol ~driver:(module Jsonm)]
end

module OpenAPI :
sig
  type t = private {
    openapi : string [@main];
    info : Info.t;
    paths : Path.t map;
    servers : Server.t list [@default []];
    components : Components.t option;
    security : Security.Requirement.t list [@default []];
    tags : Tag.t list [@default []];
    externalDocs : ExternalDocumentation.t option;
  }[@@deriving make, protocol ~driver:(module Jsonm)]

  val of_channel : in_channel -> t

  val of_string : string -> t

  val to_channel : ?minify:bool -> out_channel -> t -> unit

  val to_buffer : ?minify:bool -> Buffer.t -> t -> unit

  val to_string : ?minify:bool -> t -> string

  val pp : t Fmt.t

end

include module type of OpenAPI
