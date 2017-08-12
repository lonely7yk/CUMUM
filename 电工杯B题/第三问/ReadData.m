%% 读取数据
clc,clear
% % 2000 年死亡率
% for i = 1:20
%     temp = xlsread('birth_and_death',2,char(['A',int2str(i)]));
%     death_2000 = [death_2000;temp];
% end
% % 2000 年出生率
% for i = 1:7
%     temp = xlsread('birth_and_death',1,char(['A',int2str(i)]));
%     birth_2000 = [birth_2000;temp];
% end
death_2010 = [];
sex_2010 = [];
% 2010 年性别比
for i = 5:6:128
	temp = xlsread('2010sex',1,char(['H',int2str(i)]));
	sex_2010 = [sex_2010;temp];
end
sex_2010 = 100 ./ (100 + sex_2010);
% 2010 年死亡率，第一列为男性死亡率，第二列为女性死亡率
count = 1;
for i = 5:6:118
	temp1 = xlsread('2010death',1,char(['I',int2str(i)]));
	temp2 = xlsread('2010death',1,char(['J',int2str(i)]));
	death_2010(count,1) = temp1;
	death_2010(count,2) = temp2;
    count = count + 1;
end
death_2010 = [death_2010;[234.902 241.923]];
death_2010 = death_2010 ./ 1000;

% temp_P 是 2015 年各年龄段人数（不分性别）
temp_P = [80208866 75768620 71176028 75176777 100285560 128498426 101460217 97238365 117707343 123910284 104220133 76969980 78136446 54852793 36319240 26524602 16335037 7208288 2178327 444656]';
% 2015生育千分比
birth_2015 = [9.19 54.96 74.31 45.31 18.60 5.37 3.11]';
birth_2015 = birth_2015 ./ 1000;

death_pred = xlsread('death_pred.xlsx',1,'B2:V21');
death_pred = death_pred ./ 1000;

% L = [0 0
% 0 0
% 0 0
% 0.5 0.3
% 0.65 0.5
% 0.8 0.7
% 0.9 0.8
% 0.95 0.8
% 0.85 0.7
% 0.8 0.65
% 0.7 0.6
% 0.6 0.5
% 0.5 0.3
% 0.2 0.1
% 0.1 0
% 0 0
% 0 0
% 0 0
% 0 0
% 0 0];

L = [0 0
0 0
0 0
0.5 0.3
0.65 0.5
0.8 0.7
0.9 0.8
0.95 0.8
0.85 0.7
0.8 0.65
0.7 0.6
0.6 0.5
0.5 0.3
0.2 0.1
0.1 0
0 0
0 0
0 0
0 0
0 0];

save data