function [V,W] = pv_potential(p,t,X,Y,Z)
% V = harmonic trap + static pin array + time-dependent correction W.
V=0.5*((p.trap(1)*X).^2+(p.trap(2)*Y).^2+(p.trap(3)*Z).^2);
W=zeros(size(X));
s=max(0,min(1,(t-p.releaseTime)/p.releaseDuration));
ramp=0.5*(1-cos(pi*s));
for j=1:size(p.pinXY,1)
    pin=p.pinHeight*exp(-((X-p.pinXY(j,1)).^2+ ...
        (Y-p.pinXY(j,2)).^2)/(2*p.pinWidth^2));
    V=V+pin;
    if j==p.releasePin, W=-p.releaseFraction*ramp*pin; end
end
V=V+W;
end
