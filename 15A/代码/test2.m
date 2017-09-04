clc,clear
close all

I = imread('/Users/shengliyi/Documents/MATLAB/比赛Matlab/15A/videoPicture/1.jpg'); %读取图像
I = imrotate(I,2.5);
% BW = rgb2gray(I);
% thresh = [0.01 0.09];

BW = im2bw(I,0.82);		% 二值化

up1 = 302;
up2 = 315;
end1 = 50;
end2 = 80;
BW = BW(up1:end-end1,up2:end-end2);
% BW = rgb2gray(I);		% rgb 转灰色图
% BW = rgb2hsv(I);
% BW = BW(:,:,3);
% Iv2 = rgb2gray(I);
% figure;imshow(Iv1)
% figure;imshow(Iv2)

% sigma = 2;			% 高斯参数
BW = edge(double(BW),'canny');
BW = imdilate(BW,ones(3));
imshow(BW)

%% ******************************** 霍夫变换 *********************************
[H,T,R] = hough(BW,'RhoResolution',0.5,'ThetaResolution',0.5);

%% ******************************** 曲线图 *********************************
figure;
imshow(imadjust(mat2gray(H)),'XData',T,'YData',R,...
   'InitialMagnification','fit');
title('Limited Theta Range Hough Transform of Gantrycrane Image');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal;
colormap(hot)

%% ******************************** 标出极值点 *********************************
P = houghpeaks(H,10,'threshold',ceil(0.5*max(H(:)))); % 从霍夫变换矩阵H中提取10个极值点，大于 0.3 * maxH 会被认为是峰值
x = T(P(:,2));%极值点的theta值，即P的第二列存放的是极值点的theta值
y = R(P(:,1));%极值点的rho值，即P的第二列存放的是极值点的rho值
hold on;plot(x,y,'s','color','red');

%% ******************************** 提取直线 *********************************
lines = houghlines(BW,T,R,P,'FillGap',15,'MinLength',120);

% 绘制提取得到的直线
I2 = I(up1:end-end1,up2:end-end2,:);
figure, imshow(I2), hold on
max_len = 0;
for k = 1:length(lines)
    % 绘制第k条直线
    xy = [lines(k).point1; lines(k).point2];
%     plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    % 绘制第k条直线的起点（黄色）、终点（红色）
%     plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%     plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    % 计算第k条直线的长度，保留最长直线的端点
    len = norm(lines(k).point1 - lines(k).point2);
    if ( len > max_len)
        max_len = len;
        xy_long = xy;
    end
end
title('提取到的直线');

% 以红色线高亮显示最长的线
% plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');

% BW2=double(BW1);
% BW3=edge(BW2,'sobel');

% r_value = 42;
% g_value = 47;
% b_value = 115;
% r = BW(:,:,1);
% g = BW(:,:,2);
% b = BW(:,:,3);
% index_r = (r > r_value - 10 & r < r_value + 10);
% index_g = (g > g_value - 10 & g < g_value + 10);
% index_b = (b > b_value - 10 & b < b_value + 10);
% index = index_r & index_g & index_b;
% [x,y] = find(index == 1);