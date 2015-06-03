%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Este script genera 2 datasets balanceados, uno para training en el
% subfolder 'train' y otro para testing en el subfolder 'test', según las
% cantidades definidas en los parámetros 'countPerClassTrain' y
% 'countPerClassTest'.
% No es equivalente una corrida de este script con 2 corridas del script
% buildBalancedDataset, ya que las corridas en este último son independientes y dos
% corridas podrían tener imagenes en comun.
%
% excludeImageFolders = {'folder1','folder2'}
excludeImageFolders = {'C:\Users\Pablo\Downloads\Kaggle\ts-imbalanced-5000\class-0\selected'};
params = struct(...
    'classLabelsFile', 'trainLabels',... % nombre del archivo sin la extensión .csv
    'sourceImageFolder', 'C:\Users\Pablo\Downloads\Kaggle\train',...
    'countPerClassTrain', 4203-1720,...
    'countPerClassTest', 0);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isdir(params.sourceImageFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', params.sourceImageFolder);
%   uiwait(warndlg(errorMessage));
%   return;
  error(errorMessage);
end

labelsFullfilename = fullfile(params.sourceImageFolder, strcat(params.classLabelsFile, '.csv'));
[~, ~, rawImages] = xlsread(labelsFullfilename); % raw is a cell array, ej.: raw{730,1}
if strcmp(rawImages{1,1}, 'image') == 1
    rawImages = rawImages(2:end,:); % remuevo el header si es necesario
end

if ~isempty(excludeImageFolders)
    % params.countPerClassTrain = 0;
    % excluir de rawImages las imágenes que están en los folders excludeImageFolders
    rawImages = excludeImages(excludeImageFolders, rawImages);
end

c = clock;
runName = sprintf('%s_%d-%d-%d_%d-%d', getenv('username'), c(1), c(2), c(3), c(4), c(5));
mkdir(params.sourceImageFolder, runName);
mkdir(fullfile(params.sourceImageFolder, runName, 'train'));
mkdir(fullfile(params.sourceImageFolder, runName, 'test'));
[status,message,messageid] = copyfile(labelsFullfilename, sprintf('%s\\%s\\%s', params.sourceImageFolder, runName, strcat(params.classLabelsFile, '.csv')));

% copy images, ie.: build balanced dataset in new create folder
destFolder = sprintf('%s\\%s', params.sourceImageFolder, runName);
imgClasses = rawImages(1:end,2);
imgNames = rawImages(1:end,1);
classIndices = [];
totalPerClass = params.countPerClassTrain + params.countPerClassTest;
n_classes = 1;
for c = 0:0
    classes = find([imgClasses{:}] == c); % obtengo los indices del array de clases donde la clase es 'c'
    perm = randperm(length(classes), totalPerClass); % obtengo 'totalPerClass' valores random de 1 a la cantidad de imagenes por clase
    classIndices = classes(perm); % indices de las imágenes de la clase 'c'
    n = 1;
    for idx=classIndices
        filename = strcat(imgNames{idx}, '.jpeg');
        sourceFullfilename = sprintf('%s\\%s', params.sourceImageFolder, filename);
        if (n <= params.countPerClassTrain)
            subfolder = 'train';
        else subfolder = 'test';
        end
        destFullfilename = fullfile(destFolder, subfolder, filename);
        [status,message,messageid] = copyfile(sourceFullfilename, destFullfilename);
        fprintf('[%d] Image %s copied to folder %s...\n', n, sourceFullfilename, fullfile(destFolder, subfolder));
        n = n + 1;
    end
end

% assert all image files were copied to train
classJpegFiles = dir(fullfile(destFolder, 'train', '*.jpeg'));
copied = length(classJpegFiles);
assert(copied == n_classes*params.countPerClassTrain, 'Error: Couldn''t copy all image files to folder %s, copied %d of %d, \n', ...
    fullfile(destFolder, 'train'), copied, n_classes*params.countPerClassTrain);
fprintf('>>> All images (%d) were copied to folder %s\n', copied, fullfile(destFolder, 'train'));

% assert all image files were copied to test
classJpegFiles = dir(fullfile(destFolder, 'test', '*.jpeg'));
copied = length(classJpegFiles);
assert(copied == n_classes*params.countPerClassTest, 'Error: Couldn''t copy all image files to folder %s, copied %d of %d, \n', ...
    fullfile(destFolder, 'test'), copied, n_classes*params.countPerClassTest);
fprintf('>>> All images (%d) were copied to folder %s\n', copied, fullfile(destFolder, 'test'));
