clc,clear('all');

standard_in = xlsread('d1.xlsx','B1:C80');
standard_out = xlsread('d1.xlsx','E1:F76');
bias_in = xlsread('d1.xlsx','H1:I55');
bias_out = xlsread('d1.xlsx','K1:L53');

standard_in = standard_in ./ 1000;
standard_out = standard_out ./ 1000;
bias_in = bias_in ./ 1000;
bias_out = bias_out ./ 1000;

save data1 