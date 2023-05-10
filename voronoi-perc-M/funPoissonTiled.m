% This function simulates a Poisson point process on a rectangle 
% (simulation window). 
% INPUTS:
%
% choiceTile: 1 tile a single realization; 2 tile the random point process
% numbWrap: number of tiles that are wrapped around centre tile
%
%
% OUTPUTS:
%
% FILE DEPENDENCXE:
%
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc

function [xxTiled,yyTiled,numbPoints,windowSim,boolePeriodic]=funPoissonTiled(lambdaS,windowTile,numbWrap,choiceTile)



%tiling parameters
numbSide=(2*numbWrap+1); %width of tiling (ie number of tiles across)

numbTile=numbSide^2; %total number of tiles

%simulation window dimensions
xMin=windowTile(1);
yMin=windowTile(2);
xDelta=windowTile(3);
yDelta=windowTile(4);

xMax=xMin+xDelta;
yMax=yMin+yDelta;

xTiledMin=xMin-numbWrap*xDelta;
yTiledMin=yMin-numbWrap*yDelta;
xTiledMax=xMax+numbWrap*xDelta;
yTiledMax=yMax+numbWrap*yDelta;
windowSim=[xTiledMin,yTiledMin,xTiledMax,yTiledMax];

areaTotal=xDelta*yDelta; %area of (inner) simulation window
boolePeriodic=false; %true for periodic boundary conditions

%%%START - Simulate Poisson point process - START%%%
if choiceTile==1
    %tile realization
    numbPointSingle=poissrnd(areaTotal*lambdaS);
    %Poisson number of points (repeated numbTile times)
    numbPoints=repmat(numbPointSingle,numbTile,1);
    %x/y coordinates of a realization of Poisson process
    xxSingle=xDelta*(rand(numbPointSingle,1))+xMin;
    yySingle=yDelta*(rand(numbPointSingle,1))+yMin;
    %repeat realization numbTile times
    xx=repmat(xxSingle,numbTile,1);
    yy=repmat(yySingle,numbTile,1);
    
    %periodic boundary conditions
    boolePeriodic=true;
    
elseif choiceTile==2
    %tile point process
    %numbTile number of Poisson number of points
    numbPoints=poissrnd(areaTotal*lambdaS,numbTile,1);
    numbPointsTotal=sum(numbPoints); % number of points in all the tiles
    %x/y coordinates of copies of a Poisson process
    xx=xDelta*(rand(numbPointsTotal,1))+xMin;
    yy=yDelta*(rand(numbPointsTotal,1))+yMin;
else
    %Test case - KEEP FOR Python code
    xxSingle=[-.3;-.4;0;.2;.1;.2]/2;
    yySingle=[.4;.3;.1;.1;.3;.4];    
    numbPointSingle=numel(xxSingle);
    numbPoints=repmat(numbPointSingle,numbTile,1);
    %repeat realization numbTile times
    xx=repmat(xxSingle(:),numbTile,1);
    yy=repmat(yySingle(:),numbTile,1);
end

% convert to cell arrays, where each cell is a tile
xxTiledCell=mat2cell(xx,numbPoints);
yyTiledCell=mat2cell(yy,numbPoints);
%%%END - Simulate Poisson point process - END%%%

%%%START - Tile point process by shifting x/y values - START%%%
xShift=xDelta*(-numbWrap:numbWrap); %all possible x value shifts
yShift=yDelta*(-numbWrap:numbWrap); %all possible y value shifts

countTile=1; %initialize tile count
for ii=1:numbSide
    %loop through each x shift (corresponding to horizontal tiling)
    
    for jj=1:numbSide
        %loop through each y shift (corresponding to vertical tiling)        
        xxTiledCell{countTile}=xxTiledCell{countTile}+xShift(ii);
        yyTiledCell{countTile}=yyTiledCell{countTile}+yShift(jj);
      
        countTile=countTile+1;
    end
end

%turn coordinate cell arrays into 1-D vectors
xxTiled=cell2mat(xxTiledCell);
yyTiled=cell2mat(yyTiledCell);
%%%END - Tile point process by shifting x/y values - END%%%