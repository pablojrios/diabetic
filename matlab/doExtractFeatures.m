function doExtractFeatures(params, classLabels, featuresFileID)
    
    finishup = onCleanup(@() cleanupTasks(featuresFileID));
    
    jpegFiles = dir(fullfile(params.imageFolder, '*.jpeg'));
    n = 1;
    for f = 1:length(jpegFiles)
        baseFilename = jpegFiles(f).name;
        fullFilename = fullfile(params.imageFolder, baseFilename);
        Iraw = imread(fullFilename);
        fprintf('>>> [%d] Pre-processing image %s...\n', n, baseFilename);
        I = preprocessImage(Iraw, params);
        afterPreprocessing(I, baseFilename, params);
        if (params.extractFeatures)
            fprintf('>>> [%d] Extracting features for image %s...\n', n, baseFilename);
            features = extractImageFeatures(I, params.radonTheta, params.invariantCount);
            afterFeatureExtraction(featuresFileID, baseFilename, classLabels, features);
        end
        n = n + 1;
    end
end

function afterFeatureExtraction(featuresFileID, baseFilename, classLabels, features)
    % leo la clase de classLabels
    imageName = baseFilename(1:length(baseFilename)-5);
    ind = find(strcmp([classLabels(:,1)], imageName));
    label = classLabels{ind, 2};
    csvrow = {};
    csvrow{end+1} = imageName; csvrow{end+1} = label; csvrow{end+1} = features;
    strrow = sprintf('%s,%d,%.8f,', csvrow{1,:}); strrow = strrow(1:end-1); % remove ',' at the end
    fprintf(featuresFileID, '%s\n', strrow);
end

function afterPreprocessing(I, baseFilename, params)
    if (params.saveImageAfterPreprocess)
        imgFilename = sprintf('%s\\%s\\%s', params.imageFolder, params.runName, baseFilename);
        imwrite(I, imgFilename);
    end
end

function cleanupTasks(fileID)
    fclose(fileID);
end
