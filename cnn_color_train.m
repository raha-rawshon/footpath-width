clear all

% no of groups for classification
no_of_labels=10;

% read labeled images
segmented_road_parts = imageDatastore('F:\MS\unsw\Training_data\segmented\labeled', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

% get size of trraining images
img = readimage(segmented_road_parts,1);
[row,column,channel]=size(img);
save size row column;


% calssification parameters
layers = [
    imageInputLayer([row column channel])
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(8,'Stride',8)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(no_of_labels)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',20, ...
    'Shuffle','every-epoch', ...      
    'ValidationFrequency',20, ...
    'Verbose',false, ...
    'Plots','training-progress');

% train Convolutional Neural Network with color images
net_color = trainNetwork(segmented_road_parts,layers,options);
save net_color net_color;