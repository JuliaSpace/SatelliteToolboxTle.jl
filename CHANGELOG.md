SatelliteToolboxTle.jl Changelog
================================

Version 2.0.0
-------------

- ![BREAKING][badge-breaking] Remove `convert(String, tle)`, which invalidated the compiled
  `convert(String, ::Any)` call sites of Base and other packages. Use
  `write_tle(String, tle)` instead, which returns the same text with a trailing newline.
- ![BREAKING][badge-breaking] The parsing functions now throw the new exception
  `TleParseError`, with the line number and a description of the problem, instead of
  logging an error and throwing an `ArgumentError`. The functions that read multiple TLEs
  emit a warning and skip the invalid ones instead of logging an error.
- ![BREAKING][badge-breaking] The `TLE` constructor now validates that every field fits the
  fixed-width TLE format, throwing an `ArgumentError` otherwise, so that writing a TLE
  never fails. Previously, a satellite number, epoch day, element set number, or
  revolution number that did not fit its field was silently truncated when writing the
  TLE.
- ![BREAKING][badge-breaking] Fix the interpretation of the two-digit epoch year: years
  from 57 to 99 now refer to the 20th century, matching the SGP4 reference implementation,
  instead of years above 75. Hence, `tle_epoch` returns a different date for the years
  from 57 to 75.
- ![BREAKING][badge-breaking] The angles that round to 360° at the printed precision are
  now written as 0°, and a mean motion that rounds to 100 rev/day is saturated instead of
  overflowing the field.
- ![BREAKING][badge-breaking] The Celestrak fetcher now requires exactly one query
  parameter, throwing an `ArgumentError` otherwise, and accepts only integer satellite
  numbers. Request failures throw the new exception `TleFetchError`, with the URL and the
  HTTP status of the request, and the unregistered fetcher methods throw an
  `ArgumentError` instead of an `ErrorException`.
- ![Feature][badge-feature] Add the functions `write_tle` and `write_tles` to write TLEs to
  streams and files, or to return their text when the first argument is `String`.
- ![Feature][badge-feature] Add the keyword `epoch::DateTime` to the `TLE` constructor and
  the property `tle.epoch`, which returns the epoch as a `DateTime`.
- ![Feature][badge-feature] Add the field `ephemeris_type` to the `TLE` structure, which is
  parsed and written back instead of being discarded with a warning.
- ![Feature][badge-feature] Add support for satellite catalog numbers above 99999 using the
  Alpha-5 scheme when parsing and writing TLEs.
- ![Feature][badge-feature] The Celestrak fetcher now accepts international designators
  with the launch piece and preserves the query parameters of custom endpoints.
- ![Enhancement][badge-enhancement] Replace **Crayons.jl** by the tree printing helpers of
  **SatelliteToolboxBase.jl**, so that the TLE is displayed with the same layout and
  customizable `StyledStrings` faces as the other types of the ecosystem. The compact
  representation now includes the satellite number.
- ![Enhancement][badge-enhancement] Parse the TLE fields with an implied decimal point as
  integers scaled by exact powers of ten, which yields correctly rounded values and removes
  all allocations from the parser. Write the TLE lines digit by digit, removing the
  **Printf** dependency and reducing the writing time and allocations by roughly 6 times.
- ![Enhancement][badge-enhancement] Simplify the multi-TLE reader and the functions that
  compute the TLE epoch, which no longer allocate.
- ![Bugfix][badge-bugfix] Fix the documentation of the fetcher API and of the return type
  of `fetch_tles`.

Version 1.1.1
-------------

- ![Enhancement][badge-enhancement] The `TLE` constructor now validates its inputs (for
  example, a negative eccentricity throws an error), and angles are normalized to the
  interval [0, 360]° when converting a TLE to a string, avoiding formatting errors.
- ![Enhancement][badge-enhancement] Improve performance and reduce allocations when parsing
  TLEs and computing checksums.
- ![Enhancement][badge-enhancement] Fix factual errors, typos, and grammar in the
  documentation, and add a docstring to `convert(String, tle)`.
- ![Bugfix][badge-bugfix] Fix crashes when parsing TLEs or computing checksums for lines
  that are too short or contain non-ASCII characters.
- ![Bugfix][badge-bugfix] Fix several errors when converting a TLE to its string
  representation: the epoch year is now zero-padded, rounding can no longer overflow the
  fixed-width fields, and exponents outside ±9 are handled correctly.

Version 1.1.0
-------------

- ![Info][badge-info] We dropped support for Julia 1.6. This version only supports the
  current Julia version and v1.10 (LTS).

Version 1.0.6
-------------

- ![Enhancement][badge-enhancement] Minor source-code improvements.

Version 1.0.5
-------------

- ![Enhancement][badge-enhancement] Documentation update.

Version 1.0.4
-------------

- ![Enhancement][badge-enhancement] **SnoopPrecompile.jl** was replaced by
  **PrecompileTools.jl**.

Version 1.0.3
-------------

- ![Enhancement][badge-enhancement] The TLE printing system was improved. Notice that the
  screen output format has changed, but we do not consider those as breaking changes.

Version 1.0.2
-------------

- ![Enhancement][badge-enhancement] We added precompilation statements to improve
  performance.
- ![Enhancement][badge-enhancement] The code was refactored to follow BlueStyle, and
  line-width was increase to 92, leading to a better source-code organization.

Version 1.0.1
-------------

- ![Bugfix][badge-bugfix] Minor documentation fix.

Version 1.0.0
-------------

- ![BREAKING][badge-breaking] The function `get_epoch` was renamed to
  `get_tle_epoch`.
- ![Feature][badge-feature] We now have support to fetch TLEs from on-line
  sources. Currently, only CelesTrak is supported by default.

Version 0.1.0
-------------

- Initial version.
  - This version was based on the submodule in **SatelliteToolbox.jl**. However,
    many API changes were implemented.

[badge-breaking]: https://img.shields.io/badge/Breaking-DC2626?style=flat-square
[badge-deprecation]: https://img.shields.io/badge/Deprecation-D97706?style=flat-square
[badge-feature]: https://img.shields.io/badge/Feature-16A34A?style=flat-square
[badge-enhancement]: https://img.shields.io/badge/Enhancement-0284C7?style=flat-square
[badge-bugfix]: https://img.shields.io/badge/Bugfix-DB2777?style=flat-square
[badge-info]: https://img.shields.io/badge/Info-475569?style=flat-square
