function ms = msSelectAlignment(ms)
%MSSELECTALIGNMENT Summary of this function goes here
%   Detailed explanation goes here
    bins = -20:20;
    for ROINum=1:size(ms.alignmentROI,2)
        subplot(2,size(ms.alignmentROI,2),ROINum)               
        alignH2 = hist2(ms.hShift(:,ROINum) ,ms.wShift(:,ROINum),bins,bins);
        pcolorCentered(bins,bins,log10(alignH2));
        daspect([1 1 1]);
        h = colorbar;
        ylabel(h,'Log Counts')
        title(['Histogram for alignment #' num2str(ROINum)]);

        subplot(2,size(ms.alignmentROI,2),ROINum+size(ms.alignmentROI,2))
        imshow(uint8(ms.meanFrame{ROINum}));
        title(['Mean frame for alignment #' num2str(ROINum)]);
    end    
    userInput = input(['Select best alignment (Enter number):']);
    ms.selectedAlignment = userInput;
end

