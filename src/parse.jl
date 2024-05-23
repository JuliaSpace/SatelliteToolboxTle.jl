## Description #############################################################################
#
# Functions to parse TLEs.
#
############################################################################################

############################################################################################
#                                    Private Functions                                     #
############################################################################################

# Parse the TLE with first line `l1`, and second line `l2`.
#
# It returns the `TLE` if the information was parsed was successfully, or `nothing`
# otherwise.
function _parse_tle(
    l1::AbstractString,
    l2::AbstractString;
    name::AbstractString = "UNDEFINED",
    l1_position::Int = 0,
    l2_position::Int = 0,
    verify_checksum::Bool = true
)

    # == First Line ========================================================================

    debug_prefix = l1_position == 0 ? "" : "[Line $l1_position]: "

    # The first line must start with "1 " and have 69 characters.
    if (l1[1:2] != "1 ") || (length(l1) != 69)
        @error(debug_prefix * "The 1st line is not valid.")
        return nothing
    end

    # -- Verify the Checksum. --------------------------------------------------------------

    if verify_checksum && !_verify_tle_line_checksum(l1, 1; debug_prefix = debug_prefix)
        return nothing
    end

    # -- Satellite Number ------------------------------------------------------------------

    satellite_number = _tle_try_parse(Int, l1[3:7], 1, debug_prefix, "satellite number")
    isnothing(satellite_number) && return nothing

    # -- Classification --------------------------------------------------------------------

    classification = Char(l1[8])

    # -- International Designator ----------------------------------------------------------

    international_designator = strip(l1[10:17])

    # -- Epoch -----------------------------------------------------------------------------

    epoch_year = _tle_try_parse(Int, l1[19:20], 1, debug_prefix, "epoch year")
    isnothing(epoch_year) && return nothing

    epoch_day = _tle_try_parse(Float64, l1[21:32], 1, debug_prefix, "epoch day")
    isnothing(epoch_day) && return nothing

    # -- Mean Motion Derivatives -----------------------------------------------------------

    dn_o2 = _tle_try_parse(
        Float64,
        l1[34:43],
        1,
        debug_prefix,
        "first derivative of mean motion (dn_o2)"
    )
    isnothing(dn_o2) && return nothing

    aux = ((l1[45] == ' ') ? "+." : l1[45] * "." ) * l1[46:50]

    ddn_o6_dec = _tle_try_parse(
        Float64,
        aux,
        1,
        debug_prefix,
        "second derivative of mean motion (ddn_o6)"
    )
    isnothing(ddn_o6_dec) && return nothing

    ddn_o6_exp = _tle_try_parse(
        Float64,
        l1[51:52],
        1,
        debug_prefix,
        "second derivative of mean motion (ddn_o6)"
    )
    isnothing(ddn_o6_exp) && return nothing

    ddn_o6 = ddn_o6_dec * 10^ddn_o6_exp

    # -- BSTAR -----------------------------------------------------------------------------

    aux = ((l1[54] == ' ') ? "+." : l1[54] * "." ) * l1[55:59]

    bstar_dec = _tle_try_parse(Float64, aux, 1, debug_prefix, "BSTAR")
    isnothing(bstar_dec) && return nothing

    bstar_exp = _tle_try_parse(Float64, l1[60:61], 1, debug_prefix, "BSTAR")
    isnothing(bstar_exp) && return nothing

    bstar = bstar_dec * 10^bstar_exp

    # -- Ephemeris Type --------------------------------------------------------------------

    (l1[63] != '0' && l1[63] != ' ') && @warn(debug_prefix * "TLE ephemeris type should be 0.")

    # -- Element Number --------------------------------------------------------------------

    element_set_number = _tle_try_parse(Int, l1[65:68], 1, debug_prefix, "element set number")
    isnothing(element_set_number) && return nothing

    # == Second Line =======================================================================

    debug_prefix = l2_position == 0 ? "" : "[Line $(l2_position)]: "

    # The second line must start with "2 " and have 69 characters.
    if (l2[1:2] != "2 ") || (length(l2) != 69)
        @error(debug_prefix * "The 2nd line is not valid.")
        return nothing
    end

    # -- Verify the Checksum. --------------------------------------------------------------

    if verify_checksum && !_verify_tle_line_checksum(l2, 2; debug_prefix = debug_prefix)
        return nothing
    end

    # -- Compare Satellite Number with the One in the First Line ---------------------------

    satellite_number_line_2 = _tle_try_parse(Int, l2[3:7], 2, debug_prefix, "satellite number")
    isnothing(satellite_number_line_2) && return nothing

    if satellite_number_line_2 != satellite_number
        @error(debug_prefix * "Satellite number in line 2 is not equal to that in line 1.")
        return nothing
    end

    # Inclination
    # --------------------------------------------------------------------------------------

    inclination = _tle_try_parse(Float64, l2[9:16], 2, debug_prefix, "inclination")
    isnothing(inclination) && return nothing

    # RAAN
    # --------------------------------------------------------------------------------------

    raan = _tle_try_parse(
        Float64,
        l2[18:25],
        2,
        debug_prefix,
        "rigth ascension of the ascending node (RAAN)"
    )
    isnothing(raan) && return nothing

    # Eccentricity
    # --------------------------------------------------------------------------------------

    eccentricity = _tle_try_parse(Float64, "." * l2[27:33], 2, debug_prefix, "eccentricity")
    isnothing(eccentricity) && return nothing

    # Argument of perigee
    # --------------------------------------------------------------------------------------

    argument_of_perigee = _tle_try_parse(
        Float64,
        l2[35:42],
        2,
        debug_prefix,
        "argument of perigee"
    )
    isnothing(argument_of_perigee) && return nothing

    # Mean anomaly
    # --------------------------------------------------------------------------------------

    mean_anomaly = _tle_try_parse(Float64, l2[44:51], 2, debug_prefix, "mean anomaly")
    isnothing(mean_anomaly) && return nothing

    # Mean motion
    # --------------------------------------------------------------------------------------

    mean_motion = _tle_try_parse(Float64, l2[53:63], 2, debug_prefix, "mean motion")
    isnothing(mean_motion) && return nothing

    # Revolution number at epoch
    # --------------------------------------------------------------------------------------

    revolution_number = _tle_try_parse(Int, l2[64:68], 2, debug_prefix, "revolution number")
    isnothing(revolution_number) && return nothing

    #                                    Create the TLE
    # ======================================================================================

    # Now we can create the TLE.
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
        element_set_number,
        inclination,
        raan,
        eccentricity,
        argument_of_perigee,
        mean_anomaly,
        mean_motion,
        revolution_number
    )
