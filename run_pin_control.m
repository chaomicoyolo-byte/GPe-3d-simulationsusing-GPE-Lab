function pair = run_pin_control(p)
% Identical analytic initial state; only releaseFraction differs.
if nargin<1, p=pv_config; end
q=p; q.releaseFraction=0; q.label='control';
fprintf('Running unchanged-pin control.\n'); pair.control=run_pulsar_vortices(q);
fprintf('Running pin-release experiment.\n'); pair.release=run_pulsar_vortices(p);
if p.makePlots
    c=pair.control; r=pair.release;
    f=figure('Color','w','Name','Pin release versus matched control');
    subplot(2,2,1); plot(c.time,[c.diagnostics.Lz],r.time,[r.diagnostics.Lz]);
    xlabel('Time'); ylabel('<L_z>'); legend('Control','Release'); grid on;
    subplot(2,2,2); plot(r.time,[r.diagnostics.Lz]-[c.diagnostics.Lz]);
    xlabel('Time'); ylabel('Release minus control <L_z>'); grid on;
    subplot(2,2,3); plot(c.time,[c.diagnostics.nPlus],r.time,[r.diagnostics.nPlus]);
    xlabel('Time'); ylabel('Positive z=0 crossings'); legend('Control','Release'); grid on;
    subplot(2,2,4);
    plot(r.time,vertcat(r.diagnostics.occupancy)-vertcat(c.diagnostics.occupancy));
    xlabel('Time'); ylabel('Occupancy: release minus control'); grid on;
    if p.saveOutput
        print(f,fullfile(r.outputDirectory,'control_comparison.png'),'-dpng','-r140');
    end
end
end
