function a = pv_grid(p)
% Meshgrid ordering: array indices are (y,x,z), as in GPELab.
a.x = -p.halfBox(1)+(0:p.N(1)-1)*2*p.halfBox(1)/p.N(1);
a.y = -p.halfBox(2)+(0:p.N(2)-1)*2*p.halfBox(2)/p.N(2);
a.z = -p.halfBox(3)+(0:p.N(3)-1)*2*p.halfBox(3)/p.N(3);
[a.X,a.Y,a.Z] = meshgrid(a.x,a.y,a.z);
a.h = 2*p.halfBox./p.N;
a.dv = prod(a.h);
k = cell(1,3);
for d=1:3
    n=p.N(d); k{d}=(pi/p.halfBox(d))*[0:n/2-1 -n/2:-1];
end
[a.KX,a.KY,a.KZ]=meshgrid(k{1},k{2},k{3});
a.highK = abs(a.KX)>0.7*pi/a.h(1) | ...
    abs(a.KY)>0.7*pi/a.h(2) | abs(a.KZ)>0.7*pi/a.h(3);
a.edge = abs(a.X)>0.85*p.halfBox(1) | ...
    abs(a.Y)>0.85*p.halfBox(2) | abs(a.Z)>0.85*p.halfBox(3);
[~,a.midZ]=min(abs(a.z));
end
