function f = pv_plot(r,k)
%PV_PLOT Field slices, phase-winding intersections, and diagnostic history.
if nargin<2, k=numel(r.time); end
p=r.p; d=r.diagnostics; v=r.points{k}; t=r.time;
f=figure('Name','3D GPE analog: not a neutron-star simulation', ...
    'Color','w','Position',[40 40 1250 850]);
annotation(f,'textbox',[0 0.96 1 0.035],'String', ...
    sprintf('3D superfluid analog | %d x %d x %d grid | %s',p.N,p.label), ...
    'Interpreter','none','EdgeColor','none','HorizontalAlignment','center', ...
    'FontWeight','bold');
subplot(3,3,1); imagesc(r.x,r.y,r.rhoMid(:,:,k)); axis xy equal tight;
hold on; plot(p.pinXY(:,1),p.pinXY(:,2),'wx','LineWidth',1.5);
xlabel('x'); ylabel('y'); colorbar; title(sprintf('Density z=0, t=%.3f',t(k)));
subplot(3,3,2); imagesc(r.x,r.y,r.phaseMid(:,:,k)); axis xy equal tight;
caxis([-pi pi]); colorbar; xlabel('x'); ylabel('y'); title('Phase (radians)');
subplot(3,3,3); hold on;
for j=1:size(p.pinXY,1)
    plot3([p.pinXY(j,1) p.pinXY(j,1)],[p.pinXY(j,2) p.pinXY(j,2)], ...
        [-p.analysisHalfZ p.analysisHalfZ],'k:');
end
pos=v.charge>0; neg=v.charge<0;
scatter3(v.xyz(pos,1),v.xyz(pos,2),v.xyz(pos,3),10,[0.1 0.4 0.9],'filled');
scatter3(v.xyz(neg,1),v.xyz(neg,2),v.xyz(neg,3),10,[0.9 0.2 0.1],'filled');
axis equal; grid on; view(35,25); xlabel('x'); ylabel('y'); zlabel('z');
xlim([-p.analysisRadius p.analysisRadius]); ylim([-p.analysisRadius p.analysisRadius]);
zlim([-p.analysisHalfZ p.analysisHalfZ]); title('xy winding points: blue +1, red -1');
subplot(3,3,4); plot(t,[d.nPlus],'-',t,[d.nMinus],'--','LineWidth',1.3);
xlabel('Time'); ylabel('Count at z=0'); legend('+1','-1','Location','best'); grid on;
ylim([-0.2 max([d.nPlus d.nMinus])+0.5]);
title('Detected crossings, not total filaments');
subplot(3,3,5); occ=vertcat(d.occupancy); plot(t,occ,'LineWidth',1.3);
xlabel('Time'); ylabel('Fraction of central z slices'); ylim([0 1.05]); grid on;
labels=arrayfun(@(j) sprintf('Pin %d',j),1:size(p.pinXY,1),'UniformOutput',false);
if ~isempty(labels), legend(labels,'Location','best'); end
title('Positive winding within capture radius');
subplot(3,3,6); plot(t,[d.Lz],'LineWidth',1.3); grid on;
xlabel('Time'); ylabel('<L_z>'); title('Superfluid angular momentum');
subplot(3,3,7); plot(t,[d.energyRot],'LineWidth',1.3); grid on;
xlabel('Time'); ylabel('E - Omega <L_z>'); title('Energy changes during pin release');
subplot(3,3,8); plot(t,[d.norm]-d(1).norm,'LineWidth',1.3); grid on;
xlabel('Time'); ylabel('N(t)-N(0)'); title('Norm error (no renormalization)');
subplot(3,3,9); semilogy(t,max([d.edgeMass],eps),t,max([d.highKFraction],eps),'LineWidth',1.3);
xlabel('Time'); ylabel('Fraction'); legend('Boundary shell','High k','Location','best'); grid on;
title('Numerical warning indicators');
end
