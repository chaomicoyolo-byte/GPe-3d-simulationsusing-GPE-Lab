# First 3D GPELab vortex experiment

A small, deterministic MATLAB experiment for learning about vortex response to
local pin weakening. **This is a Bose-condensate superfluid analog, not a literal
neutron-star simulation or a demonstrated avalanche model.** It evolves a full
3D complex field using GPELab, not stacked independent 2D simulations.

## Run

1. Unzip this project into its own folder. Obtain GPELab from the
   [authors' download page](https://gpelab.math.cnrs.fr/downloads.htm) and unzip it
   separately. The toolbox is not included here. No repository needs editing.
2. In MATLAB, change into this project's folder, then run:

```matlab
addpath(genpath('C:\your\path\to\GPELab')); % change this path
which GPELab3d -all                         % resolve duplicate installations
test_pv(false);                            % helper/numerical convention tests
test_pv(true);                             % also exercise the actual GPELab solver
test_pv_time_convergence;                  % short time-step refinement test
p = pv_config('smoke');
s = run_pulsar_vortices(p);                 % short, deliberately coarse check
```

3. Run the useful demonstration and its matched control:

```matlab
p = pv_config('demo');
pair = run_pin_control(p);                 % two runs, same initial state
r = pair.release;
pv_replay(r);                              % replay saved density/phase slices
pv_plot(r,1);                              % initial 3D winding points
```

For a single run: `r = run_pulsar_vortices(pv_config('demo'));`.
Use base MATLAB R2016b or later (implicit expansion is used). No Parallel
Computing Toolbox is needed. This version runs on the CPU; it does not use your
RTX 3060. GPELab's older code may produce compatibility warnings on newer MATLAB.
Check `VALIDATION.md` for the actual validation performed, rather than assuming
that every MATLAB version has been tested.

Each run creates a new folder below `pv_results`, containing `result.mat`,
`diagnostics.csv`, `checkpoint.mat`, and, when plotting is enabled, `overview.png`.
The paired run also saves `control_comparison.png` in the release folder.
Run time depends strongly on the CPU and FFT implementation; the two demo
runs can take several minutes. The refined grid has eight times as many nodes
and twice as many time steps. Start with the smoke test.
The checkpoint stores the latest field, parameters, and time for recovery or
inspection; automatic resume is not implemented. No previous run is overwritten.

```matlab
S = load('pv_results/your_run_folder/result.mat');
pv_plot(S.result); pv_replay(S.result);
```

## The first parameters to change

Edit `pv_config.m`, or change the returned struct before running.
All quantities are **dimensionless**.

| Parameter | Meaning | First comparison |
|---|---|---|
| `pinHeight` | Strength of density-depleting barriers | 1.5, 3, 4.5 |
| `pinWidth` | Barrier width in x and y | 0.4, 0.5, 0.7; refine grid too |
| `g` | Repulsive contact interaction with unit-normalized field | 50, 100, 200 |
| `omega` | Imposed rotating-frame angular speed | 0.3, 0.45, 0.6 |
| `bend` | Initial z-dependent vortex displacement | 0 versus 0.12 |
| `releaseFraction` | Fraction removed from pin 1 | 0 control, 0.5 partial, 1 full |

Keep `abs(omega)` below both radial trap frequencies for these exploratory runs.
`pinXY`, `vortexXY`, and `charge` expose geometry and circulation, but start with
the supplied three-line setup. Changing `pinXY` does not automatically move
`vortexXY`; set both if you want initially aligned lines.

## Read the output correctly

- Density and phase slices show the field at z=0. Empty density holes alone do
  not establish the presence of a vortex.
- Blue/red 3D points mark +1/-1 phase winding through **xy plaquettes**. They show
  intersections at successive z slices, not traced filament identities.
- Pin occupancy is the fraction of central z slices containing a positive
  winding point within `captureRadius` of a pin. It is a proximity measure,
  not proof that a vortex is dynamically bound.
- Norm should stay near one without renormalization. Rotating-frame energy
  should be approximately conserved for the control; the release does work on
  the system, so energy changes during the ramp are physical.
- Superfluid angular momentum can change because the nonaxisymmetric pins exert
  torque. There is no evolving crust whose spin can be read from this quantity.
- Boundary-shell mass, high-frequency power, and the estimated healing length
  flag numerical concerns. Thresholds are warnings, not certificates of accuracy.

The Gaussian initial state is excited and deliberately not claimed to be in
equilibrium. It can breathe, emit sound, and move vortices in the control too.
Compare release versus control before interpreting any response.

## Before making a research claim

Repeat at half `dt` while keeping the observation interval fixed:
`q=p; q.dt=p.dt/2; q.sampleEvery=2*p.sampleEvery;`.
Then increase spatial resolution independently, for example
`q=p; q.N=2*p.N;`. Also enlarge the box while retaining the same spacing.
Test detection thresholds 0.01, 0.02, 0.04 and capture radii 0.5, 0.65, 0.8.
Compare energy outside the release ramp, occupancy curves, and vortex positions,
not just conserved norm. The `refined` preset doubles the grid and halves `dt`
together; it is convenient, but separate tests identify each error source.

A defensible first question is: **Does weakening one pin change the occupancy
of the other two, relative to a matched control, and does that result survive
numerical refinement?** A negative result is useful. Three vortices and one
externally imposed perturbation cannot establish avalanche scaling or pulsar
glitch statistics. See `MODEL_NOTES.md` for the equation and limits.
