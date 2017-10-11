function[img] = LoG_filter(image, scale_k)

sigma = 2; % with sigma = 2, the filtered image is of only black pixels
% 0.5 is default

% to avoid shifting artifact, keep the filter size as odd

if nargin < 2 % for image downsample implementation
    filter_size = 2*ceil(sigma) + 1;
    h = sigma^2 * fspecial('log', filter_size, sigma);
else % for increase filter size implementation
    
end


end