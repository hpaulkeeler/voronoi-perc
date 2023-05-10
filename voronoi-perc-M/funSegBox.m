% Consider a collection of (finite) line segments scattered on a
% two-dimensional (finite) window. This code finds the points where the
% segments intersect with a rectangular box with its sides parallel to the
% Cartesian axes.
%
% The intersection points are found by first deriving the linear equations
% (with form y=mx+c) of the corresponding lines of each segment. Then the
% x and y (interception) values are calculated based on the dimensions of
% the rectangular box.
%
% The segments are then truncuated, so that only segments inside the box
% remain.
%
% The results are also plotted if there are less than 30 segments.
%
% Labelling convention: N, S, E, W for North, South, East, West edges of the
% box, meaning the top, bottom, right, and left sides of the box. These
% four sides are also designated by the numbers -1,-2,-3,-4.
%
% INPUTS:
%
% dimBox=[xMin, yMin, xDelta, yDelta];
%
% OUTPUTS:
% The following output variables are 2 x n arrays, where n is the number of
% (original or new) segments. Each column corresponds to a segment.
%
% xxSegBoxed and yySegBoxed = x and y coordinates of the new (truncated)
% segment ends.
%
% bindexSegEndSide = each entry corresponds to a segment end of the
% truncated segments. A positive  number indicates the index of a segment
% % end in the original segments. A negative number indicates that the
% % segment has been truncated and intersects now with a box side indicated by a number (-1 for N etc).
%
% indexSegVertUnboxed = each entry corresponds to a segment end of the
% original (unntruncated) segments
%
% REFERENCES:
% [1]  Cali, Keeler, and Blaszczyszyn, "Connectivity and interference in 
% device-to-device networks in Poisson-Voronoi cities", 2023
%
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc

function [xxSegBoxed,yySegBoxed,bindexSegEndSide,indexSegEndBoxed,...
    xxSegUnboxed,yySegUnboxed,indexSegVertUnboxed]=funSegBox(xxSeg,yySeg,indexSegEnd,dimBox)
%Label convention: N, E, S, W for North, East, South, West edges of the box

%retrieve box dimensions
xMin=dimBox(1);
yMin=dimBox(2);
xDelta=dimBox(3);
yDelta=dimBox(4);
xMax=xMin+xDelta;
yMax=yMin+yDelta;

indexEndMax=max(indexSegEnd,[],'all'); %current maximum index value

%%%START - Helper Functions - START%%%
%check if a number s is inside an interval (sMin,sMax)
funBooleInterval=@(s,sMin,sMax)(s>sMin&s<sMax);
%checks if x or y value of edge crosses vertical or horizontal boundary
funBooleCrossBound=@(z1,z2,zBound)(xor(z1>zBound,z2>zBound));

%define functions for line parameters
fun_m=@(x1,y1,x2,y2)((y2-y1)./(x2-x1)); %slope value
fun_y0=@(x,y,c)(y-c.*x); %y intercept value
fun_x=@(y,y0,c)(y-y0)./c; %find x value given y, m, c
fun_y=@(x,m,c)(m.*x+c); %find y value given x, m, c
%%% END -- Helper Functions -- END %%%

%%% START -- Sort x and y by x values -- START %%%
xxSegMod=xxSeg;
yySegMod=yySeg;
indexSegMod=indexSegEnd;

%need to swap x values for calculating gradients
booleSwap=(xxSeg(1,:)>xxSeg(2,:));  %find where x values need swapping
%swap x values based on x values so smallest x value is first (ie left)
xxSegMod(1,booleSwap)=xxSeg(2,booleSwap);
xxSegMod(2,booleSwap)=xxSeg(1,booleSwap);
%swap y values based on x values
yySegMod(1,booleSwap)=yySeg(2,booleSwap);
yySegMod(2,booleSwap)=yySeg(1,booleSwap);
%swap indices based on x values
indexSegMod(1,booleSwap)=indexSegEnd(2,booleSwap);
indexSegMod(2,booleSwap)=indexSegEnd(1,booleSwap);

