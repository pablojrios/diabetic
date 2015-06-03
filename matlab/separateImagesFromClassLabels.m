%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
CLASS_LABELS_FILE = 'trainLabels'; % without file extension, assumes .csv
IMAGE_FOLDER = 'C:\Users\Pablo\Downloads\Kaggle\ts-imbalanced-5000';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isdir(IMAGE_FOLDER)
%   uiwait(warndlg(errorMessage));
%   return;
  error('Error: The following folder does not exist:%s\n', IMAGE_FOLDER);
end

allJpegFiles = dir(fullfile(IMAGE_FOLDER, '*.jpeg'));
% como excluir archivos
% y = dir; 
% y = y(find(~cellfun(@isempty,{y(:).date})));

labelsFile = fullfile(IMAGE_FOLDER, strcat(CLASS_LABELS_FILE, '.csv'));
[~, ~, rawImages]=xlsread(labelsFile); % raw is a cell array, ej.: raw{730,1}

imgClasses = rawImages(1:end,2);
imgNames = rawImages(1:end,1);
totalMoved = 0;
for c = 4:-1:0
    classFolder = sprintf('%s\\class-%d', IMAGE_FOLDER, c);
    status = mkdir(classFolder);
    if status == 0
        error('Error: Can''t create subfolder %s in folder %s.\n', IMAGE_FOLDER);
    end

    imgIndices = find([imgClasses{:}] == c); % obtengo los indices del array de clases donde la clase es 'c'
    if c == 0
        % como las ultimas imagenes que muevo son las de clase 0 entonces
        % no las muevo 1 a 1 sino todas juntas.
        [status, message, messageid] = movefile(fullfile(IMAGE_FOLDER, '*.jpeg'), classFolder, 'f');
        if status == 0 && strcmp(messageid, 'MATLAB:MOVEFILE:FileDoesNotExist') == 0
            errorMsg = sprintf('Error: Couldn''t move all image files of class %d to subfolder %s.\n', c, classFolder);
            error(errorMsg);
        end       
        
    else
        % muevo 1 a 1
        n = 1;
        for f = imgIndices
            baseFilename = strcat(imgNames{f}, '.jpeg');
            fullFilename = fullfile(IMAGE_FOLDER, baseFilename);
            [status, message, messageid] = movefile(fullFilename, classFolder, 'f');
            if status == 1 && isempty(messageid)
                fprintf('[%d] Image %s of class %d moved to subfolder %s...\n', n, baseFilename, imgClasses{f}, classFolder);
            elseif status == 0 && strcmp(messageid, 'MATLAB:MOVEFILE:FileDoesNotExist') == 1
                fprintf('[%d] Image %s of class %d already moved to subfolder %s...\n', n, baseFilename, imgClasses{f}, classFolder);
            elseif status == 0
                errorMsg = sprintf('Error: Can''t move image file %s to subfolder %s.\n', fullFilename, classFolder);
                error(errorMsg);
            end        
            n = n + 1;
        end
        
    end
    
    % assert all image files of class were moved
    classJpegFiles = dir(fullfile(classFolder, '*.jpeg'));
    classMoved = length(classJpegFiles);
    assert(classMoved == length(imgIndices), 'Error: Couldn''t move all image files for class %d, moved %d of %d, \n', ...
        c, classMoved, length(imgIndices));
    totalMoved = totalMoved + classMoved;
    fprintf('>>> All images of class %d (%d) were moved to subfolder %s\n', c, classMoved, classFolder);
end

% assert all image files of all classes were moved
errorMsg = sprintf('Error: Couldn''t move all image files in folder %s, moved %d of %d\n', ...
    IMAGE_FOLDER, totalMoved, length(imgClasses));
assert(length(imgClasses) == totalMoved, errorMsg);
fprintf('>>> All images in %s (%d) were moved to their class folders\n', IMAGE_FOLDER, totalMoved);
