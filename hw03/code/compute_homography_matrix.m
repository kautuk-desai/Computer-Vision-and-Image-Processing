function [H] = compute_homography_matrix(matches, inliers, ransac_num_matches)
A = [];
for i = 1:ransac_num_matches
    current_match = matches(inliers(i), :);
    x_transpose = [current_match(3), current_match(2), 1];
    A_i = [x_transpose*0, x_transpose, x_transpose*(-current_match(5));
        x_transpose, x_transpose*0, x_transpose*(-current_match(6))];
    A = cat(1, A, A_i);
end
[U, S, V] = svd(A); % Eigenvectors of transpose(A)*A
X = V(:, end);     % Vector corresponding to smallest eigenvalue
H = reshape(X, 3, 3);   % Reshape into 3x3 matrix
%H = H ./ H(3,3);
end