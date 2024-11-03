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

val connect :
  sw:Eio.Switch.t ->
  network_resource: [ `Generic | `Unix ] Eio.Net.ty Eio.Resource.t ->
  host:Eio.Net.Ipaddr.v4v6 ->
  port:int ->
  connection

(** [send ~connection data] sends [data] over the connection under the Switch instance [sw] *)
val send: connection:connection -> data -> unit

(** [receive ~connection n_bytes] expects to receive exactly [n_bytes] of data from the connection *)
val receive: connection:connection -> int -> data
