(* type 'resource_ty connection  *)
type connection
(** Abstract type representing TCP connections *)

type data = Cstruct.t

(**
   Takes a [Eio.Switch.t] (for easy cleanup) and [host] and [port] and returns connection

   Eg:


   {[
     let host = Eio.Net.Ipaddr.V4.loopback in
     let port = 1337 in
     connect ~sw ~host ~port
   ]}

 *)

(* [> [> `Generic] Eio.Net.ty ] Eio.Resource.t *)
(* type 'resource_typ = [> [> `Generic] Eio.Net.ty ] *)
val connect :
  sw:Eio.Switch.t ->
  network_resource: [ `Generic | `Unix ] Eio.Net.ty Eio.Resource.t ->
  host:Eio.Net.Ipaddr.v4v6 ->
  port:int ->
  connection

(** [send ~sw ~connection data] sends [data] over the connection under the Switch instance [sw] *)
(* val send: sw:Eio.Switch.t -> connection:connection -> data -> unit *)
