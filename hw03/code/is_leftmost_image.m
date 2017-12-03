function[is_leftmost_img] = is_leftmost_image(img1_inlier, img2_width)
mean_of_inliers = mean(img1_inlier);

if(mean_of_inliers > img2_width)
    is_leftmost_img = 0;
else
    is_leftmost_img = 1;
end

end