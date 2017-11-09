function [transformed_matrix, transposed_coordinates] = normalized_algorithm(image_coordinates)
[num_of_matches, dimension] = size(image_coordinates);
homogenous_coordinates = ones(num_of_matches, dimension+1);
homogenous_coordinates(:,1 : dimension) = image_coordinates(:,1:dimension);

%normalized_coordinates = image_coordinates;

normalized_coordinates(:,1) = homogenous_coordinates(:,1)./homogenous_coordinates(:,3);
normalized_coordinates(:,2) = homogenous_coordinates(:,2)./homogenous_coordinates(:,3);
normalized_coordinates(:,3) = 1;

%compute Euclidean Distance of each point from center for each image
c = mean(normalized_coordinates(:,1:2));
shifted_coordinates(:, 1) = normalized_coordinates(:,1)-c(1);
shifted_coordinates(:, 2) = normalized_coordinates(:,2)-c(2);

mean_distance = mean(sqrt(shifted_coordinates(:,1).^2 + shifted_coordinates(:,2).^2));

scale = sqrt(2)/mean_distance;

T = [scale   0   -scale*c(1)
    0     scale -scale*c(2)
    0       0      1      ];

shifted_coordinates = T * normalized_coordinates';

transformed_matrix = T;
transposed_coordinates = shifted_coordinates';
end