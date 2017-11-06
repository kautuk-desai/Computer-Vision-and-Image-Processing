function [transformed_matrix, transposed_coordinates] = normalized_algorithm(image_coordinates)
%{
num_of_matches = size(image_coordinates,1);
center = mean(image_coordinates);

%compute Euclidean Distance of each point from center for each image
distance = 0;
for i = 1:num_of_matches
    distance = distance + (image_coordinates(i,1)- center(1))^2 + (image_coordinates(i,2)- center(2))^2;
end

% Center the image data at the origin, and scale it so
% the mean squared distance between the origin and
% the data points is 2 pixels
avg_square_distance = mean(distance);%distance/num_of_matches;

%Finding scale transformation for point set a and b
scale = sqrt(2/(avg_square_distance));

%Transformation Matrix for Set of Points A and B
transformed_matrix = [scale 0 0;0 scale 0;0 0 1] * [1 0 -center(1);0 1 -center(2);0 0 1];

[num_of_coordinates, dimension] = size(image_coordinates);
homogeneous_coordinates = ones(num_of_coordinates, dimension+1);
homogeneous_coordinates(:,1 : dimension) = image_coordinates(:,1:dimension);

transposed_coordinates = (transformed_matrix * homogeneous_coordinates')';
%}


[numCoordinates, dimension] = size(image_coordinates);
homoCoord = ones(numCoordinates, dimension+1);
homoCoord(:,1 : dimension) = image_coordinates(:,1:dimension);


center = mean(homoCoord(:,1:2));

offset = eye(3);
offset(1,3) = -center(1); %-mu_x
offset(2,3) = -center(2); %-mu_y

sX= max(abs(homoCoord(:,1)));
sY= max(abs(homoCoord(:,2)));

scale = eye(3);
scale(1,1)=1/sX;
scale(2,2)=1/sY;

transform = scale * offset;
normCoord = (transform * homoCoord')';

transformed_matrix = transform;
transposed_coordinates = normCoord;
end