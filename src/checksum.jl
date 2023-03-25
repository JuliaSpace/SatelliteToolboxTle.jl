# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to compute the TLE line checksum.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export tle_line_checksum

"""
    tle_line_checksum(str::AbstractString)

Compute the checksum of the line `str` modulo 10.

The algorithm is simple: add all the numbers in the line, ignoring letters,
spaces, periods, and plus signs, but assigning +1 to the minus signs. The
checksum is the remainder of the division by 10.
"""
function tle_line_checksum(str::AbstractString)
    checksum = 0

    for c in str
        # Check if `c` is a number.
        if isnumeric(c)
            checksum += parse(Int, c)

        # Check if `c` is a minus sign, which has value 1.
        elseif c == '-'
            checksum += 1
        end

        # Otherwise, the value of the character is 0.
    end

    # Return the checksum modulo 10.
    return checksum % 10
end
