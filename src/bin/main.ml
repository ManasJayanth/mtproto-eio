[@@@warning "-32-27"]

open Eio.Std
module Read = Eio.Buf_read

let send_addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, 8080)
let recv_addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, 8081)

let rec send_loop flow addr =
  let from_client = Read.of_flow flow ~max_size:100 in
  Printf.printf "Received: %s\n%!" (Read.line from_client);
  Eio.Flow.copy_string "OK\n" flow;
  send_loop flow addr

let rec recv_loop flow addr =
  let from_client = Read.of_flow flow ~max_size:100 in
  Printf.printf "Received: %s\n%!" (Read.line from_client);
  Eio.Flow.copy_string "OK\n" flow;
  recv_loop flow addr

let main ~pool ~net =
  Switch.run ~name:"main" @@ fun sw ->
  let promise, _ = Promise.create () in
  let send_socket =
    Eio.Net.listen net ~sw ~reuse_addr:true ~backlog:5 send_addr
  in
  let recv_socket =
    Eio.Net.listen net ~sw ~reuse_addr:true ~backlog:5 recv_addr
  in
  let submit_to_pool socket loop = fun () ->
        Eio.Net.run_server socket loop ~on_error:(fun exn ->
            Printf.printf "%s\n" (Printexc.to_string exn)) in
  let _ =
    Eio.Executor_pool.submit_fork ~sw ~weight:1.0 pool (submit_to_pool send_socket send_loop)
  in
  let _ =
    Eio.Executor_pool.submit_fork ~sw ~weight:1.0 pool (submit_to_pool recv_socket recv_loop)
  in
  Promise.await promise

let () =
  Eio_main.run @@ fun env ->
  Switch.run @@ fun sw ->
  let pool =
    Eio.Executor_pool.create ~sw (Eio.Stdenv.domain_mgr env) ~domain_count:4
  in
  main ~net:(Eio.Stdenv.net env) ~pool
