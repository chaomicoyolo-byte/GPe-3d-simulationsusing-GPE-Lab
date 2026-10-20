function test_pv(withGPELab)
%TEST_PV Meaningful topology, spectral, solver and global-time regression tests.
% test_pv(false) needs only base MATLAB. test_pv(true) also needs GPELab.
if nargin<1, withGPELab=true; end
p=pv_config; p.N=[48 48 32]; p.bend=0; p.vortexXY=[0.11 0.13];
p.charge=1; p.pinXY=p.vortexXY;
a=pv_grid(p); psi=pv_initial(p,a);
[d,v]=pv_diagnostics(psi,p,a,0,p.densityFraction*max(abs(psi(:)).^2));
assert(abs(d.norm-1)<1e-12,'Initial state is not normalized.');
assert(v.nPlus==1 && v.nMinus==0,'Positive vortex winding failed.');
v=pv_vortices(conj(psi),p,a,1e-5);
assert(v.nMinus==1 && v.nPlus==0,'Negative winding failed.');
v=pv_vortices(abs(psi),p,a,1e-5);
assert(isempty(v.xyz),'A density hole was incorrectly classified as a vortex.');
full=pv_pad(psi);
assert(isequal(full(end,:,:),full(1,:,:)) && ...
    isequal(full(:,end,:),full(:,1,:)) && isequal(full(:,:,end),full(:,:,1)), ...
    'Periodic padding failed.');
% Exact free plane wave: checks spectral derivatives and quadrature ordering.
q=p; q.g=0; q.omega=0; q.trap=[0 0 0]; q.pinHeight=0; q.releaseFraction=0;
kx=pi/q.halfBox(1); ky=2*pi/q.halfBox(2); kz=pi/q.halfBox(3);
u=exp(1i*(kx*a.X+ky*a.Y+kz*a.Z))/sqrt(prod(2*q.halfBox));
E=0.5*(kx^2+ky^2+kz^2);
d=pv_diagnostics(u,q,a,0,1);
assert(abs(d.energyLab-E)<1e-11,'Spectral kinetic energy failed.');
% Energy angular sign check for a localized m=+1 state.
u=(a.X+1i*a.Y).*exp(-(a.X.^2+a.Y.^2+a.Z.^2)/2);
u=u/sqrt(sum(abs(u(:)).^2)*a.dv);
q.omega=0.3; d=pv_diagnostics(u,q,a,0,1);
assert(abs(d.Lz-1)<1e-6,'Lz derivative sign/order failed.');
assert(abs(d.energyRot-(d.energyLab-0.3))<1e-6,'Rotation energy sign failed.');
fprintf('PASS: topology, density-hole rejection, padding, norm, energy, Lz.\n');
if ~withGPELab, return; end
q.omega=0; q.dt=0.001;
L=q.halfBox;
G=Geometry3D_Var3d(-L(1),L(1),-L(2),L(2),-L(3),L(3),q.N(1)+1,q.N(2)+1,q.N(3)+1);
u=exp(1i*(kx*a.X+ky*a.Y+kz*a.Z))/sqrt(prod(2*q.halfBox));
actual=pv_advance(u,q,G,0,10); exact=u*exp(-1i*E*10*q.dt);
assert(norm(actual(:)-exact(:))/norm(exact(:))<1e-10, ...
    'GPELab free propagation phase/sign/step count failed.');
% Test rotation sign in solver against H0-Omega Lz on a localized state.
q.trap=[1 1 1]; q.omega=0.3; q.dt=1e-4;
u=(a.X+1i*a.Y).*exp(-(a.X.^2+a.Y.^2+a.Z.^2)/2);
u=u/sqrt(sum(abs(u(:)).^2)*a.dv);
actual=pv_advance(u,q,G,0,1); exact=u*exp(-1i*(2.5-q.omega)*q.dt);
assert(norm(actual(:)-exact(:))<2e-6,'GPELab rotation sign test failed.');
% Split a time-dependent run across an active release ramp; chunk offset
% must not restart the ramp. This tests global time and endpoint handling.
q=p; q.dt=0.002; q.releaseTime=0.004; q.releaseDuration=0.02;
q.releasePin=1;
one=pv_advance(psi,q,G,0,20);
two=pv_advance(psi,q,G,0,7); two=pv_advance(two,q,G,7*q.dt,13);
assert(norm(one(:)-two(:))/norm(one(:))<1e-10,'Chunked time ramp reset.');
assert(abs(sum(abs(one(:)).^2)*a.dv-1)<1e-10,'Dynamic norm conservation failed.');
fprintf('PASS: GPELab free wave, rotation sign, chunked ramp, dynamic norm.\n');
end