end

# Parse the TLEs in the `io`.
function _parse_tles(io::IO; verify_checksum::Bool = true)
    # State machine to read the TLE. It has three possible states:
    #
    #   :name -> Satellite name.
    #   :l1   -> Line 1.
    #   :l2   -> Line 2.
    #
    # The transitions are:
    #
    #   :name --> :l1 --> :l2
    #     ^                |
    #     |                |
    #      ----------------
    #
    state = :name

    # Output array with the TLEs found in the file.
    vtle = TLE[]

    # Auxiliary variables.
    line_num       = 0
    l1_position    = 0
    l2_position    = 0
    line           = nothing
    skip_line_read = false

    # Variables to store the each TLE inforamtion.
    name   = nothing
    line_1 = nothing
    line_2 = nothing

    while !eof(io)
        # Read the current line, strip white spaces, and skip if it is blank or is a comment.
        if !skip_line_read
            line = strip(readline(io))
            line_num += 1
            (isempty(line) || (line[1] == '#')) && continue
        else
            skip_line_read = false
        end

        # Check the state of the reading.
        if state === :name
            # Check if the line seems to be the first line of the TLE. In this case, maybe
            # the user has not provided a name. Then, change the state to `:l1`, and skip
            # the line reading in the next loop.
            if (line[1:2] == "1 ") && (length(line) == 69)
                name = "UNDEFINED"
                state = :l1
                skip_line_read = true
                continue

            # If the beginning of the line is `2 `, the line is considered the second TLE
            # line. However, if we are in this state, it means that the first line had a
            # parsing error. Hence, we need to skip this line.
            elseif (line[1:2] == "2 ")
                continue
            end

            # Otherwise, if the line is not blank, then it must be the name of the
            # satellite.
            #
            # NOTE: The name should not be bigger than 24 characters. However, we will not
            # check this here.

            # Copy the name and change to state to wait for the 1st line.
            name  = line
            state = :l1

        # TLE Line 1
        # ==================================================================================

        elseif state === :l1
            # The next non-blank line must be the first line of the TLE.  Otherwise, the
            # file is not valid.

            # The first line must start with "1 " and have 69 characters.
            if (line[1:2] != "1 ") || (length(line) != 69)
                @error("[Line $line_num]: This is not a valid 1st line.")

                # Reset the state machine and continue.
                state = :name
                continue
            end

            line_1      = line
            l1_position = line_num
            state       = :l2

        # TLE Line 2
        # ==================================================================================

        elseif state === :l2
            # The next non-blank line must be the second line of the TLE.  Otherwise, the
            # file is not valid.

            # The second line must start with "2 " and have 69 characters.
            if (line[1:2] != "2 ") || (length(line) != 69)
                @error("[Line $line_num]: This is not a valid 2nd line.")

                # Reset the state machine and continue.
                state = :name
                continue
            end

            line_2 = line
            l2_position = line_num

            # Now, we can parse the TLE.
            tle = _parse_tle(
                line_1,
                line_2;
                l1_position,
                l2_position,
                name,
                verify_checksum
            )

            !isnothing(tle) && push!(vtle, tle)

            # Change the state to wait for another TLE.
            state = :name
        end
    end

    # If the final state is not :name, then we have an incomplete TLE. Thus, throw and
    # exception because the file is not valid.
    state !== :name && @error("[Line $line_num]: " * "The last TLE in the file is incomplete.")

    return vtle
