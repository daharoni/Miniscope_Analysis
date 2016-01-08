function msBatchAlignBetweenSessions(dirName)
%MSBATCHALIGNBETWEENSESSIONS Summary of this function goes here
%   Detailed explanation goes here

    dataFolders = msBatchFindDataFolders(dirName,[]);
    
    refFolderNum = ceil(length(dataFolders)/2);
    currentFolder = dataFolders{refFolderNum};
    temp = load([currentFolder '\ms.mat']);
    msRef = temp.ms;
    display(['Reference session: ' num2str(refFolderNum)]);
    for folderNum = 1:length(dataFolders)
        userInput = 'N';
        currentFolder = dataFolders{folderNum};
        temp = load([currentFolder '\ms.mat']);
        ms = temp.ms;
        if(isfield(ms,'meanFrame'))
            while (strcmp(userInput,'N'))
                display(['Aligning session ' currentFolder])
                ms = msAlignBetweenSessions(msRef,ms);
                userInput = upper(input('Keep alignment? (Y/N)','s'));
            end
            save([currentFolder '\ms.mat'],'ms','-v7.3');
        else
            display([currentFolder 'is missing segment relations']);
        end
    end
end

