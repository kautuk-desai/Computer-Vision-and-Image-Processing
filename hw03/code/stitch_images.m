function[stitched_img] = stitch_images(original_left_img, original_right_img, homography_matrix)
%% Inorder to stitch the images. imtransform and maketform is used.
% As it gives the range of x and y in 2d.
homography_transform = maketform('projective', homography_matrix);
[left_transformed_img,xdata_range,ydata_range] = imtransform(original_left_img, homography_transform);
xdataout = [min(1,xdata_range(1)) max(size(original_right_img,2),xdata_range(2))];
ydataout = [min(1,ydata_range(1)) max(size(original_right_img,1),ydata_range(2))];

left_transformed_img = imtransform(original_left_img, homography_transform, 'XData',xdataout,'YData',ydataout);
right_transformed_img = imtransform(original_right_img, maketform('affine',eye(3)),'nearest','XData',xdataout,'YData',ydataout);

[stitched_img_height, stitched_img_width, num_of_channels] = size(left_transformed_img);
stitched_img = left_transformed_img;
output_img_size = stitched_img_height * stitched_img_width * num_of_channels;
for i = 1:output_img_size
    if(stitched_img(i) == 0)
        stitched_img(i) = right_transformed_img(i);
    elseif(stitched_img(i) ~= 0 && right_transformed_img(i) ~= 0)
        stitched_img(i) = left_transformed_img(i)/2 + right_transformed_img(i)/2;
        % stitched_img(i) = max(left_transformed_img(i), right_transformed_img(i));
    end
end
end