end

# Verify the TLE `line` checksum related to the TLE line `line_number`, which can be 1 or 2.
#
# If the checksum is valid, this function returns `true`. Otherwise, it returns `false`.
#
# `debug_prefix` is a string that will be added to the debugging messages.
function _verify_tle_line_checksum(
    line::AbstractString,
    line_number::Int;
    debug_prefix::String = ""
)
    # Try parsing the line checksum.
    checksum = _tle_try_parse(
        Int,
        string(line[69]),
        1,
        debug_prefix,
        "line $line_number checksum"
    )
    isnothing(checksum) && return false

    # Compute the expected checksum.
    expected_checksum = tle_line_checksum(@view line[1:end-1])

    if checksum != expected_checksum
        @error(
            debug_prefix *
            "Wrong checksum in TLE line $line_number (expected = $expected_checksum, found = $checksum)."
        )

        return false
    end

    return true
end

# Try to parse the `input` to type `T`.
#
# If the operation is successful, it returns the parsed value to `input`.  Otherwise, it
# prints an error message and returns `nothing`.
#
# `debug_prefix` is a string to be added to the debugging message, `line_number` must be the
# current TLE line number (1 or 2), and `field` must be the current TLE field that is being
# parsed.
function _tle_try_parse(
    T::DataType,
    input::AbstractString,
    line_number::Int,
    debug_prefix::String,
    field::String
)
    output = tryparse(T, input)

    if isnothing(output)
        @error(debug_prefix * "The $(field) in the TLE line $(line_number) could not be parsed.")
        return nothing
    end

    return output
end
