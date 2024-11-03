open Mtproto_net

type client = Tcp_client.connection

let create ?(host = Eio.Net.Ipaddr.of_raw "149.154.167.51") ?(port = 443) ~sw
    ~network_resource () =
  Tcp_client.connect ~sw ~network_resource ~host ~port

let generate_payload ~data =
  let payload_len = Cstruct.length data in
  let data_len = payload_len lsr 2 in
  (* Divide by 4 *)
  let header_len = if payload_len >= 127 then 4 else 1 in
  let len = header_len + data_len in

  let payload = Cstruct.create len in
  if data_len >= 127 then (
    Cstruct.set_uint8 payload 0 127;
    (* No idea what all these bitwise operators are supposed to be doing *)
    Cstruct.set_uint8 payload 1 (0xff land data_len);
    Cstruct.set_uint8 payload 2 (0xff land (data_len asr 8));
    Cstruct.set_uint8 payload 3 (0xff land (data_len asr 16)))
  else Cstruct.set_uint8 payload 0 data_len;
  Cstruct.blit data 0 payload header_len data_len;
  payload

let send ~client cstruct_data = Tcp_client.send ~connection:client cstruct_data
