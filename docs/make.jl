using Documenter
using SatelliteToolboxTle

makedocs(
    modules = [SatelliteToolboxTle],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://juliaspace.github.io/SatelliteToolboxTle.jl/stable/",
    ),
    sitename = "Satellite Toolbox TLE",
    authors = "Ronan Arraes Jardim Chagas",
    pages = [
        "Home" => "index.md",
        "Library" => "lib/library.md",
    ],
)

deploydocs(
    repo = "github.com/JuliaSpace/SatelliteToolboxTle.jl.git",
    target = "build",
)