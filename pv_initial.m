function psi = pv_initial(p,a)
% Analytic imprinted state, not a ground state or equilibrated pinned state.
psi=exp(-0.5*((a.X/p.envelopeWidth(1)).^2 + ...
    (a.Y/p.envelopeWidth(2)).^2+(a.Z/p.envelopeWidth(3)).^2));
for j=1:size(p.vortexXY,1)
    phaseOffset=2*pi*(j-1)/max(1,size(p.vortexXY,1));
    u=a.X-p.vortexXY(j,1)-p.bend*sin(pi*a.Z/p.halfBox(3)+phaseOffset);
    v=a.Y-p.vortexXY(j,2)-p.bend*cos(pi*a.Z/p.halfBox(3)+phaseOffset);
    r=sqrt(u.^2+v.^2);
    psi=psi.*tanh(r/p.coreWidth).*exp(1i*p.charge(j)*atan2(v,u));
end
psi=psi/sqrt(sum(abs(psi(:)).^2)*a.dv);
end
