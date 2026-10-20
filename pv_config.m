function p = pv_config(mode)
%PV_CONFIG Dimensionless BEC analog; no neutron-star calibration.
% Edit the first block for physics, the second for numerical accuracy.
if nargin < 1, mode = 'demo'; end
p.g = 100;                    % Repulsive contact interaction; integral rho=1
p.omega = 0.45;               % Rotating-frame angular speed, about +z
p.trap = [1 1 0.5];           % Harmonic trap frequencies
p.pinHeight = 3;              % Positive density-depleting Gaussian barriers
p.pinWidth = 0.50;            % Gaussian standard deviation in x,y
p.pinXY = [1.2 0; -0.6 1.03923; -0.6 -1.03923];
p.vortexXY = p.pinXY;         % One +1 circulation line at each pin
p.charge = [1 1 1];
p.bend = 0.12;                % Small z-dependent initial line displacement
p.coreWidth = 0.50;           % Initial tanh profile, NOT a calibrated core size
p.envelopeWidth = [1.7 1.7 2.7]; % Analytic, excited initial cloud
p.releasePin = 1;             % Only this pin is weakened
p.releaseFraction = 1;        % 0 = unchanged control; 1 = fully removed
p.releaseTime = 0.5;
p.releaseDuration = 0.4;      % Smooth half-cosine ramp

p.N = [64 64 96];             % UNIQUE FFT nodes [Nx Ny Nz], all even
p.halfBox = [6 6 9];          % Box is [-Lx,Lx] x [-Ly,Ly] x [-Lz,Lz]
p.dt = 0.002;
p.T = 2;
p.sampleEvery = 25;          % In time steps; observations every 0.05
p.densityFraction = 0.02;     % Detection threshold relative to initial peak
p.analysisRadius = 3.5;      % Fixed central analysis cylinder
p.analysisHalfZ = 3.5;
p.captureRadius = 0.65;      % Pin-near occupancy definition, not proof of binding
p.makePlots = true;
p.saveOutput = true;
p.outputRoot = fullfile(pwd,'pv_results');
p.label = mode;
switch mode
    case 'smoke'
        p.N = [24 24 24]; p.T = 0.02; p.sampleEvery = 5;
        p.makePlots = false; % Smoke grid is deliberately under-resolved
    case 'demo'
    case 'refined'
        p.N = [128 128 192]; p.dt = 0.001; p.sampleEvery = 50;
    otherwise
        error('pv:mode','Use smoke, demo, or refined.');
end
end
