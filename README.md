# DispatchedTuples.jl

|||
|---------------------:|:----------------------------------------------|
| **Docs Build**       | [![docs build][docs-bld-img]][docs-bld-url]   |
| **Documentation**    | [![dev][docs-dev-img]][docs-dev-url]          |
| **GHA CI**           | [![gha ci][gha-ci-img]][gha-ci-url]           |
| **Code Coverage**    | [![codecov][codecov-img]][codecov-url]        |
| **Bors enabled**     | [![bors][bors-img]][bors-url]                 |

[docs-bld-img]: https://github.com/charleskawczynski/DispatchedTuples.jl/workflows/Documentation/badge.svg
[docs-bld-url]: https://github.com/charleskawczynski/DispatchedTuples.jl/actions?query=workflow%3ADocumentation

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://charleskawczynski.github.io/DispatchedTuples.jl/dev/

[gha-ci-img]: https://github.com/charleskawczynski/DispatchedTuples.jl/workflows/ci/badge.svg
[gha-ci-url]: https://github.com/charleskawczynski/DispatchedTuples.jl/actions?query=workflow%3Aci

[codecov-img]: https://codecov.io/gh/charleskawczynski/DispatchedTuples.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/charleskawczynski/DispatchedTuples.jl

[bors-img]: https://bors.tech/images/badge_small.svg
[bors-url]: https://app.bors.tech/repositories/32073

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

```julia
julia> using DispatchedTuples

julia> struct Foo end;

julia> struct Bar end;

julia> struct Baz end;

julia> dtup = DispatchedTuple((
          Pair(Foo(), 1),
          Pair(Foo(), 2),
          Pair(Bar(), 3),
       ));

julia> dispatch(dtup, Foo())
(1, 2)

julia> dispatch(dtup, Bar())
(3,)

julia> dispatch(dtup, Baz())
()
```
