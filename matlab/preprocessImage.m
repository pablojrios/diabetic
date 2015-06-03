function I = preprocessImage(Iraw, params)
    I = Iraw;
    % hago el preprocesamiento si la imagen no es grayscale
    if (size(I,3) == 1)
        return
    end

    if (params.scale ~= 1)
        I = imresize(I, params.scale);
    end
    
    % conversión a grayscale
    if (params.RGB2gray)
        I = rgb2gray(I);
    end

    if (params.rotateInverted)
        I = imrotate(I, 180);
    end
    
    if (strcmp(params.contrastEnhancement, 'imadjust'))
        I = imadjust(I);
    elseif (strcmp(params.contrastEnhancement, 'histeq'))
        I = histeq(I);
    elseif (strcmp(params.contrastEnhancement, 'adapthisteq'))
        I = adapthisteq(I);
    end
end