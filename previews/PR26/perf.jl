using DispatchedTuples
using BenchmarkTools

# (N, N_buf) are low for quick doc builds
# (N, N_buf) = (5, 3) is reasonable
N = 0
N_buf = 1

foo(i) = Symbol(:Foo, i)
expr(i) = :(struct $(foo(i)) end)
for i in 1:N+N_buf
    eval(expr(i))
end

fooinst(i::Int) = eval(:($(foo(i))))()

footup(n::Int) = ntuple(n) do i
    (fooinst(i), i)
end

function perf_dt(N, N_buf)
    println("********* DispatchedTuple")
    for n in N_buf:N+N_buf
        println("--- n = $n")
        tup = footup(n)
        @btime footup($n)

        dtup = DispatchedTuple(tup)
        @btime DispatchedTuple($tup)
        # @btime $dtup[Foo3()] # always results in 0.028 ns (0 allocations: 0 bytes)
    end
end

function perf_ds(N, N_buf)
    println("********* DispatchedSet")
    for n in N_buf:N+N_buf
        println("--- n = $n")
        tup = footup(n)
        @btime footup($n)

        dtup = DispatchedSet(tup)
        @btime DispatchedSet($tup)
        # @btime $dtup[Foo3()] # always results in 0.028 ns (0 allocations: 0 bytes)
    end
end

perf_dt(N, N_buf)
perf_ds(N, N_buf)
