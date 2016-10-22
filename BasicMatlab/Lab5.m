close;
clear;
clc;

%% read image
filename = 'image.jpg';
I = imread(filename);
figure('name', 'source image');
imshow(I);

%% ----- pre-lab ----- %%
% output = function(input1, input2, ...);
% grey_scale function
I2 = grey_scale(I);

%% ----- homework lab ----- %%
% flip function
I3 = flip(I,0);

% rotation function
I4= rotation(I, pi/3);

%% show image
figure('name', 'grey scale image'),
imshow(I2);
figure('name', 'flip image'),
imshow(I3);
figure('name', 'rotated image'),
imshow(I4);
%% write image
% save image for your report
filename2 = 'gray_image.jpg';
imwrite(I2, filename2);
filename3 = 'flip_image.jpg';
imwrite(I3, filename3);
filename4 = 'rotate_image.jpg';
imwrite(I4, filename4);




