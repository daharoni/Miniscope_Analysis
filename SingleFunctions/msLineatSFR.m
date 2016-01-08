function ms = msLineatSFR(ms, behav, speedThresh, binSize)
%MSLINEATSFR Summary of this function goes here
%   Detailed explanation goes here
    
    %% Break position into trials

    pos = behav.position(:,1);
    ms.pos = interp1(behav.time, pos, ms.time);
    
    minP = min(ms.pos);
    maxP = max(ms.pos);
    
    edge1 = behav.trackLength/20;
    edge2 = behav.trackLength - behav.trackLength/20;
    
    tempPos = ms.pos;
    tempPos(isnan(tempPos))=-100;
    [t1,p1,idx1] = polyxpoly(ms.time,tempPos,[1 ms.time(end)],edge1*[1 1]);
    idx1 = idx1(:,1);
    [t2,p2,idx2] = polyxpoly(ms.time,tempPos,[1 ms.time(end)],edge2*[1 1]);
    idx2 = idx2(:,1);

    edgeCrossings = [];
    edgeCrossings(:,1) = [ones(1,length(idx1)) 2*ones(1,length(idx2))];
    edgeCrossings(:,2) = [idx1' idx2'];
    edgeCrossings = sortrows(edgeCrossings,2);
    diffEC = [diff(edgeCrossings(:,1)); 0];

    idx1 = find(diffEC==1);
    idx2 = find(diffEC==-1);
    temp = [];
    temp(:,1) = edgeCrossings(sort([idx1' idx2']),2);
    temp(:,2) = edgeCrossings(sort([idx1' idx2'])+1,2);
    ms.trialNum = zeros(ms.numFrames,1);
    for i=1:length(temp)
        ms.trialNum(temp(i,1):temp(i,2)) = i;
    end
    %%
    
    tempSpeed = interp1(behav.time, behav.speed,ms.time);
    idxSpeed = (tempSpeed>=speedThresh)';
    
    idx1 = mod(ms.trialNum,2)==1;
    
    idx2 = mod(ms.trialNum+1,2)==1 & ms.trialNum~=0;
    idx1 = idx1';
    idx2 = idx2';
    
    subs = 1+floor(ms.pos/binSize);
    occ1 = zeros(ceil(behav.trackLength/binSize),1);
    occ2 = zeros(ceil(behav.trackLength/binSize),1);
%     size(idx2)
%     size(idxSpeed)
    temp = accumarray(subs(idx1&idxSpeed),1);
    occ1(1:length(temp)) = temp;
    temp = accumarray(subs(idx2&idxSpeed),1);
    occ2(1:length(temp)) = temp;
    
    ms.FR = nan(length(occ1),ms.numSegments,2);
    for segNum=1:ms.numSegments
        temp = zeros(ceil(behav.trackLength/binSize),1);
        temp2 = accumarray(subs(idx1&idxSpeed),ms.firing(idx1&idxSpeed,segNum));
        temp(1:length(temp2)) = temp2;
        ms.FR(:,segNum,1) = temp./occ1;

        temp = zeros(ceil(behav.trackLength/binSize),1);
        temp2 = accumarray(subs(idx2&idxSpeed),ms.firing(idx2&idxSpeed,segNum));
        temp(1:length(temp2)) = temp2;
        ms.FR(:,segNum,2) = temp./occ2;
    end
end

