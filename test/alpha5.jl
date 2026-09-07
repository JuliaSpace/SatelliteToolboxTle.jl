## Description #############################################################################
#
# Tests related to the Alpha-5 scheme for satellite catalog numbers above 99999.
#
############################################################################################

# Return the TLE lines of `tle` with valid checksums.
function _tle_lines(tle::TLE)
    l0, l1, l2 = split(write_tle(String, tle), '\n')
    return String(l1), String(l2)
end

@testset "Alpha-5 Satellite Numbers" begin
    kwargs = (
        epoch_year          = 23,
        epoch_day           = 83.68657856,
        inclination         = 98.4304,
        raan                = 162.1097,
        eccentricity        = 0.0001247,
        argument_of_perigee = 136.2017,
        mean_anomaly        = 223.9283,
        mean_motion         = 14.40814394,
    )

    # == Writing ===========================================================================

    # Numbers up to 99999 are written as plain digits, and the others use a letter that
    # encodes the two leading digits, skipping `I` and `O`.
    for (satellite_number, field) in (
        (0,       "00000"),
        (99_999,  "99999"),
        (100_000, "A0000"),
        (107_699, "A7699"),
        (179_999, "H9999"),
        (180_000, "J0000"),
        (229_999, "N9999"),
        (230_000, "P0000"),
        (339_999, "Z9999"),
    )
        l1, l2 = _tle_lines(TLE(; kwargs..., satellite_number))

        @test l1[3:7] == field
        @test l2[3:7] == field
        @test tle_line_checksum(l1[1:68]) == parse(Int, l1[69])
        @test tle_line_checksum(l2[1:68]) == parse(Int, l2[69])
    end

    # == Parsing ===========================================================================

    for satellite_number in (100_000, 107_699, 180_000, 230_000, 339_999)
        tle = TLE(; kwargs..., satellite_number)
        @test read_tle(_tle_lines(tle)...).satellite_number == satellite_number
        @test read_tle(write_tle(String, tle)) == tle
    end

    # The letters `I` and `O` are not valid.
    l1, l2 = _tle_lines(TLE(; kwargs..., satellite_number = 107_699))

    for letter in ('I', 'O', 'a')
        l1_invalid = l1[1:2] * letter * l1[4:end]
        l2_invalid = l2[1:2] * letter * l2[4:end]

        @test_throws TleParseError read_tle(l1_invalid, l2_invalid; verify_checksum = false)
    end
end
