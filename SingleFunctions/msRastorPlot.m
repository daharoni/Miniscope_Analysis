function msRastorPlot(vidObj,segmentRange,offset,showFiring, color)
%MSRASTORPLOT Summary of this function goes here 
%   Detailed explanation goes here


    if (isempty(color))
        index = [1 4 7 10 3 6 9 2 5 8]; 
        cmap = colormap(jet(256));
        
        numColors = 10;
        colors = 0.8*cmap(ceil(255/numColors*index),:);
%         color = 'k'
    end
    
    if (isempty(segmentRange))
        segmentRange = [1 vidObj.numSegments];
    end
    if isempty(offset)
        offset = 0.1;
    end
    
%     if (showFiring)
%        pcolor((vidObj.time)/1000,0:offset:(offset*(diff(segmentRange))), vidObj.firing(:,segmentRange(1):segmentRange(2))');
%        shading flat
%        caxis([0 .3])
% hold on
%     end
    
    for segNum=segmentRange(1):segmentRange(2)
        if (isempty(color))
            color1 = colors(1+mod(segNum,numColors),:);
        end
            plot(vidObj.time/1000,vidObj.trace(:,segNum)+offset*(segNum-1),'color',color1,'linewidth',2);

        hold on
        if (showFiring)
            
%             temp = vidObj.firing(:,segNum);
%             temp(temp<0.001) = nan;
%             idx = ~isnan(temp);
            plot(vidObj.time/1000,vidObj.firing(:,segNum)+offset*(segNum-1),'r')
%             plot(vidObj.time/1000,vidObj.peakTraceCleaned(:,segNum)+offset*(segNum-1),'k','linewidth',2)
        end
    end
    
    xlim([0 vidObj.time(end)/1000])
    hold off
end

