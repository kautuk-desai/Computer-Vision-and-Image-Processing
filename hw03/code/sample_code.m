%%
%% load images and match files for the first example
%%
% 
I1 = imread('../data/part2/house1.jpg');
I2 = imread('../data/part2/house2.jpg');
matches = load('../data/part2/house_matches.txt');

% library image
% I1 = imread('../data/part2/library1.jpg');
% I2 = imread('../data/part2/library2.jpg');
% matches = load('../data/part2/library_matches.txt');
% is_house_img = 0;

% this is a N x 4 file where the first two numbers of each row
% are coordinates of corners in the first image and the last two
% are coordinates of corresponding corners in the second image:
% matches(i,1:2) is a point in the first image
% matches(i,3:4) is a corresponding point in the second image

N = size(matches,1);

%%
%% display two images side-by-side with matches
%% this code is to help you visualize the matches, you don't need
%% to use it to produce the results for the assignment
%%
imshow([I1 I2]); hold on;
plot(matches(:,1), matches(:,2), '+r');
plot(matches(:,3)+size(I1,2), matches(:,4), '+r');
line([matches(:,1) matches(:,3) + size(I1,2)]', matches(:,[2 4])', 'Color', 'r');

%%
%% display second image with epipolar lines reprojected
%% from the first image
%%

% first, fit fundamental matrix to the matches
F = fit_fundamental(matches, 1); % this is a function that you should write
% F_unnormalized = fit_fundamental(matches, 0);

% do this to record residual for unnormalized algorithm
% F = F_unnormalized;

L = (F * [matches(:,1:2) ones(N,1)]')'; % transform points from
% the first image to get epipolar lines in the second image

% find points on epipolar lines L closest to matches(:,3:4)
L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3); % rescale the line
pt_line_dist = sum(L .* [matches(:,3:4) ones(N,1)],2);

%% compute mean squared distance between points
mean_of_residual = mean(abs(pt_line_dist));
fprintf('Mean Residual: %0.4f \n', mean_of_residual);

closest_pt = matches(:,3:4) - L(:,1:2) .* repmat(pt_line_dist, 1, 2);

% find endpoints of segment on epipolar line (for display purposes)
pt1 = closest_pt - [L(:,2) -L(:,1)] * 10; % offset from the closest point is 10 pixels
pt2 = closest_pt + [L(:,2) -L(:,1)] * 10;

% display points and segments of corresponding epipolar lines
clf;
imshow(I2); hold on;
plot(matches(:,3), matches(:,4), '+r');
line([matches(:,3) closest_pt(:,1)]', [matches(:,4) closest_pt(:,2)]', 'Color', 'r');
line([pt1(:,1) pt2(:,1)]', [pt1(:,2) pt2(:,2)]', 'Color', 'g');

%% RANSAC to estimate fundamental matrix
num_of_iterations = N;
ransac_num_matches = 4;
min_inlier_ratio = 0.3;
threshold = 10;

inlier_per_iteration = zeros(num_of_iterations, 1);
F_per_inliers = {};

for i = 1 : num_of_iterations
    %select a random subset of points
    inliers = randsample(N, ransac_num_matches);
    
    img1_inlier_matches = matches(inliers, 1:2);
    img2_inlier_matches = matches(inliers, 3:4);
    
    inlier_matches = [img1_inlier_matches img2_inlier_matches];
    
    F = fit_fundamental(inlier_matches, 1);
    
    L = (F * [matches(:,1:2) ones(N,1)]')'; % transform points from
    % the first image to get epipolar lines in the second image
    
    % find points on epipolar lines L closest to matches(:,3:4)
    L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3); % rescale the line;
    pt_line_dist = sum(L .* [matches(:,3:4) ones(N,1)],2);
    
    residual_errors = abs(pt_line_dist);
    
    inlier_points = find(residual_errors < threshold);
    
    %record the number of inliers
    inlier_per_iteration(i) = length(inlier_points);
    
    %keep track of any models that generated an acceptable numbers of
    %inliers. This collection can be parsed later to find the best fit
    current_inlier_ratio = inlier_per_iteration(i) / N;
    
    if current_inlier_ratio >=  min_inlier_ratio
        img1_inlier_matches = matches(inlier_points, 1:2);
        img2_inlier_matches = matches(inlier_points, 3:4);
        inlier_matches = [img1_inlier_matches img2_inlier_matches];
        F_per_inliers{i} = fit_fundamental(inlier_matches, 1);
    end
end

best_iteration = find(inlier_per_iteration == max(inlier_per_iteration));
F_optimal = F_per_inliers{best_iteration(1)};

% compute residual error for optimal F
L = (F_optimal * [matches(:,1:2) ones(N,1)]')';
L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3);
pt_line_dist = sum(L .* [matches(:,3:4) ones(N,1)],2);
residual_errors = abs(pt_line_dist);

optimal_inlier_points = find(residual_errors < threshold);
fprintf('Number of inliers (RANSAC): %d \n', length(optimal_inlier_points));

mean_of_residual_error = mean(residual_errors);
fprintf('Mean Residual (RANSAC) = %0.4f \n', mean_of_residual_error);


%% Compute triangulation and plot
% 1 is for house image, 0 for library image
compute_triangulation(matches, is_house_img);