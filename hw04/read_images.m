function images_cell_array = read_images(image_file_path)

image_fp = fopen(image_file_path,'r','b');
magic_number = fread(image_fp, 1, 'int32');
num_of_imgs = fread(image_fp, 1, 'int32');

img_rows = fread(image_fp, 1, 'int32');
img_cols = fread(image_fp, 1, 'int32');

fseek(image_fp, 16, 'bof');
image_data = fread(image_fp, inf, 'uchar');
imgs = reshape(image_data, 28,28, num_of_imgs);

images = permute(imgs,[2 1 3]);
images = double(images) / 255;

images_cell_array = cell(1,num_of_imgs);
for i = 1:num_of_imgs
    images_cell_array{i} = images(:,:,i);
end

fclose(image_fp);
end