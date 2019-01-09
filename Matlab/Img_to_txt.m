clear all;
im1= imread('../lena_std.tif');
%im1= imread('../jt.bmp');
[n, m, d] = size(im1);
fid1 = fopen('../figureRGB','w');
for y=1:n
    for x=1:m
        fprintf(fid1,'%02x%02x%02x\n', im1(y,x,1), im1(y,x,2), im1(y,x,3));
    end 
end 
fclose(fid1);
figure, imshow(im1);
