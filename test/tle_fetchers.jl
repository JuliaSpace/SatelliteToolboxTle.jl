# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to the TLE fetchers.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# API
# ==============================================================================

struct MyTleFetcher <: AbstractTleFetcher end

@testset "TLE fetcher API" begin
    @test_throws ErrorException create_tle_fetcher(MyTleFetcher)
    @test_throws ErrorException fetch_tles(MyTleFetcher())
end

# Celestrak
# ==============================================================================

@testset "Celestrak TLE fetcher" begin
    f = create_tle_fetcher(CelestrakTleFetcher)

    # Search by satellite number
    # ==========================================================================

    tles = fetch_tles(f;
        satellite_number = 47699,
        international_designator = "2023-001", # . This option will be neglected
        satellite_name = "CBERS 4",            # . This option will be neglected
    )

    @test length(tles) == 1

    amz1_tle = tles |> first

    @test amz1_tle.name                     == "AMAZONIA 1"
    @test amz1_tle.international_designator == "21015A"
    @test amz1_tle.satellite_number         == 47699

    # Search by international designator
    # ==========================================================================

    tles = fetch_tles(f;
        international_designator = "2021-015",
        satellite_name = "CBERS 4",            # . This option will be neglected
    )

    amz1_tle = tles |> first

    @test amz1_tle.name                     == "AMAZONIA 1"
    @test amz1_tle.international_designator == "21015A"
    @test amz1_tle.satellite_number         == 47699

    # Search by satellite name
    # ==========================================================================

    tles = fetch_tles(f; satellite_name = "AMAZONIA 1")

    @test length(tles) == 1

    amz1_tle = tles |> first

    @test amz1_tle.name                     == "AMAZONIA 1"
    @test amz1_tle.international_designator == "21015A"
    @test amz1_tle.satellite_number         == 47699

    # No data found
    # ==========================================================================

    tles = @test_logs(
        (:warn, "No GP data found."),
        match_mode = :any,
        fetch_tles(f; satellite_name = "ASDFASDFADSF")
    )
    @test length(tles) == 0
end

@testset "Celestrak TLE fetcher [ERRORS]" begin
    f = create_tle_fetcher(CelestrakTleFetcher)

    # Input options
    # ==========================================================================

    @test_throws ArgumentError fetch_tles(f)
    @test_throws ArgumentError fetch_tles(f; satellite_number = -10)
    @test_throws ArgumentError fetch_tles(f; satellite_number = 100_000)
    @test_throws ArgumentError fetch_tles(f; international_designator = "2023222")
    @test_throws ArgumentError fetch_tles(f; satellite_name = "")
end
