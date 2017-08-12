clc,clear
[z]=xlsread('Z1.xlsx',1,'A1:F5036');

[NUM]=xlsread('s1');
seq = NUM(:,1);
count = [];
result = [];
for i = 1:max(seq)
	temp = find(seq == i);
	count(i,:) = [i length(temp)]; 
    if length(temp) == 0
        continue
    end
	result = [result;NUM(temp(1),:)];
end


count(find(count(:,2)<3),:)=[] ;

%age=result(find(30<result(:,3)<50),:);
%age2=age(find(count(:,1)==age(:,1)),:);

delta = [];
for i = 1:length(count)
    temp = count(i,1);
    delta = [delta;z(find(z(:,1) == temp),:)];
end

age1=delta(find(delta(:,4)<30),:);
age2=delta(find(30<delta(:,4)<40),:);
age3=delta(find(40<delta(:,4)<50),:);
age4=delta(find(delta(:,4)>50),:);


%s23=age1(find(age1(:,2)==4),:);
s33=age3(find(age3(:,2)==3),:);
% for i=1:length(s11)
%    for k=1:count(s11(i,1),2)-1
%        x11=(s11(k+1,6)-s11(1,6))/(s11(k+1,5)-s11(1,5));
%        y11=x11/(length(count(s11(i,1),2))-1);
        
flag = [0 0];	% 第一列存储行数，第二列存储序号
nongdu = 0; 
temp_sum = 0;       
for i = 1:length(s33)
	% 如果旗帜变化，更新旗帜
	if s33(i,1) ~= flag(2)
        if i ~= 1
            temp_sum = temp_sum ./ (count(find(count(:,1) == flag(2)),2) - 1);
            nongdu = nongdu + temp_sum;
        end
		temp_sum = 0;
		flag(1) = i;
		flag(2) = s33(i,1);
	else
		temp = (s33(i,6) - s33(flag(1),6)) ./ (s33(i,5) - s33(flag(1),5));
		temp_sum = temp_sum + temp;
	end
end

q=nongdu / length(s33)
