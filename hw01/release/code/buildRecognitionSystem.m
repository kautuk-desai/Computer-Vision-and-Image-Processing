function buildRecognitionSystem()
% Creates vision.mat. Generates training features for all of the training images.

	load('dictionary.mat');
	load('../data/traintest.mat');

	% TODO create train_features
    num_of_spatial_pyramid_layers = 3;
    train_images_length = size(train_imagenames);
    for i = 1:train_images_length
        % load the word map of each training image
        image_wordmap = strrep(['../data/', train_imagenames{i, 1}], '.jpg', '.mat');
        load(image_wordmap);
    
        train_features(:, i) = getImageFeaturesSPM(num_of_spatial_pyramid_layers, wordMap, size(dictionary, 2));
    end
    
	save('vision.mat', 'filterBank', 'dictionary', 'train_features', 'train_labels');

end