function ms = msMeanFrame(ms, downsample)
%MSMEANFRAME Summary of this function goes here
%   Detailed explanation goes here

    
    meanFrame = cell(size(ms.alignmentROI,2),1);
    for ROINum=1:size(ms.alignmentROI,2)
        meanFrame{ROINum} = zeros(ms.alignedHeight(ROINum),ms.alignedWidth(ROINum));
    end
    count = 0;
    for frameNum=1:downsample:ms.numFrames
%         if (ms.goodFrames(frameNum)==1)
            count = count + 1;
            frame = msReadFrame(ms,frameNum,true,false,false);
            for ROINum=1:size(ms.alignmentROI,2)
                frameTemp = frame(((max(ms.hShift(:,ROINum))+1):(end+min(ms.hShift(:,ROINum))-1))-ms.hShift(frameNum,ROINum), ...
                  ((max(ms.wShift(:,ROINum))+1):(end+min(ms.wShift(:,ROINum))-1))-ms.wShift(frameNum,ROINum));
                meanFrame{ROINum} = meanFrame{ROINum} + frameTemp;              
            end
%         end
        if (mod(frameNum,1+1000*downsample)==0)
            sprintf('Calculating mean frame. %2.0f%% done.', frameNum/ms.numFrames*100)
        end
    end

    for ROINum=1:size(ms.alignmentROI,2)
        ms.meanFrame{ROINum} = meanFrame{ROINum}/count;
    end
end

