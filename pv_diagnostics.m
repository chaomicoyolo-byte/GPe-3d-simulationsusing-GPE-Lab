function [d,v] = pv_diagnostics(psi,p,a,t,rhoThreshold)
rho=abs(psi).^2; F=fftn(psi);
dx=ifftn(1i*a.KX.*F); dy=ifftn(1i*a.KY.*F); dz=ifftn(1i*a.KZ.*F);
d.norm=sum(rho(:))*a.dv;
localL=real(conj(psi).*(-1i*(a.X.*dy-a.Y.*dx)));
d.Lz=sum(localL(:))*a.dv;
V=pv_potential(p,t,a.X,a.Y,a.Z);
localE=0.5*(abs(dx).^2+abs(dy).^2+abs(dz).^2)+V.*rho+0.5*p.g*rho.^2;
d.energyLab=sum(localE(:))*a.dv;
d.energyRot=d.energyLab-p.omega*d.Lz;
d.edgeMass=sum(rho(a.edge))*a.dv/d.norm;
spectralPower=abs(F).^2;
d.highKFraction=sum(spectralPower(a.highK))/sum(spectralPower(:));
d.xiMin=1/sqrt(max(eps,2*p.g*max(rho(:)))); % Peak-density healing estimate
[v]=pv_vortices(psi,p,a,rhoThreshold);
d.nPlus=v.nPlus; d.nMinus=v.nMinus;
d.meanRadius=v.meanRadius; d.occupancy=v.occupancy;
end
