function ms = msExtractFiring(ms)
%MSEXTRACTFIRING Summary of this function goes here
%   Detailed explanation goes here

decayTime = 1;

V.Ncells = 1;%ms.numSegments;
V.T = ms.numFrames;
V.dt = mode(diff(ms.time))/1000;
V.fast_plot = 0;

for segNum=1:ms.numSegments
    if (mod(segNum,30)==0)
        display(['Extracting firing... ' num2str(segNum/ms.numSegments*100) '%'])
    end
    F = ms.trace(:,segNum)';
    temp = min(F);
    F = F-temp;
    P.sig = mean(mad(F,1)*1.4826); 
    P.gam = (1-V.dt/decayTime)*ones(V.Ncells,1); %tau=dt/(1-gam)
    P.lam =  .2*ones(V.Ncells,1); %expected spikers per frame
    P.a = median(F,2); %size of dF per spike
    P.b = -1*temp*ones(V.Ncells,1);%quantile(F,0.05); %baseline dF

    [n_best p_best V2 C] = fast_oopsi(F,V,P);
    ms.firing(:,segNum) = n_best;
%     plot(F)
%     hold on
%     plot(n_best,'r')
%     hold off
%     ylim([-.1 .5])
%     drawnow
%     segNum
end
% ms.n = n_best;

end

