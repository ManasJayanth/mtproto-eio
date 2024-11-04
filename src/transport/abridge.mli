type client

val create :
  ?host:Eio.Net.Ipaddr.v4v6 ->
  ?port:int ->
  sw:Eio.Switch.t ->
  network_resource:[ `Generic | `Unix ] Eio.Net.ty Eio.Resource.t ->
  unit ->
  client
(** [create ~sw ~network_resource] creates a client to interact over MTProto *)

val send : client:client -> Cstruct.t -> unit
(** [send ~client cstruct_data] *)

val receive : client:client -> Cstruct.t
(** [receive ~client] returns server response sent on a client connection *)
