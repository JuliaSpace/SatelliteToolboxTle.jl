## Description #############################################################################
#
# Tests related to the errors when creating TLEs.
#
############################################################################################

# Keywords of a valid TLE used as the base of the tests.
const _VALID_TLE_KWARGS = (
    satellite_number         = 47699,
    international_designator = "21015A",
    epoch_year               = 23,
    epoch_day                = 83.68657856,
    element_set_number       = 999,
    inclination              = 98.4304,
    raan                     = 162.1097,
    eccentricity             = 0.0001247,
    argument_of_perigee      = 136.2017,
    mean_anomaly             = 223.9283,
    mean_motion              = 14.40814394,
    revolution_number        = 10865,
)

@testset "Errors When Creating TLEs" begin
    # The base keywords must create a valid TLE.
    @test TLE(; _VALID_TLE_KWARGS...) isa TLE

    # == Field Ranges ======================================================================

    # Each pair has a field and a value outside the range of the TLE format.
    for (field, value) in (
        (:satellite_number,         -1),
        (:satellite_number,         340_000),
        (:classification,           'É'),
        (:international_designator, "123456789"),
        (:international_designator, "É"),
        (:epoch_year,               -1),
        (:epoch_year,               100),
        (:epoch_day,                -0.1),
        (:epoch_day,                367.0),
        (:ephemeris_type,           -1),
        (:ephemeris_type,           10),
        (:element_set_number,       -1),
        (:element_set_number,       10_000),
        (:eccentricity,             -0.01),
        (:eccentricity,             1.0),
        (:mean_motion,              -1.0),
        (:mean_motion,              100.0),
        (:revolution_number,        -1),
        (:revolution_number,        100_000),
    )
        @test_throws ArgumentError TLE(; _VALID_TLE_KWARGS..., (field => value,)...)
    end

    # The limits of the ranges must be accepted.
    @test TLE(; _VALID_TLE_KWARGS..., satellite_number = 339_999) isa TLE
    @test TLE(; _VALID_TLE_KWARGS..., epoch_year = 99) isa TLE
    @test TLE(; _VALID_TLE_KWARGS..., ephemeris_type = 9) isa TLE
    @test TLE(; _VALID_TLE_KWARGS..., element_set_number = 9999) isa TLE
    @test TLE(; _VALID_TLE_KWARGS..., revolution_number = 99_999) isa TLE

    # == Epoch =============================================================================

    kwargs = (
        inclination         = 98.4304,
        raan                = 162.1097,
        eccentricity        = 0.0001247,
        argument_of_perigee = 136.2017,
        mean_anomaly        = 223.9283,
        mean_motion         = 14.40814394,
    )

    epoch = DateTime(2023, 3, 24, 16, 28, 40, 388)

    # The epoch must be provided exactly once.
    @test_throws ArgumentError TLE(; kwargs...)
    @test_throws ArgumentError TLE(; kwargs..., epoch_year = 23)
    @test_throws ArgumentError TLE(; kwargs..., epoch_day = 83.68657856)
    @test_throws ArgumentError TLE(; kwargs..., epoch = epoch, epoch_year = 23)
    @test_throws ArgumentError TLE(; kwargs..., epoch = epoch, epoch_day = 83.68657856)

    # The epoch year must be representable with two digits.
    @test_throws ArgumentError TLE(; kwargs..., epoch = DateTime(1956, 12, 31))
    @test_throws ArgumentError TLE(; kwargs..., epoch = DateTime(2057, 1, 1))
    @test TLE(; kwargs..., epoch = DateTime(1957, 1, 1)) isa TLE
    @test TLE(; kwargs..., epoch = DateTime(2056, 12, 31)) isa TLE
end
