clc,clear
close all
tic

[file,path] = uigetfile('/Users/shengliyi/Documents/MATLAB/比赛Matlab/15A/videoPicture/1.jpg','选择一幅图片');
rgb = imread(fullfile(path,file));
I = rgb2gray(rgb);
level = graythresh(I);
BW = im2bw(I,0.9);
BW = ~BW;

% 长度和角度的计算 最小外接矩形来计算

[L,n] = bwlabel(BW,8);
boxes = imOrientedBox(L);
imshow(~BW),title('长度数值（单位-像素）')
hold on
for i = 1:n 
    text(boxes(i,1)+10,boxes(i,2)+10,num2str(boxes(i,3)),'color','r');
end
hold off

figure,imshow(~BW),title('角度数值（单位-度）') 
hold on
for i = 1:n 
    text(boxes(i,1)+10,boxes(i,2)+10,num2str(180-boxes(i,5)*180/pi),'color','b');
end
hold off


toc