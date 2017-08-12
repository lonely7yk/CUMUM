clc,clear
excel_paifang = xlsread('tenyears.xlsx',1,'D2:D11');
excel_fenlei = xlsread('tenyears.xlsx',2,'D3:O92');
percent1 = excel_fenlei(:,2:2:end);
percent = [percent1(:,1) + percent1(:,2) + percent1(:,3), percent1(:,4) + percent1(:,5), percent1(:,6)];

density = [0.0189
		0.0188
		0.0200
		0.0144
		0.0218
		0.0236
		0.0248
		0.0251
		0.0271
		0.0303];

allwater = {};
ganwater = {};
zhiwater = {};

for i = 1:3
	allwater{i} = percent(3*i-2:9:end,:);
	ganwater{i} = percent(3*i-1:9:end,:);
	zhiwater{i} = percent(3*i:9:end,:);
end

save data