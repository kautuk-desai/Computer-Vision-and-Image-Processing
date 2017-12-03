%% read train images
train_img_fp = fopen('./data/train-images.idx3-ubyte','r','b');
magic_number = fread(train_img_fp, 1, 'int32');
num_of_train_imgs = fread(train_img_fp, 1, 'int32');
img_rows = fread(train_img_fp, 1, 'int32');
img_cols = fread(train_img_fp, 1, 'int32');

fseek(train_img_fp, 16, 'bof');
image = fread(train_img_fp, inf, 'uchar');
imgs = reshape(image, 28,28, num_of_train_imgs);

train_images = permute(imgs,[2 1 3]);
train_images = double(train_images) / 255;
x_train_images = cell(1,num_of_train_imgs);
for i = 1:num_of_train_imgs
    x_train_images{i} = train_images(:,:,i);
end

fclose(train_img_fp);

%% read labels
train_labels_fp = fopen('./data/train-labels.idx1-ubyte','r','b');
magic_number = fread(train_labels_fp, 1, 'int32');
num_of_train_labels = fread(train_labels_fp, 1, 'int32');

train_labels = fread(train_labels_fp, inf, 'uchar');

fclose(train_labels_fp);

num_classes = 10;
y_one_hot = zeros( num_classes, num_of_train_labels);

% assuming class labels start from one
for i = 0:num_classes
    rows = train_labels == i;
    rows = rows';
    y_one_hot( i+1, rows ) = 1;
end

enocded_train_labels = y_one_hot;


AutoencoderDigitsExample();