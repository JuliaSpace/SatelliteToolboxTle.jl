## Description #############################################################################
#
# Tests related to how TLEs are printed.
#
############################################################################################

const _PRINTING_TLE = tle"""
AMAZONIA 1
1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
"""

# == Function: print =======================================================================

@testset "Function print" begin
    expected = "TLE: AMAZONIA 1 [47699] (Epoch = 2023-03-24T16:28:40.388)"
    @test sprint(print, _PRINTING_TLE) == expected
end

# == Function: show ========================================================================

@testset "Function show" begin
    expected = """
    TLE: AMAZONIA 1 (Epoch = 2023-03-24T16:28:40.388):
      ├─ Line 1
      │    Satellite Number         : 47699
      │    Classification           : U
      │    International Designator : 21015A
      │    Epoch Year               : 23
      │    Epoch Day                : 83.68657856
      │    ṅ/2                      : -4.4e-7 rev/day²
      │    n̈/6                      : 1.0e-9 rev/day³
      │    B*                       : 4.3e-5 1/ER
      │    Ephemeris Type           : 0
      │    Element Set Number       : 999
      └─ Line 2
           Inclination              : 98.4304°
           RA of the Ascending Node : 162.1097°
           Eccentricity             : 0.0001247
           Arg. of Perigee          : 136.2017°
           Mean Anomaly             : 223.9283°
           Mean Motion              : 14.40814394 rev/day
           Revolution Number        : 10865"""

    # == Without Colors ====================================================================

    str = sprint(show, MIME("text/plain"), _PRINTING_TLE)
    @test str == expected

    # == With Colors =======================================================================

    # The faces can be customized by the user. Hence, we only check that the decorations
    # are present and that the text is the same as the one without colors.
    str = sprint(show, MIME("text/plain"), _PRINTING_TLE; context = :color => true)

    @test occursin("\e[1m", str)
    @test occursin("\e[1mSatellite Number\e[22m", str)
    @test replace(str, r"\e\[[0-9;]*m" => "") == expected
end

# == Exceptions ============================================================================

@testset "Exceptions" begin
    e = TleParseError("The 1st line is not valid.")
    @test sprint(showerror, e) == "TleParseError: The 1st line is not valid."

    e = TleParseError("The 1st line is not valid."; line = 3)
    @test sprint(showerror, e) == "TleParseError: [Line 3]: The 1st line is not valid."

    e = TleFetchError("The request failed.")
    @test sprint(showerror, e) == "TleFetchError: The request failed."

    e = TleFetchError("The request failed."; url = "https://celestrak.org", status = 404)
    @test sprint(showerror, e) ==
        "TleFetchError: The request failed. (HTTP status: 404)\nURL: https://celestrak.org"
end
