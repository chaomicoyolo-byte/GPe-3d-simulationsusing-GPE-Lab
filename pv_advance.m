    function psi = pv_advance(psi,p,G,t0,nSteps)
% Advance with unmodified GPELab's 3D Strang splitting solver.
% Recreate Method each block, and explicitly preserve the global time offset.
M=Method_Var3d('Dynamic',1,'Splitting',p.dt,nSteps*p.dt,[]);
M.Stop_time=(nSteps-0.25)*p.dt; % Avoid an extra step from roundoff in < test
M.Splitting='Strang'; M.Output=0;
P=Physics3D_Var3d(M,0.5,p.g,[0 0 p.omega]);
P=Dispersion_Var3d(M,P);
P=Potential_Var3d(M,P,@(X,Y,Z) staticV(p,X,Y,Z));
P=Nonlinearity_Var3d(M,P);
% Explicit coefficients ensure H_rotation = -Omega Lz, Lz=-i(x dy-y dx).
% Do not rely on the sign convention of the default gradient callbacks.
if p.omega~=0
    P=Gradientx_Var3d(M,P,@(X,Y,Z) -1i*p.omega*Y);
    P=Gradienty_Var3d(M,P,@(X,Y,Z)  1i*p.omega*X);
end
if p.releaseFraction~=0 && p.pinHeight~=0
    P=TimePotential_Var3d(M,P,@(t,X,Y,Z) correction(p,t0+t,X,Y,Z));
end
O=OutputsINI_Var3d(M,nSteps,0);
Pr=Print_Var3d(0,nSteps,0);
Phi={pv_pad(psi)};
% GPELab prints a final block even when Print=0; capture that legacy output.
evalc('[Phi,O] = GPELab3d(Phi,M,G,P,O,[],Pr);');
psi=Phi{1}(1:p.N(2),1:p.N(1),1:p.N(3));
assert(all(isfinite(psi(:))),'pv:nonfinite','GPELab returned NaN/Inf.');
end
function V=staticV(p,X,Y,Z)
q=p; q.releaseFraction=0; V=pv_potential(q,0,X,Y,Z);
end
function W=correction(p,t,X,Y,Z)
[~,W]=pv_potential(p,t,X,Y,Z);
end
