open Mtproto_server

let () = loop ()

(* let () = *)
(*   Eio_main.run @@ fun env -> *)
(*   let net = Eio.Stdenv.net env in *)
(*   Eio.Switch.run @@ fun sw -> *)
(*   Eio.Net.connect ~sw net (`Tcp (Eio.Net.Ipaddr.V4.loopback, 1234)) *)
