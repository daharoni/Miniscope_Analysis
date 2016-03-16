function msPlayVidObj(vidObj,downSamp,columnCorrect, align, dFF, overlay)
%MSPLAYVIDOBJ Summary of this function goes here
%   Detailed explanation goes here
 hSmall = fspecial('average', 2);
    for frameNum=1:downSamp:vidObj.numFrames
            frame = msReadFrame(vidObj,frameNum,columnCorrect,align,dFF);
            frame = filter2(hSmall,frame);
            pcolor(frame);
            shading flat
            if dFF
                caxis([0 0.5])
            else
                caxis([0 255])
            end
            colormap gray
            
        if overlay
            green = cat(3, zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)), ...
    ones(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)), ...
    zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)));
            hold on
            h = imshow(green);
            set(h, 'AlphaData', vidObj.segementOutline)
            
            hold off
        end
        daspect([1 1 1])
    drawnow    
    end
end

