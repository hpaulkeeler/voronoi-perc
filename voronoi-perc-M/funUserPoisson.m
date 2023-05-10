% Randomly places users on streets with according to a (one-dimensional)
% homogeneous Poisson point proces with intensity (or average density)
% lambdaU. It simulates the X point process in the work by Cali, Keeler
% and Blaszczyszyn[1].
%
% This code was used to produce the results in the manuscript[1].
% 
% INPUTS:
% 
% streetInput = data object encoding information of streets created by, for
% example, the function funStreetVoronoiPoisson.m
%
% lambdaU = (linear) intensity of users on each the street
%
% OUTPUTS: 
%
% relayBinomial = data object encoding information on users.
%
% NOTE: 
% For each street laylout, user locations are not randomly ordered,
% as they are ordered by the streets. The variable indexUser_U should be
% first randomly permuated (using the MATLAB function randperm).
%
% REFERENCES:
% [1]  Cali, Keeler, and Blaszczyszyn, "Connectivity and interference in 
% device-to-device networks in Poisson-Voronoi cities", 2023%
% 
% AUTHOR DETAILS:
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc

function userPoisson=funUserPoisson(streetInput,lambdaU)

%apply function repeatedly
[userPoisson]=...
    arrayfun(@(streetInput)funUserPoissonSingle(streetInput,lambdaU),streetInput);

% function that returns a single struct encoding information on users
    function [userPoissonSingle]...
            =funUserPoissonSingle(streetSingle,lambdaU)

        %retrieve street data
        indexStreet_S=streetSingle.indexStreet_S;
        xxEndP_S=streetSingle.xxEndP_S;
        yyEndP_S=streetSingle.yyEndP_S;
        thetaStreet_S=streetSingle.thetaStreet_S;
        lengthStreet_S=streetSingle.lengthStreet_S;
        lengthStreetP_S=streetSingle.lengthStreetP_S;
        lengthStreetQ_S=streetSingle.lengthStreetQ_S;
        rowStreetEndP_S=streetSingle.rowStreetEndP_S;
        rowStreetEndQ_S=streetSingle.rowStreetEndQ_S;

        %all street (segment) lengths, starting with the middle one
        lengthStreetExt_S=lengthStreet_S+lengthStreetP_S+lengthStreetQ_S;

        %%%START Simulate a Poisson point processes on street system START%%%
        massUser=lengthStreetExt_S*lambdaU; %total user mass for each streeet
        %Poisson number of users on each street (including truncated segments)
        numbStreetUser_S=poissrnd(massUser);
        numbUser=sum(numbStreetUser_S); %total number of users
        randUni=rand(numbUser,1); %uniformly distri    buted variables on (0,1)

        %starting points (including truncated ends)
        xxEndP_Ext_ss=xxEndP_S-lengthStreetP_S.*cos(thetaStreet_S);
        yyEndP_Ext_ss=yyEndP_S-lengthStreetP_S.*sin(thetaStreet_S);

        %calculate and repeat horizontal/vertical (ie x/y) components for each user
        cos_theta_uu=repelem(cos(thetaStreet_S),numbStreetUser_S);
        sin_theta_uu=repelem(sin(thetaStreet_S),numbStreetUser_S);

        %repeat x/y coordinates of vertex P for each user
        xxEndP_Ext_uu=repelem(xxEndP_Ext_ss,numbStreetUser_S);
        yyEndQ_Ext_uu=repelem(yyEndP_Ext_ss,numbStreetUser_S);

        %calculate truncated street segement lengths for street end P
        lengthStreet_U=repelem(lengthStreet_S,numbStreetUser_S);
        lengthStreetP_U=repelem(lengthStreetP_S,numbStreetUser_S);
        lengthStreetQ_U=repelem(lengthStreetQ_S,numbStreetUser_S);
        %
        lengthStreetExt_U=lengthStreet_U+lengthStreetP_U+lengthStreetQ_U;
        %random user positions (uniformly random distance from vertex P)
        distEndExtP_U=randUni.*lengthStreetExt_U;
        %random user positions (uniformly random distance from vertex Q)
        distEndExtQ_U=lengthStreetExt_U-distEndExtP_U;
        %calculate x/y components for each user
        xxUser_U=xxEndP_Ext_uu+distEndExtP_U.*cos_theta_uu;
        yyUser_U=yyEndQ_Ext_uu+distEndExtP_U.*sin_theta_uu;
        %%%END Simulate a Poisson point process on street system END%%%

        %%%START Find distances to street ends %%%START
        %user is located beyond truncated end P
        booleUserExtP_uu=(distEndExtP_U<lengthStreetP_U);
        %user is located beyond truncated end Q
        booleUserExtQ_uu=(distEndExtQ_U<lengthStreetQ_U);
        %index for which street segment the users are located
        %user locations: -1 in truncated P end, 1 in trucated Q end, 0 inside box
        ternUserExt_U=-booleUserExtP_uu+booleUserExtQ_uu;

        %find truncated distances (which are negative for outside the box)
        distEndP_U=distEndExtP_U-lengthStreetP_U;
        distEndQ_U=distEndExtQ_U-lengthStreetQ_U;
        %%%END Find distances to street ends END %%%

        % create indices for users
        indexUser_U=(1:numbUser)';
        indexUserRand_U=(randperm(numbUser))';


        indexStreet_U=repelem(indexStreet_S,numbStreetUser_S);
        %for a segment end, the index of vertex (starts at 2), -1 for no vertex
        indexEndP_U=repelem(rowStreetEndP_S,numbStreetUser_S);
        indexEndQ_U=repelem(rowStreetEndQ_S,numbStreetUser_S);

        %create table for user data
        tableDataUser=table(indexStreet_U,indexUser_U,indexUserRand_U,...
            ternUserExt_U,...
            distEndP_U,indexEndP_U,...
            distEndQ_U,indexEndQ_U,...
            lengthStreet_U,...
            lengthStreetP_U,lengthStreetQ_U,lengthStreetExt_U,...
            xxUser_U,yyUser_U);

        %create structure from table
        userPoissonSingle=table2struct(tableDataUser,"ToScalar",true);

        %add some additional fields
        userPoissonSingle.numbUser_U=numbUser; %total number of users layout
        userPoissonSingle.numbStreetUser_U=numbStreetUser_S;
    end
end