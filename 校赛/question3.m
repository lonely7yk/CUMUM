clc,clear
in = 0;						% 开始时间
out = 872;					% 结束时间
t = 0;						% 当前时间
sNum = 0;					% 单车数量
carNum = 0;					% 总车数
recordNum = 0;				% 记录数
stage = 1;					% 表示第几阶段
stair = [120 600 720 872];	% 四个阶段的结束时间
interval = [4.0 9.0 4.0 4.5];	% 发车间隔
dis = [80 70 80 75];		% 单程时间
T = [];					% 动态记录 1列:发车时间 2列:结束时间 3列:单双 4列:编号 5列:次数 6列:上午班次 7列:下午班次
T2 = [];				% 静态记录

hasInit = false;
a = 1;
	
while (true) 
	if stage >= 5	% 终止条件，stage只有 4 个阶段
		break;
    end
    
	% 如果有单车，先把单车安排掉
	if hasInit == false
		if t <= stair(1)
			if sNum <= 20
				for i = 1:sNum
					hasInit = true;
					carNum = carNum + 1;
					T(i,:) = [t calcOver(t) 1 i 1 1 0];
					recordNum = recordNum + 1;
					T2(recordNum,:) = T(i,:);
					t = t + interval(stage);
					if (t >= stair(stage))
						stage = stage + 1; % 如果 t 大于当前阶段的临界值，则阶段 + 1
					end
				end
			end
		end
	end

	current_record = [t calcOver(t)];
	hasAdd = false;	% 表示是否用单车添加了记录
	% 这段时间发车都会遇到晚高峰，因此优先让单车来开
	if t >= stair(2)-dis(2) & t < stair(3) | t < stair(1)
		for i = 1:size(T,1)	
			if a <= sNum
				if current_record(1) >= T(i,2) & T(i,5) < carLimit(1) & T(i,3) == 2
					hasAdd = true;
					if isMorning(t)	% 如果是上午，就加上午的班次
						T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6)+1 T(i,7)];
						recordNum = recordNum + 1;	
						T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
					else 	% 如果是下午，就加下午的班次
						T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6) T(i,7)+1];
						recordNum = recordNum + 1;
						T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
					end
				end
				a = a + 1;
				break;
			end
			if current_record(1) >= T(i,2) & T(i,5) < carLimit(1) & T(i,3) == 1
				hasAdd = true;
				if isMorning(t)	% 如果是上午，就加上午的班次
					T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6)+1 T(i,7)];
					recordNum = recordNum + 1;	
					T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
				else 	% 如果是下午，就加下午的班次
					T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6) T(i,7)+1];
					recordNum = recordNum + 1;
					T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
				end
				break;
			end
		end
	end

	% 如果已经添加过记录，则跳过这次循环
	if hasAdd == true
		t = t + interval(stage);
		if (t >= stair(stage))
			stage = stage + 1; % 如果 t 大于当前阶段的临界值，则阶段 + 1
		end
		continue;
	end

	isNeedCar = true;	% 先假设需要加车
	% hasAdd = false;		% 表示是否已经添加记录
	minCha = 6;
	maxCha = -10;
	temp = 0;
	for i = 1:size(T,1)
		if current_record(1) >= T(i,2) & T(i,5) < carLimit(T(i,3)) & T(i,3) == 2
			isNeedCar = false;
			% 如果是上午，找最小差值，将记录更新在最小差值的记录上
			if isMorning(t)
				Cha = T(i,6)+1 - T(i,7);
				if minCha >= Cha
					minCha = Cha;
					temp = i;
				end
			% 如果是下午，找最大差值，将记录更新在最大差值的记录上
			else
				Cha = T(i,6) - T(i,7)-1;
				if maxCha <= Cha
					maxCha = Cha;
					temp = i;
				end
			end
			
			% % 如果在下午，确保先加下午班次小于上午的
			% if ~isMorning(t)
			% 	if T(i,6) > T(i,7)
			% 		temp = i;
			% 	end
			% end
		end
	end
	
	% 如果没有车可以利用，则添加一条动态记录，并把这条记录调价到静态记录中
	if isNeedCar 
         
		carNum = carNum + 1;
		if isMorning(t)
			T(carNum,:) = [t calcOver(t) 2 carNum 1 1 0];
			recordNum = recordNum + 1;	
			T2(recordNum,:) = T(carNum,:);	% 将新生成的动态记录放入静态记录中
		else
			T(carNum,:) = [t calcOver(t) 2 carNum 1 0 1];
			recordNum = recordNum + 1;	
			T2(recordNum,:) = T(carNum,:);	% 将新生成的动态记录放入静态记录中
		end
    else
		for i = 1:size(T,1)	% 遍历已有的动态记录
			% 如果当前时刻能在动态记录中找到大于结束时刻的记录，且班次未到极限
			% 表明有车可以利用，则更新这条记录，并把这条记录添加到静态记录中
			if current_record(1) >= T(i,2) & T(i,5) < carLimit(T(i,3)) & i == temp & T(i,3) == 2
				% 如果已经添加过了则看当前数据的上下午差的绝对值是否比添加的记录的小
				% 如果小则更新记录
				
				if isMorning(t)	% 如果是上午，就加上午的班次
					T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6)+1 T(i,7)];
					recordNum = recordNum + 1;	
					T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
				else 	% 如果是下午，就加下午的班次
					T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6) T(i,7)+1];
					recordNum = recordNum + 1;
					T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
				end
				break;
			end
		end
		
	end

	% fprintf('1\n');
	t = t + interval(stage);	% 每次加一个时间间隔
	if (t >= stair(stage))
		stage = stage + 1; % 如果 t 大于当前阶段的临界值，则阶段 + 1
	end
end

carNum
