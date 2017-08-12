clc,clear('all');
excel_chuli = xlsread('excel_question1',1,'B2:I34');	% 各机组出力(33*8)y
excel_chaoliu = xlsread('excel_question1',2,'B2:G34');	% 各线路的潮流值(33*6)x

machine = {};	% 每个元胞(5*8)表示各个机组控制第 i 个变量后的 5 组数据
thread = {};	% 每个元胞(5*1)表示各条路线控制第 i 个变量后一条线路的 5 组数据

for i = 1:8
	machine{i} = [excel_chuli(1,:);excel_chuli(4*i-2:4*i+1,:)];
	% machine{i} = [excel_chuli(4*i-2:4*i+1,:)];
	for j = 1:6
		thread{i,j} = [excel_chaoliu(1,j);excel_chaoliu(4*i-2:4*i+1,j)];
		% thread{i,j} = [excel_chaoliu(4*i-2:4*i+1,j)];
	end
end


save data1