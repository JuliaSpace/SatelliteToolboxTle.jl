## Description #############################################################################
#
# Functions to parse TLEs.
#
# The parsers throw a `TleParseError` describing the first problem found. The functions
# that parse a set of TLEs catch those errors, emit a warning, and skip the invalid TLE.
#
############################################################################################

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _parse_tle(l1::AbstractString, l2::AbstractString; kwargs...) -> TLE

Parse the TLE with the first line `l1` and the second line `l2`, both without surrounding
whitespace, throwing a `TleParseError` if the lines are not valid.

# Keywords

- `name::AbstractString`: Satellite name assigned to the parsed TLE.
    (**Default**: `"UNDEFINED"`)
- `l1_position::Int`: Number of `l1` in the input, used in the error messages, or `0` if
    unknown.
    (**Default**: `0`)
- `l2_position::Int`: Number of `l2` in the input, used in the error messages, or `0` if
    unknown.
    (**Default**: `0`)
- `verify_checksum::Bool`: If `true`, the checksum of both lines is verified.
    (**Default**: `true`)
"""
function _parse_tle(
    l1::AbstractString,
    l2::AbstractString;
    name::AbstractString = "UNDEFINED",
    l1_position::Int = 0,
    l2_position::Int = 0,
    verify_checksum::Bool = true,
)
    # == First Line ========================================================================

    _check_tle_line(l1, 1, l1_position)
    verify_checksum && _verify_tle_line_checksum(l1, 1, l1_position)

    # The line is ASCII, so it can be indexed by bytes.
    cu = codeunits(l1)

    satellite_number         = _parse_satellite_number(cu, 1, l1_position)
    classification           = Char(cu[8])
    international_designator = String(strip(SubString(l1, 10, 17)))
    epoch_year               = _parse_tle_int(cu, 19:20, 1, l1_position, "epoch year")
    epoch_day                = _parse_tle_float(l1, 21:32, 1, l1_position, "epoch day")

    dn_o2 = _parse_tle_float(
        l1, 34:43, 1, l1_position, "first derivative of mean motion (dn_o2)"
    )

    ddn_o6 = _parse_tle_exponential(
        cu, 45, 1, l1_position, "second derivative of mean motion (ddn_o6)"
    )

    bstar              = _parse_tle_exponential(cu, 54, 1, l1_position, "BSTAR")
    ephemeris_type     = _parse_tle_ephemeris_type(cu, l1_position)
    element_set_number = _parse_tle_int(cu, 65:68, 1, l1_position, "element set number")

    # == Second Line =======================================================================

    _check_tle_line(l2, 2, l2_position)
    verify_checksum && _verify_tle_line_checksum(l2, 2, l2_position)

    cu = codeunits(l2)

    _parse_satellite_number(cu, 2, l2_position) == satellite_number || throw(
        TleParseError(
            "Satellite number in line 2 is not equal to that in line 1.", l2_position
        ),
    )

    inclination = _parse_tle_float(l2, 9:16, 2, l2_position, "inclination")

    raan = _parse_tle_float(
        l2, 18:25, 2, l2_position, "right ascension of the ascending node (RAAN)"
    )

    # The eccentricity has 7 digits with an implied leading decimal point. The division is
    # correctly rounded since both operands are exactly representable.
    eccentricity =
        _parse_tle_int(cu, 27:33, 2, l2_position, "eccentricity"; allow_sign = false) / 1e7

    argument_of_perigee = _parse_tle_float(l2, 35:42, 2, l2_position, "argument of perigee")
    mean_anomaly        = _parse_tle_float(l2, 44:51, 2, l2_position, "mean anomaly")
    mean_motion         = _parse_tle_float(l2, 53:63, 2, l2_position, "mean motion")
    revolution_number   = _parse_tle_int(cu, 64:68, 2, l2_position, "revolution number")

    # == Create the TLE ====================================================================

    # The constructor validates the field ranges. A violation means that the input is not a
    # valid TLE, so the error is converted to a parsing error.
    try
        return TLE(
            name,
            satellite_number,
            classification,
            international_designator,
            epoch_year,
            epoch_day,
            dn_o2,
            ddn_o6,
            bstar,
            ephemeris_type,
            element_set_number,
            inclination,
            raan,
            eccentricity,
            argument_of_perigee,
            mean_anomaly,
            mean_motion,
            revolution_number,
        )
    catch e
        e isa ArgumentError || rethrow(e)
        throw(TleParseError(e.msg, l1_position))
    end
end

"""
    _parse_tles(io::IO; kwargs...) -> Vector{TLE}

Parse every TLE in `io`, returning them in a vector. Blank lines and lines starting with
`#` are ignored, and the surrounding whitespace of each line is discarded. A TLE consists
of an optional satellite name line followed by the two TLE lines. If a TLE cannot be
parsed, a warning is emitted and the TLE is skipped.

# Keywords

- `verify_checksum::Bool`: If `true`, the checksum of both lines of each TLE is verified.
    (**Default**: `true`)
