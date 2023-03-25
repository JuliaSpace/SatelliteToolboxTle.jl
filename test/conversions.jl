# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Test conversions related to TLEs.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Conversion to string
# ==============================================================================

@testset "Conversion TLE => String" begin
    # Conversion to string
    # ==========================================================================

    tles = read_tles_from_file("./tles_20200122.tle")
    f    = open("./tles_20200122.tle", "r")

    for i = 1:length(tles)
        stri_name = readline(f)
        stri_l1   = readline(f)
        stri_l2   = readline(f)

        # The TLE for AMOS-4 has a `-` before the first time
        # derivative, even though it is 0. Since this is happening only here,
        # we will skip this case.
        tles[i].satellite_number == 39237 && continue

        # The conversion of the exponent signal of the second derivative of the
        # mean motion and BSTAR does not have a defined pattern if they are 0.
        # We will always using '+'. Hence, if the current TLE uses `-`, we need
        # to change it and update the checksum.

        if (tles[i].ddn_o6 == 0) && (stri_l1[51] == '-')
            stri_l1  = stri_l1[1:50] * "+" * stri_l1[52:end-1]
            stri_l1 *= string(tle_line_checksum(stri_l1[1:end]))
        end

        if (tles[i].bstar == 0) && (stri_l1[60] == '-')
            stri_l1 = stri_l1[1:59] * "+" * stri_l1[61:end-1]
            stri_l1 *= string(tle_line_checksum(stri_l1[1:end]))
        end

        stri = stri_name * "\n" * stri_l1 * "\n" * stri_l2

        # If the OS is Windows, then we should remove `\r` to avoid testing
        # failure.
        Sys.iswindows() && (stri = replace(stri, "\r" => ""))

        strf = convert(String, tles[i])

        @test strf == stri
    end
end

# Function get_epoch
# ==============================================================================

@testset "Function get_epoch" begin
    tle = tle"""
    AMAZONIA 1
    1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  9990
    2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.40814394108652
    """

    expected_epoch_dt = DateTime(2023, 3, 24, 16, 28, 40, 388)

    @test get_epoch(tle)            ≈ datetime2julian(expected_epoch_dt)
    @test get_epoch(DateTime, tle) == expected_epoch_dt
end
