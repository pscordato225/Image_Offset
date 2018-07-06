
% cam_offset - Use 2D cross-correlation to determine pixel offsets between
% images
tic 
close all
clear all
addpath(genpath('D:\Scodato_SSF_2018\Projects\SandwichBeachCam\images\2016\c1\SandwichBeachCam_March30'))
% get a list of all of the .jpg files in the directory
D = dir('D:\Scodato_SSF_2018\Projects\SandwichBeachCam\images\2016\c1\SandwichBeachCam_March30')

% initialize an array to store the x, y offsets
xyoff = zeros(length(D)-1,2);
xoff= zeros(length(D)-1, 1);
yoff= zeros(length(D)-1, 1);

% initialize an array to store time 
time= zeros(length(D)-1, 1);
% indices of upper left corner of boxes to correlate
b(1).xy = [250,1900];
b(2).xy = [1050,2250];
b(3).xy = [3600,800];
b(4).xy = [2242,897];
nb = length(b);
bs = 512; % box size

% read in all of the images and convert to b&w
for j = 3:length(D)-1;
   im = imread(D(j).name);
   ig1 = rgb2gray(im);
   im = imread(D(j+1).name);
   ig2 = rgb2gray(im);
   
   % draw boxes on the image
   %figure(1); clf
   imshow(ig1);
   hold on
   for i=1:nb
      plot([b(i).xy(1); b(i).xy(1);      b(i).xy(1)+bs-1; b(i).xy(1)+bs-1; b(i).xy(1)],...
         [b(i).xy(2); b(i).xy(2)+bs-1; b(i).xy(2)+bs-1; b(i).xy(2);      b(i).xy(2)],'-r')
      hold on
   end
   % loop over each of the boxes and estimate offset direction
   for i=1:nb
      % select subsets of the images, using indexing instead of imcrop
      %    [s1c, rect] = imcrop( ig1,[b(i).xy, bs, bs]);
      %    [s2c, rect] = imcrop( ig2,[b(i).xy, bs, bs]);
      s1c = ig1( b(i).xy(2):b(i).xy(2)+bs-1, b(i).xy(1):b(i).xy(1)+bs-1);
      s2c = ig2( b(i).xy(2):b(i).xy(2)+bs-1, b(i).xy(1):b(i).xy(1)+bs-1);
      
      c=xcorr2(s1c,s2c);
      
      % offset found by correlation
      [max_c, imax] = max(abs(c(:)));
      [ypeak, xpeak] = ind2sub(size(c),imax(1));
      corr_offset = [(xpeak-size(s1c,2))
         (ypeak-size(s1c,1))];
      
      % total offset
      offset = corr_offset;
      xoffset = offset(1);
      xoff(j, :)= [xoffset];
      yoffset = offset(2);
      yoff(j, :)= [yoffset];
      
      % create an array for time
      time(j, :)= [D(j).datenum];
      
      % running sum of offsets from each box
      xyoff(j,1)=xyoff(j,1)+xoffset;
      xyoff(j,2)=xyoff(j,2)+yoffset;
      
        
   end
   
  
end
time(1:2)=[]
xoff(1:2)=[]
yoff(1:2)=[]


figure(2); hold on
title('2016 Cross Correlation Offset in the X-Direction')
xlabel('Time (s)')
ylabel('X-Offset (pixels)')
plot(time, xoff)



figure(3); hold on
title('2016 Cross Correlation Offset in the Y-Direction')
xlabel('Time (s)')
ylabel('Y-Offset (pixels)')
plot(time, yoff)


% compute average offset between each set of images
xyoff = xyoff./nb;

save xoff 
save yoff 
save time
save xyoff
toc
