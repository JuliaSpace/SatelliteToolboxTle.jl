using Test

using Dates
using Logging
using SatelliteToolboxTle

# Do not show logging to keep the output clean.
global_logger(Logging.NullLogger())

@testset "Parse TLEs From Strings" verbose = true begin
    include("./parse_tles_from_strings.jl")
end

@testset "Parse TLEs From Files" verbose = true begin
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

@testset "TLE Creation"  verbose = true begin
    include("./errors.jl")
end

@testset "TLE Fetchers" verbose = true begin
    include("./tle_fetchers.jl")
end
