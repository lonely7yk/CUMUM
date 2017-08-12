clc,clear('all');
close all;

%% ******************************** 红酒 *********************************
for i = 1 : 27
	left = 14 * i - 9;
	right = 14 * i;
	area = strcat(['C',num2str(left),':L',num2str(right)]);
    area2 = strcat(['M',num2str(left - 2)]);
	red_1{i} = xlsread('question1.xlsx',1,area);	% 红1 元胞
	seq_1(i) = xlsread('question1.xlsx',1,area2);	% 红1 序号
	red_2{i} = xlsread('question1.xlsx',3,area);	% 红2 元胞
	seq_2(i) = xlsread('question1.xlsx',3,area2);	% 红2 序号
end

% 按样本序号排序
for i = 1:27
	red1{seq_1(i)} = red_1{i};
	red2{seq_2(i)} = red_2{i};
end

%% ******************************** 白酒 *********************************
% 白酒
for i = 1 : 28
	left = 13 * i - 8;
	right = 13 * i + 1;
	area = strcat(['C',num2str(left),':L',num2str(right)]);
    area2 = strcat(['A',num2str(left - 1)]);
    white_1{i} = xlsread('question1.xlsx',2,area);	% 白1 元胞
	seq_1(i) = xlsread('question1.xlsx',2,area2);	% 白1 序号

	left = 12 * i - 7;
	right = 12 * i + 2;
	area = strcat(['C',num2str(left),':L',num2str(right)]);
    area2 = strcat(['A',num2str(left - 1)]);
	white_2{i} = xlsread('question1.xlsx',4,area);	% 白2 元胞
	seq_2(i) = xlsread('question1.xlsx',4,area2);	% 白2 序号
end

% 按样本序号排序
for i = 1:28
	white1{seq_1(i)} = white_1{i};
	white2{seq_2(i)} = white_2{i};
end

%% ******************************** 保存 *********************************
save data1 red1 red2 white1 white2