using Test, DispatchedTuples

struct Foo end
struct Bar end
struct FooBar end

tup = (
    (Foo(), 1),
    (Bar(), 2),
    )

@testset "DispatchedTuples - error by default" begin
    dt = DispatchedTuple(tup)
    @test dispatch(dt, Foo()) == (1,)
    @test dispatch(dt, Bar()) == (2,)
    @test_throws ErrorException dispatch(dt, FooBar())
end

@testset "DispatchedTuples - has default behavior" begin
    dt = DispatchedTuple(tup, 0)
    @test dispatch(dt, Foo()) == (1,)
    @test dispatch(dt, Bar()) == (2,)
    @test dispatch(dt, FooBar()) == (dt.default,)
end

tup = (
    (Foo(), 1),
    (Bar(), 2),
    (Foo(), 3),
    )

@testset "DispatchedTuples - multiple values" begin
    dt = DispatchedTuple(tup)
    @test dispatch(dt, Foo()) == (1,3)
    @test dispatch(dt, Bar()) == (2,)
    @test_throws ErrorException dispatch(dt, FooBar())
end

tup = (
    Pair(Foo(), 1),
    Pair(Bar(), 2),
    )

@testset "DispatchedTuples - Pair interface - error by default" begin
    dt = DispatchedTuple(tup)
    @test dispatch(dt, Foo()) == (1,)
    @test dispatch(dt, Bar()) == (2,)
    @test_throws ErrorException dispatch(dt, FooBar())
end

@testset "DispatchedTuples - Pair interface - has default behavior" begin
    dt = DispatchedTuple(tup, 0)
    @test dispatch(dt, Foo()) == (1,)
    @test dispatch(dt, Bar()) == (2,)
    @test dispatch(dt, FooBar()) == (dt.default,)
end

@testset "DispatchedTuples - extending" begin
    tup = (Pair(Foo(), 1), Pair(Bar(), 2))
    dt = DispatchedTuple(tup)
    @test length(dt) == length(tup)
    @test isempty(dt) == isempty(tup)

    tup = ()
    dt = DispatchedTuple(tup)
    @test length(dt) == length(tup)
    @test isempty(dt) == isempty(tup)
end
