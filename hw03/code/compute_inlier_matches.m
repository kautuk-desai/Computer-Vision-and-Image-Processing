function[feature_matches, homography_matrix, optimal_residual_error, optimal_inlier_points, max_num_of_inliers] = compute_inlier_matches(left_image, right_image)

% declare the variables that are going to be used.
neighbor_size = 10;
num_of_descriptor_limit = 200;
% the threshold of which points can be considered as inlier
threshold = 5;

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
num_of_iterations = 10000;
max_num_of_inliers = 0;
ransac_num_matches = 4;

for i = 1 : num_of_iterations
    %select a random subset of points
    inlier_points = randsample(num_of_matches, ransac_num_matches);
    
    homography_matrix = compute_homography_matrix(feature_matches, inlier_points, ransac_num_matches);
    
    [num_of_inliers, inlier_points, residual_error] = compute_residual_error(homography_matrix, feature_matches, num_of_matches, threshold);
    
    %record the number of inliers
    inlier_per_iteration = num_of_inliers;
    
    if inlier_per_iteration >  max_num_of_inliers
        max_num_of_inliers = inlier_per_iteration;
        
        H_max_inliers = homography_matrix;
        optimal_residual_error = residual_error;
        optimal_inlier_points = inlier_points;
    end
end

homography_matrix = H_max_inliers;
end