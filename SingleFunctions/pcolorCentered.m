function p = pcolorCentered(hBin,vBin,data)
%PCOLORCENTERED Plots a pcolor figure using the bins as the center of each
%data point
%   hBin and vBin are the center locations of data
data(end+1,:) = 0;
data(:,end+1) = 0;

dH = mean(diff(hBin));
dV = mean(diff(vBin));
p = pcolor([hBin hBin(end)+dH] - dH/2,[vBin vBin(end)+dV] - dV/2,data);
end

