## Description #############################################################################
#
# Functions to write TLEs to their text representation.
#
# Every field of the TLE format is a fixed-width integer, or a fixed-point number that can
# be scaled to an integer. Hence, the lines are written digit by digit without any
# intermediate string, which avoids allocations.
#
############################################################################################

export write_tle, write_tles

############################################################################################
#                                        Overloads                                         #
############################################################################################

"""
    convert(::Type{String}, tle::TLE) -> String

Convert `tle` to its text representation: the satellite name line followed by the two TLE
lines, without a trailing newline. The lines are formatted as described in
[`write_tle`](@ref).
"""
function convert(::Type{String}, tle::TLE)
    buf = IOBuffer()
    write_tle(buf, tle)
    return String(chomp(String(take!(buf))))
end

############################################################################################
#                                     Public Functions                                     #
############################################################################################

"""
    write_tle(io::IO, tle::TLE) -> Nothing
    write_tle(file::AbstractString, tle::TLE) -> Nothing

Write the text representation of `tle` to the stream `io` or to the file `file`, which is
created or overwritten.

The output has three lines terminated by a newline: the satellite name padded to 24
characters, and the two TLE lines with recomputed checksums. The angles (inclination, RAAN,
argument of perigee, and mean anomaly) are normalized to the interval [0, 360)° before
being written. If the magnitude of `dn_o2`, `ddn_o6`, or `bstar` cannot be represented in
its TLE field, the field is saturated, or set to 0 if the value is too small, and a warning
is emitted. The other fields are validated by the [`TLE`](@ref) constructor, so they always
fit.

See also: [`write_tles`](@ref)
"""
function write_tle(io::IO, tle::TLE)
    # The lines are assembled in a buffer so that their checksums can be computed before
    # writing them to `io`.
    buf = IOBuffer()

    _write_padded_string(io, tle.name, 24)
    write(io, '\n')

    _write_tle_line_1(buf, tle)
    _write_line_with_checksum(io, buf)

    _write_tle_line_2(buf, tle)
    _write_line_with_checksum(io, buf)

    return nothing
end

function write_tle(file::AbstractString, tle::TLE)
    open(file, "w") do io
        write_tle(io, tle)
    end

    return nothing
end

"""
    write_tles(io::IO, tles::AbstractVector{TLE}) -> Nothing
    write_tles(file::AbstractString, tles::AbstractVector{TLE}) -> Nothing

Write the text representation of every TLE in `tles` to the stream `io` or to the file
`file`, which is created or overwritten. Each TLE is written as described in
[`write_tle`](@ref), one after the other.
"""
function write_tles(io::IO, tles::AbstractVector{TLE})
    for tle in tles
        write_tle(io, tle)
    end

    return nothing
end

function write_tles(file::AbstractString, tles::AbstractVector{TLE})
    open(file, "w") do io
        write_tles(io, tles)
    end

    return nothing
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _write_line_with_checksum(io::IO, buf::IOBuffer) -> Nothing

Write to `io` the line assembled in `buf` followed by its checksum and a newline, emptying
`buf`.
"""
function _write_line_with_checksum(io::IO, buf::IOBuffer)
    line = take!(buf)
    write(io, line)
    _write_digits(io, _tle_line_checksum(line), 1)
    write(io, '\n')
    return nothing
end

"""
    _write_tle_line_1(io::IO, tle::TLE) -> Nothing

Write to `io` the first line of `tle` without the checksum.
"""
function _write_tle_line_1(io::IO, tle::TLE)
    # -- Line ID, Satellite Number, Classification, and International Designator -----------

    write(io, "1 ")
    _write_satellite_number(io, tle.satellite_number)
    write(io, tle.classification, ' ')
    _write_padded_string(io, tle.international_designator, 8)
    write(io, ' ')

    # -- Epoch -----------------------------------------------------------------------------

    # The epoch day is scaled to the printed precision before being split into the integer
    # and fractional parts. Otherwise, a fraction of the day close to 1 would be rounded to
    # 1 when printed, dropping the carry to the integer part.
    epoch_day = round(Int, tle.epoch_day * 1e8)

    _write_digits(io, tle.epoch_year, 2)
    _write_fixed_point(io, epoch_day, 3, 8; pad = '0')
    write(io, ' ')

    # -- First Time Derivative of the Mean Motion ------------------------------------------

    # The field can only store magnitudes lower than 1 with 8 decimal digits. If the
    # magnitude reaches 1 after the rounding, the field is saturated.
    abs_dn_o2 = abs(tle.dn_o2)
    dn_o2     = abs_dn_o2 < 1 ? round(Int, abs_dn_o2 * 1e8) : 100_000_000

    if dn_o2 >= 100_000_000
        @warn(
            "The dn_o2 magnitude cannot be represented in a TLE. The field will be " *
                "saturated."
        )
        dn_o2 = 99_999_999
    end

    write(io, tle.dn_o2 < 0 ? '-' : ' ', '.')
    _write_digits(io, dn_o2, 8)
    write(io, ' ')

    # -- Second Time Derivative of the Mean Motion and BSTAR -------------------------------

    _write_exponential_field(io, tle.ddn_o6, "ddn_o6")
    write(io, ' ')
    _write_exponential_field(io, tle.bstar, "BSTAR")
    write(io, ' ')

    # -- Ephemeris Type and Element Set Number ---------------------------------------------

    _write_digits(io, tle.ephemeris_type, 1)
    write(io, ' ')
    _write_padded_int(io, tle.element_set_number, 4)

    return nothing
end

"""
    _write_tle_line_2(io::IO, tle::TLE) -> Nothing

