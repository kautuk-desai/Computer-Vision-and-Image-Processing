function[img] = difference_of_gaussian_filter(image, sigma)

filter_size = 2*floor(3*sigma) + 1;
gaussian_filter_1 = fspecial('gaussian', filter_size, sigma);

sigma = sigma * 1.6;
gaussian_filter_2 = fspecial('gaussian', filter_size, sigma);

gauss_filtered_img_1 = imfilter(image, gaussian_filter_1, 'replicate', 'same');
gauss_filtered_img_2 = imfilter(image, gaussian_filter_2, 'replicate', 'same');

img = gauss_filtered_img_1 - gauss_filtered_img_2;
end