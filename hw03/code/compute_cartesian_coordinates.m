function[cart_coordinates] = compute_cartesian_coordinates(homogenous_coordinates)

dimension = size(homogenous_coordinates, 2) - 1;

%divide every row by the last entry in that row
normalized_coordinates = bsxfun(@rdivide,homogenous_coordinates,homogenous_coordinates(:,end));
cart_coordinates = normalized_coordinates(:,1:dimension);
end