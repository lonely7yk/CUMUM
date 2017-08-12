clc,clear
close all
tic
load mindist
clear zhipai

%% ******************************** 初始化 *********************************
fin1 = [0 92 165 319 371 474 582];		% 每一个地区的结尾标号
fin2 = [20 100 182 328 386 485];		% 每一个站点的结尾标号
service_o{1} = [1:20];
service_o{2} = [93:100];
service_o{3} = [166:182];
service_o{4} = [320:328];
service_o{5} = [372:386];
service_o{6} = [475:485];

for i = 1:6
	origin{i} = mindist(fin1(i)+1:fin1(i+1),fin1(i)+1:fin1(i+1));		% 每个区域对应的路口距离
	service{i} = 1:length(service_o{i});						% 每个服务平台对应的索引
	% cases{i} = lcase(fin1(i)+1:fin1(i+1));
end

numTrans = 3;		% 转移个数
numAdd = 1;			% 添加个数
x = 1;				% 使用哪个区域

numChange = numTrans + numAdd;		% 改变个数
indexService = service{x};			% 服务站索引
matOrigin = origin{x};				% 区域矩阵
matCurrent = matOrigin(indexService,:);	% 现在选中服务站的矩阵
numService = length(indexService);	% 服务站个数
numOrigin = length(matOrigin);			% 区域路口个数
cases = lcase(fin1(x)+1:fin1(x+1));	% 各路口案件数

combine = nchoosek(numService+1:numOrigin,numChange);	% 可能组合
for i = 1:length(combine)
	matResult = AddorTrans(matOrigin,matCurrent,numTrans,combine(i,:),cases);
	[~,s,TorF] = Value(matResult,cases);
	if TorF == true
        display('true')
		break;
	end
end

toc
%% AddorTrans: 对现有站台做转移或添加
function [matResult] = AddorTrans(matOrigin,matCurrent,numTrans,addIndex,cases)
	[work,s] = Value(matCurrent,cases);
	sortWork = sort(work);				% 对当前站台工作量排序
	for i = 1:numTrans
        indexMin = find(work == sortWork(i));
		minIndex = indexMin(1);	% 找出工作量最小的前 numTrans 组
        matCurrent(minIndex,:) = [];		% 将找到的组删除
    end
	addRow = matOrigin(addIndex,:);		% 加上添加的组
	matResult = [matCurrent;addRow];
end

%% Value: 当前站台各站台工作量及方差
function [work,s,TorF] = Value(matCurrent,cases)
	TorF = true;
	work = zeros(size(matCurrent,1),1);	
	for i = 1:size(matCurrent,2)
		temp = matCurrent(:,i);		% 第 i 列数据
		if min(temp) > 3			% 如果一列中最小的数据大于三，证明这个路口到任何站点都大于 3
			TorF = false;
		end
		index = find(temp == min(temp));
		work(index) = work(index) + cases(i);
	end
	s = std(work,1);
end
