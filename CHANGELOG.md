# Changes

## Unreleased

- Use floating-point `std::abs` for isotope, retention-time and precursor-mass comparisons. Unqualified `abs` selected an integer overload with GCC, accepting peaks outside the tolerance and combining distinct precursors. Core's shared peak-recruitment checks require the corresponding correction.
- Add a regression that keeps reporter intensities separate for precursors 0.25 Da apart. The scientific-output test also overwrites empty results so a stale TSV cannot conceal a failure.
