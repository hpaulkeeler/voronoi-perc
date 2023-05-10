%This function takes a 2-D Voronoi tesselation and finds the all the (finite) edge
%pairs, meaning it ignores the vertex at infinity.
%
%For the input, the 2-D Voronoi tesselation expressed in the same form as
%the output of the MATLAB function voronoin, namely:
%where xyVert is a n by 2 matrix of x and y values of n vertices. The first
%vertex (that is, xyVert(1,:)) corresponds to a point at infinity, which is
%neglected here.
%
%
% File dependence:
% 
% The following files depend directly on this function:
%
% funStreetVoronoi.m
%
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc

function [xxEdgeVert, yyEdgeVert,indexEdgeVert]=funVoronoiFinite(xyVert,indexCellVert)
%number of Voronoi cells (including unbounded ones)
numbCells=length(indexCellVert);
numbEdgeMax=3*numbCells-6; %upper bound on Voronoi edges (ie 3n-6)

% initialize array for indices, each column corresponds to an Voronoi edge,
% which has two vertices as ends.
indexEdgeVertAll=zeros(2,numbEdgeMax);

countEdgePair=0; %initiatze pair couting variable
for ii=1:numbCells
    %loop through all the cells
    indexVertTemp=indexCellVert{ii};
    numbVertTemp=length(indexVertTemp);
    for jj=1:numbVertTemp
        %for each cell, loop through all its vertices
        
        if jj==numbVertTemp
            %at the last vertext, loop around to first vertex
            indexEdgeTemp=[indexVertTemp(1),indexVertTemp(numbVertTemp)];
        else
            %otherwise store edge pair
            indexEdgeTemp=[indexVertTemp(jj),indexVertTemp(jj+1)];
        end
        
        if ~any(indexEdgeTemp==1)
            %only add edge pair if there is no infinite point
            %the infinite point is located at indexEdgeTemp=1
            countEdgePair=countEdgePair+1; %update pair edge count first
            indexEdgeVertAll(:,countEdgePair)=indexEdgeTemp; %update pair
        end
    end
end
indexEdgeVertFat=indexEdgeVertAll(:,1:countEdgePair); %remove excess zeros

%%%START - Removing redundant pairs - START%%%
indexEdgeVertFat=sort(indexEdgeVertFat); %sort index pairs for pairing functions
%apply pairing function f=u+(v*(v-1))/2 for removing redundant edges
id_Edge=indexEdgeVertFat(1,:)...
    +indexEdgeVertFat(2,:).*(indexEdgeVertFat(2,:)-1)/2;
[~,indexEdgeKeep]=unique(id_Edge); %find an index for each unique value
%remove redundant edge row (ie remove the fat)
indexEdgeVert=indexEdgeVertFat(:,indexEdgeKeep);

%retrieve all x/y coordinates of vertices as two separate vectors
xxVert=xyVert(:,1);
yyVert=xyVert(:,2);

%use edge-vertex index matrix retrieve x/y coordiantes
xxEdgeVert=(xxVert(indexEdgeVert));
yyEdgeVert=(yyVert(indexEdgeVert));
%%%END - Removing redundant pairs - END%%%
