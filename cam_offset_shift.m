% cam_offset_shift - Use 2D cross-correlation to determine pixel offsets between

% images, and shift the image based on the pixel offsets. There is also

% code to test if the shift is working. 

 

close all

clear all

tic

%addpath(genpath('/Users/patrickscordato/Desktop/SSF_2018/sandwich_beach_cam'))
addpath(genpath('D:\Scodato_SSF_2018\Projects\SandwichBeachCam\images\2016\c1\Cross_Corr_Test2'))


% get a list of all of the .jpg files in the directory
D = dir('D:\Scodato_SSF_2018\Projects\SandwichBeachCam\images\2016\c1\Cross_Corr_Test2')


% initialize an array to store the x, y offsets
xyoff = zeros(length(D)-1,2);
xoff= zeros(length(D)-1, 1);
yoff= zeros(length(D)-1, 1);


%initialize an array to store the datenum values. 
time=  zeros(length(D)-1,1);

 

 

% indices of upper left corner of boxes to correlate
b(1).xy = [250,1900];
b(2).xy = [1050,2250];
b(3).xy = [3600,800];
b(4).xy = [2242,897];
nb = length(b);
bs = 512; % box size

 

% read in all of the images and convert to b&w

for j = 3:length(D)-1
   im1 = imread(D(j).name);
   ig1 = rgb2gray(im1);
   im2 = imread(D(j+1).name);
   ig2 = rgb2gray(im2);

   %For most efficient code do not plot the boxes on the images. 
   % draw boxes on the image
   %figure(1); clf
   imshow(ig1);
   hold on
   for i=1:nb
      plot([b(i).xy(1); b(i).xy(1);      b(i).xy(1)+bs-1; b(i).xy(1)+bs-1; b(i).xy(1)],...
         [b(i).xy(2); b(i).xy(2)+bs-1; b(i).xy(2)+bs-1; b(i).xy(2);      b(i).xy(2)],'-r')
      hold on
   end

%Output Filename for your first image
im_name1= D(3).name;
filePn= 'D:\Scodato_SSF_2018\Projects\SandwichBeachCam\shifted_images\shift_test1\';
outPn= strcat(filePn, im_name1);
%Cookie cutter for your starting image
im_sh1= im1(32:3264-32, 32: 4352-32);
imwrite(im_sh1, outPn)
   
   % loop over each of the boxes and estimate offset direction
   for i=1:nb
      % select subsets of the images, using indexing instead of imcrop
      %    [s1c, rect] = imcrop( ig1,[b(i).xy, bs, bs]);
      %    [s2c, rect] = imcrop( ig2,[b(i).xy, bs, bs]);

      s1c = ig1( b(i).xy(2):b(i).xy(2)+bs-1, b(i).xy(1):b(i).xy(1)+bs-1);
      s2c = ig2( b(i).xy(2):b(i).xy(2)+bs-1, b(i).xy(1):b(i).xy(1)+bs-1);

      

      c=xcorr2(s1c,s2c);

      

      % offset found by correlation. 
      [max_c, imax] = max(abs(c(:)));
      [ypeak, xpeak] = ind2sub(size(c),imax(1));
      corr_offset = [(xpeak-size(s1c,2))
         (ypeak-size(s1c,1))];

      

      % total offset
      offset = corr_offset;
      xoffset = offset(1);
      yoffset = offset(2);

      

      %fill in the initialized array for the xoffset and yoffset 
      xoff(j, :)= [xoffset]
      yoff(j, :)= [yoffset]

      %fill in the time array
      time(j, :)= [D(j).datenum];

      % running sum of offsets from each box
      xyoff(j,1)=xyoff(j,1)+xoffset;
      xyoff(j,2)=xyoff(j,2)+yoffset;
      
   end

   xo= round(xyoff(j, 1)/nb) 
   yo= round(xyoff(j, 2)/nb)

%create a large buffer around your second image based on the magnitude of the offsets 
      im_sh2= im2(32+xo:3264-32+xo, 32+yo: 4352-32+yo);
% Save images for each shifted photo
%Output Filename for your first image
      
    im_name2= D(j+1).name ;
    filePn= 'D:\Scodato_SSF_2018\Projects\SandwichBeachCam\shifted_images\shift_test1\';
    outPn= strcat(filePn, im_name2);
    imwrite(im_sh2, outPn);
      
end

%Delete the '.' and '..' files. 
time(1:2)=[];
xoff(1:2)=[];
yoff(1:2)=[];