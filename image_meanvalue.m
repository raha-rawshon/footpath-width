
% calculate and save Mean, Maximum and Minimum value of labeled footpath images

myFolder_footpath = 'F:\MS\unsw\Training_data\segmented\labeled\footpath';

if ~isfolder(myFolder_footpath)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder_footpath);
  uiwait(warndlg(errorMessage));
  return;
end

filePattern = fullfile(myFolder_footpath, '*.png');
imageFiles = dir(filePattern);
imageMean=0;
imageMin=double(0);
imageMax=double(0);

for k = 1:length(imageFiles)
  baseFileName = imageFiles(k).name;
  fullFileName = fullfile(myFolder_footpath, baseFileName);
  imageArray = imread(fullFileName);
  imageMean=mean(mean(imageArray))+imageMean;
  imageMin=double(min(min(imageArray)))+imageMin;
  imageMax=double(max(max(imageArray)))+imageMax;
end

imageMean=imageMean/k;
imageMin=imageMin/k;
imageMax=imageMax/k;
save imageAvg imageMean imageMin imageMax;