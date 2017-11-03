function [row, col, feature_descptions] = feature_descriptor(image, row, col, neighbor_size)
[height, width] = size(image);
num_of_corners = size(row, 1);

trimmed_row = [];
trimmed_col = [];
for i = 1:num_of_corners
    if((row(i) > neighbor_size) && (col(i) > neighbor_size) && (row(i) < height - neighbor_size - 1) && (col(i) < width - neighbor_size - 1))
        trimmed_row = [trimmed_row; row(i)];
        trimmed_col = [trimmed_col; col(i)];
    end
end

row = trimmed_row;
col = trimmed_col;

feature_descptions = zeros(num_of_corners, (2*neighbor_size+1)^2);
num_of_corners = size(row, 1);

for i = 1:num_of_corners
    range_of_rows = row(i) - neighbor_size : row(i)+neighbor_size;
    range_of_cols = col(i) - neighbor_size : col(i)+neighbor_size;
    padded_img = image(range_of_rows, range_of_cols);
    feature_descptions(i,:) = reshape(padded_img, 1, (2*neighbor_size+1)^2);
end

end