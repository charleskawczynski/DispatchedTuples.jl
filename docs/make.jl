using Documenter, DispatchedTuples

format = Documenter.HTML(
    prettyurls = !isempty(get(ENV, "CI", "")),
    collapselevel = 1,
)

makedocs(
    sitename = "DispatchedTuples.jl",
    strict = true,
    format = format,
    checkdocs = :exports,
    clean = true,
    doctest = true,
    modules = [DispatchedTuples],
    pages = Any[
        "Home" => "index.md",
        "Performance" => "performance.md",
        "API" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/charleskawczynski/DispatchedTuples.jl.git",
    target = "build",
    push_preview = true,
    devbranch = "main",
    forcepush = true,
)
