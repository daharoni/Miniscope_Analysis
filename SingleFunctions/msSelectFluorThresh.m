function ms = msSelectFluorThresh(ms)
%MSSELECTFLUORTHRESH Summary of this function goes here
%   Detailed explanation goes here
    userInput = 'N';
    while(strcmp(userInput,'N'))
        figure(102)
        clf
        plot(ms.minFluorescence,'y');
        hold on
%         plot(ms.quant10Fluorescence,'m');
        plot(ms.meanFluorescence,'b');
%         plot(ms.quant90Fluorescence,'g');
        plot(ms.maxFluorescence,'k');        
        legend('min','mean','max');
        xlabel('Frame');
        ylabel('Fluorescence Value');  
        display('Use mouse to select threshold for mean good fluorescence value');
        [~,fluorThresh] = ginput(1);
        plot([1 ms.numFrames],[1 1]*fluorThresh,'--r','linewidth',2);
        hold off
        userInput = upper(input('Keep selection? (Y/N)','s'));
    end
    ms.goodFrame = ms.meanFluorescence>=fluorThresh;
    ms.fluorThresh = fluorThresh;

end

