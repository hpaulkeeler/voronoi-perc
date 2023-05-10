%Helper function for varying parameters. This code was used to produce the 
% results in the manuscript[1].
%
%
% REFERENCES:
% [1]  Cali, Keeler, and Blaszczyszyn, "Connectivity and interference in 
% device-to-device networks in Poisson-Voronoi cities", 2023%
% 
% AUTHOR DETAILS:
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc

function [paramValues,pValues,U_Values,thetaValues,tauSINRValues,...
    ratioNoiseValues,betaValues,kappaValues,lambdaValuesU,lambdaZ_Values]=...
    funVaryParameters(choiceParam,numb_param,ell_one,paramMin,paramMax)

%Note:
%paramMin=[pMin,U_Min,thetaMin,tauSINRMin,ratioNoiseMin,betaMin,kappaMin];
%paramMax=[pMax,U_Max,thetaMax,tauSINRMax,ratioNoiseMax,betaMax,kappaMax];

%retrieve minimum values
pMin=paramMin(1);
U_Min=paramMin(2);
thetaMin=paramMin(3);
tauSINRMin=paramMin(4);
ratioNoiseMin=paramMin(5);
betaMin=paramMin(6);
kappaMin=paramMin(7);

%retrieve maximum values
pMax=paramMax(1);
U_Max=paramMax(2);
thetaMax=paramMax(3);
tauSINRMax=paramMax(4);
ratioNoiseMax=paramMax(5);
betaMax=paramMax(6);
kappaMax=paramMax(7);

%street system parameters
lambdaS=4/9/ell_one^2;  %intensity (ie mean density) of the Poisson point process
gammaS=2*sqrt(lambdaS); %total street length per unit area

%initially set parameters constant
pValues=pMax*ones(1,numb_param);

U_Values=U_Max*ones(1,numb_param);
thetaValues=thetaMax*ones(1,numb_param);
tauSINRValues=tauSINRMax*ones(1,numb_param);
ratioNoiseValues=ratioNoiseMax*ones(1,numb_param);
betaValues=betaMax*ones(1,numb_param);
kappaValues=kappaMax*ones(1,numb_param);

if choiceParam==1
    %vary pRelay
    pValues=linspace(pMin,pMax,numb_param);
    %plotting details
    paramValues=pValues;
elseif choiceParam==2
    %vary U (ie lambda) values
    U_Values=linspace(U_Min,U_Max,numb_param);
    %plotting details
    paramValues=U_Values;
elseif choiceParam==3
    %vary theta
    thetaValues=linspace(thetaMin,thetaMax,numb_param);
    %plotting details
    paramValues=thetaValues;
elseif choiceParam==4
    %vary tauSINR (which means varying tau STINR)
    tauSINRValues=linspace(tauSINRMin,tauSINRMax,numb_param);
    %plotting details
    paramValues=tauSINRValues;
elseif choiceParam==5
    %vary noise ratio (which means varying tau power typically)
    ratioNoiseValues=linspace(ratioNoiseMin,ratioNoiseMax,numb_param);
    %plotting details
    paramValues=ratioNoiseValues;
elseif choiceParam==6
    %vary beta (in path loss function)
    betaValues=linspace(betaMin,betaMax,numb_param);
    %plotting details
    paramValues=betaValues;

elseif choiceParam==7
    %vary kappa (in path loss function)
    kappaValues=linspace(kappaMin,kappaMax,numb_param);
    %plotting details
    paramValues=kappaValues;
end
lambdaValuesU=U_Values/ell_one;
%intensity of Z
lambdaZ_Values=2*lambdaS*pValues+gammaS*lambdaValuesU;
