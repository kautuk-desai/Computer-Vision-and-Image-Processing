function[scale_space] = downsample_img_with_DoG(image,k, sigma, num_of_levels)

[height, width] = size(image);
% initialize the scale space
scale_space = zeros(height, width, num_of_levels);

for i = 1:num_of_levels
    % downsample the image
    img = imresize(image, 1/(k^(i-1)));
    
    % Difference of gaussian filters 
    filtered_img = difference_of_gaussian_filter(img, sigma);
    
    filtered_img = filtered_img .^ 2;
    
    scale_space(:,:,i) = imresize(filtered_img, [height, width]);
    % imshow(scale_space(:,:,i));
end
end