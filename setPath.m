%% Set paths to external libraries
pathGBI='/Users/Denis/Documents/codes/GlobalBioIm-release'; % Path of the GlobalBioIm library
pathJavaMatlab='/Users/Denis/libs/Matlab9.3/java/jar/'; % Path of the Java folder of Matlab

%% Add Matlab paths
addpath(genpath('code'));
addpath(genpath('gui'));
setMatlabPathGBI(pathGBI);
javaaddpath([pathJavaMatlab,'ij.jar'])
javaaddpath([pathJavaMatlab,'mij.jar'])
