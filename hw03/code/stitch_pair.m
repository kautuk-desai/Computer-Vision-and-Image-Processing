function [] = stitch_pair()

original_left_img = imread('../data/part1/uttower/left.jpg');
left_image = im2double(rgb2gray(original_left_img));

original_right_img = imread('../data/part1/uttower/right.jpg');
right_image = im2double(rgb2gray(original_right_img));

% created this function so that it can be used for stitching multiple
% image part.
[feature_matches, homography_matrix, optimal_residual_error, optimal_inlier_points, max_num_of_inliers] = compute_inlier_matches(left_image, right_image);

fprintf('Number of inliers (RANSAC): %d \n', max_num_of_inliers);

mean_of_residual_error = mean(optimal_residual_error);
fprintf('Mean Residual (RANSAC) = %0.4f \n', mean_of_residual_error);

% display the optimal matching pairs. Commented the below code because
% while testing images would keep showing and it becomes difficult to test
% properly.
%{
optimal_feature_matches = [];
for i = 1:max_num_of_inliers
    optimal_feature_matches = cat(1, optimal_feature_matches, feature_matches(optimal_inlier_points(i), :));
end
optimal_feature_matches = feature_matches(optimal_inlier_points, :);

check_matched_pair(optimal_feature_matches, left_image, right_image, size(left_image, 2));
title('Mapping of Optimal features obatined using RANSAC');
%}

%% Warp the image using the homography matrix obtained
T = projective2d(homography_matrix);
transformed_img = imwarp(original_left_img, T);
figure, imshow(transformed_img);
title('Homography transformed image');


% create this function so that it can be used for stitching multiple
% images.
stitched_image = stitch_images(original_left_img, original_right_img, homography_matrix);

figure();
imshow(stitched_image);
title('Stitched Image');
end