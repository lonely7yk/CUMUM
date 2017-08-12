clc,clear
load data1
A = excel_chaoliu;
B = [ones(size(excel_chuli,1),1),excel_chuli];

k = B \ A;

for i = 1:6
	y{i} = @(x) sum(repmat(k(2:end,i)',size(x,1),1) .* x,2) + k(1,i);	% 每条线路的表达式，x 每行是一个方案，每列表示一个机组
end

x = excel_chuli;

temp = [];
for i = 1:6
	temp(:,i) = y{i}(x);
end

percent = abs(temp - A) ./ temp;
max_percent = max(percent)