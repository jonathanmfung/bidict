# bidict
[![Package Version](https://img.shields.io/hexpm/v/bidict)](https://hex.pm/packages/bidict)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/bidict/)


A bijective dictionary. Each key corresponds to one value, and each value corresponds to one key. To achieve this, a `Bidict` stores two one-way mappings: `Bidict(a2b: Dict(a, b), b2a: Dict(b, a))`. All functions properly update both forward and reverse mappings.

API is mostly the same as `gleam/dict`, though with a few differences:
  - `delete` -> `delete_a`, `delete_b`
  - `drop` -> `drop_a`, `drop_b`
  - `get` -> `get_a`, `get_b`
  - `has_key` -> `has_a`, `has_b`
  - new `map_keys`
  - new `map`

## Install

```sh
gleam add bidict
```

## Usage
```gleam
import bidict

pub fn main() {
  let elements: Bidict(String, String) =
    [
      #("Hydrogen", "H"),
      #("Carbon", "C"),
      #("Bromine", "Br"),
      #("Neodymium", "Nd"),
    ]
    |> bidict.from_list

  let assert Ok("Br") = bidict.get_a(elements, "Bromine")
  let assert Error(Nil) = bidict.get_a(elements, "Oxygen")

  let assert Ok("Carbon") = bidict.get_b(elements, "C")
  let assert Error(Nil) = bidict.get_b(elements, "Al")

  let assert True = bidict.has_a(elements, "Hydrogen")
  let assert False = bidict.has_b(elements, "He")

  let assert False =
    elements
    |> bidict.delete_a("Neodymium")
    |> bidict.has_b("Ne")

  let assert 3 =
    elements
    |> bidict.insert("Bromine", "Nd")
    |> bidict.size
}
```

Further documentation can be found at <https://hexdocs.pm/bidict>.

## Implementations in Other Languages
- [`Rust - bimap`](https://docs.rs/bimap/latest/bimap/index.html)
- [`Python - bidict`](https://bidict.readthedocs.io/en/main/index.html)
- [`Haskell - bimap`](https://hackage.haskell.org/package/bimap-0.5.0)
