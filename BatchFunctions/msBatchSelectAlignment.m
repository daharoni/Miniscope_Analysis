function msBatchSelectAlignment(dirName)
%MSBATCHSELECTALIGNMENT Summary of this function goes here
%   Detailed explanation goes here
       
    dataFolders = msBatchFindDataFolders(dirName,[]);
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        dirData = dir(currentFolder);
        dirIndex = [dirData.isdir];
        fileList = {dirData(~dirIndex).name};       
        if (sum(ismember(fileList,'ms.mat')) == 1)
            temp = load([currentFolder '\ms.mat']);
            ms = temp.ms;
        
            if (isfield(ms,'hShift'))
                display(['Displaying alignment(s) for ' currentFolder]);
                figure(101)
                clf
                ms = msSelectAlignment(ms);
                save([currentFolder '\ms.mat'],'ms','-v7.3');
            else
                display([currentFolder ' is missing alignment.']);
            end
        else
             display([currentFolder ' is missing ms.mat.']);
        end
    end
end

