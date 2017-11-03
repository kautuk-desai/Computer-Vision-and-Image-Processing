function [num_of_inliers, inlier_matches, residual_error] = compute_residual_error(H, matches, limit, threshold)

num_of_inliers = 0;
residual_error = [];
inlier_matches = [];

for i = 1:limit
    transformed_points = H' * [matches(i, 3); matches(i, 2); 1];
    x_2d = transformed_points(1) / transformed_points(3);
    y_2d = transformed_points(2) / transformed_points(3);
    
    residual = dist2([x_2d, y_2d], [matches(i, 6), matches(i, 5)]);
    if residual < threshold
        inlier_matches = cat(1, inlier_matches, i);
        residual_error = cat(1, residual_error, residual);
        num_of_inliers = num_of_inliers + 1;
    end
end

end