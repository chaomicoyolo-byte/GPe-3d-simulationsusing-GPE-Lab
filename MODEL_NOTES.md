# Model, numerical method, and scientific limits

## Equation

The single-component, repulsively interacting condensate obeys

\[
i\partial_t\psi=\left[-\tfrac12\nabla^2+V(x,y,z,t)
 +g|\psi|^2-\Omega L_z\right]\psi,\quad
L_z=-i(x\partial_y-y\partial_x),\quad\int |\psi|^2d^3x=1.
\]

The harmonic confinement is
`Vtrap = ((wx*x)^2+(wy*y)^2+(wz*z)^2)/2`.
Each pin adds a positive Gaussian
`V0*exp(-((x-xj)^2+(y-yj)^2)/(2*sigma^2))`, independent of z.
Such barriers deplete condensate density; their relationship to vortex binding
must be tested dynamically. They are phenomenological columnar defects, not
resolved crustal nuclei or a microscopic neutron-vortex pinning calculation.

Pin 1 is multiplied by `1-releaseFraction*s(t)`, where `s=0` before
`releaseTime`, `s=1` after `releaseTime+releaseDuration`, and a half-cosine joins
them smoothly. Other pins remain fixed in the rotating frame. Omega is constant.
The explicit gradient callbacks implement `-Omega*Lz`; a test checks its sign.

Units can be understood formally as length `a0=sqrt(hbar/(m*omega0))`, time
`1/omega0`, and energy `hbar*omega0`, with psi scaled to unit norm. This package
does not select neutron-star values for m, omega0, density, or coupling, and
does not convert outputs into seconds, hertz, or observed glitch amplitudes.

## Initial state

A Gaussian envelope is multiplied by one tanh core profile and one phase factor
`exp(i*q*atan2(y-yj(z),x-xj(z)))` per line, then normalized once. The line centers
have small sinusoidal z-dependent displacements. Each charge is +1 by default.
This is an imposed initial configuration, not a converged rotating equilibrium.
The parameter `coreWidth` controls the imprinted profile; the GPE determines its
subsequent evolution. The local healing estimate is `xi=1/sqrt(2*g*rho)` and is
reported using peak density. It is a resolution diagnostic, not neutron-star
microphysics. No imaginary-time preparation, damping, thermal bath, stochastic
forcing, or continual renormalization is applied during this experiment.

## Numerical implementation

GPELab's `GPELab3d` with `Method.Type='Splitting'` and `Splitting='Strang'`
advances the full 3D field. FFT boundaries are periodic in all three directions.
The harmonic trap is intended to make density negligible near the boundary,
but the finite box must still be checked. Arrays use `(y,x,z)` meshgrid order.
`p.N` counts unique FFT nodes; GPELab's geometry receives `p.N+1`. All periodic
duplicate faces, edges and corners are reconstructed on each block.

Runs are divided into observation blocks. The time-potential callback adds the
block start time, so the release ramp does not restart at each observation.
GPELab's floating-point stopping condition is guarded to take exactly the
requested number of steps. A regression test compares a single block against
two blocks through the active ramp. Diagnostics use the unique nodes and
spectral derivatives, with `E_rot=E_lab-Omega*<Lz>`.

The detector sums wrapped phase differences around counterclockwise xy
plaquettes, accepts integer +/-1 circulation, and applies a fixed initial-peak
density threshold on the neighborhood-averaged density and a fixed central
cylinder. The averaging box has half-width approximately `pinWidth` in x and y;
it uses surrounding density rather than demanding a dense vortex core. This
choice is also part of the detector's definition. Detection has grid-scale
positional uncertainty. It can miss horizontal segments, vortices in very dilute
regions, closely spaced opposite signs, and loops. It does not reconstruct
connectivity, line length, reconnections, or identities. Changes in measured
occupancy can arise from this detection process and require visual checks.

## What the analogy does and does not mean

The model retains a complex superfluid order parameter, quantized phase winding,
3D bending, vortex interactions, compressible density waves, and phenomenological
pinning. These make it a useful controlled learning experiment.

It omits neutron pairing microphysics, a realistic equation of state, stratified
stellar structure, proton superconductivity and flux tubes, entrainment,
mutual-friction calibration, electromagnetic spin-down torque, and a crustal
angular-momentum reservoir with backreaction. Neutrons are fermions; the scalar
weakly interacting Bose-gas GPE here is an analog, not a quantitatively validated
description of neutron matter. Neither a loss of condensate angular momentum
nor a burst of motion is automatically a measured pulsar glitch.

The externally removed pin is an imposed perturbation. It is not spontaneous
avalanche onset. An eventual avalanche study needs a demonstrably metastable
initial state, many vortices, loading/drive, appropriate reservoir dynamics,
event definitions, controls against directly forced motion and sound, and
converged ensembles. This first version intentionally stops before those claims.

## Sources and provenance

- Antoine and Duboscq, [GPELab official site and installation](https://gpelab.math.cnrs.fr/downloads.htm).
- [GPELab user guide](https://gpelab.math.cnrs.fr/downloads/GPELab_UserGuide.pdf),
  especially 3D geometry, operator callbacks, and Chapter 5 on dynamics.
- [Dynamics methods paper](https://gpelab.math.cnrs.fr/papers/CPC-GPELab2.pdf).
- Public [guozc12/GPELab mirror](https://github.com/guozc12/GPELab), inspected
  read-only at commit `e3cac2596e91c59b559fc6f8160b70575e346b6b`.
  Checked actual `Geometry3D_Var3d`, `Method_Var3d`, `GPELab3d`, `SPL_DS3d`,
  splitting operators, gradient callbacks, and the 3D examples. The mirror is
  a reference snapshot, not asserted to be the authors' official repository.
  No third-party toolbox files are redistributed in this package.
- Warszawski, Melatos and Berloff,
  [Unpinning triggers for superfluid vortex avalanches](https://arxiv.org/abs/1203.5133)
  (2012): motivation for controlled investigations of unpinning triggers, not a
  claim that this package reproduces that paper.
- Lönnborn, Melatos and Haskell,
  [Collective, glitch-like vortex motion in a neutron star with an annular pinning barrier](https://arxiv.org/abs/1905.02877)
  (2019): prior 3D GPE modeling; this project does not claim that 3D vortex
  simulations are unexplored.
