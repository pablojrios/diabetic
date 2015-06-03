%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Este script copia COPY_COUNT archivos de imagenes de IMAGE_FOLDER al
% subfolder SUBSET_FOLDER de IMAGE_FOLDER. Este subfolder es creado por el
% script.
%
IMAGE_FOLDER = 'C:\Users\Pablo\Downloads\Kaggle\ts-imbalanced-5000\class-0';
% El dataset de 5720 imágenes con la distribución del train set de Kaggle
% es: {4:115, 3:142, 2:862, 1:398, 0:4203}
COPY_COUNT = 4203;
SUBFOLDER = 'selected';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isdir(IMAGE_FOLDER)
%   uiwait(warndlg(errorMessage));
%   return;
  error('Error: The following folder does not exist:%s\n', IMAGE_FOLDER);
end

% crear subfolder en donde se copiaran las imágenes seleccionadas
destinationFolder = fullfile(IMAGE_FOLDER, SUBFOLDER);
status = mkdir(destinationFolder);
if status == 0
    error('Error: Can''t create subfolder %s in folder %s.\n', IMAGE_FOLDER);
end
    
allJpegFiles = dir(fullfile(IMAGE_FOLDER, '*.jpeg'));
% randperm(n,k) returns a row vector containing k unique integers selected
% randomly from 1 to n inclusive.
perm = randperm(length(allJpegFiles), min(length(allJpegFiles), COPY_COUNT));
selectedJpegFiles = allJpegFiles(perm);

copied = 0;
% jpegFiles is an struct array
for i = 1:length(selectedJpegFiles)
    fullFilename = fullfile(IMAGE_FOLDER, selectedJpegFiles(i).name);
    [status, message, messageid] = copyfile(fullFilename, destinationFolder);
    if status == 1 && isempty(messageid)
        copied = copied + 1;
        fprintf('[%d] Image %s copied to folder %s...\n', copied, fullFilename, destinationFolder);
    else
        warning('Image %s couldn''t be copied to folder %s...\n', copied, fullFilename, destinationFolder);
    end
end

% assert all image files were copied to SUBFOLDER
filesToCopy = length(selectedJpegFiles);
assert(filesToCopy == copied, 'Error: Couldn''t copy all image files to folder %s, copied %d of %d\n', ...
    destinationFolder, copied, filesToCopy);
fprintf('>>> All image files (%d) were copied to folder %s.\n', copied, destinationFolder);

