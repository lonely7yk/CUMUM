clc,clear;
close all;

%% ******************************** 导入数据 *********************************
% 1. red1 : 第一组红葡萄酒品尝评分，元胞，每个元胞表示某个样本标号对应的数据矩阵
% 2. red2 : 第二组红葡萄酒品尝评分
% 3. white1 : 第一组白葡萄酒品尝评分
% 4. white2 : 第二组白葡萄酒品尝评分
load data1

%% ******************************** 数据初始化 *********************************
n1 = 10;			% 第一组样本数量
n2 = 10;			% 第二组样本数量
talp = 2.1009;		% talp/2(n1 + n2 - 2)
sw = @(s1,s2) sqrt(((n1 - 1) * s1.^2 + (n2 - 1) * s2.^2) / (n1 + n2 - 2));
t1 = @(xmean,ymean,s1,s2) abs(xmean - ymean) ./ (sw(s1,s2) * sqrt(1 / n1 + 1 / n2));	% T1 统计值
t2 = @(xmean,ymean,s1,s2) abs(xmean - ymean) ./ (s1.^2 ./ n1 + s2.^2 ./ n2);	% T2 统计值

%% ******************************** 计算红酒和白酒在两组实验中的平均值和方差 *********************************
red1_miu = zeros(27,1);		% 第一组红酒均值
red1_s = zeros(27,1);		% 第一组红酒方差
red2_miu = zeros(27,1);		% 第二组红酒均值
red2_s = zeros(27,1);		% 第二组红酒方差
for i = 1:27	
	temp1 = sum(red1{i},1);

	red1_miu(i) = mean(temp1);
	red1_s(i) = std(temp1);

	temp2 = sum(red2{i},1);

	red2_miu(i) = mean(temp2);
	red2_s(i) = std(temp2);
end

white1_miu = zeros(28,1);	% 第一组白酒均值
white1_s = zeros(28,1);		% 第一组白酒方差
white2_miu = zeros(28,1);	% 第二组白酒均值
white2_s = zeros(28,1);		% 第二组白酒方差
for i = 1:28	
	temp1 = sum(white1{i},1);

	white1_miu(i) = mean(temp1);
	white1_s(i) = std(temp1);

	temp2 = sum(white2{i},1);

	white2_miu(i) = mean(temp2);
	white2_s(i) = std(temp2);
end

%% ******************************** F 检验（判断总体方差是否一致） *********************************
x = (red1_s ./ red2_s).^2;
y = (white1_s ./ white2_s).^2;		% 统计量

is_red = x > 1 / 4.03 & x < 4.03;
is_white = y > 1 / 4.03 & y < 4.03;

%% ******************************** T1 检验 *********************************
red_judge = zeros(27,1);	% 判断是否没有显著性差异，1 是没有，2 是有
red_t = zeros(27,1);		% 红酒的统计量
red_tinv = zeros(27,1);		% 记录上分位点（边界）
for i = 1:27
    % i
	% 根据方差是否一致来判断用哪种 T 检验
	if is_red(i)
		red_t(i) = t1(red1_miu(i),red2_miu(i),red1_s(i),red2_s(i));
        red_tinv(i) = tinv(0.975,18);
		if red_t(i) < tinv(0.975,18)
			red_judge(i) = 1;
		else
			red_judge(i) = 0;
		end
	else
		red_t(i) = t2(red1_miu(i),red2_miu(i),red1_s(i),red2_s(i));
		% 自由度
		v = (red1_s(i).^2 ./ n1 + red2_s(i).^2 ./ n2).^2 / ((red1_s(i).^2 ./ n1).^2 ./ (n1 - 1) + (red2_s(i).^2 ./ n2).^2 ./ (n2 - 1));
		red_tinv(i) = tinv(0.975,v);
        if red_t(i) < tinv(0.975,v)
			red_judge(i) = 1;
		else
			red_judge(i) = 0;
		end
    end
    
	
end

white_judge = zeros(28,1);	% 判断是否没有显著性差异，1 是没有，2 是有
white_t = zeros(28,1);		% 红酒的统计量
white_tinv = zeros(28,1);	% 记录上分位点（边界）
for i = 1:28
	% 根据方差是否一致来判断用哪种 T 检验
	if is_white(i)
		white_t(i) = t1(white1_miu(i),white2_miu(i),white1_s(i),white2_s(i));
        white_tinv(i) = tinv(0.975,18);
		if white_t(i) < tinv(0.975,18)
			white_judge(i) = 1;
		else
			white_judge(i) = 0;
		end
	else
		white_t(i) = t2(white1_miu(i),white2_miu(i),white1_s(i),white2_s(i));
		% 自由度
		v = (white1_s(i).^2 ./ n1 + white2_s(i).^2 ./ n2).^2 / ((white1_s(i).^2 ./ n1).^2 ./ (n1 - 1) + (white2_s(i).^2 ./ n2).^2 ./ (n2 - 1));
        white_tinv(i) = tinv(0.975,v);
        if white_t(i) < tinv(0.975,v)
			white_judge(i) = 1;
		else
			white_judge(i) = 0;
		end
	end
end

count1 = sum(red1_s > red2_s);	% 第一组红酒数据比第二组红酒数据方差大的个数
red1_smean = mean(red1_s);		% 第一组红酒方差平均
red2_smean = mean(red2_s);

count2 = sum(white1_s > white2_s);		% 第一组白酒数据比第二组白酒数据方差大的个数
white1_smean = mean(white1_s);	% 第一组白酒方差平均
white2_smean = mean(white2_s);

%% ******************************** 第二组每个样本所有指标的平均值 *********************************
red_target = [];
for i = 1:27
	temp = mean(red2{i},2);
	temp = temp';
	red_target(i,:) = temp;
end

white_target = [];
for i = 1:28
	temp = mean(white2{i},2);
	temp = temp';
	white_target(i,:) = temp;
end

save target red_target white_target
save miu red2_miu white2_miu