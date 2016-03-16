function msBatchAlignmentFFT(dirName,plotting)
%MSBATCHALIGNMENT Summary of this function goes here
%   Detailed explanation goes here

    %--------- Alignment parameters ----

    
    dataFolders = msBatchFindDataFolders(dirName,[]);
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        dirData = dir(currentFolder);
        dirIndex = [dirData.isdir];
        fileList = {dirData(~dirIndex).name};       
        if (sum(ismember(fileList,'ms.mat')) == 1)
            temp = load([currentFolder '\ms.mat']);
            ms = temp.ms;
%             if (~isfield(ms,'hShift')) %does not have alignment already done
                display(['Working on alginment of ' currentFolder]);
                ms = msAlignmentFFT(ms,plotting);  
%                 ms = msAlignment(ms);
                save([currentFolder '\ms.mat'],'ms','-v7.3');
%             else
                display([currentFolder ' already has alignment data.']);
%             end
        else
            display([currentFolder ' is missing ms.mat.']);
        end
    end
end

