// from stdlib/test/gleam/dict_test.gleam
import gleeunit
import gleeunit/should
import gleam/dict
import gleam/option.{None, Some}
import gleam/string
import gleam/list
import gleam/int
import bidict.{type Bidict}

pub fn main() {
  gleeunit.main()
}

pub fn from_list_test() {
  [#(4, 0), #(1, 0)]
  |> bidict.from_list
  |> bidict.size
  |> should.equal(1)

  [#(1, 0), #(1, 1)]
  |> bidict.from_list
  |> should.equal(bidict.from_list([#(1, 1)]))

  [#(1, 0), #(2, 3)]
  |> bidict.from_list
  |> should.equal(bidict.from_list([#(2, 3), #(1, 0)]))
}

pub fn has_ab_test() {
  []
  |> bidict.from_list
  |> bidict.has_a(1)
  |> should.be_false

  [#(1, 0)]
  |> bidict.from_list
  |> bidict.has_a(1)
  |> should.be_true

  [#(4, 0), #(1, 2)]
  |> bidict.from_list
  |> bidict.has_a(1)
  |> should.be_true

  [#(4, 0), #(1, 0)]
  |> bidict.from_list
  |> bidict.has_a(1)
  |> should.be_true
}

pub fn new_test() {
  bidict.new()
  |> bidict.size
  |> should.equal(0)

  bidict.new()
  |> bidict.to_list
  |> should.equal([])
}

type Key {
  A
  B
  C
}

pub fn get_ab_test() {
  let proplist = [#(4, 0), #(1, 1)]
  let m = bidict.from_list(proplist)

  m
  |> bidict.get_a(4)
  |> should.equal(Ok(0))

  m
  |> bidict.get_a(1)
  |> should.equal(Ok(1))

  m
  |> bidict.get_b(1)
  |> should.equal(Ok(1))

  m
  |> bidict.get_a(2)
  |> should.equal(Error(Nil))

  m
  |> bidict.get_b(2)
  |> should.equal(Error(Nil))

  let proplist = [#(A, 0), #(B, 1)]
  let m = bidict.from_list(proplist)

  m
  |> bidict.get_a(A)
  |> should.equal(Ok(0))

  m
  |> bidict.get_a(B)
  |> should.equal(Ok(1))

  m
  |> bidict.get_a(C)
  |> should.equal(Error(Nil))

  let proplist = [#(<<1, 2, 3>>, 0), #(<<3, 2, 1>>, 1)]
  let m = bidict.from_list(proplist)

  m
  |> bidict.get_a(<<1, 2, 3>>)
  |> should.equal(Ok(0))

  m
  |> bidict.get_a(<<3, 2, 1>>)
  |> should.equal(Ok(1))

  m
  |> bidict.get_a(<<1, 3, 2>>)
  |> should.equal(Error(Nil))

  m
  |> bidict.get_b(3)
  |> should.equal(Error(Nil))
}

pub fn insert_test() {
  bidict.new()
  |> bidict.insert("a", 0)
  |> bidict.insert("b", 1)
  |> bidict.insert("c", 2)
  |> should.equal(bidict.from_list([#("a", 0), #("b", 1), #("c", 2)]))

  // insert can make the bidict smaller
  [#("a", 1), #("c", 2)]
  |> bidict.from_list()
  |> bidict.insert("a", 2)
  |> bidict.size
  |> should.equal(1)
}

pub fn map_values_test() {
  [#(1, 0), #(2, 1), #(3, 2)]
  |> bidict.from_list
  |> bidict.map_values(fn(k, v) { k + v })
  |> should.equal(bidict.from_list([#(1, 1), #(2, 3), #(3, 5)]))
}

pub fn map_keys_test() {
  [#(1, 0), #(2, 1), #(3, 2)]
  |> bidict.from_list
  |> bidict.map_keys(fn(k, v) { k + v })
  |> should.equal(bidict.from_list([#(1, 0), #(3, 1), #(5, 2)]))
}

pub fn keys_test() {
  [#("a", 0), #("b", 1), #("c", 2)]
  |> bidict.from_list
  |> bidict.keys
  |> list.sort(string.compare)
  |> should.equal(["a", "b", "c"])
}

pub fn values_test() {
  [#("a", 0), #("b", 1), #("c", 2)]
  |> bidict.from_list
  |> bidict.values
  |> list.sort(int.compare)
  |> should.equal([0, 1, 2])
}

pub fn take_test() {
  [#("a", 0), #("b", 1), #("c", 2)]
  |> bidict.from_list
  |> bidict.take(["a", "b", "d"])
  |> should.equal(bidict.from_list([#("a", 0), #("b", 1)]))
}

pub fn drop_ab_test() {
  [#("a", 0), #("b", 1), #("c", 2)]
  |> bidict.from_list
  |> bidict.drop_a(["a", "b", "d"])
  |> should.equal(bidict.from_list([#("c", 2)]))

  [#("a", 0), #("b", 1), #("c", 2)]
  |> bidict.from_list
  |> bidict.drop_b([1, 2])
  |> should.equal(bidict.from_list([#("a", 0)]))
}

pub fn filter_test() {
  [#("a", 0), #("b", 1)]
  |> bidict.from_list
  |> bidict.filter(fn(_a, b) { b != 0 })
  |> should.equal(bidict.from_list([#("b", 1)]))

  [#("a", 0), #("b", 1)]
  |> bidict.from_list()
  |> bidict.filter(fn(_a, _b) { True })
  |> should.equal(bidict.from_list([#("a", 0), #("b", 1)]))
}

pub fn merge_same_key_test() {
  let a = bidict.from_list([#("a", 2)])
  let b = bidict.from_list([#("a", 0)])

  bidict.merge(a, b)
  |> should.equal(bidict.from_list([#("a", 0)]))

  bidict.merge(b, a)
  |> should.equal(bidict.from_list([#("a", 2)]))
}

pub fn merge_test() {
  let a = bidict.from_list([#("a", 2), #("c", 4), #("d", 3)])
  let b = bidict.from_list([#("a", 0), #("b", 1), #("c", 2)])

  bidict.merge(a, b)
  |> should.equal(
    bidict.from_list([#("a", 0), #("b", 1), #("c", 2), #("d", 3)]),
  )

  bidict.merge(b, a)
  |> should.equal(
    bidict.from_list([#("a", 2), #("b", 1), #("c", 4), #("d", 3)]),
  )
}

pub fn delete_ab_test() {
  [#("a", 0), #("b", 1), #("c", 2)]
  |> bidict.from_list
  |> bidict.delete_a("a")
  |> bidict.delete_a("d")
  |> should.equal(bidict.from_list([#("b", 1), #("c", 2)]))

  [#("a", 0), #("b", 1), #("c", 2)]
  |> bidict.from_list
  |> bidict.delete_b(1)
  |> should.equal(bidict.from_list([#("a", 0), #("c", 2)]))
}

pub fn update_test() {
  let bidict = bidict.from_list([#("a", 0), #("b", 1), #("c", 2)])

  let inc_or_zero = fn(x) {
    case x {
      Some(i) -> i + 1
      None -> 0
    }
  }

  bidict
  |> bidict.update("a", inc_or_zero)
  |> should.equal(bidict.from_list([#("b", 1), #("a", 1), #("c", 2)]))
  bidict
  |> bidict.update("b", inc_or_zero)
  |> should.equal(bidict.from_list([#("a", 0), #("c", 2), #("b", 2)]))

  bidict
  |> bidict.update("z", inc_or_zero)
  |> should.equal(
    bidict.from_list([#("a", 0), #("b", 1), #("c", 2), #("z", 0)]),
  )
}

pub fn fold_test() {
  let bdict = bidict.from_list([#("a", 0), #("b", 1), #("c", 2), #("d", 3)])

  let add = fn(acc, _, v) { v + acc }

  bdict
  |> bidict.fold(0, add)
  |> should.equal(6)

  let prepend = fn(acc, k, _) { list.prepend(acc, k) }

  bdict
  |> bidict.fold([], prepend)
  |> list.sort(string.compare)
  |> should.equal(["a", "b", "c", "d"])

  bidict.from_list([])
  |> bidict.fold(0, add)
  |> should.equal(0)
}

// "Integration" Tests

fn range(start, end, a) {
  case end - start {
    n if n < 1 -> a
    _ -> range(start, end - 1, [end - 1, ..a])
  }
}

fn list_to_map(list: List(a)) -> Bidict(a, a) {
  list
  |> list.map(fn(n) { #(n, n) })
  |> bidict.from_list
}

fn grow_and_shrink_map(initial_size, final_size) {
  range(0, initial_size, [])
  |> list_to_map
  |> list.fold(
    range(final_size, initial_size, []),
    _,
    fn(map, item) { bidict.delete_a(map, item) },
  )
}

// maps should be equal even if the insert/removal order was different
pub fn insert_order_equality_test() {
  grow_and_shrink_map(8, 2)
  |> should.equal(grow_and_shrink_map(4, 2))
  grow_and_shrink_map(17, 10)
  |> should.equal(grow_and_shrink_map(12, 10))
  grow_and_shrink_map(2000, 1000)
  |> should.equal(grow_and_shrink_map(1000, 1000))
}

// ensure operations on a map don't mutate it
pub fn persistence_test() {
  let a = list_to_map([0])
  bidict.insert(a, 0, 5)
  bidict.insert(a, 1, 6)
  bidict.delete_a(a, 0)
  bidict.get_a(a, 0)
  |> should.equal(Ok(0))
}

// using maps as keys should work (tests hash function)
pub fn map_as_key_test() {
  let l = range(0, 1000, [])
  let a = list_to_map(l)
  let a2 = list_to_map(list.reverse(l))
  let a3 = grow_and_shrink_map(2000, 1000)
  let b = grow_and_shrink_map(60, 50)
  let c = grow_and_shrink_map(50, 20)
  let d = grow_and_shrink_map(2, 2)

  let map1 =
    bidict.new()
    |> bidict.insert(a, "a")
    |> bidict.insert(b, "b")
    |> bidict.insert(c, "c")
    |> bidict.insert(d, "d")

  bidict.get_a(map1, a)
  |> should.equal(Ok("a"))
  bidict.get_a(map1, a2)
  |> should.equal(Ok("a"))
  bidict.get_a(map1, a3)
  |> should.equal(Ok("a"))
  bidict.get_a(map1, b)
  |> should.equal(Ok("b"))
  bidict.get_a(map1, c)
  |> should.equal(Ok("c"))
  bidict.get_a(map1, d)
  |> should.equal(Ok("d"))
  bidict.insert(map1, a2, "a2")
  |> bidict.get_a(a)
  |> should.equal(Ok("a2"))
  bidict.insert(map1, a3, "a3")
  |> bidict.get_a(a)
  |> should.equal(Ok("a3"))
}

pub fn large_n_test() {
  let n = 10_000
  let l = range(0, n, [])

  let m = list_to_map(l)
  list.map(l, fn(i) { should.equal(bidict.get_a(m, i), Ok(i)) })

  let m = grow_and_shrink_map(n, 0)
  list.map(l, fn(i) { should.equal(bidict.get_a(m, i), Error(Nil)) })
}

pub fn size_test() {
  let n = 1000
  let m = list_to_map(range(0, n, []))
  bidict.size(m)
  |> should.equal(n)

  let m = grow_and_shrink_map(n, n / 2)
  bidict.size(m)
  |> should.equal(n / 2)

  let m =
    grow_and_shrink_map(n, 0)
    |> bidict.delete_a(0)
  bidict.size(m)
  |> should.equal(0)

  let m = list_to_map(range(0, 18, []))

  bidict.insert(m, 1, 99)
  |> bidict.size()
  |> should.equal(18)
  bidict.insert(m, 2, 99)
  |> bidict.size()
  |> should.equal(18)
}

// https://github.com/gleam-lang/stdlib/issues/435
pub fn peters_bug_test() {
  bidict.new()
  |> bidict.insert(22, Nil)
  |> bidict.insert(21, Nil)
  |> bidict.insert(23, Nil)
  |> bidict.insert(18, Nil)
  |> bidict.insert(17, Nil)
  |> bidict.insert(19, Nil)
  |> bidict.insert(14, Nil)
  |> bidict.insert(13, Nil)
  |> bidict.insert(15, Nil)
  |> bidict.insert(10, Nil)
  |> bidict.insert(9, Nil)
  |> bidict.insert(11, Nil)
  |> bidict.insert(6, Nil)
  |> bidict.insert(5, Nil)
  |> bidict.insert(7, Nil)
  |> bidict.insert(2, Nil)
  |> bidict.insert(1, Nil)
  |> bidict.insert(3, Nil)
  |> bidict.get_a(0)
  |> should.equal(Error(Nil))
}

pub fn zero_must_be_contained_test() {
  let map =
    bidict.new()
    |> bidict.insert(0, Nil)

  map
  |> bidict.get_a(0)
  |> should.equal(Ok(Nil))

  map
  |> bidict.has_a(0)
  |> should.equal(True)
}

pub fn empty_map_equality_test() {
  let map1 = bidict.new()
  let map2 = bidict.from_list([#(1, 2)])

  should.be_false(map1 == map2)
  should.be_false(map2 == map1)
}

pub fn extra_keys_equality_test() {
  let map1 = bidict.from_list([#(1, 2), #(3, 4)])
  let map2 = bidict.from_list([#(1, 2), #(3, 4), #(4, 5)])

  should.be_false(map1 == map2)
  should.be_false(map2 == map1)
}

// https://docs.rs/bimap/latest/bimap/index.html
pub fn readme_test() {
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
