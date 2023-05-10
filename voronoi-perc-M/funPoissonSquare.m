%This function simulates a Poisson point process on a rectangle
% (simulation window) with intensity (or average density) lambdaS.
%
% INPUTS:
%
%
% OUTPUTS:
%
% FILE DEPENDENCE:
%
% REFERENCES:
% [1]  Cali, Keeler, and Blaszczyszyn, "Connectivity and interference in 
% device-to-device networks in Poisson-Voronoi cities", 2023
%
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc

function [xxPoisson,yyPoisson,numbPoint,windowSim]=funPoissonSquare(lambdaS,scaleLength)

%simulation window parameters (for inner tile)
xDelta=1;%width
yDelta=1;%height
x0=0; %x centre
y0=0; %y centre
%rescale widths
xDelta=(scaleLength)*xDelta;
yDelta=(scaleLength)*yDelta;
%find x/y min/max values
xMin=x0-xDelta/2; 
yMin=y0-yDelta/2; 
xMax=x0+xDelta/2; 
yMax=y0+yDelta/2; 

%simulation window
windowSim=[xMin,yMin,xMax,yMax];

areaTotal=xDelta*yDelta; %area of (inner) simulation window
massTotal=areaTotal*lambdaS;
%number of Poisson number of points
numbPoint=poissrnd(massTotal);
%x/y coordinates of copies of a Poisson process
xxPoisson=xDelta*(rand(numbPoint,1))+xMin;
yyPoisson=yDelta*(rand(numbPoint,1))+yMin;


end