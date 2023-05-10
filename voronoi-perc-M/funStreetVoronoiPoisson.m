% This function simulates a Poisson point process origin-centred square 
% (simulation window) with side this function. It then creates a Voronoi 
% tessellation, which is then truncated according to the rectangle encoded
% in the array windowTrunc. The Voronoi tessellation consists of edges and
% vertices, which represent streets and crossroads (or street
% intersections). Information on Voronoi edges (or streets) that are
% completely inside or intersect with the truncation window windowTrunc
% are kept. Edges that fall completely outside the truncation window are
% discarded.
%
% FILE DEPENDENCE:
% This function depends directly on the following files:
% 
% funPoissonTiled.m; funStreetVoronoi.m
%
% NOTES:
% For a homogeneous Poisson point process in two dimensions, the average
% number of edges (or streets) of a cell is is six.
% The average edge length (of the typical cell) is l_1=2/(3*sqrt(lambdaS),
% where lambdaS is the intensity of the underlying Poisson point process.
% The average of the total edge length per unit area is L_A=2*sqrt(lambdaS)
% For more information:
% Pages 461 and 477 in Schneider and Weil.
% Pages 357, 368 and 377 in Chiu, Chiu, Stoyan, Kendall, and Mecke.
%
% REFERENCES:
% [1]  Cali, Keeler, and Blaszczyszyn, "Connectivity and interference in 
% device-to-device networks in Poisson-Voronoi cities", 2023
%
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc

function [streetVoronoi,endVoronoi,ppPoisson,windowStreet]=funStreetVoronoiPoisson(lambdaS,scaleLength)

rng(5);

if nargin<2
    scaleLength=1;
end

%simulation window parameters (for inner tile)
xDelta=1;%width
yDelta=1;%height
x0=0; %x centre
y0=0; %y centre
xDelta=(scaleLength)*xDelta;
yDelta=(scaleLength)*yDelta;
xMin=x0-xDelta/2; %minimum x value
yMin=y0-yDelta/2; %minimum y value

%dimensions of tile window for simulation window
windowTile=[xMin, yMin, xDelta, yDelta];
%choiceTile=1; %1 tile a single realization; 2 tile the random point process
%numbWrap=1; %number tiles tiles are wrapped around centre tile
%generate a tiled Poisson point process; see funPoissonTiled.m for details
%funPointProcess=@(mu)funPoissonTiled(mu,windowTile,1,1);
funPointProcess=@(mu)funPoissonSquare(mu,scaleLength*3);


cell_lambdaS(:)=num2cell(lambdaS(:));
%generate a point process on some window that covers dimBox
[xPP,yPP,numbPP,W_PP]=cellfun(funPointProcess,cell_lambdaS,'UniformOutput',false);

%Create structure to represent Poisson realizations
ppPoisson=struct('x',xPP,'y',yPP,...
    'n',numbPP,'W',W_PP);

%generate Voronoi tessellation
[streetVoronoi,endVoronoi,windowStreet]...
    =funStreetVoronoi(ppPoisson,windowTile);

end
