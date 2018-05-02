function setMatlabPathGBI(pathToDir)
%% Script which update matlab path to work with the InvPbLib

addpath([pathToDir,'/Abstract/OperationsOnMaps']);
addpath([pathToDir,'/Abstract/']);
addpath([pathToDir,'/Util/']);
addpath([pathToDir,'/Opti/']);
addpath([pathToDir,'/Opti/TestCvg']);
addpath([pathToDir,'/Opti/OptiUtils/MatlabOptimPack']);
addpath([pathToDir,'/LinOp/']);
addpath([pathToDir,'/NonLinOp/']);
addpath([pathToDir,'/LinOp/LinOp_Utils/']);
addpath([pathToDir,'/LinOp/SelectorLinOps/']);
addpath([pathToDir,'/Cost/']);
addpath([pathToDir,'/Cost/CostUtils/']);
addpath([pathToDir,'/Cost/CostUtils/HessianSchatten/']);
addpath([pathToDir,'/Cost/IndicatorFunctions/']);
addpath([pathToDir,'/Example/']);

