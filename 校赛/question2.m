clc,clear
stair = [120 600 720 870]
interval = 4;
distance = 80;
start = 0;
T = [0, 0 + distance, false];
for i = 0+interval:interval:120-interval
	over = i + distance;
	for j = 1:size(T,1)
		if over <= T(j,2)