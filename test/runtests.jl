using Test, DispatchedTuples

struct Foo end
struct Bar end
struct FooBar end

#####
##### DispatchedTuple's
#####

@testset "DispatchedTuples - base behavior" begin
    dt = DispatchedTuple(((Foo(), 1), (Bar(), 2)))
    @test dt[Foo()] == (1,)
    @test dt[Bar()] == (2,)
    @test dt[FooBar()] == ()

    dt = DispatchedTuple(((Foo(), 1), (Bar(), 2)), 0)
    @test dt[Foo()] == (1,)
    @test dt[Bar()] == (2,)
    @test dt[FooBar()] == (dt.default,)

    # # Outer constructor with Pair's
    dt = DispatchedTuple(Pair(Foo(), 1), Pair(Bar(), 2))
    @test dt[Foo()] == (1,)
    @test dt[Bar()] == (2,)
    @test dt[FooBar()] == ()

    dt = DispatchedTuple(Pair(Foo(), 1), Pair(Bar(), 2); default = 0)
    @test dt[Foo()] == (1,)
    @test dt[Bar()] == (2,)
    @test dt[FooBar()] == (dt.default,)
end

@testset "DispatchedTuples - base behavior - show" begin
    dt = DispatchedTuple(Pair(Foo(), 1), Pair(Bar(), 2); default = 0)
    sprint(show, dt)
    dt = DispatchedTuple(Pair(Foo(), 1), Pair(Bar(), 2))
    sprint(show, dt)
    dt = DispatchedSet(Pair(Foo(), 1), Pair(Bar(), 2); default = 0)
    sprint(show, dt)
    dt = DispatchedSet(Pair(Foo(), 1), Pair(Bar(), 2))
    sprint(show, dt)
end

@testset "DispatchedTuples - base behavior - Pair interface" begin
    dt = DispatchedTuple((Pair(Foo(), 1), Pair(Bar(), 2)))
    @test dt[Foo()] == (1,)
    @test dt[Bar()] == (2,)
    @test dt[FooBar()] == ()

    dt = DispatchedTuple((Pair(Foo(), 1), Pair(Bar(), 2)), 0)
    @test dt[Foo()] == (1,)
    @test dt[Bar()] == (2,)
    @test dt[FooBar()] == (dt.default,)
end

@testset "DispatchedTuples - multiple values" begin
    dt = DispatchedTuple(((Foo(), 1), (Bar(), 2), (Foo(), 3)))
    @test dt[Foo()] == (1,3)
    @test dt[Bar()] == (2,)
    @test dt[FooBar()] == ()
end

@testset "DispatchedTuples - extending" begin
    tup1 = (Pair(Foo(), 1), Pair(Bar(), 2))
    tup2 = ()

    dt = DispatchedTuple(tup1)
    @test length(dt) == length(tup1)
    @test isempty(dt) == isempty(tup1)
    @test map(x->x, dt) == map(x->x, dt.tup)
    @test map(x->x, dt.tup) == Tuple([x for x in dt])
    @test iterate(dt.tup) == iterate(dt)
    @test values(dt) == map(x->x[2], dt.tup)
    @test keys(dt) == map(x->x[1], dt.tup)
    @test dt[Foo()] == (1, )
    @test dt[Bar()] == (2, )

    dt = DispatchedTuple(tup2)
    @test length(dt) == length(tup2)
    @test isempty(dt) == isempty(tup2)

    dt = DispatchedSet(tup1)
    @test length(dt) == length(tup1)
    @test isempty(dt) == isempty(tup1)
    @test map(x->x, dt) == map(x->x, dt.tup)
    @test map(x->x, dt.tup) == Tuple([x for x in dt])
    @test iterate(dt.tup) == iterate(dt)
    @test values(dt) == map(x->x[2], dt.tup)
    @test keys(dt) == map(x->x[1], dt.tup)
    @test dt[Foo()] == 1
    @test dt[Bar()] == 2

    dt = DispatchedSet(tup2)
    @test length(dt) == length(tup2)
    @test isempty(dt) == isempty(tup2)
    @test_throws ErrorException dt[Foo()]
    @test_throws ErrorException dt[Bar()]

end

#####
##### DispatchedSet's
#####

@testset "DispatchedTuples - unique keys" begin
    tup = ()
    @test DispatchedTuples.unique_elems(tup) == ()

    tup = (Foo(),Bar(),Foo())
    @test DispatchedTuples.unique_elems(tup) == (Foo(), Bar())

    tup = ((Foo(), 1),(Bar(), 2),(Foo(), 3))
    dt = DispatchedTuple(tup)
    @test DispatchedTuples.unique_keys(dt) == (Foo(), Bar())
end

@testset "DispatchedSet - base behavior" begin
    dt = DispatchedSet(((Foo(), 1), (Bar(), 2)))
    @test dt[Foo()] == 1
    @test dt[Bar()] == 2
    @test_throws ErrorException dt[FooBar()]

    dt = DispatchedSet(((Foo(), 1), (Bar(), 2)), 0)
    @test dt[Foo()] == 1
    @test dt[Bar()] == 2
    @test dt[FooBar()] == dt.default

    # # Outer constructor with Pair's
    dt = DispatchedSet(Pair(Foo(), 1), Pair(Bar(), 2))
    @test dt[Foo()] == 1
    @test dt[Bar()] == 2
    @test_throws ErrorException dt[FooBar()]

    dt = DispatchedSet(Pair(Foo(), 1), Pair(Bar(), 2); default = 0)
    @test dt[Foo()] == 1
    @test dt[Bar()] == 2
    @test dt[FooBar()] == dt.default
end

@testset "DispatchedSet - base behavior - Pair interface" begin
    dt = DispatchedSet((Pair(Foo(), 1), Pair(Bar(), 2)))
    @test dt[Foo()] == 1
    @test dt[Bar()] == 2
    @test_throws ErrorException dt[FooBar()]
end

@testset "DispatchedSet - multiple values, unique keys" begin
    @test_throws ErrorException dt = DispatchedSet(((Foo(), 1), (Bar(), 2), (Foo(), 3)))
    @test_throws ErrorException dt = DispatchedSet(((Foo(), 1), (Bar(), 2), (Foo(), 3)), 0)
end

@testset "DispatchedTuples - nested" begin
    dtup_L1_a = DispatchedSet(((Foo(), 1), (Bar(), 2)))
    dtup_L1_b = DispatchedSet(((Foo(), 3), (Bar(), 4)))
    dtup_L1_c = DispatchedSet(((Foo(), 5), (Bar(), 6)))
    dtup_L1_d = DispatchedSet(((Foo(), 7), (Bar(), 8)))

    dtup_L2_a = DispatchedSet(((Foo(), dtup_L1_a), (Bar(), dtup_L1_b)))
    dtup_L2_b = DispatchedSet(((Foo(), dtup_L1_c), (Bar(), dtup_L1_d)))

    dtup_L3_a = DispatchedSet(((Foo(), dtup_L2_a), (Bar(), dtup_L2_b)))

    @test dtup_L3_a[Foo(), Foo(), Foo()] == 1
    @test dtup_L3_a[Foo(), Foo(), Bar()] == 2
    @test dtup_L3_a[Foo(), Bar(), Foo()] == 3
    @test dtup_L3_a[Foo(), Bar(), Bar()] == 4
    @test dtup_L3_a[Bar(), Foo(), Foo()] == 5
    @test dtup_L3_a[Bar(), Foo(), Bar()] == 6
    @test dtup_L3_a[Bar(), Bar(), Foo()] == 7
    @test dtup_L3_a[Bar(), Bar(), Bar()] == 8
end
