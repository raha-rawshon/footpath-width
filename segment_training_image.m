clc
close all
clear all

% calculate and save row and column for future reference.
    filename='F:\MS\unsw\Training_data\image_1.png';
    rawimage = imread(filename);
    [row_rawimage,column_rawimage]=size(rawimage);
    row=uint16(row_rawimage/10);
    column=uint16(column_rawimage/10/3);
    save size row column;
    
% read images from training dataset and segment them   
for i=1:9
    s=num2str(i);
    filename=['F:\MS\unsw\Training_data\image_',s,'.png'];
    rawimage = imread(filename);
    [row_rawimage,column_rawimage]=size(rawimage);
    
    % crop the lower half of the image as Footpath is in the lower half of every image
    lower_image=imcrop(rawimage,[1,row_rawimage/2,column_rawimage,row_rawimage]);
    
%    segment all training images in predefined shape and save them for training the classifier.    
    for x=0:((row_rawimage)/2-row)/10
        for y=0:(column_rawimage/3-column)/10
            segmented_image = imcrop(lower_image,[(y)*10+1,(x)*10+1,column,row]);         
            s1=num2str(x);
            s2=num2str(y);            
            filename= ['F:\MS\unsw\Training_data\segmented\image_',s,'segment',s1,s2,'.png'];
            imwrite(segmented_image,filename);           
        end
    end        
end