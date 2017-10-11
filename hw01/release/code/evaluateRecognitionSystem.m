function [conf] = evaluateRecognitionSystem()
% Evaluates the recognition system for all test-images and returns the confusion matrix

	load('vision.mat');
	load('../data/traintest.mat');

	% TODO Implement your code here
    % initialize the confusion matrix
    confusion_mat = zeros(length(mapping));
    
    test_images_length = size(test_imagenames);
    for i = 1:test_images_length
        test_file_path = ['../data/', test_imagenames{i, 1}];
        
        guess_name = find(strcmp(guessImage(test_file_path), mapping));
        
        confusion_mat(test_labels(i), guess_name) = confusion_mat(test_labels(i), guess_name) + 1;
    end
    
    disp(confusion_mat);
    accuracy = trace(confusion_mat) / sum(confusion_mat(:));
    %a = ['accuracy: %d', 100*accuracy];
    sprintf('accuracy : ');
    disp(100*accuracy);
end