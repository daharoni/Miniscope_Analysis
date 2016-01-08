function msBatchMatchSegmentsBetweenSessions(dirName, distThresh)
%MSBATCHMATCHSEGMENTSBETWEENSESSIONS Summary of this function goes here
%   Detailed explanation goes here
    dataFolders = msBatchFindDataFolders(dirName,[]);
    for folderNum1 = 1:length(dataFolders)
        currentFolder1 = dataFolders{folderNum1};
        temp = load([currentFolder1 '\ms.mat']);
        ms1 = temp.ms;
        display(['Working on ' currentFolder1])
        ms1.matchedSegments = zeros(ms1.numSegments, length(dataFolders));
        segCent1 = transformPointsForward(ms1.tform,ms1.segCentroid);
        for folderNum2 = 1:length(dataFolders)
            currentFolder2 = dataFolders{folderNum2};
            temp = load([currentFolder2 '\ms.mat']);
            ms2 = temp.ms;
            if(isfield(ms2,'tform'))
                segCent2 = transformPointsForward(ms2.tform,ms2.segCentroid);
                for i=1:ms1.numSegments
                    for j=1:ms2.numSegments  
                        dist = sqrt((segCent1(i,1)-segCent2(j,1)).^2+(segCent1(i,2)-segCent2(j,2)).^2);
                        if dist <= distThresh
                            ms1.matchedSegments(i,folderNum2) = j;
                        end
                    end
                end                
                
            else
                display([currentFolder ' is missing tform.']);
            end
        end
        ms = ms1;
        save([currentFolder1 '\ms.mat'],'ms','-v7.3');
    end
end

