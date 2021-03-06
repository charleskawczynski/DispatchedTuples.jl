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

A `DispatchedTuple` is like a dictionary, except

 - the keys are **instances of types**
 - they are backed by tuples, so they are GPU-friendly
 - multiple keys are allowed (except for `DispatchedTupleSet`)
 - each unique key returns a tuple of values given by that key (in order)

All `AbstractDispatchedTuple`s take a `Tuple` of `Pair`s, where the `first` field of the `Pair` (the "key") is **an instance of the type you want to dispatch on**. The `second` field of the `Pair` is the quantity (the "value", which can be anything) returned by `dispatch(::AbstractDispatchedTuple, key)`, the one user-facing method exported by DispatchedTuples.jl.

DispatchedTuples.jl has several user-facing types:

 - `DispatchedTuple` - a dispatched tuple (example below)

 - `DispatchedTupleSet` - a dispatched tuple set-- duplicate keys are not allowed. An error is thrown when `dispatch` is called with a duplicate key.

 - `DispatchedTupleDict` - a dispatched tuple dict-- duplicate keys are allowed, but `dispatch` returns value from the last non-unique key.


## Example

Here is an example in action

```julia
julia> using DispatchedTuples

julia> struct Foo end;

julia> struct Bar end;

julia> dtup = DispatchedTuple((
               Pair(Foo(), 1),
               Pair(Bar(), 2),
           ));

julia> @show dispatch(dtup, Foo());
dispatch(dtup, Foo()) = (1,)

julia> @show dispatch(dtup, Bar());
dispatch(dtup, Bar()) = (2,)
```

If a `DispatchedTuple` has duplicate keys, then all values are returned in the `Tuple`. Here's an example with duplicate keys:

```julia
julia> using DispatchedTuples

julia> struct Foo end;

julia> struct Bar end;

julia> dtup = DispatchedTuple((
               Pair(Foo(), 1),
               Pair(Foo(), 3),
               Pair(Bar(), 2),
           ));

julia> @show dispatch(dtup, Foo());
dispatch(dtup, Foo()) = (1, 3)

julia> @show dispatch(dtup, Bar());
dispatch(dtup, Bar()) = (2,)
```

The second (optional) argument to `DispatchedTuple` is a default value, which is returned for any unrecognized keys. If the default value is not given, and `dispatch` is called with a key it hasn't seen, an error is thrown.

For convenience, `DispatchedTuple` can alternatively take a `Tuple` of two-element `Tuple`s.