%%% END -- Sort by x values --  END %%%

%%% START -- Find segment/line parameters -- START %%%
%calculate gradients/slopes (ie m value) for all edges
slopeSeg=fun_m(xxSegMod(1,:),yySegMod(1,:),xxSegMod(2,:),yySegMod(2,:));
%calcualte y intersecpts of all edges
yInterSeg=fun_y0(xxSegMod(2,:),yySegMod(2,:),slopeSeg);

%find the segments that intersect with the box edges/boundaries
%x values for north and south box edges
xSegN=fun_x(yMax,yInterSeg,slopeSeg);
xSegS=fun_x(yMin,yInterSeg,slopeSeg);
%y values for east and west box edges
ySegE=fun_y(xMax,slopeSeg,yInterSeg);
ySegW=fun_y(xMin,slopeSeg,yInterSeg);
%%% END -- Find segment/line parameters -- END %%%

%%%START - Various indicators such as segments crossing edges - START%%%
%indicator fuctions that are outside box (infinitely extended) boundaries
booleN=yySegMod>yMax; %segment ends above the north box edge
booleS=yySegMod<yMin; %segment ends below the south box edge
booleE=xxSegMod>xMax; %segment ends right of the east box edge
booleW=xxSegMod<xMin; %segment ends left of the westbox edge

%segment ends lying inside the box
booleEndIn=(~booleE)&(~booleW)&(~booleN)&(~booleS);

%segment ends that lie outside the box
booleEndOut=~booleEndIn;
%find segment *both* ends lie  outside the box
booleOutBoth=and(booleEndOut(1,:),booleEndOut(2,:));

%segments crossing north box edge
booleCrossBoxN=funBooleCrossBound(yySegMod(1,:),yySegMod(2,:),yMax)...
    &funBooleInterval(xSegN,xMin,xMax);
%segments crossing south box edge
booleCrossBoxS=funBooleCrossBound(yySegMod(1,:),yySegMod(2,:),yMin)...
    &funBooleInterval(xSegS,xMin,xMax);
%segments crossing east box edge
booleCrossBoxE=funBooleCrossBound(xxSegMod(1,:),xxSegMod(2,:),xMax)...
    &funBooleInterval(ySegE,yMin,yMax);
%segments crossing west box edge
booleCrossBoxW=funBooleCrossBound(xxSegMod(1,:),xxSegMod(2,:),xMin)...
    &funBooleInterval(ySegW,yMin,yMax);

%find non-intersecting (with box) segments
booleNoCrossBox=((~booleCrossBoxN)&(~booleCrossBoxS)...
    &(~booleCrossBoxE)&(~booleCrossBoxW));

%keep edges interior and intersecting segments
booleSegKeep=~(booleNoCrossBox&booleOutBoth);
%%%END - Various indicators such as segments crossing edges - END%%%

%%%START - Replace old segment ends with new ones - START%%%
%find new edge end values for intersecting edges
%north box edge
xxSegTruncN=xSegN(booleCrossBoxN);
yySegTruncN=yMax*ones(size(xxSegTruncN));
%south box edge
xxSegTruncS=xSegS(booleCrossBoxS);
yySegTruncS=yMin*ones(size(xxSegTruncS));
%east box edge
xxSegTruncE=ySegE(booleCrossBoxE);
yySegTruncE=xMax*ones(size(xxSegTruncE));
%west box edge
xxSegTruncW=ySegW(booleCrossBoxW);
yySegTruncW=xMin*ones(size(xxSegTruncW));

%new x and y values
xxSegTrunc=xxSegMod;
yySegTrunc=yySegMod;
indexEndTrunc=indexSegMod;

