module DispatchedTuples

import Base

export AbstractDispatchedTuple, dispatch

export DispatchedTuple
export DispatchedTupleSet
export DispatchedTupleDict

struct NoDefaults end

"""
    AbstractDispatchedTuple{T <: Tuple, D}

An abstract dispatch tuple type, for sub-typing
dispatched tuples.
"""
abstract type AbstractDispatchedTuple{T <: Tuple, D} end

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

If a `DispatchedTuple` has duplicate keys, then all values
are returned in the `Tuple`.

The second (optional) argument to `DispatchedTuple` is a
default value, which is returned for any unrecognized keys.
If the default value is not given, and `dispatch` is called
with a key it hasn't seen, an error is thrown.

For convenience, `DispatchedTuple` can alternatively take a
`Tuple` of two-element `Tuple`s.
"""
struct DispatchedTuple{T,D} <: AbstractDispatchedTuple{T, D}
    tup::T
    default::D
    function DispatchedTuple(tup_in::T, default=NoDefaults()) where {T<:Tuple}
        if eltype(tup_in) <: Pair
            tup = map(x->(x.first, x.second), tup_in)
        else
            tup = tup_in
        end
        return new{typeof(tup), typeof(default)}(tup, default)
    end
end

"""
    dispatch(::DispatchedTuple, type_instance)

Dispatch on the [`DispatchedTuple`](@ref), based
on the instance of the input type `type_instance`.
"""
@generated function dispatch(dt::DispatchedTuple{TT, NoDefaults}, ::T) where {TT, T}
    expr = quote tuple() end
    found_match = false
    for (i,k) in enumerate(fieldnames(TT))
        if first_eltype(fieldtype(TT, i)) == T
            found_match = true
            push!(expr.args[2].args, :(dt.tup[$i][2]))
        end
    end
    if !found_match
        expr = quote end
        push!(expr.args, :(throw(error("No method dispatch defined for type $T"))))
    end
    expr
end

@generated function dispatch(dt::DispatchedTuple{TT,D}, ::T) where {TT, D, T}
    expr = quote tuple() end
    found_match = false
    for (i,k) in enumerate(fieldnames(TT))
        if first_eltype(fieldtype(TT, i)) == T
            found_match = true
            push!(expr.args[2].args, :(dt.tup[$i][2]))
        end
    end
    if !found_match
        push!(expr.args[2].args, :(dt.default))
    end
    expr
end

#####
##### DispatchedTupleSet
#####

"""
    DispatchedTupleSet(tup[, default_value])

Similar to `DispatchedTuple`, except:
 - keys must be unique.
 - returns the value, and not a tuple of values.
 - throws an error in `dispatch` if keys are not unique.
"""
struct DispatchedTupleSet{T,D} <: AbstractDispatchedTuple{T, D}
    tup::T
    default::D
    function DispatchedTupleSet(tup_in::T, default=NoDefaults()) where {T<:Tuple}
        if eltype(tup_in) <: Pair
            tup = map(x->(x.first, x.second), tup_in)
        else
            tup = tup_in
        end
        return new{typeof(tup), typeof(default)}(tup, default)
    end
end

"""
    dispatch(::DispatchedTupleSet, type_instance)

Dispatch on the [`DispatchedTupleSet`](@ref), based
on the instance of the input type `type_instance`.
"""
@generated function dispatch(dt::DispatchedTupleSet{TT, NoDefaults}, ::T) where {TT, T}
    match_count = 0
    expr = quote end
    for (i,k) in enumerate(fieldnames(TT))
        if first_eltype(fieldtype(TT, i)) == T
            match_count += 1
            expr = :(dt.tup[$i][2])
        end
    end
    if match_count == 0
        return :(throw(error("No method dispatch defined for type $T")))
    elseif match_count > 1
        return :(throw(error("DispatchedTupleSet has non-unique keys for type $T")))
    else
        return expr
    end
end

@generated function dispatch(dt::DispatchedTupleSet{TT,D}, ::T) where {TT, D, T}
    match_count = 0
    expr = quote end
    for (i,k) in enumerate(fieldnames(TT))
        if first_eltype(fieldtype(TT, i)) == T
            match_count += 1
            expr = :(dt.tup[$i][2])
        end
    end
    if match_count == 0
        return :(dt.default)
    elseif match_count > 1
        return :(throw(error("DispatchedTupleSet has non-unique keys for type $T")))
    else
        return expr
    end
end

#####
##### DispatchedTupleDict
#####

"""
    DispatchedTupleDict(tup[, default_value])

Similar to `DispatchedTuple`, except:
 - keys need not be unique, _but_ only the last key is used
 - returns the value, and not a tuple of values.
"""
struct DispatchedTupleDict{T,D} <: AbstractDispatchedTuple{T, D}
    tup::T
    default::D
    function DispatchedTupleDict(tup_in::T, default=NoDefaults()) where {T<:Tuple}
        if eltype(tup_in) <: Pair
            tup = map(x->(x.first, x.second), tup_in)
        else
            tup = tup_in
        end
        return new{typeof(tup), typeof(default)}(tup, default)
    end
end

"""
    dispatch(::DispatchedTupleDict, type_instance)

Dispatch on the [`DispatchedTupleDict`](@ref), based
on the instance of the input type `type_instance`.
"""
@generated function dispatch(dt::DispatchedTupleDict{TT, NoDefaults}, ::T) where {TT, T}
    match_count = 0
    expr = quote end
    for (i,k) in enumerate(fieldnames(TT))
        if first_eltype(fieldtype(TT, i)) == T
            match_count += 1
            expr = :(dt.tup[$i][2])
        end
    end
    if match_count == 0
        push!(expr.args, :(throw(error("No method dispatch defined for type $T"))))
    end
    return expr
end

@generated function dispatch(dt::DispatchedTupleDict{TT,D}, ::T) where {TT, D, T}
    match_count = 0
    expr = quote end
    for (i,k) in enumerate(fieldnames(TT))
        if first_eltype(fieldtype(TT, i)) == T
            match_count += 1
            expr = :(dt.tup[$i][2])
        end
    end
    if match_count == 0
        return :(dt.default)
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

# Helper
first_eltype(::Type{Tuple{T, V}}) where {T,V} = T

end # module