"""
function _parse_tles(io::IO; verify_checksum::Bool = true)
    tles     = TLE[]
    line_num = 0

    while true
        # The next meaningful line is either the satellite name or the first TLE line.
        line, line_num = _next_tle_input_line(io, line_num)
        isnothing(line) && break

        if _is_tle_line(line, 1)
            name        = SubString("UNDEFINED")
            l1          = line
            l1_position = line_num

        elseif startswith(line, "2 ")
            # A second line here is the remnant of a TLE whose first line was not valid and
            # has already been reported. Hence, we can skip it.
            continue

        else
            name = line

            l1, line_num = _next_tle_input_line(io, line_num)
            l1_position  = line_num

            if isnothing(l1)
                @warn("[Line $line_num]: The last TLE in the input is incomplete.")
                break
            end

            if !_is_tle_line(l1, 1)
                @warn("[Line $line_num]: The 1st line is not valid. The TLE was skipped.")
                continue
            end
        end

        l2, line_num = _next_tle_input_line(io, line_num)
        l2_position  = line_num

        if isnothing(l2)
            @warn("[Line $line_num]: The last TLE in the input is incomplete.")
            break
        end

        if !_is_tle_line(l2, 2)
            @warn("[Line $line_num]: The 2nd line is not valid. The TLE was skipped.")
            continue
        end

        try
            tle = _parse_tle(l1, l2; name, l1_position, l2_position, verify_checksum)
            push!(tles, tle)
        catch e
            e isa TleParseError || rethrow(e)
            @warn(_tle_parse_error_message(e) * " The TLE was skipped.")
        end
    end

    return tles
end

"""
    _next_tle_input_line(io::IO, line_num::Int) -> Union{SubString{String}, Nothing}, Int

Read from `io` the next line that is neither blank nor a comment starting with `#`,
returning it without the surrounding whitespace together with its number in the input,
given that `line_num` lines were read before. If `io` is exhausted, the returned line is
`nothing`.
"""
function _next_tle_input_line(io::IO, line_num::Int)
    while !eof(io)
        line      = strip(readline(io))
        line_num += 1

        (isempty(line) || (line[1] == '#')) && continue

        return line, line_num
    end

    return nothing, line_num
end

"""
    _is_tle_line(line::AbstractString, line_number::Int) -> Bool

Return `true` if `line` has the shape of the TLE line `line_number` (1 or 2): 69 bytes
starting with the line number followed by a space.
"""
function _is_tle_line(line::AbstractString, line_number::Int)
    return (sizeof(line) == 69) && startswith(line, line_number == 1 ? "1 " : "2 ")
end

"""
    _check_tle_line(line::AbstractString, line_number::Int, position::Int) -> Nothing

Throw a `TleParseError` at `position` if `line` is not a valid TLE line `line_number` (1
or 2): 69 ASCII characters starting with the line number followed by a space. The ASCII
check allows the fields to be sliced by bytes.
"""
function _check_tle_line(line::AbstractString, line_number::Int, position::Int)
    (_is_tle_line(line, line_number) && isascii(line)) || throw(
        TleParseError(
            "The $(line_number == 1 ? "1st" : "2nd") line is not valid.", position
        ),
    )

    return nothing
end

"""
    _verify_tle_line_checksum(
        line::AbstractString,
        line_number::Int,
        position::Int
    ) -> Nothing

Throw a `TleParseError` at `position` if the checksum in the last character of the TLE
`line`, which is the line `line_number` (1 or 2), does not match the checksum computed
from the other characters.
"""
function _verify_tle_line_checksum(line::AbstractString, line_number::Int, position::Int)
    field = line_number == 1 ? "line 1 checksum" : "line 2 checksum"
    found = _parse_tle_int(codeunits(line), 69:69, line_number, position, field)

    expected = tle_line_checksum(SubString(line, 1, 68))

    found == expected || throw(
        TleParseError(
            "Wrong checksum in TLE line $line_number (expected = $expected, found = " *
            "$found).",
            position,
        ),
    )

    return nothing
end

"""
    _parse_tle_int(
        cu::AbstractVector{UInt8},
        range::UnitRange{Int},
        line_number::Int,
        position::Int,
        field::String;
        kwargs...
    ) -> Int

Parse the integer in the bytes `range` of the TLE line `cu`, which is the line
`line_number` (1 or 2) at `position` in the input. Leading spaces are ignored, and a
`TleParseError` naming `field` is thrown if the remaining characters are not a sign
followed by digits.

# Keywords

- `allow_sign::Bool`: If `true`, a `+` or `-` sign may precede the digits.
    (**Default**: `true`)