Write to `io` the second line of `tle` without the checksum.
"""
function _write_tle_line_2(io::IO, tle::TLE)
    write(io, "2 ")
    _write_satellite_number(io, tle.satellite_number)
    write(io, ' ')

    # -- Inclination and RAAN [°] ----------------------------------------------------------

    _write_tle_angle(io, tle.inclination)
    write(io, ' ')
    _write_tle_angle(io, tle.raan)
    write(io, ' ')

    # -- Eccentricity ----------------------------------------------------------------------

    # The eccentricity is lower than 1, but it can reach 1 when rounded to the printed
    # precision, breaking the implied decimal point notation. In this case, the field is
    # saturated.
    _write_digits(io, min(round(Int, tle.eccentricity * 1e7), 9_999_999), 7)
    write(io, ' ')

    # -- Argument of Perigee and Mean Anomaly [°] ------------------------------------------

    _write_tle_angle(io, tle.argument_of_perigee)
    write(io, ' ')
    _write_tle_angle(io, tle.mean_anomaly)
    write(io, ' ')

    # -- Mean Motion [rev/day] -------------------------------------------------------------

    # The mean motion is lower than 100, but it can reach 100 when rounded to the printed
    # precision, overflowing the field. In this case, the field is saturated.
    mean_motion = min(round(Int, tle.mean_motion * 1e8), 9_999_999_999)
    _write_fixed_point(io, mean_motion, 2, 8)

    # -- Revolution Number at Epoch --------------------------------------------------------

    _write_padded_int(io, tle.revolution_number, 5)

    return nothing
end

"""
    _write_satellite_number(io::IO, satellite_number::Int) -> Nothing

Write to `io` the 5-character field with the `satellite_number`. Numbers up to 99999 are
written as plain digits. Otherwise, the first character is the letter of the Alpha-5
scheme that encodes the two leading digits (`A` = 10, `B` = 11, ..., `Z` = 33, skipping
`I` and `O`).
"""
function _write_satellite_number(io::IO, satellite_number::Int)
    leading, digits = divrem(satellite_number, 10_000)

    if leading < 10
        _write_digits(io, leading, 1)
    else
        write(io, _ALPHA5_LETTERS[leading - 9])
    end

    _write_digits(io, digits, 4)

    return nothing
end

"""
    _write_exponential_field(io::IO, value::Float64, field::String) -> Nothing

Write to `io` the 8-character TLE field with `value` in the format `±MMMMM±E`, where
`MMMMM` are the mantissa digits with an implied leading decimal point and `E` is the
exponent digit. `field` names the field in the warnings emitted when `value` cannot be
represented and must be saturated or set to 0.
"""
function _write_exponential_field(io::IO, value::Float64, field::String)
    mantissa, exponent = _tle_mantissa_and_exponent(abs(value), field)

    write(io, value < 0 ? '-' : ' ')
    _write_digits(io, mantissa, 5)
    write(io, exponent < 0 ? '-' : '+')
    _write_digits(io, abs(exponent), 1)

    return nothing
end

"""
    _tle_mantissa_and_exponent(value::Float64, field::String) -> Int, Int

