function pv_replay(r,pauseSeconds)
% Replay saved midplane slices; does not rerun GPELab or require a video toolbox.
if nargin<2, pauseSeconds=0.05; end
f=figure('Color','w','Name','Vortex analog: density and phase');
for k=1:numel(r.time)
    if ~ishandle(f), break; end
    subplot(1,2,1); imagesc(r.x,r.y,r.rhoMid(:,:,k)); axis xy equal tight;
    colorbar; title(sprintf('Density, t=%.3f',r.time(k))); xlabel('x'); ylabel('y');
    subplot(1,2,2); imagesc(r.x,r.y,r.phaseMid(:,:,k)); axis xy equal tight;
    clim    ([-pi pi]); colorbar; title('Phase'); xlabel('x'); ylabel('y');
    drawnow; pause(pauseSeconds);
end
end
