function result = run_pulsar_vortices(p)
%RUN_PULSAR_VORTICES GPELab 3D superfluid analog with original diagnostics.
% addpath(genpath('C:\path\to\GPELab')); result=run_pulsar_vortices;
if nargin<1, p=pv_config; end
pv_validate(p);
required={'GPELab3d','Method_Var3d','Geometry3D_Var3d','Physics3D_Var3d', ...
 'Dispersion_Var3d','Potential_Var3d','Nonlinearity_Var3d', ...
 'Gradientx_Var3d','Gradienty_Var3d','TimePotential_Var3d','OutputsINI_Var3d','Print_Var3d'};
for j=1:numel(required)
    assert(exist(required{j},'file')==2,'pv:missingGPELab', ...
      'Missing %s. Unzip GPELab and addpath(genpath(toolboxFolder)).',required{j});
end
a=pv_grid(p); psi=pv_initial(p,a); psiInitial=psi;
L=p.halfBox;
G=Geometry3D_Var3d(-L(1),L(1),-L(2),L(2),-L(3),L(3), ...
    p.N(1)+1,p.N(2)+1,p.N(3)+1);
assert(isequal(size(G.X),size(pv_pad(psi))),'pv:shape','GPELab geometry mismatch.');
rhoThreshold=p.densityFraction*max(abs(psi(:)).^2);
nSteps=round(p.T/p.dt);
sampleSteps=unique([0:p.sampleEvery:nSteps nSteps]);
times=sampleSteps*p.dt; ns=numel(times);
points=cell(1,ns); diagnostics=struct([]);
rhoMid=zeros(p.N(2),p.N(1),ns,'single');
phaseMid=zeros(size(rhoMid),'single');
outDir='';
if p.saveOutput
    if ~exist(p.outputRoot,'dir'), mkdir(p.outputRoot); end
    outDir=tempname(p.outputRoot); mkdir(outDir); % Never overwrite a previous run
end
clockStart=tic;
fprintf('3D BEC analog, %d x %d x %d FFT nodes, %d steps.\n',p.N,nSteps);
for k=1:ns
    if k>1
        psi=pv_advance(psi,p,G,times(k-1),sampleSteps(k)-sampleSteps(k-1));
    end
    [d,v]=pv_diagnostics(psi,p,a,times(k),rhoThreshold);
    if k == 1
    diagnostics = repmat(d, 1, ns);
end
diagnostics(k) = d;
points{k} = v;;
    rhoMid(:,:,k)=single(abs(psi(:,:,a.midZ)).^2);
    phaseMid(:,:,k)=single(angle(psi(:,:,a.midZ)));
    if k==1 || k==ns || mod(k,10)==0
        fprintf('t=%6.3f  norm=%.10f  Lz=%8.4f  midplane +/−=%d/%d\n', ...
            times(k),d.norm,d.Lz,d.nPlus,d.nMinus);
    end
    if p.saveOutput
        checkpoint=struct('p',p,'t',times(k),'psi',psi,'completedSample',k); 
        save(fullfile(outDir,'checkpoint.mat'),'checkpoint','-v7');
    end
end
result=struct('p',p,'time',times,'diagnostics',diagnostics,'points',{points}, ...
    'rhoMid',rhoMid,'phaseMid',phaseMid,'psiInitial',psiInitial,'psiFinal',psi, ...
    'x',a.x,'y',a.y,'z',a.z,'rhoThreshold',rhoThreshold, ...
    'elapsedSeconds',toc(clockStart),'outputDirectory',outDir, ...
    'runtimeVersion',version,'gpelabPath',which('GPELab3d'));
if max(abs([diagnostics.norm]-diagnostics(1).norm))>1e-7
    warning('pv:norm','Norm drift exceeds 1e-7; reject quantitative results.');
end
if max([diagnostics.edgeMass])>1e-4
    warning('pv:edge','Appreciable mass in boundary shell; test a larger box.');
end
if min([diagnostics.xiMin])/max(a.h)<2 || p.pinWidth/min(a.h(1:2))<2
    warning('pv:resolution','Core or pin resolution is marginal; refine before interpreting.');
end
if max([diagnostics.highKFraction])>1e-4
    warning('pv:spectrum','High-frequency power is non-negligible; test spatial refinement.');
end
if p.saveOutput
    save(fullfile(outDir,'result.mat'),'result','-v7');
    pv_write_csv(result,fullfile(outDir,'diagnostics.csv'));
end
if p.makePlots
    f=pv_plot(result);
    if p.saveOutput, print(f,fullfile(outDir,'overview.png'),'-dpng','-r140'); end
end
fprintf('Completed in %.1f s.\n',result.elapsedSeconds);
if p.saveOutput, fprintf('Results: %s\n',outDir); end
end
