I = imread('25_left.jpeg');
pout = rgb2gray(I);

pout_imadjust = imadjust(pout);
% pout_histeq = histeq(pout);
% pout_adapthisteq = adapthisteq(pout);

imshow(pout);
title('Original');

figure, imshow(pout_imadjust);
title('Imadjust');

figure, imhist(pout), title('Hist Original');
figure, imhist(pout_imadjust), title('Hist Imadjust');
