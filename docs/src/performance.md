# Performance

The performance of `DispatchedTuple`s should scale similar to the performance of ordinary tuples (good with small tuples, but expensive with larger ones).

```@example perf
using DispatchedTuples
using InteractiveUtils

struct Foo end;
struct Bar end;
struct Baz end;

tup = (
   Pair(Foo(), 1),
   Pair(Bar(), 3),
   Pair(Foo(), 2),
)

tupset = (
   Pair(Foo(), 1),
   Pair(Bar(), 3),
   Pair(Baz(), 2),
)
dtup = DispatchedTuple(tup);
dset = DispatchedSet(tupset);
nothing
```

Using `dispatch` on a `DispatchedTuple` is equivalent to hard-coding the intended indexes ahead of time, which means that the LLVM code is concise:

## DispatchedTuple

```@example perf
get_foo_magic(dtup) = (dtup.tup[1][2], dtup.tup[3][2])
@code_typed get_foo_magic(dtup)
```
```@example perf
@code_typed dispatch(dtup, Foo())
```

```@example perf
@code_native get_foo_magic(dtup)
```
```@example perf
@code_native dispatch(dtup, Foo())
```

## DispatchedSet

```@example perf
get_foo_magic(dset) = dset.tup[1][2]
@code_typed get_foo_magic(dset)
```
```@example perf
@code_typed dispatch(dset, Foo())
```

```@example perf
@code_native get_foo_magic(dset)
```
```@example perf
@code_native dispatch(dset, Foo())
```
