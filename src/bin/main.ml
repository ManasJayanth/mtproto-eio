let mtproto_request_pq () =
  let nonce = Cstruct.of_string @@ Mirage_crypto_rng.generate 16 in
  let encoder_buffer = TLRuntime.Encoder.create () in
  TLSchema.MTProto.TL_req_pq_multi.(encode encoder_buffer { nonce });
  TLRuntime.Encoder.to_cstruct encoder_buffer

let () =
  let ping_tl ~env sw =
    let network_resource = Eio.Stdenv.net env in
    let client = Mtproto_transport.create ~sw ~network_resource ~host:(Eio.Net.Ipaddr.of_raw "\127\000\000\001") ~port:8080 () in
    let data = mtproto_request_pq () in
    print_endline "Sending data";
    Mtproto_transport.send ~client data;
    print_endline "Sent. Waiting...";
    let TLSchema.MTProto.TL_resPQ.
          {
            nonce;
            server_nonce = _;
            pq = _;
            server_public_key_fingerprints = _;
          } =
      Mtproto_transport.receive ~client
      |> TLRuntime.Decoder.of_cstruct |> TLSchema.MTProto.TL_resPQ.decode
    in
    print_endline ("Received server response" ^ Cstruct.to_string nonce)
  in
  Eio_main.run @@ fun env ->
  Mirage_crypto_rng_eio.run (module Mirage_crypto_rng.Fortuna) env @@ fun () ->
  let name = "Main program" in
  Eio.Switch.run ~name (ping_tl ~env)

(* wire shark filter: ip.dst == 149.154.167.051 or ip.src  == 149.154.167.051 *)
