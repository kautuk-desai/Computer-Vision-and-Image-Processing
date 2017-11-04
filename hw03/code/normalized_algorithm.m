function [transformed_matrix, transposed_coordinates] = normalized_algorithm(image_coordinates)

num_of_matches = size(image_coordinates,1);
center = mean(image_coordinates);

%compute Euclidean Distance of each point from center for each image
dist = 0;
for i = 1:num_of_matches
    dist = dist + (image_coordinates(i,1)- center(1))^2 + (image_coordinates(i,2)- center(2))^2;
end

% Center the image data at the origin, and scale it so
% the mean squared distance between the origin and
% the data points is 2 pixels
avgsqdist1 = dist/num_of_matches;

%Finding scale transformation for point set a and b
s1 = sqrt(2/(avgsqdist1));

%Transformation Matrix for Set of Points A and B
transformed_matrix = [s1 0 0;0 s1 0;0 0 1] * [1 0 -center(1);0 1 -center(2);0 0 1];

[num_of_coordinates, dimension] = size(image_coordinates);
homogeneous_coordinates = ones(num_of_coordinates, dimension+1);
homogeneous_coordinates(:,1 : dimension) = image_coordinates(:,1:dimension);

transposed_coordinates = (transformed_matrix * homogeneous_coordinates')';

transposed_coordinates = transposed_coordinates(:, 1:2);
end