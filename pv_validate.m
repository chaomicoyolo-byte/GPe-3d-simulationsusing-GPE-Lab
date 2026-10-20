function pv_validate(p)
validateattributes(p.N,{'numeric'},{'vector','numel',3,'integer','>=',8});
assert(all(mod(p.N,2)==0),'pv:grid','N must contain even FFT node counts.');
validateattributes(p.halfBox,{'numeric'},{'vector','numel',3,'positive','finite'});
validateattributes(p.trap,{'numeric'},{'vector','numel',3,'nonnegative','finite'});
validateattributes(p.envelopeWidth,{'numeric'},{'vector','numel',3,'positive','finite'});
positive={'dt','T','pinWidth','coreWidth','releaseDuration','analysisRadius', ...
    'analysisHalfZ','captureRadius'};
for j=1:numel(positive)
    validateattributes(p.(positive{j}),{'numeric'},{'scalar','positive','finite'});
end
nonnegative={'g','pinHeight','bend','releaseTime','densityFraction'};
for j=1:numel(nonnegative)
    validateattributes(p.(nonnegative{j}),{'numeric'},{'scalar','nonnegative','finite'});
end
validateattributes(p.omega,{'numeric'},{'scalar','finite','real'});
validateattributes(p.sampleEvery,{'numeric'},{'scalar','positive','integer'});
validateattributes(p.releaseFraction,{'numeric'},{'scalar','>=',0,'<=',1});
assert(abs(p.T/p.dt-round(p.T/p.dt))<1e-7,'pv:time','T must be a multiple of dt.');
assert(size(p.pinXY,2)==2 && size(p.vortexXY,2)==2,'pv:xy','Coordinates must be Nx2.');
assert(all(isfinite(p.pinXY(:))) && all(isfinite(p.vortexXY(:))),'pv:xy','Nonfinite coordinates.');
assert(numel(p.charge)==size(p.vortexXY,1) && all(abs(p.charge)==1), ...
    'pv:charge','One +1 or -1 charge is required per line.');
assert(p.analysisRadius<min(p.halfBox(1:2)) && p.analysisHalfZ<p.halfBox(3), ...
    'pv:analysis','Analysis cylinder must lie inside the box.');
if p.releaseFraction>0 && p.pinHeight>0
    assert(p.releasePin>=1 && p.releasePin<=size(p.pinXY,1) && mod(p.releasePin,1)==0, ...
        'pv:pin','releasePin must index pinXY.');
end
end
