clc,clear
close all
tic

videoName = 'video.mp4';
obj = VideoReader(videoName);
numFrames = obj.NumberOfFrames;	% 帧的总数
needFrames = 2440;      % 需要分成多少张图片
stepLength = ceil(numFrames ./ needFrames);
% 读取数据
for k = 1:needFrames
	frame_num = stepLength * k;
	frame = read(obj,frame_num);
	% imshow(frame);
	imwrite(frame,strcat('/Users/shengliyi/Documents/MATLAB/比赛Matlab/15A/videoPicture/',num2str(k),'.jpg'));
end

toc