function vidObjMoving = msAlignBetweenSessions(vidObjFixed, vidObjMoving)
%MSALIGNBETWEENSESSIONS Summary of this function goes here
%   Detailed explanation goes here

    hLarge = fspecial('average', 80);
    hSmall = fspecial('average', 5);
    
    refFrame = vidObjFixed.meanFrame{vidObjFixed.selectedAlignment};
    refFrame1 = refFrame;
    frame = vidObjMoving.meanFrame{vidObjMoving.selectedAlignment}; %ms2
    frame1 = frame;
    figure(103)
    clf
    subplot(2,3,1)
    pcolor(refFrame)
    shading flat
    daspect([1 1 1])
    colormap gray
    title('Reference Frame')
    
    subplot(2,3,4)
    pcolor(frame)
    shading flat
    daspect([1 1 1])
    colormap gray
    title('Frame')
    
    %----------------
    subplot(2,3,[2 3 5 6])
    pcolor(refFrame)
    shading flat
    daspect([1 1 1])
    colormap gray
    title('Select landmark')
    [curserW(1), curserH(1), curserB] = ginput(1);
    pcolor(frame)
    shading flat
    daspect([1 1 1])
    colormap gray
    title('Select landmark')
    [curserW(2), curserH(2), curserB] = ginput(1);
    dw = curserW(2) - curserW(1);
    dh = curserH(2) - curserH(1);
    title('Select ROI')
    rect = getrect(); 
    ROI = uint16([rect(1) rect(1)+rect(3) rect(2) rect(2)+rect(4)]);
    
%     clf
    refRect = rect - [dw dh 0 0];
    refROI = uint16([refRect(1) refRect(1)+refRect(3) refRect(2) refRect(2)+refRect(4)]);
    
    refFrame = (filter2(hSmall,refFrame) - filter2(hLarge, refFrame));
    
    
    refFrame = refFrame(refROI(3):refROI(4),refROI(1):refROI(2));
    refFrame = (refFrame-min(min(refFrame)))/max(max(refFrame-min(min(refFrame))));
    
    frame = (filter2(hSmall,frame) - filter2(hLarge, frame));
    frame = frame(ROI(3):ROI(4),ROI(1):ROI(2));
    frame = (frame-min(min(frame)))/max(max(frame-min(min(frame))));
    
    
    [optimizer,metric] = imregconfig('multimodal');
    vidObjMoving.tform = imregtform(frame,refFrame,'translation',optimizer,metric); %rigid, similarity
    movingRegistered = imwarp(frame,vidObjMoving.tform,'OutputView',imref2d(size(refFrame)));
    vidObjMoving.tform.T = vidObjMoving.tform.T - [0,0,0;0,0,0;dw,dh,0];
    
    
    
    subplot(2,3,1)
    imshow(refFrame);
    subplot(2,3,4)
    imshow(movingRegistered);
    subplot(2,3,2)
    imshow(uint8(refFrame1));
    hold on
    plot(curserW(1),curserH(1),'+r','markersize',40);
    hold off
    subplot(2,3,5)
    imshow(uint8(frame1));
    hold on
    plot(curserW(1)-vidObjMoving.tform.T(3,1),curserH(1)-vidObjMoving.tform.T(3,2),'+r','markersize',40);
    hold off
%     subplot_tight(2,1,2,[0 0])
%     imshow(uint8(vidObjFixed.meanFrame));
%     subplot_tight(2,2,3,[0 0])
%     imshow(frame);

%     subplot(1,2,2)
%     imshowpair(movingRegistered,vidObjFixed.segementOutline);
%     seg = imwarp(flipud(vidObjMoving.segementOutline'),vidObjMoving.tform,'OutputView',imref2d(size(vidObjFixed.meanFrame)));
    seg = imwarp(vidObjMoving.segementOutline,vidObjMoving.tform,'OutputView',imref2d(size(vidObjFixed.meanFrame{vidObjFixed.selectedAlignment})));

    subplot(2,3,[ 3  6])
    imshowpair(seg,vidObjFixed.segementOutline)
    title(['wShift: ' num2str(vidObjMoving.tform.T(3,1)) ' | hShift: ' num2str(vidObjMoving.tform.T(3,2))]);
    if isfield(vidObjFixed,'dateNum')
        vidObjMoving.alignedDateNum = vidObjFixed.dateNum;
    end

end