Return the 5-digit integer mantissa and the exponent that represent the non-negative
`value` in the TLE exponential notation, i.e. `value ≈ 0.MMMMM × 10^E`. The mantissa is
normalized to the interval [10000, 99999] whenever the exponent fits in the single digit
of the field. Otherwise, the field is saturated if `value` is too large, or the mantissa
is denormalized and set to 0 if `value` is too small, emitting a warning that names
`field`.
"""
function _tle_mantissa_and_exponent(value::Float64, field::String)
    value == 0 && return 0, 0

    exponent = floor(Int, log10(value)) + 1

    if exponent > 9
        @warn(
            "The $field magnitude is too large to be represented in a TLE. The field " *
                "will be saturated."
        )
        return 99_999, 9
    end

    if exponent < -9
        # The value can still be represented by denormalizing the mantissa. If it is too
        # small, the mantissa becomes 0 at the printed precision.
        mantissa = round(Int, value * 1e14)

        if mantissa == 0
            @warn(
                "The $field magnitude is too small to be represented in a TLE. The " *
                    "field will be set to 0."
            )
            return 0, 0
        end

        return mantissa, -9
    end

    mantissa = round(Int, _scale_by_power_of_ten(value, 5 - exponent))

    # Due to the rounding, the mantissa can reach 100000. In this case, we must carry to
    # the exponent, which can then overflow the field.
    if mantissa >= 100_000
        mantissa  = 10_000
        exponent += 1

        if exponent > 9
            @warn(
                "The $field magnitude is too large to be represented in a TLE. The " *
                    "field will be saturated."
            )
            return 99_999, 9
        end
    end

    return mantissa, exponent
end

"""
    _write_tle_angle(io::IO, angle::Float64) -> Nothing

Write to `io` the 8-character TLE field with the `angle` [°] normalized to the interval
[0, 360)°, with 4 decimal digits. An angle that rounds to 360° at this precision is
written as 0°.
"""
function _write_tle_angle(io::IO, angle::Float64)
    scaled_angle = round(Int, mod(angle, 360) * 1e4)
    scaled_angle >= 3_600_000 && (scaled_angle = 0)
    _write_fixed_point(io, scaled_angle, 3, 4)
    return nothing
end

"""
    _write_fixed_point(
        io::IO,
        value::Int,
        int_width::Int,
        frac_digits::Int;
        kwargs...
    ) -> Nothing

Write to `io` the fixed-point number `value / 10^frac_digits` with exactly `frac_digits`
decimal digits and the integer part right-justified to `int_width` characters using `pad`.

# Keywords

- `pad::Char`: Character used to pad the integer part.
    (**Default**: `' '`)
"""
function _write_fixed_point(
    io::IO, value::Int, int_width::Int, frac_digits::Int; pad::Char = ' '
)
    int_part, frac_part = divrem(value, 10^frac_digits)
    _write_padded_int(io, int_part, int_width; pad)
    write(io, '.')
    _write_digits(io, frac_part, frac_digits)
    return nothing
end

"""
    _write_padded_int(io::IO, value::Int, width::Int; kwargs...) -> Nothing

Write to `io` the non-negative integer `value` right-justified to `width` characters using
`pad`. If `value` has more digits than `width`, all of them are written.

# Keywords

- `pad::Char`: Character used to pad the number.
    (**Default**: `' '`)
"""
function _write_padded_int(io::IO, value::Int, width::Int; pad::Char = ' ')
    num_digits = ndigits(value)

    for _ in 1:(width - num_digits)
        write(io, pad)
    end

    _write_digits(io, value, num_digits)

    return nothing
end

"""
    _write_digits(io::IO, value::Int, num_digits::Int) -> Nothing

Write to `io` the `num_digits` least significant decimal digits of the non-negative integer
`value`, zero-padded to the left.
"""
function _write_digits(io::IO, value::Int, num_digits::Int)
    divisor = 10^(num_digits - 1)

    while divisor > 0
        write(io, UInt8('0' + (value ÷ divisor) % 10))
        divisor ÷= 10
    end

    return nothing
end

"""
    _write_padded_string(io::IO, str::AbstractString, width::Int) -> Nothing

Write to `io` the string `str` followed by the spaces required to fill `width` characters.
"""
function _write_padded_string(io::IO, str::AbstractString, width::Int)
    write(io, str)

    for _ in 1:(width - textwidth(str))
        write(io, ' ')
    end

    return nothing
end

"""
    _scale_by_power_of_ten(x::Number, k::Int) -> Float64

Return `x × 10^k` for `k` in the interval [-14, 14], multiplying or dividing `x` by an
exactly representable power of ten so that the result is correctly rounded.
"""
function _scale_by_power_of_ten(x::Number, k::Int)
    return k >= 0 ? x * _POWERS_OF_TEN[k + 1] : x / _POWERS_OF_TEN[1 - k]
end
