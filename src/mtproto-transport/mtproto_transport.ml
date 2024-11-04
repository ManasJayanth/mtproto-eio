open Transport
type client = Abridge.client

let time_offset = 0L

  let generate_message_id () =
    let open Int64 in
    let sec_time_f = Unix.gettimeofday () in
    let sec_time = of_float sec_time_f in
    let ms_time = of_float (sec_time_f *. 1000.0) in
    let ns_time = (mul ms_time 1000L) in
    let new_msg_id =
      (logor (shift_left (add sec_time time_offset) 32) (logand ns_time 0xffff_fffcL))
    in
    (* let new_msg_id = *)
    (*   if t.last_msg_id >= new_msg_id *)
    (*     then new_msg_id + 4L + (t.last_msg_id - new_msg_id) *)
    (*     else new_msg_id *)
    (* in *)
    (* t.last_msg_id <- new_msg_id; *)
    new_msg_id


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
  
