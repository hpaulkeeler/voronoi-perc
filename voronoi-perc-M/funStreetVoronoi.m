% For a given point pattern ppInput, this function creates a Voronoi
% tessellation, which is then truncated according to the rectangle encoded
% in the array windowTrunc. The Voronoi tessellation consists of edges and
% vertices, which represent streets and crossroads (or street
% intersections). Information on Voronoi edges (or streets) that are
% completely inside or intersect with the truncation window windowTrunc
% are kept. Edges that fall completely outside the truncation window are
% discarded.
%
% INPUTS:
%
%
% OUTPUTS:
%
% FILE DEPENDENCXE:
%
% This function depends on the following files:
%
% funVoronoiFinite; funSegBox.m;
%
% REFERENCES:
% [1]  Cali, Keeler, and Blaszczyszyn, "Connectivity and interference in
% device-to-device networks in Poisson-Voronoi cities", 2023
%
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc


function [streetVoronoi,endVoronoi,windowVoronoi]...
    =funStreetVoronoi(ppInput,windowTrunc)

%apply function repeatedly
[streetVoronoi,endVoronoi,windowVoronoi]=...
    arrayfun(@(pp)funStreetVoronoiSingle(pp,windowTrunc),ppInput);


% function that returns two structs encoding information on
% streets and street ends formed from truncating the Voronoi tessellation.
    function [streetVoronoiSingle,endVoronoiSingle,windowStreetSingle]...
            =funStreetVoronoiSingle(ppInputSingle,windowTrunc)
        %retrieve point process
        x=ppInputSingle.x;
        y=ppInputSingle.y;
        windowSim=ppInputSingle.W; %simulation window of point process/pattern

        %%%START - Generate Voronoi tesselation - START%%%
        % perform Voronoi tessellation using built-in MATLAB function voronoin
        [xyVert,indexCellVert]=voronoin([x,y]);

        % extract x/y coordinates of vertices of all edge (ie street) pairs,
        % ignoring the vertex at infinity
        [xxEdgeVert,yyEdgeVert,indexEdgeVert]=...
            funVoronoiFinite(xyVert,indexCellVert);

        % box/truncate segments
        [xxStreetEnd,yyStreetEnd,bindexStreetEndOldSide,indexStreetEndOld,...
            xxStreetEndOld,yyStreetEndOld,indexStreetCrossOld]=funSegBox(xxEdgeVert,yyEdgeVert,indexEdgeVert,windowTrunc);
        % The above variables (generated by funSegBox) are 2 x n matrices.
        % Each column corresponds to a street, and there are two rows
        % corresponding to the two ends of each street. Street ends can be crossroads (/
        % vertices) or not.
        %%%END - Generate Voronoi tesselation - END%%%

        %%%START - Find network/adjacency details - START%%%
        %street ends that are not internal crossroads
        booleStreetEndTrunc=bindexStreetEndOldSide<0;
        booleStreetEndCrossInt=~booleStreetEndTrunc;
        % retrieve (unique) Voronoi vertices inside box (1-D array)
        indexEndCrossIntOld=unique(indexStreetEndOld(booleStreetEndCrossInt));
        %number of internal crossroads (or vertices)
        numbCrossInt=numel(indexEndCrossIntOld);

        % retrieve (unique) street ends that are not crossroads (or vertices)
        indexEndTruncOldRep=indexStreetEndOld(booleStreetEndTrunc);
        [indexEndTruncExtOld,indexEndSide]=unique(indexEndTruncOldRep);

        %original vertices that are not crossroads -- may have repeats
        indexCrossExtOldAll=indexStreetCrossOld(booleStreetEndTrunc);

        %find street ends that exist on the box border (ie not cross roads)
        bindexEndNotCrossInt=bindexStreetEndOldSide(booleStreetEndTrunc);
        bindexEndSide=bindexEndNotCrossInt(indexEndSide);

        % combine indices so crossroads (or vertices) are first in the array
        indexEndOld=[indexEndCrossIntOld;indexEndTruncExtOld]; %indices are increasing
        numbEnd=numel(indexEndOld); %number of (unique) street ends

        % street (or edge) data
        numbStreet=numel(indexStreetEndOld(1,:)); %number of streets
        % each column is a street, where the values are the street end indices
        indexStreetEndNew=-ones(2,numbStreet);

        % street end data
        % x/y values of street ends. each row is street end
        xxEnd_E=zeros(numbEnd,1);
        yyEnd_E=zeros(numbEnd,1);
        xxEndOld_E=zeros(numbEnd,1);
        yyEndOld_E=zeros(numbEnd,1);
        %max number of streets intersecting at crossroads (typically 3 for
        %random point processes)
        [~,numbStreetCrossMax_S]=mode(indexEdgeVert(:)); 
        % each row is a (unique) street end connected to 3 streets at most
        bindexEndStreetABC=-ones(numbEnd,max(3,numbStreetCrossMax_S));

        %each row is a street end P or Q, each value column of indexEndStreetABC where to find street
        %end P or Q
        colStreetEnd=-ones(2,numbStreet);
        indexEnd=(1:numbEnd); %create new indexing for street ends
        indexCrossExtTruncOld=-1*ones(1,numbEnd-numbCrossInt);

        %booles for street ends with shared vertices outside box
        %Note: Assumed only two street ends
        bindexEndCrossExtSharedJ_E=-1*ones(numbEnd,1);
        bindexEndCrossExtSharedK_E=-1*ones(numbEnd,1);
        %index from ends to crossroads
        indexEndCross=-1*ones(numbEnd,1);
        indexEndCross(indexEnd)=indexEnd;
        for indexEndTemp=indexEnd
            % loop through all the street ends, finding which streets they
            % belong to, and assigning each street end with a new index indexEndTemp.
            indexEndOldTemp=indexEndOld(indexEndTemp); %original street end numbering
            % find street with street end (index) indexEndTemp
            [rowEndTemp,colEndTemp]=find(indexStreetEndOld==indexEndOldTemp);
            % NOTE: colTemp gives the street number
            % find corresponding (linear) index
            indexStreetTemp=sub2ind(size(indexStreetEndOld),rowEndTemp,colEndTemp);
            % index for each street end connected to streets ABC
            bindexEndStreetABC(indexEndTemp,1:numel(colEndTemp))=colEndTemp;
            % update street and street end information
            indexStreetEndNew(indexStreetTemp)=indexEndTemp;%new street end numbering
            %update column values where to find street end
            colStreetEnd(indexStreetTemp)=1:numel(colEndTemp);
            %take first x/y value (from maximum of three indentical values)
            xxEnd_E(indexEndTemp)=xxStreetEnd(rowEndTemp(1),colEndTemp(1));
            yyEnd_E(indexEndTemp)=yyStreetEnd(rowEndTemp(1),colEndTemp(1));

            if indexEndTemp>numbCrossInt
                %find indices of truncated street ends sharing a common vertex
                %convert to vertex indices
                indexCrossExtTemp=indexEndTemp-numbCrossInt;
                %convert to indices for array indexVertNotCrossIntAllOld
                indexVertSide=indexEndSide(indexCrossExtTemp);
                %original vertex index
                indexCrossExtTruncOldTemp=indexCrossExtOldAll(indexVertSide);

                %previously collected (original) vertex indices
                indexCrossExtTruncOldPrev=indexCrossExtTruncOld(1:(indexCrossExtTemp-1));
                %see if (original) vertex indices already exist
                booleCrossExtRep=(indexCrossExtTruncOldPrev==indexCrossExtTruncOldTemp);
                if any (booleCrossExtRep)
                    %find corresponding (new) vertex indices
                    indexCrossExtRepTemp=find(booleCrossExtRep);
                    %convert to (new) end indices
                    indexEndRepTemp=indexCrossExtRepTemp+numbCrossInt;
                    bindexEndCrossExtSharedJ_E(indexEndRepTemp)=indexEndTemp;
                    bindexEndCrossExtSharedK_E(indexEndTemp)=indexEndRepTemp;
                    %update index
                    indexEndCross(indexEndTemp)=indexEndRepTemp;
                end
                %update collected (original) vertex indices
                indexCrossExtTruncOld(indexCrossExtTemp)=indexCrossExtTruncOldTemp;
            end
            xxEndOld_E(indexEndTemp)=xxStreetEndOld(rowEndTemp(1),colEndTemp(1));
            yyEndOld_E(indexEndTemp)=yyStreetEndOld(rowEndTemp(1),colEndTemp(1));
        end

        %ends and crossroad indices agree, but ends intersecting with sides
        %of the box have negative indices
        bindexEndCrossIntSide_E=zeros(numbEnd,1);
        bindexEndCrossIntSide_E(1:numbCrossInt)=(1:numbCrossInt);
        bindexEndCrossIntSide_E(numbCrossInt+1:end)=bindexEndSide;
        %Coding note: might not need negative indices
        indexEndSide_E=find(bindexEndCrossIntSide_E<0);
        %extract indices for street ends with shared crossroads/vertices
        indexEndCrossExtSharedJ_E=find(bindexEndCrossExtSharedJ_E>-1);
        indexEndCrossExtSharedK_E=find(bindexEndCrossExtSharedK_E>-1);

        %find which sides (ie N=-1, E=-2, S=-3, W=-4)
        indexEndN_E=indexEndSide_E(bindexEndCrossIntSide_E(indexEndSide_E)==-1);
        indexEndE_E=indexEndSide_E(bindexEndCrossIntSide_E(indexEndSide_E)==-2);
        indexEndS_E=indexEndSide_E(bindexEndCrossIntSide_E(indexEndSide_E)==-3);
        indexEndW_E=indexEndSide_E(bindexEndCrossIntSide_E(indexEndSide_E)==-4);
        %%%END - Find network/adjacency details - END%%%

        % create indices for simulations and streets
        indexStreet_S=(1:numbStreet)'; %(arbitrary) street numbers

        %%%START - Write to parameters and data to file - START%%%

        %%%START - Street details - START%%%
        % retrieve x/y coordiates of street ends
        xxEndP_S=xxStreetEnd(1,:)';
        xxEndQ_S=xxStreetEnd(2,:)';
        yyEndP_S=yyStreetEnd(1,:)';
        yyEndQ_S=yyStreetEnd(2,:)';

        %calculate lengths of all streets
        xxDiffStreet=xxEndQ_S-xxEndP_S;
        yyDiffStreet=yyEndQ_S-yyEndP_S;
        lengthStreet_S=hypot(xxDiffStreet,yyDiffStreet);

        %orientation angle of all streets
        thetaStreet_S=atan(yyDiffStreet./xxDiffStreet);

        %calculate the truncated lengths at ends P and Q
        booleEndReplaced=booleStreetEndTrunc;
        lengthStreetPQ=zeros(2,numbStreet);
        for jj=1:2
            %loop through the two different street ends

            %distance difference between boxed and unboxed (original) segment ends
            %(order doesn't matter for lengths)
            xxDiffStreet_jj=xxStreetEndOld(jj,booleEndReplaced(jj,:))...
                -xxStreetEnd(jj,booleEndReplaced(jj,:));
            yyDiffStreet_jj=yyStreetEndOld(jj,booleEndReplaced(jj,:))...
                -yyStreetEnd(jj,booleEndReplaced(jj,:));
            %Euclidean difference
            lengthStreetPQ_jj=hypot(xxDiffStreet_jj,yyDiffStreet_jj);
            lengthStreetPQ(jj,booleEndReplaced(jj,:))=lengthStreetPQ_jj;
        end
        %retrieve truncated lengths
        lengthStreetP_S=lengthStreetPQ(1,:)';
        lengthStreetQ_S=lengthStreetPQ(2,:)';

        % retrieve end rows/indices (which overlap with vertex rows/indices)
        rowStreetEndP_S=(indexStreetEndNew(1,:))';
        rowStreetEndQ_S=(indexStreetEndNew(2,:))';
        %retrieve columns for each end
        colStreetEndP_S=(colStreetEnd(1,:))';
        colStreetEndQ_S=(colStreetEnd(2,:))';

        %find street indices of connected street (including self streets)
        %example: street A has street end P, which connects to streets A,B, and
        %C, where street A is "self street".
        bindexStreetEndP_StreetAll=bindexEndStreetABC(rowStreetEndP_S,:);
        bindexStreetEndQ_StreetAll=bindexEndStreetABC(rowStreetEndQ_S,:);

        %find indices of self streets using rows and columns
        indexStreetEnd_P_Self=sub2ind([numbStreet,numbStreetCrossMax_S],(1:numbStreet)',colStreetEndP_S);
        indexStreetEnd_Q_Self=sub2ind([numbStreet,numbStreetCrossMax_S],(1:numbStreet)',colStreetEndQ_S);

        %booles for removing street indices connecting to themselves
        booleStreetEndP_NotSelf=true([numbStreet,numbStreetCrossMax_S]);
        booleStreetEndQ_NotSelf=true([numbStreet,numbStreetCrossMax_S]);
        booleStreetEndP_NotSelf(indexStreetEnd_P_Self)=false;
        booleStreetEndQ_NotSelf(indexStreetEnd_Q_Self)=false;

        %initiate arrays
        bindexStreetEndP_Street=-ones(numbStreet,2);
        bindexStreetEndQ_Street=-ones(numbStreet,2);
        for ii=indexStreet_S'
            %loop through all streets
            bindexStreetEndP_Street(ii,:)=bindexStreetEndP_StreetAll(ii,booleStreetEndP_NotSelf(ii,:));
            bindexStreetEndQ_Street(ii,:)=bindexStreetEndQ_StreetAll(ii,booleStreetEndQ_NotSelf(ii,:));
        end

        % find street end indices using rows and columns
        indexStreetEndABC_P_S=sub2ind(size(bindexEndStreetABC),...
            rowStreetEndP_S,colStreetEndP_S);
        indexStreetEndABC_Q_S=sub2ind(size(bindexEndStreetABC),...
            rowStreetEndQ_S,colStreetEndQ_S);

        %truncated streets at street ends P and Q
        %(not necessarily of equal size)
        indexStreetTruncP_S=find(lengthStreetP_S>0);
        indexStreetTruncQ_S=find(lengthStreetQ_S>0);

        % create table for streets (ie edges)
        tableDataStreet=table(indexStreet_S,...
            xxEndP_S,yyEndP_S,xxEndQ_S,yyEndQ_S,thetaStreet_S,...
            lengthStreet_S,lengthStreetP_S,lengthStreetQ_S,...
            rowStreetEndP_S,rowStreetEndQ_S,...
            colStreetEndP_S,colStreetEndQ_S);

        %REMOVE later unnecessary variables  in table
        streetVoronoiSingle=table2struct(tableDataStreet,"ToScalar",true);

        %add some additional fields
        streetVoronoiSingle.bindexStreetEndP_StreetBC_S=bindexStreetEndP_Street;
        streetVoronoiSingle.bindexStreetEndQ_StreetBC_S=bindexStreetEndQ_Street;
        streetVoronoiSingle.indexStreetEndABC_P_S=indexStreetEndABC_P_S;
        streetVoronoiSingle.indexStreetEndABC_Q_S=indexStreetEndABC_Q_S;
        streetVoronoiSingle.numbStreet_S=numbStreet;
        streetVoronoiSingle.indexStreetTruncP_S=indexStreetTruncP_S;
        streetVoronoiSingle.indexStreetTruncQ_S=indexStreetTruncQ_S;
        streetVoronoiSingle.numbStreetCrossMax_S=numbStreetCrossMax_S;
        %%%END - Street details - END%%%

        %%%START - Street end details - START%%%
        %number of street ends
        indexEnd_E=indexEnd';
        %find ends with street ends with valid streets
        booleEndStreetABC_E=bindexEndStreetABC>.0;

        %create table for street ends
        tableDataEnd=table(indexEnd_E,...
            xxEnd_E,yyEnd_E,bindexEndCrossIntSide_E,...
            xxEndOld_E,yyEndOld_E,...
            indexEndCross);

        %create struct from table
        endVoronoiSingle=table2struct(tableDataEnd,"ToScalar",true);

        %add some additional fields
        endVoronoiSingle.numbEnd_E=numbEnd;
        endVoronoiSingle.bindexEndStreetABC_E=bindexEndStreetABC;
        endVoronoiSingle.indexEndSide_E=indexEndSide_E;
        endVoronoiSingle.indexEndCrossExtSharedJ_E=indexEndCrossExtSharedJ_E;
        endVoronoiSingle.indexEndCrossExtSharedK_E=indexEndCrossExtSharedK_E;
        endVoronoiSingle.indexEndN_E=indexEndN_E;
        endVoronoiSingle.indexEndE_E=indexEndE_E;
        endVoronoiSingle.indexEndS_E=indexEndS_E;
        endVoronoiSingle.indexEndW_E=indexEndW_E;
        endVoronoiSingle.booleEndStreetABC_E=booleEndStreetABC_E;


        %%%END - Street end  details - END%%%
        windowStreetSingle=struct('windowSim',windowSim,'windowTrunc',windowTrunc);
    end
end
