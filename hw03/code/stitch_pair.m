function [] = stitch_pair()

% declare the variables that are going to be used.
neighbor_size = 10;
num_of_descriptor_limit = 200;
% the threshold of which points can be considered as inlier
threshold = 5;

original_left_img = imread('../data/part1/uttower/left.jpg');
left_image = im2double(rgb2gray(original_left_img));

original_right_img = imread('../data/part1/uttower/right.jpg');
right_image = im2double(rgb2gray(original_right_img));

% chose sigma as 3 and radius as 2 so that the mask size is 5.
[left_img_corner_idx, left_img_row_idx, left_img_col_idx] = harris(left_image, 3, 0.025, 2, 1);
[right_img_corner_idx, right_img_row_idx, right_img_col_idx] = harris(right_image, 3, 0.025, 2, 1);

[left_img_row_idx, left_img_col_idx, left_img_feature_desc] = feature_descriptor(left_image, left_img_row_idx, left_img_col_idx, neighbor_size);
[right_img_row_idx, right_img_col_idx, right_img_feature_desc] = feature_descriptor(right_image, right_img_row_idx, right_img_col_idx, neighbor_size);

num_left_img_corners = size(left_img_row_idx, 1);
num_right_img_corners = size(right_img_row_idx, 1);

% select only corner points obtained from feature descriptor
left_img_feature_desc = left_img_feature_desc(1:num_left_img_corners,:);
right_img_feature_desc = right_img_feature_desc(1:num_right_img_corners, :);

% compute the eclidean mean squared distance between each points
feature_match_dist = dist2(left_img_feature_desc, right_img_feature_desc);

% find the minimum distance between points and select those feature matches
feature_matches = [];
for i = 1:num_of_descriptor_limit
    [row_id, col_id] = find(feature_match_dist == min(min(feature_match_dist)));
    if(length(row_id) == 1)
        temp_matches = [row_id, left_img_row_idx(row_id), left_img_col_idx(row_id), col_id, right_img_row_idx(col_id), right_img_col_idx(col_id), min(min(feature_match_dist))];
        feature_matches = cat(1, feature_matches, temp_matches);
        % put high values so that they are not selected for the next
        % iteration
        feature_match_dist(row_id, :) = 100;
        feature_match_dist(:, col_id) = 100;
    end
end

% % display the matching pairs
% check_matched_pair(feature_matches, left_image, right_image, size(left_image, 2));
% title('Mapping of Harris features');

%% Perform RANSAC to find the inliers and the corresponding homograpy matrix.
num_of_matches = size(feature_matches, 1);
% ransac_num_matches = 4;
% n = 1;
% 
% while(n < num_of_matches)
%     % randomly pick 4 points.
%     if ransac_num_matches == 4
%         inlier_points = randsample(num_of_matches, ransac_num_matches);
%     end
%     
%     homography_matrix = compute_homography_matrix(feature_matches, inlier_points, ransac_num_matches);
%     
%     [num_of_inliers, inlier_points, residual_error] = compute_residual_error(homography_matrix, feature_matches, num_of_matches, threshold);
%     
%     % this is to check if the inliers are less than 10 then the optimal
%     % value is obtained at 4.
%     if(num_of_inliers < 10)
%         ransac_num_matches = 4;
%     else
%         ransac_num_matches = num_of_inliers;
%         n = n+1;
%     end
% end
% 
% fprintf('Number of inliers (RANSAC): %d \n', num_of_inliers);
% 
% mean_of_residual_error = mean(residual_error);
% fprintf('Mean Residual (RANSAC) = %0.4f \n', mean_of_residual_error);


num_of_iterations = 1000;
N = num_of_matches;
max_num_of_inliers = 0;
ransac_num_matches = 4;
mean_of_residual_error = 0;

for i = 1 : num_of_iterations
    %select a random subset of points
    inlier_points = randsample(N, ransac_num_matches);
    
    homography_matrix = compute_homography_matrix(feature_matches, inlier_points, ransac_num_matches);
    
    [num_of_inliers, inlier_points, residual_error] = compute_residual_error(homography_matrix, feature_matches, num_of_matches, threshold);
    
    %record the number of inliers
    inlier_per_iteration = length(inlier_points);
    
    if inlier_per_iteration >  max_num_of_inliers
        max_num_of_inliers = inlier_per_iteration;
        
        F_max_inliers = homography_matrix;
        optimal_residual_error = residual_error;
        optimal_inlier_points = inlier_points;
    end
end

homography_matrix = F_max_inliers;
fprintf('Number of inliers (RANSAC): %d \n', max_num_of_inliers);

mean_of_residual_error = mean(optimal_residual_error);
fprintf('Mean Residual (RANSAC) = %0.4f \n', mean_of_residual_error);

% display the optimal matching pairs
%{
optimal_feature_matches = [];
for i = 1:num_of_inliers
    optimal_feature_matches = cat(1, optimal_feature_matches, feature_matches(inlier_points(i), :));
end


check_matched_pair(optimal_feature_matches, left_image, right_image, size(left_image, 2));
title('Mapping of Optimal features obatined using RANSAC');
%}


%% Warp the image using the homography matrix obtained
T = projective2d(homography_matrix);
transformed_img = imwarp(original_left_img, T);
figure, imshow(transformed_img);
title('Homography transformed image');


%% Inorder to stitch the images. imtransform and maketform is used.
% As it gives the range of x and y in 2d.
homography_transform = maketform('projective', homography_matrix);
[left_transformed_img,xdata_range,ydata_range] = imtransform(original_left_img, homography_transform);
xdataout = [min(1,xdata_range(1)) max(size(original_right_img,2),xdata_range(2))];
ydataout = [min(1,ydata_range(1)) max(size(original_right_img,1),ydata_range(2))];

left_transformed_img = imtransform(original_left_img, homography_transform, 'XData',xdataout,'YData',ydataout);
right_transformed_img = imtransform(original_right_img, maketform('affine',eye(3)),'nearest','XData',xdataout,'YData',ydataout);

[stitched_img_height, stitched_img_width, num_of_channels] = size(left_transformed_img);
stitched_img = left_transformed_img;
output_img_size = stitched_img_height * stitched_img_width * num_of_channels;
for i = 1:output_img_size
    if(stitched_img(i) == 0)
        stitched_img(i) = right_transformed_img(i);
    elseif(stitched_img(i) ~= 0 && right_transformed_img(i) ~= 0)
        stitched_img(i) = left_transformed_img(i)/2 + right_transformed_img(i)/2;
        % stitched_img(i) = max(left_transformed_img(i), right_transformed_img(i));
    end
end

figure();
imshow(stitched_img);
title('Stitched Image');
end