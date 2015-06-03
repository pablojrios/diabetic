%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 'classLabelsFile' es el nombre del archivo sin la extensión (se asume que es .csv),
% y tiene que estar en 'imageFolder'.
CONTRAST_ENHANCEMENT_TECHNIQUES = {'none', 'imadjust', 'histeq', 'adapthisteq'};
params = struct(...
    'runName', '',...
    'classLabelsFile', 'trainLabels',... % nombre del archivo sin la extensión .csv
    'imageFolder', 'C:\Users\dames\Documents\Kaggle\25-04-15\250 pablo\test a rotar',...
    'extractFeatures', false,...
    'radonTheta', 5,... % cada cuantos grados se toma una proyección de 0 a 180, excluyendo 180
    'invariantCount', 4,...
    'contrastEnhancement', CONTRAST_ENHANCEMENT_TECHNIQUES{1},... % 1: 'none'
    'saveImageAfterPreprocess', true,...
    'scale', 1,... % 0.5 tarda 290 segs, 0.75 tarda 400 segs, 1.0 tarda 1050 segs.
    'RGB2gray', false,... %
    'rotateInverted', true); % Inverted images are not flipped horizontally,
                               % you must rotate the image by 180 degrees to change from one orientation to the other.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isdir(params.imageFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', params.imageFolder);
%   uiwait(warndlg(errorMessage));
%   return;
  error(errorMessage);
end

[~, ~, rawImages]=xlsread(fullfile(params.imageFolder, strcat(params.classLabelsFile, '.csv'))); % raw is a cell array, ej.: raw{730,1}

c = clock;
runName = sprintf('%s_%d-%d-%d_%d-%d', getenv('username'), c(1), c(2), c(3), c(4), c(5));
mkdir(params.imageFolder, runName);
featFilename = sprintf('%s\\%s\\features_%s.csv', params.imageFolder, runName, runName);
% 'a+' Open or create new file for reading and writing. Append data to the end of the file.
featuresFileID = fopen(featFilename,'w');

radon_projections = 0:params.radonTheta:180;
if 180/params.radonTheta == 0
    radon_projections = radon_projections(1:end-1);
end
num_features = length(radon_projections) * params.invariantCount;

%% build and write header of .csv features file
k = cell(1, num_features);
for n=1:length(k)
    k{n} = strcat('F',num2str(n));
end
k = ['image_ID' 'class' k];
header = sprintf('%s,', k{1,:});
header = header(1:end-1); % remove ',' at the end
fprintf(featuresFileID, '%s\n', header);

params.runName = runName;
if (params.extractFeatures ~= 1)
    warning('>>> Features are not being extracted.');
end
tic;
doExtractFeatures(params, rawImages, featuresFileID);
toc;
