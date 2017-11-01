function [feature_descptions] = feature_descriptor(image, row, col, neighbor_size)
% Identify feature description

num_of_corners = length(row);
feature_descptions = zeros(num_of_corners, (2*neighbor_size + 1)^2);

% matrix with a single 1 in the center and zeros all around it
padding = zeros(2 * neighbor_size + 1);
padding(neighbor_size + 1, neighbor_size + 1) = 1;

% use the pad Helper matrix to pad the img such that the border values
% extend out by the radius
padded_img = imfilter(image, padding, 'replicate', 'full');

for i = 1:num_of_corners
    range_of_rows = row(i) : row(i) + 2 * neighbor_size;
    range_of_cols = col(i) : col(i) + 2 * neighbor_size;
    % convert to flattened vector
    image_range = padded_img(range_of_rows, range_of_cols);
    %fprintf('i = %d \n',i);
    feature_descptions(i,:) = reshape(image_range, 1, (2 * neighbor_size + 1)^2);
end

% normalizing all descriptors to have zero mean and unit standard deviation
% found the function on mathworks
feature_descptions = zscore(feature_descptions')';

end