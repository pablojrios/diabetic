% It is worthwhile to note that while
% A(2) = []
% works for a cell array,
% A(2) = [5 6 7]
% does not (it errors). This seems to be a source of confusion that I often see
% in those learning to work with MATLAB cell arrays. The correct syntax, of course, is
% A(2) = {[5 6 7]}
% or
% A{2} = [5 6 7]
function outImages = excludeImages(excludeImageFolders, rawImages)
    
    all = struct([]);
    for s=excludeImageFolders
        jpegFiles = dir(fullfile(s{1}, '*.jpeg'));
        if isempty(all)
            all = jpegFiles;
        else
            % concatenar struct arrays
            all = cell2struct( ...
                cat(2, struct2cell(all),struct2cell(jpegFiles)), ...
                fieldnames(jpegFiles), ...
                1);
        end
    end
    
    % jpegFiles is an struct array
    for i = 1:length(all)
        name = strsplit(all(i).name,'.');
        pos = find(strcmp([rawImages(1:end,1)], name(1)));
        rawImages(pos, :) = []; % remove item from cell array
    end
    outImages = rawImages;
end