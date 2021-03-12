module DispatchedTuples

import Base

export AbstractDispatchedTuple, dispatch

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
anything) returned by `dispatch`.

If a `DispatchedTuple` has non-unique keys, then all values
are returned in the returned `Tuple`.

The second (optional) argument to `DispatchedTuple` is a
default value, which is returned for any unrecognized keys.
If the default value is not given, then `dispatch` on an
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

dispatch(dtup, Foo()) # returns (1, 2)
dispatch(dtup, Bar()) # returns (3,)
dispatch(dtup, Baz()) # returns ()
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
 - throws an error in `dispatch` if the key is not unique (without a default value).
"""
struct DispatchedSet{T,D} <: AbstractDispatchedTuple{T, D}
    tup::T
    default::D
    function DispatchedSet(tup_in::T, default=NoDefaults()) where {T<:Tuple}
        tup = unwrap_pair(tup_in)
        return new{typeof(tup), typeof(default)}(tup, default)
    end
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
    elseif match_count > 1
        return :(throw(error("DispatchedSet has non-unique keys for type $T")))
    else
        return expr
    end
end

@generated function dispatch(dt::DispatchedSet{TT,D}, ::T) where {TT, D, T}
    expr, match_count = match_expr_val(dt, TT, T)
    if match_count == 0
        return :(dt.default)
    elseif match_count > 1
        return :(throw(error("DispatchedSet has non-unique keys for type $T")))
    else
        return expr
    end
end

# Nested dispatch calls:
dispatch(dt::AbstractDispatchedTuple, a, b...) = dispatch(dispatch(dt, a), b...)

# Interface / extending:
Base.isempty(dt::AbstractDispatchedTuple) = Base.isempty(dt.tup)
Base.length(dt::AbstractDispatchedTuple) = Base.length(dt.tup)
Base.map(f, dt::AbstractDispatchedTuple) = Base.map(f, dt.tup)
Base.keys(dt::AbstractDispatchedTuple) = map(x->x[1], dt)
Base.values(dt::AbstractDispatchedTuple) = map(x->x[2], dt)
Base.getindex(dt::AbstractDispatchedTuple, e) = dispatch(dt, e)

# Helper
first_eltype(::Type{Tuple{T, V}}) where {T,V} = T

end # module
