function vidObj = msGoodFrames(vidObj, fluorescenceFrameThresh)
%MSGOODFRAMES Summary of this function goes here
%   Detailed explanation goes here
    vidObj.fluorescenceFrameThresh = fluorescenceFrameThresh;
    vidObj.frameFluorescence = nan(1,vidObj.numFrames);
    for frameNum=1:vidObj.numFrames
        if mod(frameNum,300) == 0
            display(['Reading in Frames: ' num2str(frameNum/vidObj.numFrames*100) '% done'])
        end
        frame = msReadFrame(vidObj,frameNum,false,false,false);
        vidObj.frameFluorescence(frameNum) = mean(frame(:));
    end
    vidObj.goodFrames =  vidObj.frameFluorescence>=fluorescenceFrameThresh;
%     figure
    plot(vidObj.frameFluorescence);
    hold on
    plot([1 vidObj.numFrames],fluorescenceFrameThresh*[1 1],'--r');
    xlabel('Frames');
    ylabel('Average Pixel Value');
    hold off
end

