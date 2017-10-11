function [filterResponses] = extractFilterResponses(img, filterBank)
% Extract filter responses for the given image.
% Inputs:
%   img:                a 3-channel RGB image with width W and height H
%   filterBank:         a cell array of N filters
% Outputs:
%   filterResponses:    a W x H x N*3 matrix of filter responses


% TODO Implement your code here

% if the image is a grayscale image repeat it across all layers. The reason
% this code is written here is because it is used to get visual words and
% also by filterbank and dictionary.
if size(img, 3) == 1
    img = repmat(img, 1, 1, 3);
end

% the given image is converted in to Lab color space.
img = double(img);
[L,a,b] = RGB2Lab(img(:,:,1), img(:,:,2), img(:,:,3));
pixel_count = size(img,1)*size(img,2);

% initialize the filter response matrix with zeros. As explained in the
% problem set pdf the length of filter bank is multiplied by 3 (l,a,b)
filterResponses = zeros(pixel_count, length(filterBank)*3);

%{
code for generating montage:
fimg_array = strings([1,20]);
delete filtimage*.jpg
%}

% the following loop applies each filter in the filter bank to each
% channel (L,a,b)
% the reshape will convert the matrix in 1 column.
% the empty array [] is used to let reshape automatically calculate the
% number of rows
for i = 1 : length(filterBank)
    Lightness_filter = imfilter(L, filterBank{i}, 'replicate','same','conv');
    filterResponses(:, i*3-2) = reshape(Lightness_filter, [], 1);
    
    a_filter = imfilter(a, filterBank{i}, 'replicate','same','conv');
    filterResponses(:, i*3-1) = reshape(a_filter, [], 1);
    
    b_filter = imfilter(b, filterBank{i}, 'replicate','same','conv');
    filterResponses(:, i*3) = reshape(b_filter, [], 1);
    
    %{
    code for generating montage:
    fimg = reshape(filterResponses(1:size(img,1)*size(img,2),i*3-2: i*3),size(img,1),size(img,2),3);
    
    if i >= 10
        file_name = sprintf('filtimage%d.jpg', i);
    else
        file_name = sprintf('filtimage0%d.jpg', i);
    end
    
    fimg_array(i) = file_name;
    imwrite(fimg, file_name);
    %}
end
%{
code for generating montage:
dir_utput = dir(fullfile('./','filtimage*.jpg'));
file_names = {dirOutput.name};
montage(file_names, 'Size', [4,5]);
img_montage = getframe(gca);
delete filtimage*.jpg;
imwrite(img_montage.cdata,'montage.jpg','jpg');
%}
end
