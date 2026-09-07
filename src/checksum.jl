## Description #############################################################################
#
# Functions to compute the TLE line checksum.
#
############################################################################################

export tle_line_checksum

"""
    tle_line_checksum(str::AbstractString) -> Int

Compute the checksum of the line `str` modulo 10.

The algorithm is simple: add all the numbers in the line, ignoring letters, spaces, periods,
and plus signs, but assigning +1 to the minus signs. The checksum is the remainder of the
division by 10.
"""
tle_line_checksum(str::AbstractString) = _tle_line_checksum(codeunits(str))

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _tle_line_checksum(bytes::AbstractVector{UInt8}) -> Int

Compute the checksum modulo 10 of the line encoded in UTF-8 by `bytes`, as described in
[`tle_line_checksum`](@ref).

The computation can be performed byte by byte because only the ASCII digits and the minus
sign have a value, and the bytes of the multi-byte characters never match them.
"""
function _tle_line_checksum(bytes::AbstractVector{UInt8})
    checksum = 0

    for b in bytes
        if UInt8('0') <= b <= UInt8('9')
            checksum += b - UInt8('0')
        elseif b == UInt8('-')
            checksum += 1
        end
    end

    return checksum % 10
end
