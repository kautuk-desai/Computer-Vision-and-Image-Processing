function[] = check_matched_pair(matches, left_img, right_img, left_img_width)

left_img_row_matches = matches(:,2);
left_img_col_matches = matches(:, 3);
right_img_row_matches = matches(:, 5);
right_img_col_matches = matches(:, 6);

plot_row = [left_img_row_matches, right_img_row_matches];
plot_col = [left_img_col_matches, right_img_col_matches + left_img_width];

figure;
imshow([left_img right_img]);
hold on;
title('Mapping of closest features');
hold on;

% features position of left image
plot(left_img_col_matches, left_img_row_matches,'ys');

% features position of right image
plot(right_img_col_matches + left_img_width, right_img_row_matches, 'ys');

num_of_matches = size(matches, 1);

% connect the matching pairs with lines
for i = 1:num_of_matches
    plot(plot_col(i,:), plot_row(i,:));
end


end
