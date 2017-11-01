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
neighborhood_size = 3;

left_img_feature_desc = feature_descriptor(left_image, left_row_coordinates, left_col_coordinates, neighborhood_size);
right_img_feature_desc = feature_descriptor(right_image, right_row_coordinates, right_col_coordinates, neighborhood_size);

%% match features
num_of_matches = 200;

num_of_left_img_features = length(left_img_feature_desc);
num_of_right_img_features = length(right_img_feature_desc);
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

end