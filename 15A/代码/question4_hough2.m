%--------------------------------------------------------------------------
%             question4_hough.m
%             通过霍夫变换找到影子端点坐标
%--------------------------------------------------------------------------

clc,clear
close all
tic

basePoint = [3,24];
num_Pic = 2346;

for i = 1:num_Pic
    I = imread(strcat('/Users/shengliyi/Documents/MATLAB/比赛Matlab/15A/videoPicture/',num2str(i),'.jpg')); %读取图像
    I = imrotate(I,2.5);
    BW = im2bw(I,0.82);		% 二值化
    up1 = 302;
    up2 = 315;
    end1 = 50;
    end2 = 80;
    BW = BW(up1:end-end1,up2:end-end2);
    BW = edge(double(BW),'canny');
    BW = imdilate(BW,ones(3));

    %% ******************************** 霍夫变换 *********************************
    [H,T,R] = hough(BW,'RhoResolution',0.5,'ThetaResolution',0.5);

    %% ******************************** 标出极值点 *********************************
    P = houghpeaks(H,10,'threshold',ceil(0.5*max(H(:)))); % 从霍夫变换矩阵H中提取10个极值点，大于 0.3 * maxH 会被认为是峰值

    %% ******************************** 提取直线 *********************************
    lines = houghlines(BW,T,R,P,'FillGap',15,'MinLength',120);

    point = [];
    for j = 1:length(lines)
        point(j,:) = lines(j).point2;
    end

    [~,index] = sort(point(:,1),'descend');
    result(i,:) = point(index(1),:);
end

% dis = pdist2(basePoint,result);
% b = polyfit(1:num_Pic,dis,2);
% y = polyval(b,0:num_Pic);
% plot(0:num_Pic,y)

x0 = result(:,1) - basePoint(1);
y0 = (result(:,2) - basePoint(2)) ./ sind(40.52);
b1 = polyfit(1:num_Pic,x0',2);
b2 = polyfit(1:num_Pic,y0',2);

%% 误差分析
x1 = polyval(b1,1:num_Pic);
x_delta = (x1 - x0) ./ x0;
y1 = polyval(b2,1:num_Pic);
y_delta = (y1 - y0) ./ y0;

%% 数据准备
x2 = polyval(b1,1:60:num_Pic);
y2 = polyval(b2,1:60:num_Pic);
shadowLength0 = sqrt(x2.^2 + y2.^2);
shadowAngle0 = atand(y2 ./ x2);
diffShadowAngle0 = abs(diff(shadowAngle0));

toc