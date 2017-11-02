function [] = stitch_pair()

% load the images and convert to grayscale
left_image = imread('../data/part1/uttower/left.jpg');
left_img_2dbl = im2double(left_image);
left_image = rgb2gray(left_img_2dbl);

right_image = imread('../data/part1/uttower/right.jpg');
right_img_2dbl = im2double(right_image);
right_image = rgb2gray(right_img_2dbl);

% get the height of images. which can be used for neighbor points
% detection.
[left_img_height, left_img_width] = size(left_image);
[right_img_height, right_img_width] = size(right_image);


% selecting sigma = 3 as in the previous project good results were obtained
% using this value. The threshold value were tested for a range of 0.1 -
% 0.009. Selected radius = 2 to make the size of the mask as 5
[left_img_corners, left_row_coordinates, left_col_coordinates] = harris(left_image, 3, 0.025, 2, 1);
[right_img_corners, right_row_coordinates, right_col_coordinates] = harris(right_image, 3, 0.025, 2, 1);

% get feature descriptions of left and right images
neighborhood_size = 10;

left_img_feature_desc = feature_descriptor(left_image, left_row_coordinates, left_col_coordinates, neighborhood_size);
right_img_feature_desc = feature_descriptor(right_image, right_row_coordinates, right_col_coordinates, neighborhood_size);

%% match features
num_of_matches = 200;

num_of_left_img_features = size(left_img_feature_desc, 1);
num_of_right_img_features = size(right_img_feature_desc, 1);
distance = zeros(num_of_left_img_features, num_of_right_img_features);

for i = 1:num_of_left_img_features
    for j = 1:num_of_right_img_features
        distance(i, j) = dist2(left_img_feature_desc(i, :), right_img_feature_desc(j, :));
        %distance(i, j) = normxcorr2(left_img_feature_desc(i, :), right_img_feature_desc(j, :));
    end
end


num_of_matches = min([num_of_matches, num_of_left_img_features, num_of_right_img_features]);
matches = [];%index_left, row_left, col_left, index_right, row_right, col_right, distance

for i = 1:num_of_matches
    [r, c] = find(distance == min(min(distance)));
    if(length(r) == 1)
        temp_matches = [r, left_row_coordinates(r), left_col_coordinates(r), c, right_row_coordinates(c), right_col_coordinates(c), min(min(distance))];
        matches = cat(1, matches, temp_matches);
        distance(r,:) = 100;
        distance(:,c) = 100;
    end
end

check_matched_pair(matches, left_img_2dbl, right_img_2dbl, left_img_width);

num_of_matches = size(matches, 1);

%% Estimate homography using RANSAC

left_img_matched_features = [matches(:, 3), matches(:, 2), ones(num_of_matches, 1)];
right_img_matched_features = [matches(:, 6), matches(:, 5), ones(num_of_matches, 1)];


ransac_num_of_matches = 4;
num_of_iterations = 200;
threshold = 10;

for i = 1:num_of_iterations
    subset_matches = randsample(num_of_matches, ransac_num_of_matches);
    left_subset = left_img_matched_features(subset_matches, :);
    right_subset = right_img_matched_features(subset_matches, :);
    
    A = [];
    for j = 1:num_of_matches
        left_subset_points = left_subset(i,:);
        right_subset_points = right_subset(i,:);
        
        A_i = [ zeros(1,3), -left_subset_points, right_subset_points(2)*left_subset_points;
            left_subset_points, zeros(1,3),-right_subset_points(1)*left_subset_points];
        A = cat(1, A, A_i);
    end
    
    [~,~,V] = svd(A); % Eigenvectors of transpose(A)*A
    h = V(:,9);     % Vector corresponding to smallest eigenvalue 
    H = reshape(h, 3, 3);   % Reshape into 3x3 matrix
    H = H ./ H(3,3); 
    
    transformed_points = left_img_matched_features * H;
    
    x_left = transformed_points(:, 1) ./ transformed_points(:, 3);
    x_right = right_img_matched_features(:, 1) ./ right_img_matched_features(:, 3);
    x_2d = x_left - x_right;
    
    y_left = transformed_points(:, 2) ./ transformed_points(:, 3);
    y_right = right_img_matched_features(:, 2) ./ right_img_matched_features(:, 3);
    y_2d = y_left - y_right;
    
    residuals = x_2d .* x_2d + y_2d .* y_2d;
    
    inlier_matches = find(residuals < threshold);
    
    num_of_inlier_iterations = length(inlier_matches);
end

optimal_matches = [];
for i = 1:num_of_inliers
    temp_matches = [matches(inliers(i), :)];
    optimal_matches = cat(1, optimal_matches, temp_matches);
end

check_matched_pair(optimal_matches, left_img_2dbl, right_img_2dbl, left_img_width);

end