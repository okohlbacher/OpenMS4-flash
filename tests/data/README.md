# FLASH numerical reference

`FLASHDeconv_sample_pre_refactor.tsv` was generated on macOS arm64 by running
the unchanged FLASHDeconv front end against the previously installed Core
`21b295c9ad889b402db1e3a20f13e8d08330b61b`, before the adversarial-audit fixes.
The dyld load trace confirms that this run loaded that old Core SDK.
Its numerical columns match the independently run refactored Core
`4fdec46b205459b92e7d3b9e56df5d8e912d5c85` within the existing tolerances.
The algorithm and FLASH output-writer sources are unchanged between those commits.

Input: the pinned TestData package's `FLASHDeconv_sample_input.mzML`.
Invocation: `FLASHDeconv -test -in INPUT -out OUTPUT`, two OpenMP threads.
The parent implementation report preserves the old-library load trace, output,
binary/input/source hashes and comparison result. The reference keeps all
numerical fields; its filename is normalized because paths are not compared.

The older archived TestData output is preserved untouched. It reports a
17989.073405 Da feature at charges 15–17, whereas both tested Core revisions
report 8994.536888 Da at charge 8. It also predates the current writer's retention
time convention and score column. The present writer emits start/end/apex in
minutes but duration in seconds; this test preserves that existing convention.
No tolerance was increased to accept the discrepancy. This new reference tests
equivalence to the selected pre-refactor implementation, not biological accuracy
or equivalence to an older, unidentified FLASH algorithm revision.
