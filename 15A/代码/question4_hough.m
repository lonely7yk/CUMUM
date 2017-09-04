%--------------------------------------------------------------------------
%             question4_hough.m
%             ./霍夫变换
%--------------------------------------------------------------------------

clc,clear
close all
tic

basePoint = [1,19];
num_Pic = 2346;

for i = 1:num_Pic

	I = imread(strcat('/Users/shengliyi/Documents/MATLAB/比赛Matlab/15A/videoPicture/',num2str(i),'.jpg')); %读取图像
	BW = im2bw(I,0.79);		% 二值化
	up1 = 290;		
	up2 = 305;
	BW = BW(up1:end,up2:end);		% 框定范围
	BW = edge(double(BW),'canny');	% 边界图
	BW = imdilate(BW,ones(3));		% 膨胀
		
	%% ******************************** 霍夫变换 *********************************
	[H,T,R] = hough(BW,'RhoResolution',0.5,'ThetaResolution',0.5);
	
	%% ******************************** 标出极值点 *********************************
	P = houghpeaks(H,10,'threshold',ceil(0.5*max(H(:)))); % 从霍夫变换矩阵H中提取10个极值点，大于 0.3 * maxH 会被认为是峰值
	
	%% ******************************** 提取直线 *********************************
	lines = houghlines(BW,T,R,P,'FillGap',100,'MinLength',130);

	point = [];
	for j = 1:length(lines)
		point(j,:) = lines(j).point2;
	end

	[~,index] = sort(point(:,1),'descend');
	result(i,:) = point(index(1),:);
end

dis = pdist2(basePoint,result);
b = polyfit(1:num_Pic,dis,2);
y = polyval(b,0:num_Pic);
plot(0:num_Pic,y)

toc