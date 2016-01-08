function msAlignmentHistogram(ms,bins)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if (isempty(bins))
        bins = -20:20;
    end
    alignH2 = hist2(ms.hShift ,ms.wShift,bins,bins);
    pcolorCentered(bins,bins,log10(alignH2));
    colormap jet
%     colorbar
    xlabel('Horizontal Shift (px)')
    ylabel('Vertical Shift (px)');
    hcb=colorbar

    ylabel(hcb,'Log10(Number of Frames)')
    
end

