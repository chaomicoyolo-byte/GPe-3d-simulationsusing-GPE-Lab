function full = pv_pad(psi)
% Restore ALL duplicate periodic faces, edges and corner for GPELab.
full=psi([1:size(psi,1) 1],[1:size(psi,2) 1],[1:size(psi,3) 1]);
end
