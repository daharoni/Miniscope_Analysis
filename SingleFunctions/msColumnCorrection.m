function vidObj = msColumnCorrection(vidObj,downSamp)
%MSREMOVECOLUMNVARIATION Generates the vector used to correct for ADC noise
%   downSamp will cut down on the number of frames used in the calculation

    meanFrame = zeros(vidObj.height,vidObj.width); %allocate memory
    count = 0;
    for frameNum=1:downSamp:vidObj.numFrames
        count = count + 1;
        meanFrame = meanFrame + double(msReadFrame(vidObj,frameNum,false,false,false));
        if (mod(frameNum,1+100*downSamp)==0)
            display(['Calculating column correction. ' num2str(frameNum/vidObj.numFrames*100) '% done'])
        end
    end
    
    % creates correction frame used to remove ADC noise
    vidObj.columnCorrection = round(repmat(mean(meanFrame/count,1),vidObj.height,1));
    vidObj.columnCorrectionOffset = mean(vidObj.columnCorrection(:));
end
