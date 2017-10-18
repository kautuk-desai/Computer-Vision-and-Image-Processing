function[scale_space] = increase_filter_size(image, k, sigma, num_of_levels)

[height, width] = size(image);

% initialize the scale space
scale_space = zeros(height, width, num_of_levels);

for i = 1:num_of_levels
    scale_k = k^(i-1);
    scale_sigma = sigma * scale_k;
    filter_size = 2*ceil(3*scale_sigma) + 1;
    
    % scale normalize the filter
    % Laplacian is the second Gaussian derivative, so it must be multiplied
    % by sigma ^ 2
    h = scale_sigma^2 * fspecial('log', filter_size, scale_sigma); 
    filtered_img = imfilter(image, h, 'replicate');
    
    filtered_img = filtered_img .^ 2;
    
    scale_space(:,:,i) = filtered_img;
    % imshow(scale_space(:,:,i));
    % fprintf('Iteration num: %d \n', i);
    
    pause(0.1); % this is because my machine takes too much time to evaluate
    % the increase filter size execution. But if i debug the code line by line
    % it does not take much time. So realized to give a small delay. Stupid
    % implentation but it worked.
end

end