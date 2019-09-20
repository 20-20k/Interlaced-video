% ECE 483, Analysis of De-interlacing techniques
% Video de-interlacing
% Jason Carpenter, V00203100
% March 5, 2019

clc;
clear;

% use zombie (25 fps), elmo (30 fps), silky blue (24 fps) videos
% create video reader object
v = VideoReader('Silky_Blue.mp4');

% import all frames from video sequence
% WARNING, this will create lots of files if your video is long
for img = 1:v.NumberOfFrames
    filename = strcat('Silky_f',num2str(img),'.bmp');
    b = read(v, img);
    imwrite(b,filename);
end

% creates a cell of images
for n=1:img
  images{n} = imread(sprintf('Silky_f%d.bmp',n));
  [row col dim] = size(images{n}); 
  
  % ensure even number of rows
  if(mod(row, 2)) ~= 0
      images{n} = images{n}(1:end-1, :, :);   % get rid of last row if odd
      row(n) = row(n) - 1;
  end
  
  % extract even and odd fields
  im_odd{n} = images{n}(1:2:end, :, :);     % every odd second row, all columns
  im_even{n} = images{n}(2:2:end, :, :);    % every even second row, all columns
  
  % duplicate every second row to have full size image to process
  dup_odd{n} = repelem(im_odd{n}(1:1:end, :, :), 2, 1);
  dup_even{n} = repelem(im_even{n}(1:1:end, :, :), 2, 1);
  
  % new fully populated cell to work with
  new_img{n} = dup_even{n};
end

%% ------ Intra Field: Scan Line Interpolation, Edge Line Interpolation (ELA)

for a = 1:img-1
    for z = 1:dim                     % 3 rgb frames for jpg
        for y = 2:2:(col-1)         % check every 2nd y position
            for x = 2:1:(row-1)     % check every x position

                 A = new_img{a}(x-1, y-1, z);    
                 F = new_img{a}(x+1, y+1, z);
                 B = new_img{a}(x, y-1, z);
                 E = new_img{a}(x, y+1, z);
                 C = new_img{a}(x+1, y-1, z);
                 D = new_img{a}(x-1, y+1, z);

                 X_a = A/2 + F/2;
                 X_b = B/2 + E/2;
                 X_c = C/2 + D/2;

                 % Looking for lowest value between two pixels, designates an
                 % edge
                 if((abs(A-F) < abs(C-D)) && (abs(A-F) < abs(B-E)))
                     new_img{a}(x, y, z) = X_a;
                 elseif((abs(C-D) < abs(A-F)) && (abs(C-D) < abs (B-E)))
                     new_img{a}(x, y, z) = X_c; 
                 else
                     new_img{a}(x, y, z) = X_b;
                 end

            end
        end
    end
end
%%
% Create video of deinterlaced pictures 
video = VideoWriter('Silky_Blue_Intra_Field_Interpolation.avi'); %create the video object
video.FrameRate = 24;

open(video); %open the file for writing
for ii=1:img 
    frame = im2frame(new_img{ii});
    writeVideo(video,frame); %write the image to file
end
close(video); %close the file

% play the newly created video
implay('Silky_Blue_Intra_Field_Interpolation.avi');
%% ------------- Inter Field averaging ------------------------------------

for a = 1:img-1
    for z = 1:dim                   % 3 rgb frames 
        for y = 2:1:(col-1)         % check every y position minus the edge
            for x = 3:2:(row-2)     % check every 2nd x position minus big edge

                new_img{a}(x,y,z) = dup_even{a}(x-1, y, z)/4 + dup_even{a}(x+1, y, z)/4 + ...
                    dup_odd{a}(x, y, z)/4 + dup_odd{a+1}(x, y, z)/4;
            end
        end
    end
end

% Create video of deinterlaced pictures 
video = VideoWriter('Silky_Blue_Inter_Field_averaging.avi'); %create the video object
video.FrameRate = 24;

open(video); %open the file for writing
for ii=1:img 
    frame = im2frame(new_img{ii});
    writeVideo(video,frame); %write the image to file
end
close(video); %close the file

% play the newly created video
implay('Silky_Blue_Inter_Field_averaging.avi');




