function [ hour ] = minute2Hour1( minute )
%UNTITLED8 此处显示有关此函数的摘要
%   此处显示详细说明
    m = mod(minute,60);
    s = (m - floor(m)) * 60 / 10000;
    m = floor(m);
    m = m / 100;
    h = floor(minute / 60) + 6;
    hour = h + m + s;
end

