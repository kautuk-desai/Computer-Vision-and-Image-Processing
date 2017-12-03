function[] = stitch_multiple_images()
image1 = imread('../data/part1/hill/1.JPG');
image2 = imread('../data/part1/hill/2.JPG');
image3 = imread('../data/part1/hill/3.JPG');

img1_gray = rgb2gray(image1);
img2_gray = rgb2gray(image2);
img3_gray = rgb2gray(image3);

img1 = im2double(img1_gray);
img2 = im2double(img2_gray);
img3 = im2double(img3_gray);

image1_width = size(img1, 2);
image2_width = size(img2, 2);
image3_width = size(img3, 2);

% so to stitch more than 2 images, first we need to find the middle image,
% then the leftmost image and the remaining image will be the right most
% image. To do this, we can compute the number of inliers for each image.
% Then by logic the middle image will have the most number of inliers as it
% is being stitched from the left as well from the right. Once, we find the
% middle image we then find the left most image. After, the order of images
% has been identified we stitch them 2 images at a time and the stitch pair
% logic can be used for this.

[feature_matches_12, H_12, opt_residual_error_12, opt_inlier_points_12, max_num_of_inliers_12] = compute_inlier_matches(img1, img2);
[feature_matches_23, H_23, opt_residual_error_23, opt_inlier_points_23, max_num_of_inliers_23] = compute_inlier_matches(img2, img3);
[feature_matches_13, H_13, opt_residual_error_13, opt_inlier_points_13, max_num_of_inliers_13] = compute_inlier_matches(img1, img3);

% fprintf('Num of inliers for 1-2 %d \n', max_num_of_inliers_12);
% fprintf('Num of inliers for 2-3 %d \n', max_num_of_inliers_23);
% fprintf('Num of inliers for 1-3 %d \n', max_num_of_inliers_13);


%% find image order and then stitch them
% check if image 1 is the middle image.
if(max_num_of_inliers_12 > max_num_of_inliers_23 && max_num_of_inliers_13 > max_num_of_inliers_23)
    is_leftmost_img = is_leftmost_image(opt_inlier_points_12, image2_width / 2);
    
    if(is_leftmost_img == 0) % image 2 is leftmost image
        fprintf('order of stitching: 2->1->3 \n');
        stitched_image = stitch_images(image1, image2, H_12);
        stitched_img_gray = rgb2gray(im2double(stitched_image));
        [~, H, ~, ~, ~] = compute_inlier_matches(stitched_img_gray, img3);
        stitched_image = stitch_images(stitched_image, image3, H);
        
    else % image 3 is leftmost image
        fprintf('order of stitching: 3->1->2 \n');
        stitched_image = stitch_images(image3, image1, H_13);
        % convert the stitched image to gray
        stitched_img_gray = rgb2gray(im2double(stitched_image));
        
        %compute homography for stitched image and right most image
        [~, H, ~, ~, ~] = compute_inlier_matches(stitched_img_gray, img2);
        stitched_image = stitch_images(stitched_image, image2, H);
    end
    
% check if image 2 is the middle image.
elseif(max_num_of_inliers_23 > max_num_of_inliers_13 && max_num_of_inliers_12 > max_num_of_inliers_13)
    is_leftmost_img = is_leftmost_image(opt_inlier_points_23, image3_width /2);
    
    if(is_leftmost_img == 0) % image 3 is leftmost image
        fprintf('order of stitching: 3->2->1 \n');
        stitched_image = stitch_images(image3, image2, H_23);
        stitched_img_gray = rgb2gray(im2double(stitched_image));
        [~, H, ~, ~, ~] = compute_inlier_matches(stitched_img_gray, img1);
        stitched_image = stitch_images(stitched_image, image1, H);
        
    else % image 1 is leftmost image
        fprintf('order of stitching: 1->2->3 \n');
        stitched_image = stitch_images(image1, image2, H_12);
        stitched_img_gray = rgb2gray(im2double(stitched_image));
        [~, H, ~, ~, ~] = compute_inlier_matches(stitched_img_gray, img3);
        stitched_image = stitch_images(stitched_image, image3, H);
    end
    
% check if image 3 is the middle image.
elseif(max_num_of_inliers_23 > max_num_of_inliers_12 && max_num_of_inliers_13 > max_num_of_inliers_12)
    is_leftmost_img = is_leftmost_image(opt_inlier_points_13, image1_width / 2);
    
    if(is_leftmost_img == 0) % image 1 is leftmost image
        fprintf('order of stitching: 1->3->2 \n');
        stitched_image = stitch_images(image1, image3, H_13);  
        stitched_img_gray = rgb2gray(im2double(stitched_image));
        
        [~, H, ~, ~, ~] = compute_inlier_matches(stitched_img_gray, img2);
        stitched_image = stitch_images(stitched_image, image2, H);
        
    else % image 2 is leftmost image
        fprintf('order of stitching: 2->3->1 \n');
        stitched_image = stitch_images(image2, image3, H_23);
        stitched_img_gray = rgb2gray(im2double(stitched_image));
        [~, H, ~, ~, ~] = compute_inlier_matches(stitched_img_gray, img1);
        stitched_image = stitch_images(stitched_image, image1, H);
    end
end

figure;
imshow(stitched_image);
end