module DispatchedTuples

import Base

export DispatchedTuple, dispatch

struct NoDefaults end

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
struct DispatchedTuple{T,D}
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

first_eltype(::Type{Tuple{T, V}}) where {T,V} = T

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

Base.isempty(dt::DispatchedTuple) = Base.isempty(dt.tup)
Base.length(dt::DispatchedTuple) = Base.length(dt.tup)

end # module
