function[scale_space] = downsample_img(image,k, sigma, num_of_levels)

[height, width] = size(image);
% initialize the scale space
scale_space = zeros(height, width, num_of_levels);

filter_size = 2*floor(3*sigma) + 1; % inorder to make kernel size odd
h = sigma^2 * fspecial('log', filter_size, sigma);
img = image;
for i = 1:num_of_levels
    % downsample the image
    img = imresize(image, 1/(k^(i-1)));
    filtered_img = imfilter(img, h, 'replicate');
    
    filtered_img = filtered_img .^ 2;
    
    scale_space(:,:,i) = imresize(filtered_img, [height, width]);
    % imshow(scale_space(:,:,i));
end

end