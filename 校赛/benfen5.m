clc,clear
in = 0;						% 开始时间
out = 1065;					% 结束时间
t = 0;						% 当前时间
sNum = 22;					% 单车数量
carNum = 0;					% 总车数
recordNum = 0;				% 记录数
stage = 1;					% 表示第几阶段
stair = [30 90 210 690 810 1067];	% 四个阶段的结束时间
interval = [7.0 4.5 3.0 4.5 3.0 6.5];	% 发车间隔
dis = [70 70 75 75 75 70];		% 单程时间
T = [];					% 动态记录 1列:发车时间 2列:结束时间 3列:单双 4列:编号 5列:次数 6列:上午班次 7列:下午班次
T2 = [];				% 静态记录

hasInit = false;
change = false;	% 是否有换班

while (true) 
	if stage >= 7	% 终止条件，stage只有 6 个阶段
		break;
    end

	current_record = [t calcStop2(t)];
	% 是否用单班车添加
	hasAdd = false;
	% 这段时间发车都会遇到晚高峰，因此如果有单车优先让单车来开
	if (t >= stair(4)-dis(4) & t < stair(5) || t >= stair(2) & t < stair(3)) 
		for i = 1:size(T,1)	
			if current_record(1) >= T(i,2) & T(i,5) < carLimit(1) & T(i,3) == 1
				hasAdd = true;
				if isMorning(t)	% 如果是上午，就加上午的班次
					T(i,:) = [t calcStop1(t) T(i,3) T(i,4) T(i,5)+1 T(i,6)+1 T(i,7)];
					recordNum = recordNum + 1;	
					T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
				else 	% 如果是下午，就加下午的班次
					T(i,:) = [t calcStop1(t) T(i,3) T(i,4) T(i,5)+1 T(i,6) T(i,7)+1];
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
	maxNum = -1;
	temp = 0;
	DAN = false;
	SHUANG = false;
    
    if t == 435.5
        fprintf('1\n');
    end
    
	for i = 1:size(T,1)
		if current_record(1) >= T(i,2) & T(i,5) < carLimit(T(i,3))
			isNeedCar = false;
			if maxNum < carLimit(T(i,3)) - T(i,5)
				maxNum = carLimit(T(i,3)) - T(i,5);
				temp = i;
			end
			% 如果是高峰时段，且有单车，则优先用单车
			if (t >= stair(4)-dis(4) & t < stair(5) || t >= stair(2) & t < stair(3)) & T(i,3) == 1
				% temp = i;
				DAN = true;
				break;
			% 如果是平峰时段，且有双车，则优先用双车
			elseif ~(t >= stair(4) & t < stair(5) || t >= stair(2) & t < stair(3)) & T(i,3) == 2
				% temp = i;
				SHUANG = true;
				break;
			end
		end
	end

	if DAN
		maxDan = -1;
		for i = 1:size(T,1)
			if current_record(1) >= T(i,2) & T(i,5) < carLimit(T(i,3))
	
				if (t >= stair(4)-dis(4) & t < stair(5) || t >= stair(2) & t < stair(3)) & T(i,3) == 1
					if maxDan < carLimit(T(i,3)) - T(i,5)
						maxDan = carLimit(T(i,3)) - T(i,5);
						temp = i;
					end
				end
			end
		end
    end

	if SHUANG
		maxSHUANG = -1;
		for i = 1:size(T,1)
			if current_record(1) >= T(i,2) & T(i,5) < carLimit(T(i,3))

				if ~(t >= stair(4)-dis(4) & t < stair(5) || t >= stair(2) & t < stair(3)) & T(i,3) == 2
					if maxSHUANG < carLimit(T(i,3)) - T(i,5)
						maxSHUANG = carLimit(T(i,3)) - T(i,5);
						temp = i;
					end
				end
			end
		end
	end

	% % isNeedCar = true;	% 先假设需要加车
	% for i = 1:size(T,1)	% 遍历已有的动态记录
	% % 如果当前时刻能在动态记录中找到大于结束时刻的记录，且班次未到极限
	% % 表明有车可以利用，则更新这条记录，并把这条记录添加到静态记录中
 %        if current_record(1) >= T(i,2) & T(i,5) < carLimit(T(i,3)) & T(i,3) == 2
	% 		% 如果已经添加过了则看当前数据的上下午差的绝对值是否比添加的记录的小
	% 		% 如果小则更新记录
	% 		isNeedCar = false;
	% 		if isChange(T(i,6)+1)	% 如果是加上这次换班，则结束时间 +20
	% 			change = true;
	% 			T(i,:) = [t calcStop2(t)+20 T(i,3) T(i,4) T(i,5)+1 T(i,6)+1 T(i,7)];
	% 			recordNum = recordNum + 1;	
	% 			T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
	% 		elseif isChange(T(i,6))	% 如果已经换班
	% 			T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6) T(i,7)+1];
	% 			recordNum = recordNum + 1;
	% 			T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
 %            else    % 如果不换班
 %                T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6)+1 T(i,7)];
	% 			recordNum = recordNum + 1;
	% 			T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
	% 		end
	% 		break;
	% 	end
	% 	if current_record(1) >= T(i,2) & T(i,5) < 3 & T(i,3) == 1
	% 		% 如果已经添加过了则看当前数据的上下午差的绝对值是否比添加的记录的小
	% 		% 如果小则更新记录
	% 		isNeedCar = false;
	% 		T(i,:) = [t calcStop1(t) T(i,3) T(i,4) T(i,5)+1 T(i,6) T(i,7)+1];
	% 		recordNum = recordNum + 1;
	% 		T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
	% 		break;
	% 	end
		
	% end

	% 如果没有车可以利用，则添加一条动态记录，并把这条记录调价到静态记录中
	if isNeedCar 
        if length(T) == 0
            carNum = carNum + 1;
			T(carNum,:) = [t calcStop2(t) 2 carNum 1 1 0];
			recordNum = recordNum + 1;	
			T2(recordNum,:) = T(carNum,:);	% 将新生成的动态记录放入静态记录中
        else
        	if (t >= stair(2)+18 && t <= stair(3) || t >= stair(4) && t <= stair(5))
        		carNum = carNum + 1;
        		T(carNum,:) = [t calcStop1(t) 1 carNum 1 1 0];
      			recordNum = recordNum + 1;	
				T2(recordNum,:) = T(carNum,:);	% 将新生成的动态记录放入静态记录中
        	else
				carNum = carNum + 1;
				T(carNum,:) = [t calcStop2(t) 2 carNum 1 1 0];
				recordNum = recordNum + 1;	
				T2(recordNum,:) = T(carNum,:);	% 将新生成的动态记录放入静态记录中
        	end
        end
		% if isMorning(t)
		% 	T(carNum,:) = [t calcStop2(t) 2 carNum 1 1 0];
		% 	recordNum = recordNum + 1;	
		% 	T2(recordNum,:) = T(carNum,:);	% 将新生成的动态记录放入静态记录中
		% else
		% 	T(carNum,:) = [t calcStop2(t) 2 carNum 1 0 1];
		% 	recordNum = recordNum + 1;	
		% 	T2(recordNum,:) = T(carNum,:);	% 将新生成的动态记录放入静态记录中
		% end
	else
		for i = 1:size(T,1)	% 遍历已有的动态记录
	% 如果当前时刻能在动态记录中找到大于结束时刻的记录，且班次未到极限
	% 表明有车可以利用，则更新这条记录，并把这条记录添加到静态记录中
        	if current_record(1) >= T(i,2) & T(i,5) < carLimit(T(i,3)) & i == temp
				% 如果已经添加过了则看当前数据的上下午差的绝对值是否比添加的记录的小
				% 如果小则更新记录
				isNeedCar = false;
				if isChange(T(i,6)+1)	% 如果是加上这次换班，则结束时间 +20
					change = true;
					T(i,:) = [t calcStop2(t)+20 T(i,3) T(i,4) T(i,5)+1 T(i,6)+1 T(i,7)];
					recordNum = recordNum + 1;	
					T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
				elseif isChange(T(i,6))	% 如果已经换班
					T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6) T(i,7)+1];
					recordNum = recordNum + 1;
					T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
        	    else    % 如果不换班
        	        T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6)+1 T(i,7)];
					recordNum = recordNum + 1;
					T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
				end
				break;
			end
			if current_record(1) >= T(i,2) & T(i,5) < 3 & i == temp
				% 如果已经添加过了则看当前数据的上下午差的绝对值是否比添加的记录的小
				% 如果小则更新记录
				isNeedCar = false;
				T(i,:) = [t calcStop1(t) T(i,3) T(i,4) T(i,5)+1 T(i,6) T(i,7)+1];
				recordNum = recordNum + 1;
				T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
				break;
			end
		end
	end

	% else
	% 	for i = 1:size(T,1)	% 遍历已有的动态记录
	% 	% 如果当前时刻能在动态记录中找到大于结束时刻的记录，且班次未到极限
	% 	% 表明有车可以利用，则更新这条记录，并把这条记录添加到静态记录中
	% 		if current_record(1) >= T(i,2) & T(i,5) < carLimit(T(i,3)) & i == temp & T(i,3) == 2
	% 			% 如果已经添加过了则看当前数据的上下午差的绝对值是否比添加的记录的小
	% 			% 如果小则更新记录
				
	% 			if isMorning(t)	% 如果是上午，就加上午的班次
	% 				T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6)+1 T(i,7)];
	% 				recordNum = recordNum + 1;	
	% 				T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
	% 			else 	% 如果是下午，就加下午的班次
	% 				T(i,:) = [current_record T(i,3) T(i,4) T(i,5)+1 T(i,6) T(i,7)+1];
	% 				recordNum = recordNum + 1;
	% 				T2(recordNum,:) = T(i,:);	% 将新生成的动态记录放入静态记录中
	% 			end
	% 			break;
	% 		end
	% 	end
		

	% fprintf('1\n');
	t = t + interval(stage);	% 每次加一个时间间隔
	if (t >= stair(stage))
		stage = stage + 1; % 如果 t 大于当前阶段的临界值，则阶段 + 1
	end
end

carNum