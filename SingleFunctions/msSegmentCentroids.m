function ms = msSegmentCentroids(ms)
%MSSEGMENTCENTROIDS Summary of this function goes here
%   Detailed explanation goes here

    ms.segCentroid = [];
    for segNum=1:ms.numSegments
        bwProps = regionprops(ms.segments(:,:,segNum),'Centroid');
        ms.segCentroid(segNum,:) = bwProps.Centroid;   
    end
end

