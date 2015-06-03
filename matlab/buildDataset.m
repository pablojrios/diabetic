function buildDataset(params, imgIndices, imgClasses, imgNames, destFolder)
    n = 1;
    for idx=imgIndices
        classLabel = imgClasses{idx};
        filename = strcat(imgNames{idx}, '.jpeg');
        sourceFullfilename = sprintf('%s\\%s', params.imageFolder, filename);
        destFullfilename = fullfile(destFolder, filename);
        % status: The value is 1 for success and 0 for failure.
        [status,message,messageid] = copyfile(sourceFullfilename, destFullfilename);
        if (status == 1)
            fprintf('[%d] Image %s copied to folder %s...\n', n, sourceFullfilename, destFolder);
            n = n + 1;
        else
            warning('Image %s couldn''t be copied to folder %s...\n', n, sourceFullfilename, destFolder);
        end
    end

    total = length(imgIndices);
    for c = 0:4
        cantSelectedForClass = length(find([imgClasses{imgIndices}]==c));
        fprintf('%d(%0.1f%%) images selected for class %d\n', cantSelectedForClass, cantSelectedForClass/total*100, c);
    end

    % assert all image files were copied
    classJpegFiles = dir(fullfile(destFolder, '*.jpeg'));
    copied = length(classJpegFiles);
    assert(copied == n-1, 'Error: Couldn''t copy all image files to folder %s, copied %d of %d, \n', ...
        destFolder, copied, n-1);
    fprintf('>>> All images (%d) were copied to folder %s\n', copied, destFolder);
end