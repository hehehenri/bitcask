module Cache = Map.Make (String) ;;
module Keydir = Map.Make (String) ;;

type key_location = {
  file_id : string;
  record_line : int;
}

type storage = {
  active_file : string;      
  directory : string;
  keydir : key_location Keydir.t;
  last_line : int
} ;;

let new_storage directory =
  let file_id = Ulid.ulid () in
  let keydir = Keydir.empty in
  let last_line = 0 in
  { active_file = file_id; keydir; last_line; directory; }
;;

let update_key_dir key storage = 
  let record_line = storage.last_line + 1 in
  let key_location = { file_id = storage.active_file; record_line } in
  let keydir = Keydir.remove key storage.keydir in
  let keydir = Keydir.add key key_location keydir in
  { 
    keydir;
    last_line = record_line;
    active_file = storage.active_file;
    directory = storage.directory
  }
;;

type record = {
  timestamp : string;
  key_size : int;
  value_size : int;
  key : string;
  value : string;
} [@@deriving yojson]

let record_to_json record = Yojson.Safe.to_string (record_to_yojson record) 
let record_from_json json = 
  let record = record_of_yojson (Yojson.Safe.from_string json) in
  match record with
  | Ok record -> record
  | Error err -> failwith err

let write_to_file key record storage =
  let file_path = Printf.sprintf "%s/%s" storage.directory storage.active_file in
  let oc = open_out file_path in
  let record = record_to_json record in
  Printf.fprintf oc "%s\n" record;
  close_out oc;
  update_key_dir key storage
;;

let read_from_file key storage =
  let (let*) = Option.bind in
  let* key_location = Keydir.find_opt key storage.keydir in
  let file_path = Printf.sprintf "%s/%s" storage.directory key_location.file_id in

  let in_channel = open_in file_path in

  let try_read () = try Some (input_line in_channel) with End_of_file -> None in

  let rec find_key () = match try_read () with
    | Some (value) -> 
      let record = record_from_json value in
      (match record.key == key with
      | true -> Some record
      | false -> find_key ())
    | None -> close_in in_channel; None in
  find_key ()

type cache = record Cache.t ;;

type store = { 
  cache : cache;
  storage : storage; 
} ;;

let empty_store directory = { cache = Cache.empty; storage = new_storage directory } ;;
let update_cache cache store = { cache = cache; storage = store.storage } ;;
let update_cache key record store =
  let cache = Cache.remove key store.cache in
  let cache = Cache.add key record cache in
  update_cache cache store

let find_from_store key store =
  match Cache.find_opt key store.cache with
  | Some record -> Some (record, store)
  | None ->
    let record = read_from_file key store.storage in
    match record with
    | Some record ->
      let store = update_cache key record store in
      Some (record, store)
    | None -> None
