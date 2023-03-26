using Test

using Dates
using Logging
using SatelliteToolboxTle

# Do not show logging to keep the output clean.
global_logger(Logging.NullLogger())

@testset "Parse TLEs from strings" verbose = true begin
    include("./parse_tles_from_strings.jl")
end

@testset "Parse TLEs from files" verbose = true begin
    include("./parse_tles_from_files.jl")
end

@testset "Macros" verbose = true begin
    include("./macros.jl")
end

@testset "Conversions" verbose = true begin
    include("./conversions.jl")
end

@testset "Printing" verbose = true begin
    include("./printing.jl")
end
