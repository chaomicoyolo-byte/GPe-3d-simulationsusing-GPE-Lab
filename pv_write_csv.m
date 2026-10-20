function pv_write_csv(r,path)
fid=fopen(path,'w'); assert(fid~=-1,'pv:csv','Cannot open CSV.');
cleanup=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'time,norm,energyRot,energyLab,Lz,plusMid,minusMid,meanRadius,edgeMass,highKFraction,xiMin');
for j=1:size(r.p.pinXY,1), fprintf(fid,',occupancyPin%d',j); end
fprintf(fid,'\n');
for k=1:numel(r.time)
    d=r.diagnostics(k);
    row=[r.time(k) d.norm d.energyRot d.energyLab d.Lz d.nPlus d.nMinus ...
        d.meanRadius d.edgeMass d.highKFraction d.xiMin d.occupancy];
    fprintf(fid,'%.12g',row(1)); fprintf(fid,',%.12g',row(2:end)); fprintf(fid,'\n');
end
end
