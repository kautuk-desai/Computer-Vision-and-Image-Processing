function [camera_center] = get_camera_center(camera_matrix)

[U, S, V] = svd(camera_matrix);
camera_center = V(:,end);

end