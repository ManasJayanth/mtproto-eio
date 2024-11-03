let mtproto_request_pq () =
  let nonce = Cstruct.of_string @@ Mirage_crypto_rng.generate 32 in
  let encoder_buffer = TLRuntime.Encoder.create () in
  TLSchema.MTProto.TL_req_pq_multi.(encode encoder_buffer { nonce });
  TLRuntime.Encoder.to_cstruct encoder_buffer

let () =
  let ping_tl ~env sw =
    let network_resource = Eio.Stdenv.net env in
    let client = Mtproto_transport.create ~sw ~network_resource () in

    let data = mtproto_request_pq () in
    let payload = Mtproto_transport.generate_payload ~data in
    (* Wrap the data in a payload of it's own *)
    Mtproto_transport.send ~client payload
  in
  Eio_main.run @@ fun env ->
  Mirage_crypto_rng_eio.run (module Mirage_crypto_rng.Fortuna) env @@ fun () ->
  let name = "Main program" in
  Eio.Switch.run ~name (ping_tl ~env)
