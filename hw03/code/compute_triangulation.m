function[] = compute_triangulation(matches, is_house_img)

% load house image's camera matrix
img1_cam_matrix = load('../data/part2/house1_camera.txt');
img2_cam_matrix = load('../data/part2/house2_camera.txt');

% load library image's camera matrix
if is_house_img ~= 1
    img1_cam_matrix = load('../data/part2/library1_camera.txt');
    img2_cam_matrix = load('../data/part2/library2_camera.txt');
end

% required for 3d plot
img1_cam_center = get_camera_center(img1_cam_matrix);
img2_cam_center = get_camera_center(img2_cam_matrix);

num_of_matches = size(matches, 1);
triangulated_points = zeros(num_of_matches, 3); % 3d
img1_projected_points = zeros(num_of_matches, 2); % 2d
img2_projected_points = zeros(num_of_matches, 2); % 2d

for i = 1: num_of_matches
    img1_points = matches(i, 1:2);
    img2_points = matches(i, 3:4);
    
    img1_crossproduct_matrix = [0 -1 img1_points(2); 1 0 -img1_points(1); -img1_points(2) img1_points(1) 0];
    img2_crossproduct_matrix = [0 -1 img2_points(2); 1 0 -img2_points(1); -img2_points(2) img2_points(1) 0];
    
    equations = [img1_crossproduct_matrix * img1_cam_matrix; img2_crossproduct_matrix * img2_cam_matrix];
    
    [U, S, V] = svd(equations);
    temp_triangulated_points = V(:, end)';
    triangulated_points(i, :) = compute_cartesian_coordinates(temp_triangulated_points);
    
    img1_projected_points(i, :) = compute_cartesian_coordinates((img1_cam_matrix * temp_triangulated_points')');
    img2_projected_points(i, :) = compute_cartesian_coordinates((img2_cam_matrix * temp_triangulated_points')');
    
end

%% compute residual error between 2d points and 3d points
img1_distance = diag(dist2(matches(:,1:2), img1_projected_points));
img2_distance = diag(dist2(matches(:,3:4), img2_projected_points));
fprintf('Mean Residual of Img 1: %0.4f \n', mean(img1_distance));
fprintf('Mean Residual of Img 2: %0.4f \n', mean(img2_distance));

%% plot traingulation
% figure;
% axis equal;
% hold on;
% rotate3d on;
% plot3(-triangulated_points(:,1), triangulated_points(:,2), triangulated_points(:,3), '.r');
% plot3(-img1_cam_center(1), img1_cam_center(2), img1_cam_center(3),'*g');
% plot3(-img2_cam_center(1), img2_cam_center(2), img2_cam_center(3),'*b');
% grid on;
% xlabel('x');
% ylabel('y');
% zlabel('z');
% axis equal;

end