"""
function _parse_tle_int(
    cu::AbstractVector{UInt8},
    range::UnitRange{Int},
    line_number::Int,
    position::Int,
    field::String;
    allow_sign::Bool = true,
)
    i    = first(range)
    stop = last(range)

    # Skip the leading spaces used to right-justify the field.
    while (i <= stop) && (cu[i] == UInt8(' '))
        i += 1
    end

    sign = 1

    if allow_sign && (i <= stop)
        if cu[i] == UInt8('-')
            sign = -1
            i   += 1
        elseif cu[i] == UInt8('+')
            i += 1
        end
    end

    # The remaining characters must be at least one digit.
    i <= stop || _throw_tle_field_error(line_number, position, field)

    value = 0

    for j in i:stop
        c = cu[j]
        (UInt8('0') <= c <= UInt8('9')) ||
            _throw_tle_field_error(line_number, position, field)
        value = 10value + (c - UInt8('0'))
    end

    return sign * value
end

"""
    _parse_tle_float(
        line::AbstractString,
        range::UnitRange{Int},
        line_number::Int,
        position::Int,
        field::String
    ) -> Float64

Parse the floating-point number in the bytes `range` of the TLE `line`, which is the line
`line_number` (1 or 2) at `position` in the input, throwing a `TleParseError` naming
`field` if the characters cannot be parsed.
"""
function _parse_tle_float(
    line::AbstractString,
    range::UnitRange{Int},
    line_number::Int,
    position::Int,
    field::String,
)
    value = tryparse(Float64, SubString(line, first(range), last(range)))
    isnothing(value) && _throw_tle_field_error(line_number, position, field)
    return value
end

"""
    _parse_tle_exponential(
        cu::AbstractVector{UInt8},
        start::Int,
        line_number::Int,
        position::Int,
        field::String
    ) -> Float64

Parse the 8-byte field starting at byte `start` of the TLE line `cu`, which is the line
`line_number` (1 or 2) at `position` in the input, written in the TLE exponential notation
`±MMMMM±E`: a sign (`-`, `+`, or space), 5 mantissa digits with an implied leading
decimal point, and a signed exponent digit. A `TleParseError` naming `field` is thrown if
the characters cannot be parsed.
"""
function _parse_tle_exponential(
    cu::AbstractVector{UInt8},
    start::Int,
    line_number::Int,
    position::Int,
    field::String,
)
    sign_char = cu[start]

    if sign_char == UInt8('-')
        sign = -1
    elseif (sign_char == UInt8('+')) || (sign_char == UInt8(' '))
        sign = +1
    else
        _throw_tle_field_error(line_number, position, field)
    end

    mantissa = _parse_tle_int(
        cu, (start + 1):(start + 5), line_number, position, field; allow_sign = false
    )
    exponent = _parse_tle_int(cu, (start + 6):(start + 7), line_number, position, field)

    # The mantissa has 5 digits after the implied decimal point, so the value is
    # `mantissa × 10^(exponent - 5)`. The scaling is correctly rounded since both operands
    # are exactly representable.
    return sign * _scale_by_power_of_ten(mantissa, exponent - 5)
end

"""
    _parse_satellite_number(
        cu::AbstractVector{UInt8},
        line_number::Int,
        position::Int
    ) -> Int

Parse the satellite catalog number in bytes 3 to 7 of the TLE line `cu`, which is the line
`line_number` (1 or 2) at `position` in the input. Besides the plain 5-digit numbers, the
Alpha-5 scheme is supported, in which the first character is a letter encoding the two
leading digits (`A` = 10, `B` = 11, ..., `Z` = 33, skipping `I` and `O`). A
`TleParseError` is thrown if the characters cannot be parsed.
"""
function _parse_satellite_number(
    cu::AbstractVector{UInt8}, line_number::Int, position::Int
)
    field = "satellite number"
    c     = Char(cu[3])

    isletter(c) || return _parse_tle_int(cu, 3:7, line_number, position, field)

    letter_index = findfirst(==(c), _ALPHA5_LETTERS)
    isnothing(letter_index) && _throw_tle_field_error(line_number, position, field)

    digits = _parse_tle_int(cu, 4:7, line_number, position, field; allow_sign = false)

    return (letter_index + 9) * 10_000 + digits
end

"""
    _parse_tle_ephemeris_type(cu::AbstractVector{UInt8}, position::Int) -> Int

Parse the ephemeris type in byte 63 of the first TLE line `cu`, at `position` in the
input. A blank field is interpreted as 0, and a `TleParseError` is thrown if the character
is not a digit.
"""
function _parse_tle_ephemeris_type(cu::AbstractVector{UInt8}, position::Int)
    cu[63] == UInt8(' ') && return 0
    return _parse_tle_int(cu, 63:63, 1, position, "ephemeris type"; allow_sign = false)
end

"""
    _throw_tle_field_error(line_number::Int, position::Int, field::String) -> Nothing

Throw the `TleParseError` reporting that `field` of the TLE line `line_number` (1 or 2),
at `position` in the input, could not be parsed.
"""
function _throw_tle_field_error(line_number::Int, position::Int, field::String)
    throw(
        TleParseError(
            "The $field in the TLE line $line_number could not be parsed.", position
        ),
    )
end

"""
    _tle_parse_error_message(e::TleParseError) -> String

Return the message of `e` prefixed by the line number in the input, if known.
"""
function _tle_parse_error_message(e::TleParseError)
    return e.line > 0 ? "[Line $(e.line)]: $(e.msg)" : e.msg
end
