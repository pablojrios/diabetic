%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Este script recorre las imágenes en IMAGE_FOLDER y las mueve a distintos
% subfolder según la clase, que obtiene de trainLabels.csv. Estos
% subfolders se llaman 'class-<clase>' y son creados por el script en el
% folder IMAGE_FOLDER
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

% crear un folder para cada clase
for c = 4:-1:0
    classFolder = sprintf('%s\\class-%d', IMAGE_FOLDER, c);
    status = mkdir(classFolder);
    if status == 0
        error('Error: Can''t create subfolder %s in folder %s.\n', IMAGE_FOLDER);
    end
end

allJpegFiles = dir(fullfile(IMAGE_FOLDER, '*.jpeg'));

labelsFile = fullfile(IMAGE_FOLDER, strcat(CLASS_LABELS_FILE, '.csv'));
[~, ~, rawImages]=xlsread(labelsFile); % raw is a cell array, ej.: raw{730,1}
imgClasses = rawImages(2:end,2);
imgNames = rawImages(2:end,1);

totalMoved = 0;
% jpegFiles is an struct array
for i = 1:length(allJpegFiles)
    name = strsplit(allJpegFiles(i).name, '.');
    % en trainLabels.csv solo tengo los nombres de los archivos de imágenes
    % sn la extension
    index = find(strcmp(imgNames, name(1)));
    % obtengo la clase
    c = imgClasses{index};

    classFolder = sprintf('%s\\class-%d', IMAGE_FOLDER, c);
    fullFilename = fullfile(IMAGE_FOLDER, allJpegFiles(i).name);
    [status, message, messageid] = movefile(fullFilename, classFolder, 'f');
    if status == 1 && isempty(messageid)
        fprintf('[%d] Image %s of class %d moved to subfolder %s...\n', i, allJpegFiles(i).name, c, classFolder);
    elseif status == 0 && strcmp(messageid, 'MATLAB:MOVEFILE:FileDoesNotExist') == 1
        fprintf('[%d] Image %s of class %d already moved to subfolder %s...\n', i, allJpegFiles(i).name, c, classFolder);
    elseif status == 0
        errorMsg = sprintf('Error: Can''t move image file %s to subfolder %s.\n', fullFilename, classFolder);
        error(errorMsg);
    end        
    totalMoved = totalMoved + 1;
end

% assert all image files of class were moved
filesToMove = length(allJpegFiles);
assert(filesToMove == totalMoved, 'Error: Couldn''t move all image files to class subfolders, moved %d of %d\n', ...
    totalMoved, filesToMove);
fprintf('>>> All image files (%d) were moved to class subfolders.\n', totalMoved);

% contar las imágenes en los class subfolders
for c = 0:4
    classJpegFiles = dir(fullfile(IMAGE_FOLDER, sprintf('class-%d', c), '*.jpeg'));
    n = length(classJpegFiles);
    fprintf('%d(%0.1f%%) images of class %d\n', n, n/filesToMove*100, c);
end
