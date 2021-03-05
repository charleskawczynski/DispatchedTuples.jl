using Test, DispatchedTuples

struct Foo end
struct Bar end
struct FooBar end

#####
##### DispatchedTuple's
#####

@testset "DispatchedTuples - base behavior" begin
    dt = DispatchedTuple(((Foo(), 1), (Bar(), 2)))
    @test dispatch(dt, Foo()) == (1,)
    @test dispatch(dt, Bar()) == (2,)
    @test_throws ErrorException dispatch(dt, FooBar())

    dt = DispatchedTuple(((Foo(), 1), (Bar(), 2)), 0)
    @test dispatch(dt, Foo()) == (1,)
    @test dispatch(dt, Bar()) == (2,)
    @test dispatch(dt, FooBar()) == (dt.default,)
end

@testset "DispatchedTuples - base behavior - Pair interface" begin
    dt = DispatchedTuple((Pair(Foo(), 1), Pair(Bar(), 2)))
    @test dispatch(dt, Foo()) == (1,)
    @test dispatch(dt, Bar()) == (2,)
    @test_throws ErrorException dispatch(dt, FooBar())

    dt = DispatchedTuple((Pair(Foo(), 1), Pair(Bar(), 2)), 0)
    @test dispatch(dt, Foo()) == (1,)
    @test dispatch(dt, Bar()) == (2,)
    @test dispatch(dt, FooBar()) == (dt.default,)
end

@testset "DispatchedTuples - multiple values" begin
    dt = DispatchedTuple(((Foo(), 1), (Bar(), 2), (Foo(), 3)))
    @test dispatch(dt, Foo()) == (1,3)
    @test dispatch(dt, Bar()) == (2,)
    @test_throws ErrorException dispatch(dt, FooBar())
end

@testset "DispatchedTuples - extending" begin
    tup = (Pair(Foo(), 1), Pair(Bar(), 2))
    dt = DispatchedTuple(tup)
    @test length(dt) == length(tup)
    @test isempty(dt) == isempty(tup)
    @test map(x->x, dt) == map(x->x, dt.tup)
    @test values(dt) == map(x->x[2], dt.tup)
    @test keys(dt) == map(x->x[1], dt.tup)

    tup = ()
    dt = DispatchedTuple(tup)
    @test length(dt) == length(tup)
    @test isempty(dt) == isempty(tup)
end

#####
##### DispatchedTupleSet's
#####

@testset "DispatchedTupleSet - base behavior" begin
    dt = DispatchedTupleSet(((Foo(), 1), (Bar(), 2)))
    @test dispatch(dt, Foo()) == 1
    @test dispatch(dt, Bar()) == 2
    @test_throws ErrorException dispatch(dt, FooBar())

    dt = DispatchedTupleSet(((Foo(), 1), (Bar(), 2)), 0)
    @test dispatch(dt, Foo()) == 1
    @test dispatch(dt, Bar()) == 2
    @test dispatch(dt, FooBar()) == dt.default
end

@testset "DispatchedTupleSet - base behavior - Pair interface" begin
    dt = DispatchedTupleSet((Pair(Foo(), 1), Pair(Bar(), 2)))
    @test dispatch(dt, Foo()) == 1
    @test dispatch(dt, Bar()) == 2
    @test_throws ErrorException dispatch(dt, FooBar())
end

@testset "DispatchedTupleSet - multiple values, unique keys" begin
    dt = DispatchedTupleSet(((Foo(), 1), (Bar(), 2), (Foo(), 3)))
    @test_throws ErrorException dispatch(dt, Foo()) == 1
    @test dispatch(dt, Bar()) == 2
    @test_throws ErrorException dispatch(dt, FooBar())

    dt = DispatchedTupleSet(((Foo(), 1), (Bar(), 2), (Foo(), 3)), 0)
    @test_throws ErrorException dispatch(dt, Foo()) == 1
    @test dispatch(dt, Bar()) == 2
    @test dispatch(dt, FooBar()) == dt.default
end

@testset "DispatchedTuples - nested" begin
    dtup_L1_a = DispatchedTupleSet(((Foo(), 1), (Bar(), 2)))
    dtup_L1_b = DispatchedTupleSet(((Foo(), 3), (Bar(), 4)))
    dtup_L1_c = DispatchedTupleSet(((Foo(), 5), (Bar(), 6)))
    dtup_L1_d = DispatchedTupleSet(((Foo(), 7), (Bar(), 8)))

    dtup_L2_a = DispatchedTupleSet(((Foo(), dtup_L1_a), (Bar(), dtup_L1_b)))
    dtup_L2_b = DispatchedTupleSet(((Foo(), dtup_L1_c), (Bar(), dtup_L1_d)))

    dtup_L3_a = DispatchedTupleSet(((Foo(), dtup_L2_a), (Bar(), dtup_L2_b)))

    @test dispatch(dtup_L3_a, Foo(), Foo(), Foo()) == 1
    @test dispatch(dtup_L3_a, Foo(), Foo(), Bar()) == 2
    @test dispatch(dtup_L3_a, Foo(), Bar(), Foo()) == 3
    @test dispatch(dtup_L3_a, Foo(), Bar(), Bar()) == 4
    @test dispatch(dtup_L3_a, Bar(), Foo(), Foo()) == 5
    @test dispatch(dtup_L3_a, Bar(), Foo(), Bar()) == 6
    @test dispatch(dtup_L3_a, Bar(), Bar(), Foo()) == 7
    @test dispatch(dtup_L3_a, Bar(), Bar(), Bar()) == 8
end
