%% read images
train_images = read_images('./data/train-images.idx3-ubyte');
test_images = read_images('./data/t10k-images.idx3-ubyte');

%% read labels
train_labels = read_labels_n_format('./data/train-labels.idx1-ubyte');
test_labels = read_labels_n_format('./data/t10k-labels.idx1-ubyte');

AutoencoderDigitsExample(train_images, train_labels, test_images, test_labels);