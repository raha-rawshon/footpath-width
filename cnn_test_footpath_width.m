
% Load saved data
load net_color;
load imageAvg;
load size  
    % read image from testing dataset  
    s=num2str(12);
    filename=['F:\MS\unsw\Testing_data\image_',s,'.png'];
    rawimage = imread(filename);
    
     % crop the lower half of the image as Footpath is in the lower half of every image
    [row_rawimage,column_rawimage]=size(rawimage);
    lower_image=imcrop(rawimage,[1,row_rawimage/2,column_rawimage,row_rawimage]);
    
    % prepare variable for future use
    imspace_mean=lower_image;    
    imspace_mean(:,:,:)=0;
    
    imspace_freq=rgb2gray(lower_image);
    imspace_freq(:,:)=0;
       
    row_segment=uint16(row_rawimage/10);
    column_segment=uint16(column_rawimage/10/3);

    
     % segment testing image in predefined shape and predict the label using the classifier.    
    for x=0:((row_rawimage)/2-row)/10
        for y=0:(column_rawimage/3-column)/10
            segmented_image = imcrop(lower_image,[(y)*10+1,(x)*10+1,column_segment,row_segment]);
            imager=imresize(segmented_image,[row,column]);
            
    % predict the label of current segment
            YPred = classify(net_color,imager);
            
    % calculate Mean, Maximum and Minimum value of current segment
            testSegmentMean=mean(mean(imager));
            testSegmentMax=max(max(imager));
            testSegmentMin=min(min(imager));
        
    % further calculation to improve accuracy of predicted label
    
            if(strcmp(char(YPred),'footpath'))    
        
                % compare mean of current segment with mean of labeled footpath images      
                if ( abs(testSegmentMean(1)-imageMean(1))<30 && abs(testSegmentMean(2)-imageMean(2))<30 && abs(testSegmentMean(3)-imageMean(3))<30)
                    imspace_mean((x)*10+1:(x)*10+row,(y)*10+1:(y)*10+column,:)=imager(:,:,:);                
                end                 
            
                % count the number of prediction as footpath for each pixel              
                imspace_freq((x)*10+1:(x)*10+row,(y)*10+1:(y)*10+column,:)=imspace_freq((x)*10+1:(x)*10+row,(y)*10+1:(y)*10+column,:)+1;  
            end          
            
        end
    end
    
    % Discard false predictions 

    imspace_freq_binary = imbinarize(imspace_freq,30/255);
    
    detected_footpath = bsxfun(@times, imspace_mean, cast(imspace_freq_binary, 'like', imspace_mean));
    
    
    detected_footpath_binary = imbinarize(detected_footpath(:,:,3),5/255);
   
    detected_footpath_binary =  bwareafilt(detected_footpath_binary, 1);
    detected_footpath = bsxfun(@times, detected_footpath, cast(detected_footpath_binary, 'like', detected_footpath));
    figure, imshow(detected_footpath);   
    hold on
    
    stat = regionprops(detected_footpath_binary,'BoundingBox');
    boundary= uint16(stat.BoundingBox);
    
    % Initialize variables for calculating left and right curb end points 
     left1xa=zeros(boundary(4)/4,1);
     left1y=boundary(2);
     right1xa=zeros(boundary(4)/4,1);
     right1y=boundary(2);
     left2xa=zeros(boundary(4)/4,1);
     left2y=boundary(2)+boundary(4);
     right2xa=zeros(boundary(4)/4,1);
     right2y=boundary(2)+boundary(4);
     
     % calculate left and right curb end points      
     count=0;
     index=0;
     for j=boundary(2):(boundary(2)+boundary(4))/4
        for i=boundary(1):boundary(1)+boundary(3)
            if (detected_footpath_binary(j,i)==1)
               detected_footpath_binary(j,i)=255;
               count = count+1;
               left1xa(count) = i;
               
                plot(i,j,'b*')
                break;
            end
        end
                       
        for i=boundary(1)+boundary(3):-1:boundary(1)
            if (detected_footpath_binary(j,i)==1)
               detected_footpath_binary(j,i)=255;
               index = index+1;
               right1xa(index) = i;
               
                plot(i,j,'b*')
                break;
            end
        end
     end
     
     
     right1x = mean(nonzeros(right1xa));
     left1x = mean(nonzeros(left1xa));
     
     index=0;
     count=0;
     for j=(boundary(2)+boundary(4))/4*3:boundary(4)
        for i=boundary(1):boundary(1)+boundary(3)
            if (detected_footpath_binary(j,i)==1)
               detected_footpath_binary(j,i)=255;
               count = count+1;
               left2xa(count) = i;
               
                plot(i,j,'b*')
                break;
            end
        end
        for i=boundary(1)+boundary(3):-1:boundary(1)
            if (detected_footpath_binary(j,i)==1)
               detected_footpath_binary(j,i)=255;
               index = index+1;
               right2xa(index) = i;
                plot(i,j,'b*')
                break;
            end
        end
     end
     
     right2x = mean(nonzeros(right2xa));
     left2x = mean(nonzeros(left2xa));
     
     % plot curb and curb endpoints     
     plot(left1x,left1y,'r*')
     plot(right1x,right1y,'r*')
     plot(left2x,left2y,'r*')
     plot(right2x,right2y,'r*')
     
     plot([left1x left2x], [left1y left2y],'LineWidth',4)
     plot([right1x right2x], [right1y right2y],'LineWidth',4)
     hold off
              
     % Calculate minimum distance from point to line to determine footpath width
     
       v1 = [right1x right1y 0];
       v2 = [right2x right2y 0];
       pt = [left2x left2y 0];
       a = double(abs(v2 - v1)); 
       b = double(abs(v2 - pt));
       footpath_width = norm(cross(a,b)) / norm(a)
   