%intersecting segment ends that need replacing
%Note: the function repmat is used as booleCrossBox refers to segments,
%not segement ends, meaning two dimensional arrays are needed
booleReplaceN=booleN&booleEndOut&repmat(booleCrossBoxN,2,1); %north
booleReplaceS=booleS&booleEndOut&repmat(booleCrossBoxS,2,1); %south
booleReplaceE=booleE&booleEndOut&repmat(booleCrossBoxE,2,1); %east
booleReplaceW=booleW&booleEndOut&repmat(booleCrossBoxW,2,1); %west

%replacement step
%north edge
xxSegTrunc(booleReplaceN)=xxSegTruncN;
yySegTrunc(booleReplaceN)=yySegTruncN;
numbTrunc=numel(xxSegTruncN); %number of new segment ends
if numbTrunc>0
    %create new indices for the truncated segment ends
    indexEndNew=indexEndMax+1:indexEndMax+numbTrunc;
    indexEndTrunc(booleReplaceN)=indexEndNew;
    indexEndMax=indexEndNew(end);
end
%south edge
xxSegTrunc(booleReplaceS)=xxSegTruncS;
yySegTrunc(booleReplaceS)=yySegTruncS;
numbTrunc=numel(xxSegTruncS); %number of new segment ends
if numbTrunc>0
    %create new indices for the truncated segment ends
    indexEndNew=indexEndMax+1:indexEndMax+numbTrunc;
    indexEndTrunc(booleReplaceS)=indexEndNew;
    indexEndMax=indexEndNew(end);
end
%east edge
xxSegTrunc(booleReplaceE)=yySegTruncE;
yySegTrunc(booleReplaceE)=xxSegTruncE;
numbTrunc=numel(xxSegTruncE); %number of new segment ends
if numbTrunc>0
    %create new indices for the truncated segment ends
    indexEndNew=indexEndMax+1:indexEndMax+numbTrunc;
    indexEndTrunc(booleReplaceE)=indexEndNew;
    indexEndMax=indexEndNew(end);
end
%west edge
xxSegTrunc(booleReplaceW)=yySegTruncW;
yySegTrunc(booleReplaceW)=xxSegTruncW;
numbTrunc=numel(xxSegTruncW); %number of new segment ends
if numbTrunc>0
    %create new indices for the truncated segment ends
    indexEndNew=indexEndMax+1:indexEndMax+numbTrunc;
    indexEndTrunc(booleReplaceW)=indexEndNew;
end

%remove segments that do not intersect with box or lie outside the box
xxSegBoxed=[xxSegTrunc(1,booleSegKeep);xxSegTrunc(2,booleSegKeep)];
yySegBoxed=[yySegTrunc(1,booleSegKeep);yySegTrunc(2,booleSegKeep)];
%indices for original segment ends after being truncated by box
indexSegEndBoxed=[indexEndTrunc(1,booleSegKeep);indexEndTrunc(2,booleSegKeep)];

bindexSegEndSide=indexSegEndBoxed;
for jj=1:2
    bindexSegEndSide(jj,booleReplaceN(jj,booleSegKeep))=-1; %north side
    bindexSegEndSide(jj,booleReplaceE(jj,booleSegKeep))=-2; %east side
    bindexSegEndSide(jj,booleReplaceS(jj,booleSegKeep))=-3; %south side
    bindexSegEndSide(jj,booleReplaceW(jj,booleSegKeep))=-4; %west side
end
% for bindexSegEndSide, the columns and rows represent the segements and
% their two ends, while the negative values of the array represent the
% sides used for replacement. (A postive number means the end wasn't replaced)

%retrieve xy/ values of unboxed/untrucnated street ends (does not include
%streets that were entirely outside of box)
xxSegUnboxed=[xxSegMod(1,booleSegKeep);xxSegMod(2,booleSegKeep)];
yySegUnboxed=[yySegMod(1,booleSegKeep);yySegMod(2,booleSegKeep)];

%original vertex indices of the untruncated (but removed) streets
indexSegVertUnboxed=[indexSegMod(1,booleSegKeep);indexSegMod(2,booleSegKeep)];

%%%END - Replace old segment ends with new ones  END%%%

end