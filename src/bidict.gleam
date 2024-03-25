// https://hackage.haskell.org/package/bimap-0.5.0/docs/Data-Bimap.html

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option}

pub type Bidict(a, b) {
  Bidict(a2b: Dict(a, b), b2a: Dict(b, a))
}

pub fn delete_a(bdict: Bidict(a, b), a: a) -> Bidict(a, b) {
  let b = dict.get(bdict.a2b, a)
  let new_a2b = dict.delete(bdict.a2b, a)
  let new_b2a = case b {
    Ok(b) -> dict.delete(bdict.b2a, b)
    Error(Nil) -> bdict.b2a
  }

  Bidict(new_a2b, new_b2a)
}

pub fn delete_b(bdict: Bidict(a, b), b: b) -> Bidict(a, b) {
  let a = dict.get(bdict.b2a, b)
  let new_b2a = dict.delete(bdict.b2a, b)
  let new_a2b = case a {
    Ok(a) -> dict.delete(bdict.a2b, a)
    Error(Nil) -> bdict.a2b
  }

  Bidict(new_a2b, new_b2a)
}

pub fn drop_a(bdict: Bidict(a, b), disallowed_a: List(a)) -> Bidict(a, b) {
  case disallowed_a {
    [] -> bdict
    [a, ..xs] -> drop_a(delete_a(bdict, a), xs)
  }
}

pub fn drop_b(bdict: Bidict(a, b), disallowed_b: List(b)) -> Bidict(a, b) {
  case disallowed_b {
    [] -> bdict
    [b, ..xs] -> drop_b(delete_b(bdict, b), xs)
  }
}

pub fn filter(
  in bdict: Bidict(a, b),
  keeping predicate: fn(a, b) -> Bool,
) -> Bidict(a, b) {
  let insert = fn(dict, a, b) {
    case predicate(a, b) {
      True -> insert(dict, a, b)
      _ -> dict
    }
  }
  bdict
  |> fold(from: new(), with: insert)
}

fn do_fold(list: List(#(a, b)), initial: acc, fun: fn(acc, a, b) -> acc) -> acc {
  case list {
    [] -> initial
    [#(a, b), ..rest] -> do_fold(rest, fun(initial, a, b), fun)
  }
}

pub fn fold(
  over bdict: Bidict(a, b),
  from initial: acc,
  with fun: fn(acc, a, b) -> acc,
) -> acc {
  bdict
  |> to_list
  |> do_fold(initial, fun)
}

pub fn from_list(list: List(#(a, b))) -> Bidict(a, b) {
  fold_list_of_pair(list, new())
}

fn fold_list_of_pair(
  over list: List(#(a, b)),
  from initial: Bidict(a, b),
) -> Bidict(a, b) {
  case list {
    [] -> initial
    [x, ..rest] -> fold_list_of_pair(rest, insert(initial, x.0, x.1))
  }
}

pub fn get_a(bdict: Bidict(a, b), a: a) -> Result(b, Nil) {
  dict.get(bdict.a2b, a)
}

pub fn get_b(bdict: Bidict(a, b), b: b) -> Result(a, Nil) {
  dict.get(bdict.b2a, b)
}

// replacement of has_key
pub fn has_a(bdict: Bidict(a, b), a: a) -> Bool {
  dict.has_key(bdict.a2b, a)
}

pub fn has_b(bdict: Bidict(a, b), b: b) -> Bool {
  dict.has_key(bdict.b2a, b)
}

pub fn insert(bdict: Bidict(a, b), a: a, b: b) -> Bidict(a, b) {
  bdict
  |> delete_a(a)
  |> delete_b(b)
  |> do_insert(a, b)
}

fn do_insert(bdict: Bidict(a, b), a: a, b: b) -> Bidict(a, b) {
  case !has_a(bdict, a), !has_b(bdict, b) {
    True, True -> {
      let new_a2b = dict.insert(bdict.a2b, a, b)
      let new_b2a = dict.insert(bdict.b2a, b, a)
      Bidict(new_a2b, new_b2a)
    }
    _, _ -> bdict
  }
}

pub fn keys(bdict: Bidict(a, b)) -> List(a) {
  dict.keys(bdict.a2b)
}

pub fn map_keys(bdict: Bidict(a, b), fun: fn(a, b) -> c) -> Bidict(c, b) {
  let f = fn(bdict, k, v) { insert(bdict, fun(k, v), v) }
  bdict
  |> fold(from: new(), with: f)
}

pub fn map_values(bdict: Bidict(a, b), fun: fn(a, b) -> c) -> Bidict(a, c) {
  let f = fn(bdict, k, v) { insert(bdict, k, fun(k, v)) }
  bdict
  |> fold(from: new(), with: f)
}

pub fn map(bdict: Bidict(a, b), fun: fn(a, b) -> c) -> List(c) {
  list.map2(keys(bdict), values(bdict), fun)
}

pub fn merge(bdict: Bidict(a, b), new_bdict: Bidict(a, b)) -> Bidict(a, b) {
  new_bdict
  |> to_list
  |> fold_inserts(bdict)
}

fn fold_inserts(new_entries: List(#(a, b)), bdict: Bidict(a, b)) -> Bidict(a, b) {
  case new_entries {
    [] -> bdict
    [x, ..xs] -> fold_inserts(xs, insert(bdict, x.0, x.1))
  }
}

pub fn new() -> Bidict(a, b) {
  Bidict(dict.new(), dict.new())
}

pub fn size(bdict: Bidict(a, b)) -> Int {
  dict.size(bdict.a2b)
}

pub fn take(
  from bdict: Bidict(a, b),
  keeping desired_keys: List(a),
) -> Bidict(a, b) {
  insert_taken(bdict, desired_keys, new())
}

fn insert_taken(
  bdict: Bidict(a, b),
  desired_keys: List(a),
  acc: Bidict(a, b),
) -> Bidict(a, b) {
  let insert_ = fn(taken: Bidict(a, b), a) {
    case get_a(bdict, a) {
      Ok(b) -> insert(taken, a, b)
      _ -> taken
    }
  }
  case desired_keys {
    [] -> acc
    [x, ..xs] -> insert_taken(bdict, xs, insert_(acc, x))
  }
}

pub fn to_list(bdict: Bidict(a, b)) -> List(#(a, b)) {
  dict.to_list(bdict.a2b)
}

pub fn update(
  bidict: Bidict(a, b),
  a: a,
  fun: fn(Option(b)) -> b,
) -> Bidict(a, b) {
  let new_b =
    bidict
    |> get_a(a)
    |> option.from_result
    |> fun

  insert(bidict, a, new_b)
}

pub fn values(bdict: Bidict(a, b)) -> List(b) {
  dict.keys(bdict.b2a)
}
