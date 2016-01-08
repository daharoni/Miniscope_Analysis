function msPlayVidObj(vidObj,downSamp,columnCorrect, align, dFF, overlay)
%MSPLAYVIDOBJ Summary of this function goes here
%   Detailed explanation goes here
 hSmall = fspecial('average', 2);
    for frameNum=500:downSamp:vidObj.numFrames
            frame = msReadFrame(vidObj,frameNum,columnCorrect,align,dFF);
            frame = filter2(hSmall,frame);
            pcolor(frame);
            shading flat
            if dFF
                caxis([0 0.3])
            else
                caxis([60 120])
            end
            colormap gray
            
        if overlay
            green = cat(3, ones(vidObj.alignedHeight,vidObj.alignedWidth), ...
                zeros(vidObj.alignedHeight,vidObj.alignedWidth), ...
                zeros(vidObj.alignedHeight,vidObj.alignedWidth));
            hold on
            h = imshow(green);
            set(h, 'AlphaData', vidObj.segementOutline)
            
            hold off
        end
        daspect([1 1 1])
    drawnow    
    end
end

