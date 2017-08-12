clc,clear
interval = 3;
start = [0:interval:120-interval];	% 发车时间
ending = start + 80;	% 发车时间对应的结束时间
temp = 0:interval:120-80-1;
s = ones(1,size(0:interval:120-80-1,2));	% 单车的数量
d = ones(1,size(temp(end)+1:interval:120-interval,2),1) + 1;	% 双车的数量
car = [s,d]';	% 因为单车要走两到三次，所以发两次车的是单车
T = [start',ending',car];
for i = 1:size(T,1)
	for j = 1:size(T,1)
		if j > size(T,1) || i > size(T,1)
			break;
		end
		if T(i,1) == T(j,2)
			T(i,:) = [];
		end
	end
end
T
carNum = size(T,1);
sNum = size(find(T(:,3) == 1),1);
dNum = carNum - sNum;
fprintf('最少需要车 %d 辆\n%d 辆单班车，%d 辆双班车\n', carNum,sNum,dNum);