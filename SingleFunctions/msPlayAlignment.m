function msPlayAlignment(vidObj, downSamp)
%MSPLAYALIGNMENT Summary of this function goes here
%   Detailed explanation goes here
% count = 0;
 cc = {'b' 'g' 'm' 'y'};
%  h = vidObj.alignedHeight(1)/2;
%  w=vidObj.alignedWidth(1)/2;
 f = figure(1);
 frame = msReadFrame(vidObj,1,true,false,false);
 imshow(uint8(frame));
 [w, h] = ginput(1);
for i=1:downSamp:vidObj.numFrames
    frame = msReadFrame(vidObj,i,true,false,false);
%     frame = uint8((filter2(hSmall,frame) - filter2(hLarge, frame))*10+127);
    imshow(uint8(frame));
    hold on
    for j=1:size(vidObj.hShift,2)
        plot(w-vidObj.wShift(i,j),h-vidObj.hShift(i,j),'.','markersize',30,'color',cc{j});
    end
    plot(w,h,'+r','markersize',20);
    
    hold off
    drawnow
%     count = count+1;
%                 filename = ['video/frame' num2str(count) '.jpg'];
%                 saveas(f,filename);
end

end

