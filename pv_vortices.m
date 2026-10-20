function v = pv_vortices(psi,p,a,rhoThreshold)
% Detect circulation through xy plaquettes at each z. These are intersections,
% NOT tracked line identities, a full 3D filament reconstruction, or loop lengths.
% Counterclockwise viewed from +z: bottom-left -> right -> up -> left -> down.
A=psi(1:end-1,1:end-1,:); B=psi(1:end-1,2:end,:);
C=psi(2:end,2:end,:); D=psi(2:end,1:end-1,:);
w=angle(conj(A).*B)+angle(conj(B).*C)+ ...
  angle(conj(C).*D)+angle(conj(D).*A);
q=round(w/(2*pi));
% Estimate ambient support over a physical neighborhood of radius pinWidth.
% A threshold applied only at the core corners can hide real pinned vortices
% simply because a barrier has depleted their cores more deeply.
rx=max(1,ceil(p.pinWidth/a.h(1))); ry=max(1,ceil(p.pinWidth/a.h(2)));
kernel=ones(2*ry+1,2*rx+1)/((2*ry+1)*(2*rx+1));
support=convn(abs(psi).^2,kernel,'same');
rho=(support(1:end-1,1:end-1,:)+support(1:end-1,2:end,:)+ ...
    support(2:end,2:end,:)+support(2:end,1:end-1,:))/4;
xc=(a.x(1:end-1)+a.x(2:end))/2;
yc=(a.y(1:end-1)+a.y(2:end))/2;
[X,Y,Z]=meshgrid(xc,yc,a.z);
mask=abs(q)==1 & rho>rhoThreshold & ...
    X.^2+Y.^2<p.analysisRadius^2 & abs(Z)<=p.analysisHalfZ;
v.xyz=[X(mask) Y(mask) Z(mask)]; v.charge=q(mask);
[~,~,iz]=ind2sub(size(mask),find(mask));
v.zIndex=iz;
v.nPlus=sum(v.charge(iz==a.midZ)>0);
v.nMinus=sum(v.charge(iz==a.midZ)<0);
if isempty(v.xyz), v.meanRadius=NaN;
else, v.meanRadius=mean(sqrt(sum(v.xyz(:,1:2).^2,2))); end
zs=find(abs(a.z)<=p.analysisHalfZ);
v.occupancy=zeros(1,size(p.pinXY,1));
for j=1:size(p.pinXY,1)
    near=sum((v.xyz(:,1:2)-p.pinXY(j,:)).^2,2)<p.captureRadius^2;
    v.occupancy(j)=numel(unique(iz(near & v.charge>0)))/numel(zs);
end
end
