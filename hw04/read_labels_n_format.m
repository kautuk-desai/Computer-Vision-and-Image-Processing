function one_hot = read_labels_n_format(file_path)
labels_fp = fopen(file_path,'r','b');
magic_number = fread(labels_fp, 1, 'int32');
num_of_labels = fread(labels_fp, 1, 'int32');

labels = fread(labels_fp, inf, 'uchar');
fclose(labels_fp);

num_classes = 10;
one_hot = zeros( num_classes, num_of_labels);

% assuming class labels start from one and then checking for 0-9
for i = 1:num_classes
    rows = labels == i-1;
    rows = rows';
    one_hot( i, rows ) = 1;
end

end