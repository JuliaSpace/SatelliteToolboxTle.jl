## Description #############################################################################
#
# Tests related to the TLE fetchers.
#
############################################################################################

# == API ===================================================================================

struct MyTleFetcher <: AbstractTleFetcher end

@testset "TLE fetcher API" begin
    @test_throws ArgumentError create_tle_fetcher(MyTleFetcher)
    @test_throws ArgumentError fetch_tles(MyTleFetcher())
end

# == Celestrak =============================================================================

@testset "Celestrak TLE fetcher" begin
    f = create_tle_fetcher(CelestrakTleFetcher)

    @test f.url == "https://celestrak.org/NORAD/elements/gp.php"
    @test sprint(show, f) == "CelestrakTleFetcher: " * f.url

    # == Search By Satellite Number ========================================================

    tles = fetch_tles(f; satellite_number = 47699)

    @test length(tles) == 1

    amz1_tle = tles |> first

    @test amz1_tle.name == "AMAZONIA 1"
    @test amz1_tle.international_designator == "21015A"
    @test amz1_tle.satellite_number == 47699

    # == Search By International Designator ================================================

    tles = fetch_tles(f; international_designator = "2021-015")

    amz1_tle = tles |> first

    @test amz1_tle.name == "AMAZONIA 1"
    @test amz1_tle.international_designator == "21015A"
    @test amz1_tle.satellite_number == 47699

    # The launch number is padded and the piece is accepted.
    tles = fetch_tles(f; international_designator = "2021-15A")

    @test length(tles) == 1
    @test first(tles).satellite_number == 47699

    # == Search By Satellite Name ==========================================================

    tles = fetch_tles(f; satellite_name = "AMAZONIA 1")

    @test length(tles) == 1

    amz1_tle = tles |> first

    @test amz1_tle.name == "AMAZONIA 1"
    @test amz1_tle.international_designator == "21015A"
    @test amz1_tle.satellite_number == 47699
end

@testset "Celestrak TLE fetcher [ERRORS]" begin
    f = create_tle_fetcher(CelestrakTleFetcher)

    # == Query Parameters ==================================================================

    @test_throws ArgumentError fetch_tles(f)
    @test_throws ArgumentError fetch_tles(f; satellite_number = 47699, satellite_name = "A")
    @test_throws ArgumentError fetch_tles(f; satellite_number = -10)
    @test_throws ArgumentError fetch_tles(f; satellite_number = 0)
    @test_throws ArgumentError fetch_tles(f; satellite_number = 340_000)
    @test_throws ArgumentError fetch_tles(f; international_designator = "2023222")
    @test_throws ArgumentError fetch_tles(f; satellite_name = "")

    # == Request Failures ==================================================================

    # A connection failure must be reported as a `TleFetchError`.
    f = create_tle_fetcher(CelestrakTleFetcher; url = "http://127.0.0.1:1/gp.php")
    @test_throws TleFetchError fetch_tles(f; satellite_number = 47699)
end
