open Transport
type client = Abridge.client

let generate_message_id () = 0L

let client_of_abridge x = x

let send ~client mtproto_message =
  let mtproto_message_len = Cstruct.length mtproto_message in
  let msg_id = generate_message_id () in
  (* https://core.telegram.org/mtproto/description#unencrypted-message *)
  let auth_key_id = 0L in (* as spec. To signify lack of auth_key_id *)
  (* Can I do bit shifting magic instead int -> int64 isn't fast? Should I? Is the stdlib/cstruct doing this? *)
  let buffer = Cstruct.create_unsafe (8 (* auth_key_id:int64 *) + 8 (* message_id:int64 *) + 4 (* message_data_length:int32 *) + mtproto_message_len) in
  Cstruct.LE.set_uint64 buffer 0 auth_key_id;
  Cstruct.LE.set_uint64 buffer 8 msg_id;
  Cstruct.LE.set_uint32 buffer 16 (Int32.of_int mtproto_message_len);
  Cstruct.blit mtproto_message 0 buffer 20 mtproto_message_len;
  Transport.Abridge.send ~client buffer

let receive ~client =
  let buffer = Abridge.receive ~client in
  let _msg_id = Cstruct.LE.get_uint64 buffer 8 in
  let mtproto_message_len = Int32.to_int @@ Cstruct.LE.get_uint32 buffer 16 in
  Cstruct.sub buffer 20 mtproto_message_len
  
