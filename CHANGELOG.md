SatelliteToolboxTle.jl Changelog
================================

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

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/Deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/Feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/Enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/Bugfix-purple.svg
[badge-info]: https://img.shields.io/badge/Info-gray.svg
