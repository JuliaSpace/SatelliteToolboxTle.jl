SatelliteToolboxTle.jl Changelog
================================

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
