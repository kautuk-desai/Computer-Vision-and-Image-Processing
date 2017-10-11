function [h] = getImageFeaturesSPM(layerNum, wordMap, dictionarySize)
% Compute histogram of visual words using SPM method
% Inputs:
%   layerNum: Number of layers (L+1)
%   wordMap: WordMap matrix of size (h, w)
%   dictionarySize: the number of visual words, dictionary size
% Output:
%   h: histogram of visual words of size {dictionarySize * (4^layerNum - 1)/3} (l1-normalized, ie. sum(h(:)) == 1)

    % TODO Implement your code here
    C = cell(1,3);
    C{1,3} = [];
    for l = layerNum:-1:1     
        layer_num = l - 1;
        chop_size = 2^layer_num;
        [h,w] = size(wordMap);

        h_remainder = mod(h, chop_size);
        h_split = floor(h/chop_size);

        w_remainder = mod(w, chop_size);
        w_split = floor(w/chop_size);

        h_split_vector = ones(1, chop_size) .* h_split;
        w_split_vector = ones(1, chop_size) .* w_split;

        if h_remainder > 0
            h_split_vector(1) = h_split_vector(1) + h_remainder;
        end
        if w_remainder > 0
            w_split_vector(1) = w_split_vector(1) + w_remainder;
        end

        img_cell = mat2cell(wordMap,h_split_vector,w_split_vector);
        hist = []; % bad method to initialize hist.
        % hint for efficiency
        for i = 1:chop_size
            for j = 1:chop_size
                word_map = img_cell{i,j};
                temp_hist = getImageFeatures(word_map, dictionarySize);
                hist = [hist; temp_hist];
            end
        end
        C{1,l} = hist;
    end
    
    h0 = C{1,l}; % getImageFeatures(wordMap, dictionarySize);
    h1 = C{1,2};
    h2 = C{1,3};
    h = [0.25 .* h0(:); 0.25 .* h1(:); 0.5 .* h2(:)];
    h = h ./ sum(h(:));
    % plot(h);
end