function vidObj = msExtractdFFTraces(vidObj)
%MSEXTRACTDFF Summary of this function goes here
%   Detailed explanation goes here
    segmentMask = nan(vidObj.cellAreaLimits(2)*2,vidObj.numSegments);
    for segNum=1:vidObj.numSegments
        index = find(vidObj.segments(:,:,segNum)==1);
        segmentMask(1:length(index),segNum) = index;
%         pcolor(segmentMask)
%         shading flat
%         drawnow
    end
%     nanmin(segmentMask)
    vidObj.trace = zeros(vidObj.numFrames,size(vidObj.segments,3));
    tempHolder = nan(size(segmentMask));
    for frameNum=1:vidObj.numFrames
         if (mod(frameNum,200)==0)
                display(['Extracting dF/F traces: ' num2str(frameNum/vidObj.numFrames*100)]);
         end
%         frame = msReadFrame(vidObj,frameNum,true,true,true);
        frame = msReadFrame(vidObj,frameNum,true,true,false);
        tempHolder(~isnan(segmentMask)) = frame(segmentMask(~isnan(segmentMask)));
        vidObj.trace(frameNum,:) = nanmean(tempHolder,1);

    end
    %---------- added to correctly calculate the F or dF/F
%     traceMode = mode(vidObj.trace(vidObj.goodFrames,:));
    traceMode = mode(vidObj.trace);
    vidObj.trace = vidObj.trace./repmat(traceMode,vidObj.numFrames,1)-1;
    %------------------------------------------------------
    vidObj.dFFBaseline = mean(vidObj.trace,2);
end

