type client

val client_of_abridge: Transport.Abridge.client -> client
(** Takes an abridge transport client and return [client] *)

val send : client:client -> Cstruct.t -> unit
(** [send ~client cstruct_data] *)

val receive : client:client -> Cstruct.t
(** [receive ~client] returns server response sent on a client connection *)
