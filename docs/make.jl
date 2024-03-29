using Documenter
using SatelliteToolboxTle

makedocs(
    modules = [SatelliteToolboxTle],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://juliaspace.github.io/SatelliteToolboxTle.jl/stable/",
    ),
    sitename = "SatelliteToolboxTle.jl",
    authors = "Ronan Arraes Jardim Chagas",
    pages = [
        "Home" => "index.md",
        "Usage" => [
            "The TLE structure"   => "man/tle_structure.md",
            "Creating TLEs"       => "man/creating_tles.md",
            "Parsing TLEs"        => "man/parsing_tles.md",
            "Fetching TLEs"       => "man/fetching_tles.md",
            "Auxiliary functions" => "man/auxiliary_functions.md"
        ],
        "Library" => "lib/library.md",
    ],
)

deploydocs(
    repo = "github.com/JuliaSpace/SatelliteToolboxTle.jl.git",
    target = "build",
)
