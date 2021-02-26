using Documenter, DispatchedTuples

makedocs(
    sitename = "DispatchedTuples.jl",
    strict = true,
    checkdocs = :exports,
    clean = true,
    modules = [DispatchedTuples],
    pages = Any[
        "Home" => "index.md",
    ],
)

deploydocs(
    repo = "github.com/charleskawczynski/DispatchedTuples.jl.git",
    target = "build",
    push_preview = true,
    devbranch = "main",
    forcepush = true,
)
