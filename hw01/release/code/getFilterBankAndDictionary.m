function [filterBank, dictionary] = getFilterBankAndDictionary(imPaths)
% Creates the filterBank and dictionary of visual words by clustering using kmeans.

% Inputs:
%   imPaths: Cell array of strings containing the full path to an image (or relative path wrt the working directory.
% Outputs:
%   filterBank: N filters created using createFilterBank()
%   dictionary: a dictionary of visual words from the filter responses using k-means.

filterBank  = createFilterBank();

% TODO Implement your code here

% Number of chosen pixels for filter responces per layer
alpha = 150;

% Initialize the output matrix
all_responses = zeros(length(imPaths), length(filterBank) * 3);
total_images = length(imPaths);

%% Read the images and apply filters
for i = 1:total_images
    %  read the image
    img = imread(imPaths{i});
    
    % Calculate filter responces for the current image
    current_responses = extractFilterResponses(img, filterBank);
    fprintf('extracted filter responses %d of %d\n', i, total_images);
    
    indices = randperm(size(current_responses, 1), alpha);
    all_responses((i*alpha-alpha+1):(i*alpha), :) = current_responses(indices, :);
end

% Perform K-Means
K = 150;
[~, dictionary] = kmeans(all_responses, K, 'EmptyAction', 'drop');

% the below code is used to evaluate the optimum number of clusters
% va = evalclusters(meas,clust,'CalinskiHarabasz');
% fprintf('optimal clusters %d',va);

dictionary = dictionary';

end
