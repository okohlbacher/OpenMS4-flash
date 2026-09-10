# OpenMSFLASH 1.0.0 experimental

Independent FLASH algorithms and command-line tools, built against the exact installed Core and CLI revisions in `dependencies.lock.json`. The package exports `OpenMS::FLASH` and owns `FLASHDeconvAlgorithm`, `SpectralDeconvolution`, `MassFeatureTrace`, `Qvalue`, `TopDownIsobaricQuantification`, and the FLASHDeconv executable. FLASHDeconv is the only FLASH executable source present in this checkout; FLASHIda mentions describe algorithm modes. Web applications are separate products.

Core retains every file-format reader/writer, including FLASHDeconvFeatureFile and FLASHDeconvSpectrumFile. Their shared records (`FLASHHelperClasses`, `PeakGroup`, `DeconvolvedSpectrum`) and `PeakGroupScoring` also stay in Core. Shared isotope scoring has one Core implementation; the existing SpectralDeconvolution methods forward to it. Core does not link this backend.

Use the same compiler and build type as the installed SDKs. With matching Debug Core, Core TestSupport, and CLI installed:

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_PREFIX_PATH=/sdk/openms4 -DCMAKE_INSTALL_PREFIX=/sdk/openms4
cmake --build build --parallel 2
ctest --test-dir build --output-on-failure
cmake --install build
```

The default tests include four native class/integration tests and two executable metadata tests. Run metadata tests before installing this build into a prefix that is already discovered by the registry: the build and installed manifests both register FLASHDeconv, and duplicate registrations intentionally fail. Use a fresh validation prefix or isolate tool discovery while testing.

`OPENMSFLASH_BUILD_TOOLS=OFF` builds and installs the backend without requiring CLI, for C++ or optional Python consumers. With `BUILD_TESTING=OFF`, backend builds need only the pinned Core SDK; tests additionally require its installed TestSupport. C++ consumers use `find_package(OpenMSFLASH 1.0.0 EXACT CONFIG REQUIRED)` and link `OpenMS::FLASH`; its configuration checks the required Core revision. The moved header paths and class names remain the same, while their symbols now come from this library. Rebuild consumers when adopting this package boundary.

The package owns its moved class fixtures. The former deconvolution-driven Core DeconvolvedSpectrum test is preserved as `DeconvolvedSpectrum_integration_test`; Core tests now construct domain records directly. Full TOPP numerical fixtures remain in the pinned TestData package. Set `OPENMS_TOOL_PREFIX_PATH` to installation prefixes for executable discovery.

## Installation and source identity

The example co-locates independently built packages in one install prefix.
Unix executables and libraries use relative loader paths to its library directory;
Windows deployments place the Core/CLI and dependency DLLs beside the executables
in `bin`. For deliberately separate Unix prefixes, supply their library paths in
`CMAKE_INSTALL_RPATH`; this is a fixed-prefix deployment rather than a relocatable
combined bundle. `OPENMS_TOOL_PREFIX_PATH` controls tool discovery, not native
library loading. Package external native dependencies when creating a bundle.

`OPENMS4_REQUIRE_CLEAN_SOURCE=ON` rejects uncommitted source inputs for published
builds. Source archives must provide `OPENMS4_SOURCE_REVISION` and explicitly
assert `OPENMS4_SOURCE_DIRTY`; Git checkouts derive both from the checkout.
The consumer helper is generated from the parent experiment's canonical CMake
source; standalone builds do not require the parent checkout.

`tools.json` owns executable registration and categories. Missing, duplicate or invalid metadata fails configuration.

With `OPENMS4_REGRESSION_TESTS=ON` and the pinned TestData package installed,
`TOPP_FLASHDeconv_1_science` compares the sample's mass, retention-time,
charge, intensity and score columns against an independently executed
pre-refactor Core reference. It ignores only the filename and row identifier.
See [reference provenance](tests/data/README.md) for its measured origin and the
archived upstream reference's mismatch. This guards refactoring equivalence;
it does not establish the biological correctness of that baseline assignment.
INI/CTD tests parse generated XML and assert product identity.
