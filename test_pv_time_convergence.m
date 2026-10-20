function errors = test_pv_time_convergence
% Short coarse-grid time-order test; does not establish spatial convergence.
p=pv_config; p.N=[24 24 24]; p.releaseTime=0; p.releaseDuration=0.02;
a=pv_grid(p); u=pv_initial(p,a); L=p.halfBox;
G=Geometry3D_Var3d(-L(1),L(1),-L(2),L(2),-L(3),L(3),25,25,25);
p.dt=0.004; u1=pv_advance(u,p,G,0,10);
p.dt=0.002; u2=pv_advance(u,p,G,0,20);
p.dt=0.001; u3=pv_advance(u,p,G,0,40);
p.dt=0.0005; u4=pv_advance(u,p,G,0,80);
e1=norm(u1(:)-u4(:))/norm(u4(:)); e2=norm(u2(:)-u4(:))/norm(u4(:)); e3=norm(u3(:)-u4(:))/norm(u4(:));
fprintf('Time convergence errors: %.12g %.12g %.12g\n',e1,e2,e3);
assert(e1>3*e2 && e2>3*e3,'Time convergence not consistent with second order');
errors=[e1 e2 e3];
end
