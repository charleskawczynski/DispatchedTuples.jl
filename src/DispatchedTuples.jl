module DispatchedTuples

import Base

export AbstractDispatchedTuple

export DispatchedTuple
export DispatchedSet

struct NoDefaults end

"""
    AbstractDispatchedTuple{T <: Tuple, D}

An abstract dispatch tuple type, for sub-typing
dispatched tuples.
"""
abstract type AbstractDispatchedTuple{T <: Tuple, D} end

unwrap_pair(tup) = eltype(tup) <: Pair ?
    map(x->(x.first, x.second), tup) : tup

function match_expr(dt, TT, T)
    expr = quote tuple() end
    found_match = false
    for (i,k) in enumerate(fieldnames(TT))
        if first_eltype(fieldtype(TT, i)) == T
            found_match = true
            push!(expr.args[2].args, :(dt.tup[$i][2]))
        end
    end
    return expr, found_match
end

function match_expr_val(dt, TT, T)
    match_count = 0
    expr = quote end
    for (i,k) in enumerate(fieldnames(TT))
        if first_eltype(fieldtype(TT, i)) == T
            match_count += 1
            expr = :(dt.tup[$i][2])
        end
    end
    return expr, match_count
end

@generated function throw_key_error(::T) where {T}
    :(throw(error("Non-unique keys given to DispatchedSet for $T")))
end

#####
##### DispatchedTuple
#####

"""
    DispatchedTuple(tup[, default_value])

A dispatch-able tuple.

`DispatchedTuple` takes a `Tuple` of `Pair`s, where the
`first` field of the `Pair` (the "key") is **an instance
of the type you want to dispatch on**. The `second` field
of the `Pair` is the quantity (the "value", which can be
anything) returned by `dtup[key]`.

If a `DispatchedTuple` has non-unique keys, then all values
are returned in the returned `Tuple`.

The second (optional) argument to `DispatchedTuple` is a
default value, which is returned for any unrecognized keys.
If the default value is not given, then `dtup[key]` on an
unregistered key will return an empty tuple.

For convenience, `DispatchedTuple` can alternatively take a
`Tuple` of two-element `Tuple`s.

## Example

```julia
using DispatchedTuples
struct Foo end;
struct Bar end;
struct Baz end;

dtup = DispatchedTuple((
   Pair(Foo(), 1),
   Pair(Foo(), 2),
   Pair(Bar(), 3),
));

dtup[Foo()] # returns (1, 2)
dtup[Bar()] # returns (3,)
dtup[Baz()] # returns ()
```
"""
struct DispatchedTuple{T,D} <: AbstractDispatchedTuple{T, D}
    tup::T
    default::D
    function DispatchedTuple(tup_in::T, default=NoDefaults()) where {T<:Tuple}
        tup = unwrap_pair(tup_in)
        return new{typeof(tup), typeof(default)}(tup, default)
    end
end

# Accept vararg Pairs:
DispatchedTuple(p...; default=NoDefaults()) = DispatchedTuple(Tuple(p), default)

"""
    dispatch(::DispatchedTuple, type_instance)

Dispatch on the [`DispatchedTuple`](@ref), based
on the instance of the input type `type_instance`.
"""
@generated function dispatch(dt::DispatchedTuple{TT, NoDefaults}, ::T) where {TT, T}
    expr, found_match = match_expr(dt, TT, T)
    expr
end

@generated function dispatch(dt::DispatchedTuple{TT,D}, ::T) where {TT, D, T}
    expr, found_match = match_expr(dt, TT, T)
    if !found_match
        push!(expr.args[2].args, :(dt.default))
    end
    expr
end

#####
##### DispatchedSet
#####

"""
    DispatchedSet(tup[, default_value])

Similar to [`DispatchedTuple`](@ref), except:
 - keys must be unique.
 - returns the value, and not a tuple of values.
 - throws an error in `dtup[key]` if the key is not unique (without a default value).
"""
struct DispatchedSet{T,D} <: AbstractDispatchedTuple{T, D}
    tup::T
    default::D
    function DispatchedSet(tup_in::T, default=NoDefaults()) where {T<:Tuple}
        tup = unwrap_pair(tup_in)
        _keys = map(t -> t[1], tup)
        elems_are_unique(_keys) || throw_key_error(_keys)
        return new{typeof(tup), typeof(default)}(tup, default)
    end
