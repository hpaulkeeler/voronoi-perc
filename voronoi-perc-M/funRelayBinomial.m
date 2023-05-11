% Randomly places relays at crossroads (or street intersections) with
% probability pRelay.  It simulates the Y point process in the work by
% Cali, Keeler and Blaszczyszyn[1].
%
% This code was used to produce the results in the manuscript[1].
%
% INPUTS:
% endInput = data object encoding information of streets created by, for
% example, the function funStreetVoronoiPoisson.m
%
% pRelay = probability of a relay existing at a crossroads (or street
% intesection)
%
% OUTPUTS:
%
% relayBinomial = data object encoding information on relays.
%
% REFERENCES:
% [1]  Cali, Keeler, and Blaszczyszyn, "Connectivity and interference in
% device-to-device networks in Poisson-Voronoi cities", 2023
%
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc


function relayBinomial=funRelayBinomial(endInput,pRelay)

%apply function repeatedly
[relayBinomial]=...
    arrayfun(@(endSingle)funRelayBinomialSingle(endSingle,pRelay),endInput);

% function definition that returns a single struct encoding information on
% relays
    function [relayBinomialSingle]=funRelayBinomialSingle(endSingle,pRelay)

        %retrieve street ends (including crossroads) data
        indexEnd_E=endSingle.indexEnd_E; %local indices for crossroads/vertices
        xxEndOld_E=endSingle.xxEndOld_E;
        yyEndOld_E=endSingle.yyEndOld_E;
        indexEndCrossExtSharedJ_E=endSingle.indexEndCrossExtSharedJ_E;
        indexEndCrossExtSharedK_E=endSingle.indexEndCrossExtSharedK_E;
        indexEndCross_E=endSingle.indexEndCross;
        numbEnd_E=endSingle.numbEnd_E;  % number of street ends
        booleEndStreetABC_E=endSingle.booleEndStreetABC_E;


        %%%START Simulate a binomial point process on all the crossroads/vertices START%%%
        %first simulate binomial point process on ends (any two ends can share a vertex)
        booleEndRelay=(rand(numbEnd_E,1)<pRelay(:)); %Bernoulli variable for each vertex

        %update the pairs of ends that are the same relays by arbitraly replacing
        %one of the ends (which one doesn't matter) so that any two ends with a
        %shared vertex are now matching
        booleEndRelay(indexEndCrossExtSharedJ_E)=booleEndRelay(indexEndCrossExtSharedK_E);
        numbRelay=nnz(booleEndRelay)-numel(indexEndCrossExtSharedJ_E);
        numbEndRelay=numel(indexEndCrossExtSharedJ_E);
        %%%END Simulate a binomial point process on all the crossroads/vertices END%%%

        %ends corresponding to relays
        indexEnd_R=indexEnd_E(booleEndRelay);
        %relay ids - a single truncated relay can have two realy IDs due two
        %truncated streets (or street ends) intersecting the box
        indexEndRelay_R=indexEndCross_E(booleEndRelay);

        %find corresponding boolean for streets ABC
        booleRelayStreetABC_R=booleEndStreetABC_E;
        %a relay can only receive a signal if it is at a street end
        booleRelayStreetABC_R(~indexEndRelay_R,:)=false;

        %use old ends (outside the box) to retrieve x/y coordinates for the crossroads
        xxRelay_R=xxEndOld_E(booleEndRelay);
        yyRelay_R=yyEndOld_E(booleEndRelay);

        %create a table
        tableDataRelay=table(indexEnd_R,indexEndRelay_R,xxRelay_R,yyRelay_R);

        %create structure from table
        relayBinomialSingle=table2struct(tableDataRelay,"ToScalar",true);

        %add some additional fields
        relayBinomialSingle.numbEnd_R=numbEnd_E;
        relayBinomialSingle.numbRelay_R=numbRelay;
        relayBinomialSingle.numbEndRelay_R=numbEndRelay;
        relayBinomialSingle.booleRelayStreetABC_R=booleRelayStreetABC_R; 
        relayBinomialSingle.booleEndRelay_R=booleEndRelay;

    end
end