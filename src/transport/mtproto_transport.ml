open Mtproto_net

type client = Tcp_client.connection

let create ?(host = Eio.Net.Ipaddr.of_raw "149.154.167.51") ?(port = 443) ~sw
    ~network_resource () =
  Tcp_client.connect ~sw ~network_resource ~host ~port

let send ~client cstruct_data =
  Tcp_client.send ~connection:client cstruct_data
