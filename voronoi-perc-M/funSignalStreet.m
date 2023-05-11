
%pathloss function depends only on distance d; pathloss parameters are
%passed into the function funPathloss_d

% This code was used to produce the results in the manuscript[1].
%
% REFERENCES:
% [1]  Cali, Keeler, and Blaszczyszyn, "Connectivity and interference in
% device-to-device networks in Poisson-Voronoi cities", 2023%
%
% AUTHOR DETAILS:
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc

function sigEndStreetEnd=...
    funSignalStreet(streetInput,endInput,funPathloss_d)

%retrieve variables from street data structure
lengthStreet_S=streetInput.lengthStreet_S;
lengthStreetP_S=streetInput.lengthStreetQ_S;
lengthStreetQ_S=streetInput.lengthStreetQ_S;
rowStreetEndP_S=streetInput.rowStreetEndP_S;
rowStreetEndQ_S=streetInput.rowStreetEndQ_S;
colStreetEndP_S=streetInput.colStreetEndP_S;
colStreetEndQ_S=streetInput.colStreetEndQ_S;
indexStreetTruncP_S=streetInput.indexStreetTruncP_S;
indexStreetTruncQ_S=streetInput.indexStreetTruncQ_S;

%retrieve variables from (street) end data structure
rowEndStreetABC_E=endInput.bindexEndStreetABC_E;
booleEndStreetABC_E=endInput.booleEndStreetABC_E;

%numbStreetCrossMax_S=streetInput.numbStreetCrossMax_S;
size_EndStreetABC=size(booleEndStreetABC_E);

%assign street lengths for each street intersecting at street end
lengthStreetTruncABC_ss=lengthStreet_S(rowEndStreetABC_E(booleEndStreetABC_E));

%matrix for lengths of (internal) streets at street ends
lengthEndStreetABC=zeros(size_EndStreetABC);
lengthEndStreetABC(booleEndStreetABC_E)=lengthStreetTruncABC_ss;

%add truncated (street segments to ends (ie treat ends like crossroads)
%find indices of truncated streets to lengthen
indexStreetTruncEndABC_PQ_ss=sub2ind(size(rowEndStreetABC_E),...
    rowStreetEndQ_S(indexStreetTruncP_S),colStreetEndQ_S(indexStreetTruncP_S));
indexStreetTruncEndABC_QP_ss=sub2ind(size(rowEndStreetABC_E),...
    rowStreetEndP_S(indexStreetTruncQ_S),colStreetEndP_S(indexStreetTruncQ_S));

%lengthen truncated streets
lengthEndStreetABC(indexStreetTruncEndABC_PQ_ss)=...
    lengthEndStreetABC(indexStreetTruncEndABC_PQ_ss)...
    +lengthStreetP_S(indexStreetTruncP_S);
lengthEndStreetABC(indexStreetTruncEndABC_QP_ss)=...
    lengthEndStreetABC(indexStreetTruncEndABC_QP_ss)...
    +lengthStreetQ_S(indexStreetTruncQ_S);

%include truncated (external) street lengths for ends on window sides
%put street lengths in second column (always empty for truncated steets)
lengthEndStreetABC(rowStreetEndP_S(indexStreetTruncP_S),2)=...
    lengthEndStreetABC(rowStreetEndP_S(indexStreetTruncP_S),2)...
    +lengthStreetP_S(indexStreetTruncP_S);
lengthEndStreetABC(rowStreetEndQ_S(indexStreetTruncQ_S),2)=...
    lengthEndStreetABC(rowStreetEndQ_S(indexStreetTruncQ_S),2)...
    +lengthStreetQ_S(indexStreetTruncQ_S);

%update boolean matrix saying where street ends are
booleEndStreetABC_E(rowStreetEndP_S(indexStreetTruncP_S),2)=true;
booleEndStreetABC_E(rowStreetEndQ_S(indexStreetTruncQ_S),2)=true;

%%%START - Calculate power values at street ends - START%%%
%update street lengths for each street end
lengthEndStreetABC_End=lengthEndStreetABC(booleEndStreetABC_E);

sigEndStreetEnd=zeros(size_EndStreetABC); %initial power values
%at each street end calculate signal powers from relays on adjacent streets
%relays can be inside or outside simulation window
sigEndStreetEnd(booleEndStreetABC_E)=funPathloss_d(lengthEndStreetABC_End);
%%%END - Calculate power values at street ends - END%%%

end