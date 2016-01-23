function vidObj = msCalcSegmentRelations(vidObj,calcCorr, calcDist, calcOverlap)
%MSCALCSEGMENTRELATIONS Summary of this function goes here
%   Detailed explanation goes here
    if calcCorr
        segCorr = zeros(vidObj.numSegments,vidObj.numSegments);
    end
    if calcDist
        segDist = zeros(vidObj.numSegments,vidObj.numSegments);
    end
    if calcOverlap
        segOverlap = zeros(vidObj.numSegments,vidObj.numSegments);
    end
    segArea = squeeze(sum(sum(vidObj.segments,2),1));
    for segNum =1:vidObj.numSegments
        props = regionprops(vidObj.segments(:,:,segNum),'Centroid');
        centroid(:,segNum) = props.Centroid;
    end
    for segNum =1:vidObj.numSegments
%         segNum
        if mod(segNum,25) == 0
            display(sprintf('%2.0f%% done.', segNum/vidObj.numSegments*100));
        end
        if calcCorr
        segCorr(segNum:vidObj.numSegments,segNum) = ...
            corr(vidObj.trace(:,segNum:vidObj.numSegments)-repmat(vidObj.dFFBaseline,1,length(segNum:vidObj.numSegments)),vidObj.trace(:,segNum)-vidObj.dFFBaseline);
%			corr(vidObj.trace(:,segNum:vidObj.numSegments),vidObj.trace(:,segNum));
        end
        if calcDist
        segDist(segNum:vidObj.numSegments,segNum) = ...
            sqrt((centroid(1,segNum:vidObj.numSegments)-centroid(1,segNum)).^2 ...
            +(centroid(2,segNum:vidObj.numSegments)-centroid(2,segNum)).^2);
        end
        if calcOverlap
            temp = vidObj.segments(:,:,segNum:vidObj.numSegments);
            temp = temp & repmat(vidObj.segments(:,:,segNum),1,1,length(segNum:vidObj.numSegments));
            temp2 = min([segArea(segNum:vidObj.numSegments) repmat(segArea(segNum),1,length(segNum:vidObj.numSegments))'],[],2);
            segOverlap(segNum:vidObj.numSegments,segNum) = squeeze(sum(sum(temp,2),1))./temp2;
        end
    end
    if calcCorr
        vidObj.segCorr = segCorr + segCorr';  
        vidObj.segCorr(vidObj.segCorr==0)=nan;
    end
    if calcDist
        vidObj.segDist = segDist + segDist';
        vidObj.segDist(vidObj.segDist == 0) = nan;
    end
    if calcOverlap
        vidObj.segOverlap = segOverlap + segOverlap';
        vidObj.segOverlap(eye(size(segOverlap))==1) = nan;
    end
%     segMatch = segCorr>corrThresh & segDist<distThresh;

end

