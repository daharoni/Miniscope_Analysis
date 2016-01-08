function ms = msCleandFFTraces(ms)
%MSCLEANDFFTRACES Summary of this function goes here
%   Detailed explanation goes here
    ms.originalTrace = ms.trace;
    [bFilt,aFilt] = butter(2,  2/(30/2), 'low');
    F = ms.trace - repmat(ms.dFFBaseline,1,ms.numSegments);
    F = filtfilt(bFilt,aFilt,F);
    F=detrend(F);
    
    
    [N,X] = hist(F,100);
    [~, idx] = max(N);
    F=F-repmat(X(idx)',ms.numFrames,1);
    ms.trace = F;
    

end

