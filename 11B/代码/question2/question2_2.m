clc,clear
close all

% 读取数据
% 1. mindist : 最短距离矩阵
% 2. dist : 邻接矩阵
load dist.mat

global result
global count 
count = 1;

a{1} = 1:20;
a{2} = 93:100;
a{3} = 166:182;
a{4} = 320:328;
a{5} = 372:386;
a{6} = 475:485;
b = [];
for i = 1:6
	b = [b,a{i}];
end

stationDist = mindist(b,:);

X{1} = [7     8     9    30    31    32    33    34    35    36    45    46    47    48];
[sortDist,index] = sort(mindist(32,:));
initialIndex = length(X{1}) + 1;
for i = 2:10000
%     X{i-1}
	[Y] = OutPoint(X{i-1},dist);
    X{i} = [X{i-1},index(initialIndex)];
    initialIndex = initialIndex + 1;
	theftDist = mindist(32,Y) - 3;
    
	policeDist = stationDist(:,Y);
%     minTheftDist = min(theftDist);
    
    is = true;
    everyIndex = cell(length(Y),1);
    for j = 1:length(Y)
        everyIndex{j} = find(policeDist(:,j) < theftDist(j));
        if isempty(everyIndex{j})
            is = false;
        end
    end
    if is == true
        array = [];
        FindBunch(everyIndex,array,1,length(Y),Y,mindist,inf);
    end
end



%% OutPoint: 外包的点
function [Y] = OutPoint(X,dist)
	% input
	% X : 某些点，行矩阵
	% output
	% Y : 与 X 相邻却不包含在 X 中的所有点，行矩阵
	Y = [];
	dist(find(dist == inf)) = 0;
	for i = 1:size(X,2)
		rowIndex = X(i);		% 第几行
		temp_y = find(dist(rowIndex,:) > 0);
		Y = [Y,temp_y];
    end
    Y = unique(Y);
    Y = setdiff(Y,X);
end

%% FindBunch: 找到那一串
function FindBunch(everyIndex,array,k,l,Y,mindist,MAX)
    global result
    global count
    
    
    array(k:end) = [];		% 把当前层之后的序列全部=清空
%     if length(array) >= 1
%     	for i = 1:length(array)
%     	    time(i) = mindist(Y(i),array(i));	% 记录站点到路口的所有时间
%     	end
%     	maxTime = max(time);		% 记录当前序列时间最大值
%     	if maxTime > MAX 			% 如果当前序列时间最大值大于上一层时间，则剪枝
%     	    return;
%     	else
%     	    MAX = maxTime;			% 否则更新这一层序列最大时间
%     	end
%     end
    
	if (length(array) == l)			% 如果序列达到要求长度，证明它满足他的最长时间小于之前的最长时间
		result{count} = array;		% 将结果记录下来
        count = count + 1;
		return;
	end

	temp = everyIndex{k};
	for i = 1:length(temp)
		if ~ismember(temp(i),array)
			array(k) = temp(i);
			FindBunch(everyIndex,array,k+1,l,Y,mindist,MAX);
		else
			continue;
		end
	end

end
