## Description #############################################################################
#
# Functions to read TLE from different sources.
#
############################################################################################

export @tle_str, @tle_nc_str, @tles_str, @tles_nc_str
export read_tle, read_tles, read_tles_from_file

############################################################################################
#                                          Macros                                          #
############################################################################################

"""
    @tle_str(str)

Parse the single TLE in the string `str` at macro expansion time, returning a `TLE`. The
checksums of both lines are verified. A `TleParseError` is thrown if `str` is not a valid
TLE.

`str` must contain **only** one TLE, i.e. two or three non-empty lines: the optional
satellite name and the two TLE lines. Blank lines and lines starting with `#` are
discarded.

See also: [`@tle_nc_str`](@ref), [`read_tle`](@ref)

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

Parse the single TLE in the string `str` at macro expansion time, returning a `TLE`. The
checksums of the lines are **not** verified. A `TleParseError` is thrown if `str` is not
a valid TLE.

`str` must contain **only** one TLE, i.e. two or three non-empty lines: the optional
satellite name and the two TLE lines. Blank lines and lines starting with `#` are
discarded.

See also: [`@tle_str`](@ref), [`read_tle`](@ref)

# Example

```julia-repl
julia> tle = tle_nc\"""
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

Parse the set of TLEs in the string `str` at macro expansion time, returning a
`Vector{TLE}`. The checksums of the lines are verified, and the TLEs that cannot be parsed
are skipped with a warning.

See also: [`@tles_nc_str`](@ref), [`read_tles`](@ref)

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

Parse the set of TLEs in the string `str` at macro expansion time, returning a
`Vector{TLE}`. The checksums of the lines are **not** verified, and the TLEs that cannot
be parsed are skipped with a warning.

See also: [`@tles_str`](@ref), [`read_tles`](@ref)

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

############################################################################################
#                                        Functions                                         #
############################################################################################

"""
    read_tle(str::AbstractString; kwargs...) -> TLE

Read the single TLE in the string `str`, throwing a `TleParseError` if it is not valid.

`str` must contain **only** one TLE, i.e. two or three non-empty lines: the optional
satellite name and the two TLE lines. Blank lines and lines starting with `#` are
discarded.

See also: [`read_tles`](@ref), [`@tle_str`](@ref)

# Keywords

- `verify_checksum::Bool`: If `true`, the checksum of both TLE lines is verified.
    (**Default**: `true`)

# Extended help

## Throws

- `TleParseError`: If `str` does not contain exactly one TLE, or if the TLE cannot be
    parsed.
"""
function read_tle(str::AbstractString; verify_checksum::Bool = true)
    # Split the string into lines, discarding empty lines and comments.
    lines     = filter(l -> !isempty(l) && (l[1] != '#'), strip.(split(str, '\n')))
    num_lines = length(lines)

    (num_lines == 2) || (num_lines == 3) ||
        throw(TleParseError("The string must contain only one TLE (2 or 3 lines)."))

    if num_lines == 2
        return _parse_tle(lines[1], lines[2]; verify_checksum)
    else
        return _parse_tle(lines[2], lines[3]; name = lines[1], verify_checksum)
    end
end

"""
    read_tle(l1::AbstractString, l2::AbstractString; kwargs...) -> TLE

Read the TLE whose first line is `l1` and second line is `l2`, throwing a `TleParseError`
if it is not valid. The surrounding whitespace of the lines is discarded.

# Keywords

- `name::AbstractString`: Satellite name assigned to the returned TLE.
    (**Default**: `"UNDEFINED"`)
- `verify_checksum::Bool`: If `true`, the checksum of both TLE lines is verified.
    (**Default**: `true`)

# Extended help

## Throws

- `TleParseError`: If the TLE cannot be parsed.
"""
function read_tle(
    l1::AbstractString,
    l2::AbstractString;
    name::AbstractString = "UNDEFINED",
    verify_checksum::Bool = true,
)
    return _parse_tle(strip(l1), strip(l2); name, verify_checksum)
end

"""
    read_tles(str::AbstractString; kwargs...) -> Vector{TLE}

Read the set of TLEs in the string `str`, returning them in a vector.

Each TLE consists of an optional satellite name line followed by the two TLE lines. Blank
lines and lines starting with `#` are discarded. The TLEs that cannot be parsed are skipped
with a warning.

See also: [`read_tle`](@ref), [`read_tles_from_file`](@ref), [`@tles_str`](@ref)

# Keywords

- `verify_checksum::Bool`: If `true`, the checksum of both lines of each TLE is verified.
    (**Default**: `true`)
"""
function read_tles(str::AbstractString; verify_checksum::Bool = true)
    return _parse_tles(IOBuffer(str); verify_checksum)
end

"""
    read_tles_from_file(filename::AbstractString; kwargs...) -> Vector{TLE}

Read the set of TLEs in the file `filename`, returning them in a vector.

Each TLE consists of an optional satellite name line followed by the two TLE lines. Blank
lines and lines starting with `#` are discarded. The TLEs that cannot be parsed are skipped
with a warning.

See also: [`read_tles`](@ref), [`write_tles`](@ref)

# Keywords

- `verify_checksum::Bool`: If `true`, the checksum of both lines of each TLE is verified.
    (**Default**: `true`)
"""
function read_tles_from_file(filename::AbstractString; verify_checksum::Bool = true)
    return open(filename, "r") do io
        return _parse_tles(io; verify_checksum)
    end
end
