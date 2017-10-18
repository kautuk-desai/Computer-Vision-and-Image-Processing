function[] = blob_detection(img)

grayscale_img = im2double(rgb2gray(img));

[height, width] = size(grayscale_img);

k = 1.5;
num_of_levels = 7;
sigma = 3;

tic
fprintf('Downsample image, keep the filter size same: \n');
scale_space = downsample_img(grayscale_img, k, sigma, num_of_levels);
toc

tic
fprintf('Implementing Difference of Gaussian filter... \n');
% scale_space = downsample_img_with_DoG(grayscale_img, k, sigma, num_of_levels);
toc

tic
fprintf('Change the filter size, Keep image size same: \n');
% scale_space = increase_filter_size(grayscale_img, k, sigma, num_of_levels);
toc

pause(0.1);

% perform non maximum suppression
non_max_suppression = zeros(height, width, num_of_levels);
% nlfilter can take a long time to process large images.
% In some cases, the colfilt function can perform the same operation much faster.
for i = 1:num_of_levels
    % non_max_suppression(:,:,i) = colfilt(scale_space_1(:,:,i), [3,3],'sliding', @max);
    non_max_suppression(:,:,i) = ordfilt2(scale_space(:,:,i), 3^2, ones(3));
end

% perform non maximum suppression between scale spaces. compare the current
% scaled image with the previous one and the next one
for i = 1:num_of_levels
    non_max_suppression(:,:,i) = max(non_max_suppression(:,:,max(i-1,1):min(i+1,num_of_levels)),[],3);
    % imshow(non_max_suppression(:,:,i));
end
% if the suppressed scale space is same as the scale space of sampling then
% keep the max suppression same else make it 0
non_max_suppression = non_max_suppression .* (non_max_suppression == scale_space);

threshold = 0.0035;
cx = [];
cy = [];
rad = [];
for i = 1:num_of_levels
    [y_pos, x_pos] = find(non_max_suppression(:,:,i) >= threshold);
    num_of_blobs = length(x_pos);
    
    radii = sqrt(2) * sigma * k^(i-1); % forumula given in lecture slide
    radii = ones(num_of_blobs, 1) .* radii;
    cx = cat(1, cx, x_pos);
    cy = cat(1, cy, y_pos);
    rad = cat(1, rad, radii);
end


show_all_circles(img, cx, cy, rad);

% Print parameters value
fprintf('k: %0.2f \n', k);
fprintf('num of levels: %d \n', num_of_levels);
fprintf('sigma: %0.2f \n', sigma);
fprintf('threshold: %0.4f \n', threshold);
end