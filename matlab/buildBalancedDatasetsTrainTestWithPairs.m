%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Este script genera 2 datasets balanceados, uno para training en el
% subfolder 'train' y otro para testing en el subfolder 'test', según las
% cantidades definidas en los parámetros 'countPerClassTrain' y
% 'countPerClassTest'.
%
excludeImageFolders = {}; % excludeImageFolders = {'folder1','folder2'}
params = struct(...
    'classLabelsFile', 'trainLabels',... % nombre del archivo sin la extensión .csv
    'imageFolder', 'F:\kaggle\train\train',... % 'imageFolder', 'C:\Users\Pablo\Downloads\Kaggle\train',... ;
    'countPerClassTrain', 520,...
    'countPerClassTest', 120);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isdir(params.imageFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', params.imageFolder);
%   uiwait(warndlg(errorMessage));
%   return;
  error(errorMessage);
end

labelsFullfilename = fullfile(params.imageFolder, strcat(params.classLabelsFile, '.csv'));
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
mkdir(params.imageFolder, runName);
[status,message,messageid] = copyfile(labelsFullfilename, sprintf('%s\\%s\\%s', params.imageFolder, runName, strcat(params.classLabelsFile, '.csv')));

imgClasses = rawImages(1:end,2);
imgNames = rawImages(1:end,1);
trainIndices = [];
testIndices = [];
totalPerClass = params.countPerClassTrain + params.countPerClassTest;
rng('shuffle')
for c = 0:4
    classes = find([imgClasses{:}] == c); % obtengo los indices del array de clases donde la clase es 'c'
    perm = randperm(length(classes), params.countPerClassTest); % obtengo 'countPerClass' valores random de 1 a la cantidad de imagenes por clase
    % en classes(perm) tengo los indices de las imágenes de la clase 'c'
    % para cada imágen tengo que tener su imágen par
    classIndices = classes(perm);
    for f=classIndices
        testIndices = [testIndices f];
        np = strsplit(imgNames{f}, '_'); % los nombres de las imágens son de la forma 10_right
        if (strcmp(np(2), 'right') == 1)
            pair = sprintf('%s_left', np{1});
        else
            pair = sprintf('%s_right', np{1});
        end
        pair_index = find(strcmp(imgNames, pair));
        % me fijo si ya está en los índices de imágenes imgIndices
        % seleccionados hasta el momento; si está no hago nada, si no está
        % lo agrego
        if isempty(find(testIndices==pair_index, 1)) && isempty(find(trainIndices==pair_index, 1)) % no está
            testIndices = [testIndices pair_index];
        end
    end
    % agrego las imágenes de training
    remaining = setdiff(classes, union(testIndices, trainIndices));
    perm = randperm(length(remaining), min(length(remaining), params.countPerClassTrain));
    trainIndices = [trainIndices remaining(perm)];
end

destTestFolder = fullfile(params.imageFolder, runName, 'test');
mkdir(destTestFolder);
destTrainFolder = fullfile(params.imageFolder, runName, 'train');
mkdir(destTrainFolder);

testIndices = unique(testIndices);
buildDataset(params, testIndices, imgClasses, imgNames, destTestFolder);
trainIndices = unique(trainIndices);
buildDataset(params, trainIndices, imgClasses, imgNames, destTrainFolder);
