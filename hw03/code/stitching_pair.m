function [] = stitching_pair()
input1 = '../data/part1/uttower/left.jpg';
input2 = '../data/part1/uttower/right.jpg';
neighbor_size = 5; % (2x+1)*(2x+1) pixels total
    top = 200;
    iterations = 200;

    input_rgb_left = imread(input1, 'jpg');
    input_rgb_left = remove_border(input_rgb_left);
    input_rgb_right = imread(input2, 'jpg');
    input_rgb_right = remove_border(input_rgb_right);
    input_left = rgb2gray(input_rgb_left);
    input_right = rgb2gray(input_rgb_right);
    input_left = im2double(input_left);
    input_right = im2double(input_right);
    [left_height, left_width] = size(input_left);
    [right_height, right_width] = size(input_right);

    [output_left, row_left, col_left] = harris(input_left, 3, 0.05, 3, 1); 
    [output_right, row_right, col_right] = harris(input_right, 3, 0.05, 3, 1);

    [num_of_corners_left, tmp] = size(row_left);
    [num_of_corners_right, tmp] = size(row_right);

    new_row_left = [];
    new_col_left = [];
    for i = 1:num_of_corners_left
        if((row_left(i) > neighbor_size) && (col_left(i) > neighbor_size) && (row_left(i) < left_height-neighbor_size-1) && (col_left(i) < left_width-neighbor_size-1))
            new_row_left = [new_row_left; row_left(i)];
            new_col_left = [new_col_left; col_left(i)];
        end
    end
    row_left = new_row_left;
    col_left = new_col_left;

    new_row_right = [];
    new_col_right = [];
    for i = 1:num_of_corners_right
        if((row_right(i) > neighbor_size) && (col_right(i) > neighbor_size) && (row_right(i) < right_height-neighbor_size-1) && (col_right(i) < right_width-neighbor_size-1))
            new_row_right = [new_row_right; row_right(i)];
            new_col_right = [new_col_right; col_right(i)];
        end
    end
    row_right = new_row_right;
    col_right = new_col_right;
    [number_of_corners_left, tmp] = size(row_left);
    [number_of_corners_right, tmp] = size(row_right);

    descriptor_left = zeros(number_of_corners_left, (2*neighbor_size+1)^2);
    descriptor_right = zeros(number_of_corners_right, (2*neighbor_size+1)^2);

    for i = 1:number_of_corners_left
        descriptor_left(i,:) = reshape(input_left(row_left(i)-neighbor_size:row_left(i)+neighbor_size, col_left(i)-neighbor_size:col_left(i)+neighbor_size), 1, (2*neighbor_size+1)^2);
        %descriptor_left(i,:) = zscore(descriptor_left(i,:));
    end
    
    for i = 1:number_of_corners_right
        descriptor_right(i,:) = reshape(input_right(row_right(i)-neighbor_size:row_right(i)+neighbor_size, col_right(i)-neighbor_size:col_right(i)+neighbor_size), 1, (2*neighbor_size+1)^2);
        %descriptor_right(i,:) = zscore(descriptor_right(i,:));
    end

    distance = zeros(number_of_corners_left, number_of_corners_right);

    for i = 1:number_of_corners_left
        for j = 1:number_of_corners_right
            distance(i, j) = dist2(descriptor_left(i, :), descriptor_right(j, :));
            %distance(i, j) = normalized_corr(descriptor_left(i, :), descriptor_right(j, :));
        end
    end
end