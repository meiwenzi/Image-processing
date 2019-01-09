clear all;
v_size = 512;
h_size = 512;
a = textread('../figureRGB3','%s');
A=hex2dec(a);
A=abs(A);
im = zeros(v_size, h_size, 3, 'uint8')  ;
for n =1:v_size
   for m = 1:h_size
       for ppc = 1:3
            pos = m*3 - 3 + ppc + n*h_size *3 - h_size*3;
            im(n ,m, ppc) = A(pos) ;
       end 
   end
end 
figure, imshow(im);
%imwrite(im, '../Veirlog/Gray/im.bmp');%灰度化
%imwrite(im, '../Veirlog/Binarization/im.bmp'); %二值化
imwrite(im, '../Veirlog/Sharpen/im.bmp');% 锐化
%imwrite(im, '../Veirlog/image smoothing/im.bmp');