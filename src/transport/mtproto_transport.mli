type client

val create :
  ?host:Eio.Net.Ipaddr.v4v6 ->
  ?port:int ->
  sw:Eio.Switch.t ->
  network_resource:[ `Generic | `Unix ] Eio.Net.ty Eio.Resource.t ->
  unit ->
  client
(** [create ~sw ~network_resource] creates a client to interact over MTProto *)

val generate_payload : data:Cstruct.t -> Cstruct.t
(** [generate_payload ~data] generates the final payload to send over MTProto client *)

val send : client:client -> Cstruct.t -> unit
(** [send ~client cstruct_data] *)
