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

  let payload = Cstruct.create_unsafe len in
  if data_len >= 127 then (
    Cstruct.set_uint8 payload 0 127;
    (* No idea what all these bitwise operators are supposed to be doing *)
    Cstruct.set_uint8 payload 1 (0xff land data_len);
    Cstruct.set_uint8 payload 2 (0xff land (data_len asr 8));
    Cstruct.set_uint8 payload 3 (0xff land (data_len asr 16)))
  else Cstruct.set_uint8 payload 0 data_len;
  Cstruct.blit data 0 payload header_len data_len;
  payload

let send ~client data =
  let payload = generate_payload ~data in
    (* Wrap the data in a payload of it's own *)
  Tcp_client.send ~connection:client payload

let buf_to_int cstruct =
  let data = Cstruct.get_uint8 cstruct 0 in
  let data = ((Cstruct.get_uint8 cstruct 1) lsl 8) + data in
  ((Cstruct.get_uint8 cstruct 2) lsl 16) + data

let receive ~client =
  let buf = Tcp_client.receive ~connection:client 1 in
  let first_byte = Cstruct.get_uint8 buf 0 in
  let body_length = 
  if first_byte = 127 then
    Tcp_client.receive ~connection:client 3 |> buf_to_int
  else
    first_byte in
  Tcp_client.receive ~connection:client body_length
    
