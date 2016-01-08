function vidObj = msCleanSegments(vidObj,corrThresh,distThresh,overlapThresh)
%MSCLEANSEGMENTS Summary of this function goes here
%   Detailed explanation goes here
%     vidObj.corrThresh = corrThresh;
    vidObj.distThresh = distThresh;
    vidObj.overlapThresh = overlapThresh;
    vidObj.originalSegments = vidObj.segments;
    removedSegments = zeros(vidObj.numSegments,1);
   
    %Distance
     for segNum=1:vidObj.numSegments
        index = vidObj.segDist(:,segNum)<=distThresh;
        index(segNum) = 1;
        if (removedSegments(segNum) == 0 && sum(index)>1)
            
%             size(index)
            temp = sum(vidObj.segments(:,:,index),3);
            
            vidObj.segments(:,:,segNum) = (temp == max(temp(:)));
            
%             subplot(2,1,1)
%             pcolor(temp)
%             shading flat
%             subplot(2,1,2)
%             pcolor(double(vidObj.segments(:,:,segNum)))
%             shading flat
%             waitforbuttonpress
            
            removedSegments = removedSegments | index;
            removedSegments(segNum) = 0;
            sum(~removedSegments);
        end
     end
    % Overlap 
    for segNum=1:vidObj.numSegments
        index = vidObj.segOverlap(:,segNum)>=overlapThresh;
        index(segNum) = 1;
%         [removedSegments(segNum) sum(index)]
        if (removedSegments(segNum) == 0 && sum(index)>=1)
           
            
            temp = sum(vidObj.segments(:,:,index),3);
            vidObj.segments(:,:,segNum) = (temp == max(temp(:)));
            removedSegments = removedSegments | index;
            removedSegments(segNum) = 0;
            sum(~removedSegments);
        end
    end
    vidObj.segments = vidObj.segments(:,:,~removedSegments);
    vidObj.numSegments = sum(~removedSegments);
    vidObj.segMat = sum(vidObj.segments,3);
    
    vidObj.segementOutline = zeros(size(vidObj.segMat));
    for segNum=1:vidObj.numSegments
        vidObj.segementOutline = vidObj.segementOutline | bwperim(vidObj.segments(:,:,segNum) > 0);
    end
    
    %%
    
%     for segNum=1:vidObj.numSegments
% %         temp = zeros(size(vidObj.segments,1),size(vidObj.segments,2));
%         if(sum(segMatch(:,segNum))>1)
%             temp = sum(vidObj.segments(:,:,segMatch(:,segNum)),3);
%             subplot_tight(3,1,[1 2],[1 1]*0.05)
%             pcolor(temp)
%             colormap gray
%             shading flat
%             subplot_tight(3,1,3,[1 1]*0.05)
%             plot(vidObj.time,vidObj.trace(:,segMatch(:,segNum))-repmat(vidObj.dFFBaseline,1,sum(segMatch(:,segNum))))
%         waitforbuttonpress
%         end
%     end
end

