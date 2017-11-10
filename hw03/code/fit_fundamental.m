function [fundamental_matrix] = fit_fundamental(matches, normalize_coordinates)
%       matches is a N x 4 file where the first two numbers of each row
%       are coordinates of corners in the first image and the last two
%       are coordinates of corresponding corners in the second image:
%       matches(i,1:2) is a point in the first image
%       matches(i,3:4) is a corresponding point in the second image

num_of_matches = size(matches, 1);

img1_coordinates = matches(:, 1:2);
img2_coordinates = matches(:, 3:4);

if normalize_coordinates == 1
    [img_1_transformed_matrix, img1_transformed_coordinates] = normalized_algorithm(img1_coordinates);
    [img_2_transformed_matrix, img2_transformed_coordinates] = normalized_algorithm(img2_coordinates);
    
    img1_coordinates = img1_transformed_coordinates;
    img2_coordinates = img2_transformed_coordinates;
end

u1 = img1_coordinates(:,1);
v1 = img1_coordinates(:,2);
u2 = img2_coordinates(:,1);
v2 = img2_coordinates(:,2);

A = ones(num_of_matches, 9);
A(:, 1:8) = [u2.*u1, u2.*v1, u2, v2.*u1, v2.*v1, v2, u1, v1];

% solve the homogenous linear system
[U, S, V] = svd(A);
X = V(:,end);
F = reshape(X, [3, 3])';

% enforce the rank-2 constraint
[U, S, V] = svd(F);
% set the smallest singular value to zero
S(end) = 0;
% Recompute F
fundamental_matrix = U*S*V';

if normalize_coordinates == 1
    % Transform fundamental matrix back to original units
    fundamental_matrix = img_2_transformed_matrix' * fundamental_matrix * img_1_transformed_matrix;
end

end