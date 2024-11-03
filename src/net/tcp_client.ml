type connection = [ `Generic | `Unix ] Eio.Net.stream_socket_ty Eio.Resource.t
type data = Cstruct.t

let connect ~sw ~network_resource ~host ~port =
  Eio.Net.connect ~sw network_resource (`Tcp (host, port))

let send ~connection data =
  ignore @@ Eio.Flow.single_write connection [ data ] 

(** TODO review and improve API. This could be very slow *)
let receive ~connection n_bytes =
  let buffer = Cstruct.create n_bytes in
  Eio.Flow.read_exact connection buffer;
  buffer
