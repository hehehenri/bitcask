# Bitcask

## Overview

This is a simple implementation of the Bitcask storage system in OCaml. Bitcask is a key/value store that provides fast and predictable performance with a straightforward design.

## Features

- **Key/Value Store:** Store and retrieve key-value pairs efficiently.
- **Append-Only File:** Data is appended to a write-ahead log file for durability.
- **In-Memory Hash Table:** Fast in-memory access for frequently accessed keys.
- **Merge Process:** Periodically compact and merge data files to manage space efficiently.

## Installation

1. Clone the repository:

  ```bash
  git clone https://github.com/hnrbs/bitcask.git
  cd bitcask
  ```

2. Install opam dependencies:
  ```bash
  opam install . --deps-only  
  ```

3. Build and run it:
  ```bash
  dune exec ./bin/main.exe
  ```

## References

1. [Bitcask Intro](https://riak.com/assets/bitcask-intro.pdf) - Justin Sheehy

2. [Paper Notes: Bitcask](https://distributed-computing-musings.com/2023/01/paper-notes-bitcask-a-log-structured-hash-table-for-fast-key-value-data/) - varunu28

## License
This project is licensed under the MIT License.
