function ms = msFluorFrameProps(ms)
%MSFLOURFRAME Summary of this function goes here
%   Detailed explanation goes here
    ms.minFluorescence = nan(1,ms.numFrames);
    ms.meanFluorescence = nan(1,ms.numFrames);
    ms.maxFluorescence = nan(1,ms.numFrames);
    for frameNum=1:ms.numFrames
        frame = msReadFrame(ms,frameNum,true,false,false);
        ms.minFluorescence(frameNum) = min(frame(:));
        ms.maxFluorescence(frameNum) = max(frame(:));
%         ms.quant10Fluorescence(frameNum) = quantile(frame(:),.1);
%         ms.quant90Fluorescence(frameNum) = quantile(frame(:),.9);
        ms.meanFluorescence(frameNum) = mean(frame(:));
        
        if (mod(frameNum,1+1000)==0)
            display(sprintf('Calculating fluorescence properties: %2.0f%% done.', frameNum/ms.numFrames*100));      
        end
    end
%     ms.minF = min(ms.minFluorescence);
%     ms.maxF = max(ms.maxFluorescence);

    
end

