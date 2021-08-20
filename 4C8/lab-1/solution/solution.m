%clear and reset workspace
clear; clear global; close all;

% 1
I = imread("jfk.png");
pic = I; figure; image(I);  colormap(gray(256)); axis image; title('jfk.png - original', 'FontSize', 8);
pic = rgb2gray(pic); figure; imshow(pic); title('jfk.png - grayscale', 'FontSize', 8);

figure(3); imshow(pic+128); title('jfk.png - added 128 pixels', 'FontSize', 8);
newpic = pic-128; figure; imshow(newpic); title('jfk.png - subtracted 128 pixels', 'FontSize', 8);

% 2
pic = imread('jfk.png'); figure; image(pic);
pic = rgb2gray(pic); figure; imshow(pic); title('jfk.png - gray', 'FontSize', 8)

figure; histogram(pic, 256); title('histogram of jfk.png - gray', 'FontSize', 8)

% 3.1
pic = imread('tennis.png'); figure; image(pic);
r = pic(:,:,1); figure; imshow(r); title('tennis.png - R', 'FontSize', 8)
figure; histogram(r, 256); title('histogram of tennis.png - R', 'FontSize', 8)

g = pic(:,:,2); figure; imshow(g); title('tennis.png - G', 'FontSize', 8)
figure; histogram(g, 256); title('histogram of tennis.png - G', 'FontSize', 8)

b = pic(:,:,3); figure; imshow(b); title('tennis.png - B', 'FontSize', 8)
figure; histogram(b, 256); title('histogram of tennis.png - B', 'FontSize', 8)

% 3.2
pic = imread('tennis.png'); figure; image(pic);
pic = rgb2ycbcr(pic);
y = pic(:,:,1); figure; imshow(pic); title('tennis.png - YCbCr', 'FontSize', 8)
figure(2); histogram(y, 256); title('histogram of tennis.png - Y', 'FontSize', 8)

cb = pic(:,:,2); figure; imshow(cb); title('tennis.png - Cb', 'FontSize', 8)
figure; histogram(cb, 256); title('histogram of tennis.png - Cb', 'FontSize', 8)

cr = pic(:,:,3); figure; imshow(cr); title('tennis.png - Cr', 'FontSize', 8)
figure; histogram(cr, 256); title('histogram of tennis.png - Cr', 'FontSize', 8)

% 4.1
pic = imread('tennis.png');

r = pic(:,:,1);
g = pic(:,:,2);
b = pic(:,:,3);
mask = (r > 20 & r < 64) & (b > 120 & b < 180) & (g > 60 & g < 130);

figure;imshow(g > 60 & g < 130); title('tennis.png - Green', 'FontSize', 8)
figure;imshow(mask); title('tennis.png - RGB Segmentation', 'FontSize', 8)