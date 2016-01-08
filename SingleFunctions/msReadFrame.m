function frame = msReadFrame(ms,frameNum,columnCorrect, align, dFF)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    vidNum = ms.vidNum(frameNum);
    vidFrameNum = ms.frameNum(frameNum);    
    frame = double(ms.vidObj{vidNum}.read(vidFrameNum));

    if (columnCorrect)
        frame = frame - ms.columnCorrection + ms.columnCorrectionOffset;
    end
    if (align)
        frame = frame(((max(ms.hShift(:,ms.selectedAlignment))+1):(end+min(ms.hShift(:,ms.selectedAlignment))-1))-ms.hShift(frameNum,ms.selectedAlignment), ...
                      ((max(ms.wShift(:,ms.selectedAlignment))+1):(end+min(ms.wShift(:,ms.selectedAlignment))-1))-ms.wShift(frameNum,ms.selectedAlignment));
    end
    if (dFF)
        frame = frame./ms.meanFrame{ms.selectedAlignment}-1;
    end
    
end

