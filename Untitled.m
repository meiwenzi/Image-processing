I = imread('Park.bmp');
imshow(I);
J = imnoise(I, 'salt & pepper');
figure, imshow(J);
J3 = medfilt2(J);
figure, imshow(J3);
imwrite(J3, 'J3.bmp');
w = [1 2 1;
    2 4 2;
    1 2 1]/16;
J1 = imfilter(J, w, 'corr', 'replicate');
figure, imshow(J1);
imwrite(J1, 'J1.bmp');
w1 = [1 1 1;
    1 1 1;
    1 1 1] / 9;
J2 = imfilter(J, w1, 'corr', 'replicate');
figure, imshow(J2);
imwrite(J2, 'J2.bmp');

    