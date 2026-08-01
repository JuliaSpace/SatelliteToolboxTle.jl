## Description #############################################################################
#
# Tests related to the TLE line checksum.
#
############################################################################################

@testset "Function: tle_line_checksum" begin
    l1 = "1 47699U 21015A   23083.68657856 -.00000044  10000-8  43000-4 0  999"
    l2 = "2 47699  98.4304 162.1097 0001247 136.2017 223.9283 14.4081439410865"

    @test tle_line_checksum(l1) == 0
    @test tle_line_checksum(l2) == 2

    # Only ASCII digits and the minus sign have a value. Other characters, including
    # Unicode numerals, must count as 0.
    @test tle_line_checksum("123")     == 6
    @test tle_line_checksum("1-2-3")   == 8
    @test tle_line_checksum("A b.+/#") == 0
    @test tle_line_checksum("¾٣½1")    == 1
end
