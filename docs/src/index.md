# DispatchedTuples.jl

## What are dispatched tuples?

`DispatchedTuple`s are like immutable dictionaries (so, they're technically more like `NamedTuple`s) except that the keys are **instances of types**. Also, because `DispatchedTuple`s are backed by tuples, they are GPU-friendly.

There are two kinds of `DispatchedTuple`s with different behavior:

```
┌────────────────────────────────────┬───────────────────────────┬────────────────────┐
│                       Return value │           DispatchedTuple │ DispatchedSet      │
│                                    │ (non-unique keys allowed) │ (unique keys only) │
├────────────────────────────────────┼───────────────────────────┼────────────────────┤
│                               Type │                     Tuple │              Value │
│ Unregistered key (without default) │                        () │              error │
│    Unregistered key (with default) │                (default,) │            default │
│                    Duplicative key │     all registered values │          one value │
└────────────────────────────────────┴───────────────────────────┴────────────────────┘
```

## Creating and using dispatched tuples

`DispatchedTuple` and `DispatchedSet`s have three constructors:

1. A variable number of (vararg) `Pair`s + keyword default
2. A `Tuple` of `Pair`s + positional default
3. A `Tuple` of 2-element `Tuple`s (the first element being the "key", and the second the "value") + positional default

The `first` field of the `Pair` (the "key") is **an instance of the type you want to dispatch on**. The `second` field of the `Pair` is the quantity (the "value", which can be anything) returned by `dispatch(dtup::AbstractDispatchedTuple, key)` (or via `dtup[key]`).

A default value, if passed to `DispatchedTuple` and `DispatchedSet`, is returned for any unrecognized keys as shown in the table above.

## Example

Here is an example in action

```@example
using DispatchedTuples
struct Foo end;
struct Bar end;
struct Baz end;

dtup = DispatchedTuple((
   Pair(Foo(), 1),
   Pair(Foo(), 2),
   Pair(Bar(), 3),
))

dispatch(dtup, Foo()) # returns (1, 2)
dispatch(dtup, Bar()) # returns (3,)
dispatch(dtup, Baz()) # returns ()
nothing
```

For convenience, `DispatchedTuple` can alternatively take a `Tuple` of two-element `Tuple`s.
