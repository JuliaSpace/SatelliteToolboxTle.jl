# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to read TLE from different sources.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export @tle_str, @tle_nc_str, @tles_str, @tles_nc_str
export read_tle, read_tles, read_tles_from_file

################################################################################
#                                    Macros
################################################################################

"""
    @tle_str(str)

Parse one TLE in the string `str.

This function returns the parsed TLE or `nothing`, if an error occured.

!!! note
    This function verifies the checksums of the TLE. If the checksum
    verification is not desired, use [`@tle_nc_str`](@ref).

!!! note
    `str` must contain **only** one TLE. Hence, it must have two or three
    non-empty lines. The lines beginning with the character `#` are discarded.

# Example

```julia-repl
julia> tle = tle\"""
       CBERS 4
       1 40336U 14079A   18166.15595376 -.00000014  00000-0  10174-4 0  9993
       2 40336  98.4141 237.7928 0001694  75.7582 284.3804 14.35485112184485
       \"""
```
"""
macro tle_str(str)
    return read_tle(str; verify_checksum = true)
end

"""
    @tle_nc_str(str)

Parse one TLE in the string `str.

This function returns the parsed TLE or `nothing`, if an error occured.

!!! note
    This function **does not** verify the checksums of the TLE. If the checksum
    verification is desired, use [`@tle_str`](@ref).

!!! note
    `str` must contain **only** one TLE. Hence, it must have two or three
    non-empty lines. The lines beginning with the character `#` are discarded.

# Example

```julia-repl
julia> tles = tle_nc\"""
       CBERS 4
       1 40336U 14079A   18166.15595376 -.00000014  00000-0  10174-4 0  9993
       2 40336  98.4141 237.7928 0001694  75.7582 284.3804 14.35485112184485
       \"""
```
"""
macro tle_nc_str(str)
    return read_tle(str; verify_checksum = false)
end

"""
    @tles_str(str)

Parse a set of TLEs in the string `str` and return them as a `Vector{TLE}`.

!!! note
    This function verifies the checksums of the TLE. If the checksum
    verification is not desired, use [`@tles_nc_str`](@ref).

# Example

```julia-repl
julia> tles = tles\"""
       CBERS 4
       1 40336U 14079A   18166.15595376 -.00000014  00000-0  10174-4 0  9993
       2 40336  98.4141 237.7928 0001694  75.7582 284.3804 14.35485112184485
       SCD 1
       1 22490U 93009B   18165.62596833  .00000225  00000-0  11410-4 0  9991
       2 22490  24.9690 231.7852 0042844 200.7311 292.7198 14.44524498338066
       SCD 2
       1 25504U 98060A   18165.15074951  .00000201  00000-0  55356-5 0  9994
       2 25504  24.9961  80.1303 0017060 224.4822 286.6438 14.44043397 37312
       \"""
```
"""
macro tles_str(str)
    return read_tles(str; verify_checksum = true)
end

"""
    @tles_nc_str(str)

Parse a set of TLEs in the string `str` and return them as a `Vector{TLE}`.

!!! note
    This version **does not** verify the checksum of the TLE. If the checksum
    verification is required, use [`@tles_nc_str`](@ref).

# Example

```julia-repl
julia> tles = tles_nc\"""
       CBERS 4
       1 40336U 14079A   18166.15595376 -.00000014  00000-0  10174-4 0  9993
       2 40336  98.4141 237.7928 0001694  75.7582 284.3804 14.35485112184485
       SCD 1
       1 22490U 93009B   18165.62596833  .00000225  00000-0  11410-4 0  9991
       2 22490  24.9690 231.7852 0042844 200.7311 292.7198 14.44524498338066
       SCD 2
       1 25504U 98060A   18165.15074951  .00000201  00000-0  55356-5 0  9994
       2 25504  24.9961  80.1303 0017060 224.4822 286.6438 14.44043397 37312
       \"""
```
"""
macro tles_nc_str(str)
    return read_tles(str; verify_checksum = false)
end

################################################################################
#                                  Functions
################################################################################

"""
    read_tle(str::AbstractString; verify_checksum::Bool = false)

Read the TLE in the string `str`.

!!! note
    `str` must contain **only** one TLE. Hence, it must have two or three
    non-empty lines. The lines beginning with the character `#` are discarded.

# Keywords

- `verify_checksum::Bool`: If `true`, the checksum of both TLE lines will be
    verified. Otherwise, the checksum will not be checked.
    (**Default** = `true`)
"""
function read_tle(
    str::AbstractString;
    verify_checksum::Bool = true
)
    # Split the string into lines, discarding empty lines and comments.
    lines = filter(l -> !isempty(l) && (l[1] != '#'), strip.(split(str, '\n')))
    num_lines = length(lines)

    if (num_lines != 2) && (num_lines != 3)
        throw(ArgumentError("The string `str` must contain only one TLE (2 or 3 lines)."))
    end

    if (num_lines == 2)
        tle = _parse_tle(lines[1], lines[2]; verify_checksum)
    else
        tle = _parse_tle(lines[2], lines[3]; name = lines[1], verify_checksum)
    end

    isnothing(tle) && throw(ArgumentError("The TLE is not valid."))

    return tle
end

"""
    read_tle(l1::AbstractString, l2::AbstractString; name::AbstractString = "UNDEFINED", verify_checksum::Bool = false)

Read the TLE in which the first line is `l1` and second line is `l2`.

The keyword `name` can be used to set the satellite name in the output TLE
object.

# Keywords

- `verify_checksum::Bool`: If `true`, the checksum of both TLE lines will be
    verified. Otherwise, the checksum will not be checked.
    (**Default** = `true`)
"""
function read_tle(
    l1::AbstractString,
    l2::AbstractString;
    name::AbstractString = "UNDEFINED",
    verify_checksum::Bool = true
)
    tle = _parse_tle(strip(l1), strip(l2); name, verify_checksum)
    isnothing(tle) && throw(ArgumentError("The TLE is not valid."))
    return tle
end

"""
    read_tles(tles::AbstractString; verify_checksum::Bool = true)

Parse a set of TLEs in the string `tles`. This function returns a `Vector{TLE}`
with the parsed TLEs.

# Keywords

- `verify_checksum::Bool`: If `true`, the checksum of both TLE lines will be
    verified. Otherwise, the checksum will not be checked.
    (**Default** = `true`)
"""
function read_tles(tles::AbstractString; verify_checksum::Bool = true)
    # Convert the string to an `IOBuffer` and call the function to parse it.
    return _parse_tles(IOBuffer(tles); verify_checksum)
end

"""
    read_tles_from_file(filename::String; verify_checksum::Bool = true)

Read the TLEs in the file `filename` and return a `Vector{TLE}` with the parsed
TLEs.

# Keywords

- `verify_checksum::Bool`: If `true`, the checksum of both TLE lines will be
    verified. Otherwise, the checksum will not be checked.
    (**Default** = `true`)
"""
function read_tles_from_file(filename::String; verify_checksum::Bool = true)
    # Open the file in read mode.
    tles = open(filename, "r") do f
        _parse_tles(f; verify_checksum)
    end

    return tles
end
