type connection = [ `Generic | `Unix ] Eio.Net.stream_socket_ty Eio.Resource.t

type data = Cstruct.t

let connect ~sw ~network_resource ~host ~port =
  Eio.Net.connect ~sw network_resource (`Tcp (host, port))

(* let send ~sw ~connection data = *)
