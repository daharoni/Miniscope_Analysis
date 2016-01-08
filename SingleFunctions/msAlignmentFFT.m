function ms = msAlignmentFFT(ms)
%MSALIGNMENTFFT Summary of this function goes here
%   Detailed explanation goes here
    
    for ROINum = 1:size(ms.alignmentROI,2)
        display(['Alignment ' num2str(ROINum) '/' num2str(size(ms.alignmentROI,2))]);
        rect = ms.alignmentROI(:,ROINum);
        if(mod(round(min(rect([3 4]))),2)==0)
            rect([3 4]) = rect([3 4]) -1;
        end
        ROI = uint16([rect(1) rect(1)+rect(3) rect(2) rect(2)+rect(4)]);
        r = sbxalign(ms,1:ms.numFrames,ROI);

        ms.hShift(:,ROINum) = r.T(:,1);
        ms.wShift(:,ROINum) = r.T(:,2);
        ms.alignedHeight(ROINum) = ms.height - (max(ms.hShift(:,ROINum))-min(ms.hShift(:,ROINum))+1);
        ms.alignedWidth(ROINum) = ms.width - (max(ms.wShift(:,ROINum))-min(ms.wShift(:,ROINum))+1);
    end
end