end

# Accept vararg Pairs:
DispatchedSet(p...; default=NoDefaults()) = DispatchedSet(Tuple(p), default)

@generated function elems_are_unique(::T) where {T <: Tuple}
    no_dupes = true
    for i in 1:length(fieldnames(T))
        T_i = fieldtype(T, i)
        for j in i:length(fieldnames(T))
            i == j && continue
            T_j = fieldtype(T, j)
            if T_i == T_j
                no_dupes = false
            end
        end
    end
    return :($no_dupes)
end

"""
    dispatch(::DispatchedSet, type_instance)

Dispatch on the [`DispatchedSet`](@ref), based
on the instance of the input type `type_instance`.
"""
@generated function dispatch(dt::DispatchedSet{TT, NoDefaults}, ::T) where {TT, T}
    expr, match_count = match_expr_val(dt, TT, T)
    if match_count == 0
        return :(throw(error("No method dispatch defined for type $T")))
    else
        return expr
    end
end

@generated function dispatch(dt::DispatchedSet{TT,D}, ::T) where {TT, D, T}
    expr, match_count = match_expr_val(dt, TT, T)
    if match_count == 0
        return :(dt.default)
    else
        return expr
    end
end

# Nested dispatch calls:
dispatch(dt::AbstractDispatchedTuple, a, b...) = dispatch(dispatch(dt, a), b...)
Base.getindex(dt::AbstractDispatchedTuple, a, b...) = dispatch(dt, a, b...)

# Interface / extending:
Base.isempty(dt::AbstractDispatchedTuple) = Base.isempty(dt.tup)
Base.length(dt::AbstractDispatchedTuple) = Base.length(dt.tup)
Base.map(f, dt::AbstractDispatchedTuple) = Base.map(f, dt.tup)
Base.keys(dt::AbstractDispatchedTuple) = map(x->x[1], dt)
Base.values(dt::AbstractDispatchedTuple) = map(x->x[2], dt)
Base.getindex(dt::AbstractDispatchedTuple, e) = dispatch(dt, e)
Base.iterate(dt::AbstractDispatchedTuple, state = 1) = Base.iterate(dt.tup, state)

# Note: this is not GPU-friendly
show_default(io::IO, dt::AbstractDispatchedTuple, any) = println(io, "  default => $(dt.default)")

show_default(io::IO, dt::DispatchedTuple, ::NoDefaults) = println(io, "  default => ()")
show_default(io::IO, dt::DispatchedSet, ::NoDefaults) = println(io, "  default => error")

function Base.show(io::IO, dt::AbstractDispatchedTuple)
    show(io, typeof(dt))
    print(io, " with $(length(dt)) entries:")
    println(io)
    foreach(dt) do tup
        print(io, "  ")
        show(io, Pair(tup...))
        println(io)
    end
    show_default(io, dt, dt.default)
end

# Ideally, we'd call Tuple(Set(tup)), but
# Set is backed by a Dict, which can't reside
# on the gpu, so let's get unique elements
# with Tuples:

# `a` is empty, we're done
unique_elems(a::Tuple{}, b::Tuple) = (a, b)
# `a` has one element, move `a[1]` into `b` if not unique
unique_elems(a::Tuple{A}, b::Tuple) where {A} = a[1] in b ? ((), b) : ((), (b..., a[1]))

# recurse
unique_elems(a::Tuple, b::Tuple) = a[1] in b ?
    unique_elems(a[2:end], b) :
    unique_elems(a[2:end], (b..., a[1]))

# Return `b`, which is the unique set of `a`
unique_elems(a::Tuple) = unique_elems(a, ())[2]

unique_keys(dt::DispatchedTuple) = unique_elems(keys(dt))

# Helper
first_eltype(::Type{Tuple{T, V}}) where {T,V} = T

end # module
