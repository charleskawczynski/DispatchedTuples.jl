# DispatchedTuples.jl

DispatchedTuples.jl defines one user-facing type: `DispatchedTuple`, and one user-facing method: `dispatch`. A `DispatchedTuple` is similar to a compile-time dictionary, that uses dispatch for the look-up.

`DispatchedTuple` takes a `Tuple` of `Pair`s, where the `first` field of the `Pair` (the "key") is **an instance of the type you want to dispatch on**. The `second` field of the `Pair` is the quantity (the "value", which can be anything) returned by `dispatch`.

## Example

Here is an example in action

```@example
using DispatchedTuples
struct Foo end;
struct Bar end;
dtup = DispatchedTuple((
               Pair(Foo(), 1),
               Pair(Bar(), 2),
           ))

println(dispatch(dtup, Foo()))
println(dispatch(dtup, Bar()))
```

If a `DispatchedTuple` has duplicate keys, then all values are returned in the `Tuple`. Here's an example with duplicate keys:

```@example
using DispatchedTuples
struct Foo end
struct Bar end

dtup = DispatchedTuple((
               Pair(Foo(), 1),
               Pair(Foo(), 3),
               Pair(Bar(), 2),
           ))

println(dispatch(dtup, Foo()))
println(dispatch(dtup, Bar()))
```

The second (optional) argument to `DispatchedTuple` is a default value, which is returned for any unrecognized keys. If the default value is not given, and `dispatch` is called with a key it hasn't seen, an error is thrown.

For convenience, `DispatchedTuple` can alternatively take a `Tuple` of two-element `Tuple`s.

## API

```@docs
DispatchedTuples.DispatchedTuple
DispatchedTuples.dispatch
```
