# What was actually tested

Execution used GNU Octave 8.4.0 and the unmodified GPELab source at the GitHub
commit recorded in MODEL_NOTES.md. **MATLAB itself was not available.** Passing
Octave execution is useful compatibility evidence, not a guarantee for every
MATLAB release or a different GPELab fork.

## Passed checks

- MISS_HIT parsed/linted all 16 MATLAB files without findings.
- `test_pv(true)` passed: positive/negative circulation, rejection of density
  holes with no circulation, periodic face/edge/corner padding, normalization,
  analytic plane-wave kinetic energy, and the sign of angular momentum.
- Actual GPELab evolution passed exact free-wave propagation (including phase
  and step count), a harmonic-oscillator rotation-sign check, and norm tests.
- A time-dependent pin-release ramp gave matching wavefunctions when advanced
  in one block versus two blocks; relative discrepancy was below 1e-10.
- `test_pv_time_convergence` gave relative wavefunction errors 3.10315e-6,
  7.36407e-7, and 1.47162e-7 for dt=0.004, 0.002, and 0.001, compared with
  dt=0.0005 at t=0.04. This short, coarse-grid test supports second-order time
  convergence; it does not establish spatial convergence.
- The smoke runner, MAT/CSV output, nine-panel plotting, and PNG export executed.
  The rendered plot was visually checked.
- The default 64 x 64 x 96 control was exercised through t=0.9, then stopped
  to finish the full-duration checks on a smaller grid. A full default-grid
  pair and the refined preset were **not** completed here.
- Both full-duration control and release runs completed on a 32 x 32 x 48 grid,
  dt=0.002, T=2, with all other demo physics parameters unchanged. Their CSVs
  and release overview are in `example_output/`. These are coarse execution
  examples, not converged research data.

## Coarse full-run checks

| Quantity | Control | Release |
|---|---:|---:|
| Maximum absolute norm drift | 1.98e-13 | 1.77e-13 |
| Final minus initial rotating-frame energy | +4.27e-7 | -0.17085 |
| Initial positive midplane crossings | 3 | 3 |
| Final positive midplane crossings | 3 | 3 |
| Final condensate angular momentum | 1.31796 | 1.49207 |
| Maximum boundary-shell mass fraction | 0.00165 | 0.00164 |

The control's energy is approximately conserved. The release's energy change
is expected because removing a barrier does work on the condensate. This is
not evidence that the spatial grid is adequate.

**Do not infer an avalanche from these examples.** Both runs end with zero
measured pin-near occupancy, so the initial configuration is not demonstrably
stably pinned. The unchanged control already shows substantial vortex motion.
The coarse runs flag marginal resolution, high-frequency content, and boundary
shell mass. These are reasons to refine the grid, enlarge the box at fixed
spacing, and improve initial-state preparation before drawing physical
conclusions. No avalanche statistics, observational comparison, or neutron-star
calibration was performed.

## Remaining verification on your machine

Run the supplied tests with your MATLAB and GPELab installation. Complete the
demo pair, then vary dt, spatial grid, box size, and detector thresholds
independently as described in README.md. Save the parameters and controls for
every run. Norm conservation alone is insufficient: a unitary solver can still
evolve a poorly resolved or physically unsuitable initial state.
