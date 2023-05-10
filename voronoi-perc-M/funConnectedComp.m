% This function checks if a connected component exists that traverses the
% network horizontally, vertically or both, which serves as an
% approximation for a giant (or big) component existing in the percolation
% model described in the work by Cali, Keeler, and Blaszczyszyn[1].
%
% It relies upon the MATLAB function conncomp:
% mathworks.com/help/matlab/ref/graph.conncomp.html
%
% This code was used to produce the results in the manuscript[1].
%
% REFERENCES:
% [1]  Cali, Keeler, and Blaszczyszyn, "Connectivity and interference in
% device-to-device networks in Poisson-Voronoi cities", 2023
%
% AUTHOR DETAILS:
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc

function [booleConnected_ss,booleTraverseVer,booleTraverseHor]=...
    funConnectedComp(streetInput,endInput,booleOpenInput)

%retrieve relevant data from street and street end objects
%street data
numbStreet_S=streetInput.numbStreet_S;
rowStreetEndP_S=streetInput.rowStreetEndP_S;
rowStreetEndQ_S=streetInput.rowStreetEndQ_S;
%street end data
indexEndCrossExtSharedJ_E=endInput.indexEndCrossExtSharedJ_E;
indexEndCrossExtSharedK_E=endInput.indexEndCrossExtSharedK_E;
indexEndN_E=endInput.indexEndN_E;
indexEndE_E=endInput.indexEndE_E;
indexEndS_E=endInput.indexEndS_E;
indexEndW_E=endInput.indexEndW_E;

%helper functions
%check traversal in one way (up/down or left/right) given an array of cluster nodes
funTraverse=@(indexEnd1,indexEnd2,compTest)(any(ismember(indexEnd1,compTest))&any(ismember(indexEnd2,compTest)));
%check traveersl in one way (up/down or left/right) given a cell array of cluster nodes
funTraverseCell=@(indexEnd1,indexEnd2,cellComp)(any(cellfun(@(compTest)funTraverse(indexEnd1,indexEnd2,compTest),cellComp)));

%start creating graph data structure
indexStreet=(1:numbStreet_S)'; %labels for streets
tableEdgeStreet=table(indexStreet); %convert to table
graphStreet0_ss=graph(rowStreetEndP_S',rowStreetEndQ_S',tableEdgeStreet); %create graph data structure

%add virtual edges between shared node pairs due to (truncated) crossroads/vertices
graphStreet_ss=addedge(graphStreet0_ss,indexEndCrossExtSharedJ_E,indexEndCrossExtSharedK_E);
%these additional virtual edges will have the same index/label 0

%MATLAB edge to street mapping - each row corresponds to a street number
indexEdgeToStreet=graphStreet_ss.Edges.indexStreet;
[~,indexStreetToEdge]=ismember(indexStreet,indexEdgeToStreet);
indexEdgeClose=indexStreetToEdge(~booleOpenInput);
%remove closed streets
graphStreet_ss= graphStreet_ss.rmedge(indexEdgeClose);

%find the connected component of the graph
cellComp_ss=conncomp(graphStreet_ss,'OutputForm','cell');

%check if connected component traverses the vertically/horizontally
booleTraverseVer=funTraverseCell(indexEndN_E,indexEndS_E,cellComp_ss);
booleTraverseHor=funTraverseCell(indexEndE_E,indexEndW_E,cellComp_ss);
booleConnected_ss=booleTraverseVer|booleTraverseHor;

end