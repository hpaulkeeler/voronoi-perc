% This code was used to produce the results in the manuscript[1].
%
% FILE DEPENDENCE:
% This function depends directly on the following files:
%
% funVaryParameters.m;
% funStreetVoronoiPoisson.m; funUserPoisson.m; funRelayBinomial.m
% funSignalStreet.m; funConnectedComp.m; funStreetRelayUserOpen
%
%
% NOTES:
%
% 1) For the connectivity, the STINR values at street ends on the box edge
% need to be larger, even though no users or relays exist with probability
% one.
%
% 2) Useful statistics
%
% gammaS=2*sqrt(lambdaS); %total street lenght per unit area
% ell_one=2/3/sqrt(lambdaS);  %mean length of the typical street
%
% 3)
% Noise is a power measured in watts. A standard dimensional analysis shows
% that noise is then proportional to distance (in metres) squared. For
% example, a change from metres to km gives an increase of noise by a factor of 10^6 exactly.
%
% REFERENCES:
% [1]  Cali, Keeler, and Blaszczyszyn, "Connectivity and interference in
% device-to-device networks in Poisson-Voronoi cities", 2023%
%
% AUTHOR DETAILS:
% Author: H. Paul Keeler, 2023.
% Website: hpaulkeeler.com
% Repository: github.com/hpaulkeeler/voronoi-perc


clearvars;
close all;
clc;

%set up plotting defaults
set(0, 'DefaultLineLineWidth', 2);
set(0,'DefaultLineMarkerSize',16);
set(0,'defaultTextInterpreter','latex'); %trying to set the default
set(0,'defaultAxesFontSize',12);
set(0,'defaultLegendFontSize',12);
datetimeStart=(datetime(datetime,'Format','yy-MM-dd_HH-mm-ss'));

numbSimS=30; %number of street simulations

booleWrite=1; %write results to file
boolePlot=1; %create plots
%can't write plots to file without plotting them
booleWrite=boolePlot&booleWrite;

%1 varies pRelay, 2 varies U (or lambdaU), 3 varies theta, 4 varies tau, 5
%noise ratio, 6 varies beta (path loss exponent, 7 varies kappa (scale
%parameter)
choiceParam1=2;
choiceParam2=3;

%number of pRelay, U, theta etc (or lambdaU) values
numb_param1=8; %x axis of plots (ie number of parameter values on x axis)
numb_param2=1; %different plots (ie number of different plots)

%%% START model parameters START %%%
ell_one=100; %mean length of street
%Poisson point process parameter for street system
lambdaS=4/9/ell_one^2;  %intensity (ie mean density) of the Poisson point process
gammaS=2*sqrt(lambdaS); %total street length per unit area
scaleLength=20*ell_one; %to scale lengths of unit square simulation region

areaSim=scaleLength^2; %area of square simulation window centred at origin
massStreet=lambdaS*scaleLength^2;%total mass of street process

%mean number of users per typical street (rescaled Poisson intensity)
U_Min=0;
U_Max=10;

%relay parameters (probability of a relay existing at a vertex)
pMin=0.5;
pMax=1;

%STINR parameters
%theta (interference reduction)
thetaMin=0;
thetaMax=.004;

%SINR threshold tau
tauSINRMin=db2pow(-5);
tauSINRMax=1;

%exponent for path loss function
betaMin=1.8;
betaMax=2;

%%distance scaling factor for path loss function
kappaMin=1;
kappaMax=100;

%path loss model
funPathloss_B_K=@(B,K,d)(1./(1+(abs(d)*K)).^(B));

H=1;%
rGilbert=ell_one/H; %transmission under Gilbert model
% "mean field approximation" of average path loss over a street
pathLossStreet=funPathloss_B_K(betaMax,kappaMax,ell_one/H);
%choose noise term for corresponding Gilbert radius
ratioNoiseMax=1e-8;
ratioNoiseMin=ratioNoiseMax/1000;

%collect all parameters as arrays
paramMin=[pMin,U_Min,thetaMin,tauSINRMin,ratioNoiseMin,betaMin,kappaMin];
paramMax=[pMax,U_Max,thetaMax,tauSINRMax,ratioNoiseMax,betaMax,kappaMax];

%vary second parameter to vary
paramMaxValues2=linspace(paramMin(choiceParam2),paramMax(choiceParam2),numb_param2);
%%% END model parameters END %%%

%inverse path loss function (calculated numerically)
%helper functions
%fun_tauSINR_1=@(tau_2,theta)(tau_2./(1-theta.*tau_2));
fun_tauSTINR_2=@(tau_1,theta)(tau_1./(1+theta.*tau_1));
%STINR function for users (includes interference from other streets)
funSTINR=@(theta,ratioNoise,P,indexTX,indexRX,I0)(P(indexTX)...
    /(theta*(sum(P((1:numel(P))~=indexRX))+I0)+ratioNoise));
%%STINR function (takes signals of relays at street ends)
funSTINR_Relay=@(theta,ratioNoise,P)(P./(theta*(repmat(sum(P,2),1,3))+ratioNoise));
%STINR connectivity model
funSTINR_User=@(theta,ratioNoise,B,K,XZ,indexTX,indexRX,I0)(funSTINR(theta,ratioNoise,funPathloss_B_K(B,K,(XZ(indexRX)-XZ)),indexTX,indexRX,I0));
funOpen_User=@(tau,theta,ratioNoise,B,K,XZ,indexTX,indexRX,I0)(funSTINR_User(theta,ratioNoise,B,K,XZ,indexTX,indexRX,I0)>tau);
%funOpen_Relay=@(tau,theta,ratioNoise,B,K,P)(funSTINR_Relay(theta,ratioNoise,B,K,P)>tau);

%user parameters
lambdaU_Max=U_Max/ell_one; %(linear) density of users on the street

numbDigitsMax=ceil(abs(log10(min(paramMax(paramMax>0)))));
numbDigitsMin=ceil(abs(log10(min(paramMin(paramMin>0)))));
numbDigitsPrint=max(numbDigitsMax,numbDigitsMin)+3;
%numbDigitsPrint=10;

%prepraparing labels, values etc
labelParamAll={'p', 'U', '\theta', '\tau', '\bar{N}','\beta','\kappa','\ell_1'};
labelSepAll={', ', ', ', ', ',', ', ', ', ', ','.'};
label_x=append('$',labelParamAll{choiceParam1},'$');
label_Legend={'Simulation results'};

if booleWrite
    %prepare and create diretcory for results
    pathParamAll={'p', 'U', 'theta', 'tau', 'ratioNoise','beta','kappa'};

    strResults='Results/Temp/';
    strVaryTemp=append('Vary_',pathParamAll{choiceParam1},...
        '_Diff_',pathParamAll{choiceParam2},'/');

    strPlots='Plots/';
    pathResultsVary=append(strResults,strVaryTemp);
    strTime=(string(datetimeStart));

    pathResultsTime=append(pathResultsVary,strTime, '/');
    mkdir(pathResultsTime);

    writematrix(paramMaxValues2,append(pathResultsTime,pathParamAll{choiceParam2},'_All','.csv'));
    writematrix(paramMaxValues2,append(pathResultsTime,pathParamAll{choiceParam2},'_All','.xls'));
end

paramMax_kk=paramMax;
for kk=1:numb_param2
    paramMax_kk(choiceParam2)=paramMaxValues2(kk);
    %vary parameter values according to choices
    [paramValues,pValues,U_Values,thetaValues,tauSINRValues,...
        ratioNoiseValues,betaValues,kappaValues,lambdaValuesU,lambdaZ_Values]=...
        funVaryParameters(choiceParam1,numb_param1,ell_one,paramMin,paramMax_kk);

    %calculate corresponding STINR threshold valuu0es
    tauSTINRValues=fun_tauSTINR_2(tauSINRValues,thetaValues);

    %initialize arrays for collecting statistics
    numbStreet_G=zeros(numbSimS,1);
    numbOpenRelay_G=zeros(numbSimS,1);
    numbOpenRelayUser_G=zeros(numbSimS,1);
    booleConnectRelay_G=false(numbSimS,numb_param1);
    booleConnectRelayUser_G=false(numbSimS,numb_param1);

    disp('Running connectivity model....');
    tic;
    for ss=1:numbSimS

        %generate a single street system
        [street_ss,end_ss]=funStreetVoronoiPoisson(lambdaS,scaleLength);


        %intiiate connectivity boolean vectors
        booleConnectRelay_ss=false(1,numb_param1);
        booleConnectRelayUser_ss=false(1,numb_param1);

        % street end indices using rows and columns
        indexStreetEndABC_P_ss=street_ss.indexStreetEndABC_P_S;
        indexStreetEndABC_Q_ss=street_ss.indexStreetEndABC_Q_S;

        % find shared ends
        indexEndCrossExtSharedJ_ss=end_ss.indexEndCrossExtSharedJ_E;
        indexEndCrossExtSharedK_ss=end_ss.indexEndCrossExtSharedK_E;

        %which street ends intersect with other street ends
        booleEndStreetABC_ss=end_ss.booleEndStreetABC_E;

        %START varying parameters
        for tt=1:numb_param1
            %retrieve current parameter
            pRelay_tt=pValues(tt);
            lambdaU_tt=lambdaValuesU(tt);
            thetaInter_tt=thetaValues(tt);
            tauSTINR_tt=tauSTINRValues(tt);
            ratioNoise_tt=ratioNoiseValues(tt);
            beta_tt=betaValues(tt);
            kappa_tt=kappaValues(tt);

            %anonymous function with the path loss data
            funPathloss_d=@(d)funPathloss_B_K(beta_tt,kappa_tt,d);

            %annoymous function for passing to funStreetRelayUserOpen
            funOpen_User_tt=@(XZ,indexTX,indexRX,I0)funOpen_User(tauSTINR_tt,thetaInter_tt,ratioNoise_tt, ...
                beta_tt,kappa_tt,...
                XZ,indexTX,indexRX,I0);



            %%%START Setting up relays and users START%%%
            %place relays on street system
            relay_ss=funRelayBinomial(end_ss,pRelay_tt);

            if lambdaU_Max>0
                %thinning probability (for users)
                probThinUser_tt=lambdaU_tt./lambdaU_Max;
            else
                probThinUser_tt=0;
            end
            %place users on street system
            lambdaU_tt=probThinUser_tt*lambdaU_Max;
            user_ss=funUserPoisson(street_ss,lambdaU_tt);
            numbUser_ss_tt=user_ss.numbUser_U; %number of users in ss layout
            %randomly permutate all users
            indexUserRand=randperm(numbUser_ss_tt);
            indexUser_ss_tt=user_ss.indexUser_U(indexUserRand);

            %%%END Setting up p up relays and users END%%%

            %%%START - Check relay-to-relay connectivity - START%%%
            %calculate signal strengths at all street ends
            sigEndStreetEnd_ss_tt=funSignalStreet(street_ss,end_ss,funPathloss_d);

            [stinrEndStreetRelay_PQ_ss_tt,interEndRelay_ss_tt]...
                =funRelaySTINR(street_ss,relay_ss,thetaInter_tt,ratioNoise_tt,sigEndStreetEnd_ss_tt);

            %find open streets based on relay-to-relay connectivity
            booleOpenRelay_ss_tt=funRelayOpen(tauSTINR_tt,stinrEndStreetRelay_PQ_ss_tt);

            %check if graph is connected (ie a horizontal or vertical crossing)
            booleConnected_ss_tt=funConnectedComp(street_ss,end_ss,booleOpenRelay_ss_tt);

            booleConnectRelay_ss(tt)=booleConnected_ss_tt;
            %%%END - Check relay-to-relay connectivity - END%%%

            %%%START - Calculate SINR values for users on streets - START%%%
            %number of users on each street in layout ss
            numbStreetUser_ss=user_ss.numbStreetUser_U;
            indexStreetUserCell_ss=mat2cell(-ones(numbUser_ss_tt,1),numbStreetUser_ss);
            countStreetUser_ss=zeros(size(numbStreetUser_ss)); %starting index

            %interference of relays and users
            interEndRelayUser_ss_tt=interEndRelay_ss_tt;

            for uuUser=1:numbUser_ss_tt
                %retrieve user index from list of user indices indexSim_U_ss
                indexUser_ss_uu=indexUser_ss_tt(uuUser);
                indexStreet_uu=user_ss.indexStreet_U(indexUser_ss_uu); %user's street index

                %update which streets users exist on
                countStreetUser_ss_uu=countStreetUser_ss(indexStreet_uu)+1;
                countStreetUser_ss(indexStreet_uu)=countStreetUser_ss_uu;
                indexStreetUserCell_ss{indexStreet_uu}(countStreetUser_ss_uu)=indexUser_ss_uu;

                % %retrieve indices for street ends P and Q
                % indexEndP_uu=user_ss.indexEndP_U(indexUser_ss_uu);
                % indexEndQ_uu=user_ss.indexEndQ_U(indexUser_ss_uu);
                % %ternary variable saying whether user is on extended street
                % ternUserExt_uu=user_ss.ternUserExt_U(indexUser_ss_uu);
                %
                % %retrieve distances relative to street ends (inside simulation
                % %window)
                % distEndUserP_uu=user_ss.distEndP_U(indexUser_ss_uu);
                % distEndUserQ_uu=user_ss.distEndQ_U(indexUser_ss_uu);
                % %signal powers experienced at street ends (not relays) P and Q
                % sigEndUserP_uu=funPathloss_B_K(beta_tt,kappa_tt,distEndUserP_uu);
                % sigEndUserQ_uu=funPathloss_B_K(beta_tt,kappa_tt,distEndUserQ_uu);
                % %TO EDIT: pre-calculate above terms
                %
                %
                %
                % indexStreetPQ_ABC_uu=[indexStreet_uu,indexStreet_uu];
                % booleEndQ_uu=[true(1),false(1)];
                %
                % %number of adjacent open streets in immediate neighbourhood
                % numbStreetNeigh=numel(indexStreetPQ_ABC_uu)-1;
                % rangeStreet=1:(numbStreetNeigh+1);
                % for iiStreet=rangeStreet
                %     indexStreet_uu_ii=indexStreetPQ_ABC_uu(iiStreet); %street index
                %
                %     %choose which street end (P or Q) for interference term
                %     if booleEndQ_uu(iiStreet)
                %         indexEndP_or_Q_uu=indexEndP_uu; %interference at P end
                %         sigEndP_or_Q_uu=sigEndUserP_uu;
                %     else
                %         indexEndP_or_Q_uu=indexEndQ_uu; %interference at Q end
                %         sigEndP_or_Q_uu=sigEndUserQ_uu;
                %     end
                %
                %
                % end %(iiStreet in rangeStreet loop)
                % %%%END Check adjacent streets END%%%

            end %end looping through users
            %%%END- Calculate SINR values for users on streets - END%%%

            %final connectivity due to users and relays
            [booleOpenRelayUser_ss,booleOpenRelayUserP_Q_ss,booleOpenRelayUserQ_P_ss]=...
                funRelayUserOpen(street_ss,relay_ss, user_ss,...
                interEndRelayUser_ss_tt,...
                countStreetUser_ss,indexStreetUserCell_ss,funOpen_User_tt);

            %run connectivity function to see if the network is connected
            [booleConnected_ss_uu_tt,~,~]=...
                funConnectedComp(street_ss,end_ss,booleOpenRelayUser_ss);

            booleConnectRelayUser_ss(tt)=booleConnected_ss_uu_tt;

        end
        %%%END varying parameters
        %update statistics on connected component (here for parfor loop)
        booleConnectRelay_G(ss,:)=booleConnectRelay_ss;
        booleConnectRelayUser_G(ss,:)=booleConnectRelayUser_ss;
    end
    toc;

    disp('Connectivity calculations completed.')
    %Start calculating statistics by using marginal statistics
    probConnectRelay=mean(booleConnectRelay_G,1);
    probConnectRelayUser=mean(booleConnectRelayUser_G,1);
    if U_Max==0
        %no user case
        probConnect=probConnectRelay;
    else
        probConnect=probConnectRelayUser;
    end

    if boolePlot
        %update model parameters array
        valueParamAll=[pValues(end),U_Values(end),thetaValues(end),...
            tauSINRValues(end),ratioNoiseValues(end),betaValues(end),kappaValues(end),ell_one];

        %%create title/label that gives parameter values
        indexVary=setdiff(1:numel(valueParamAll),choiceParam1);
        labelTitle='';
        for  tt=1:length(indexVary)
            vv=indexVary(tt);
            labelTitle= append(labelTitle,'$',labelParamAll{vv},' = ',sprintf(' %0.4g',valueParamAll(vv)),'$',labelSepAll(tt));
        end

        figure;
        plot(paramValues,probConnect, 'r.');
        ylim([0,1]);
        %add labels and title to second plot
        xlabel(label_x);
        ylabel('Connected Probability');
        title(labelTitle); %add descriptive title


    end
    if booleWrite
        %create directories
        strFormat=append('-%0.%',string(numbDigitsPrint),'f');
        str_kk=append(pathParamAll{choiceParam2},sprintf( '-%0.10f',valueParamAll(choiceParam2)));
        pathResultsTimePlot_kk=append(pathResultsTime,strPlots,str_kk,'/');
        mkdir(pathResultsTimePlot_kk);
        %filename base for figures
        strFileName='FigProbConnect_';
        %saving figures
        savefig(append(pathResultsTimePlot_kk,strFileName,str_kk,'.fig')); %save figure
        ax = gca;
        %export figure as jpg and put in simulation root directory
        exportgraphics(ax,append(pathResultsTimePlot_kk,strFileName,str_kk,".png"));
        exportgraphics(ax,append(pathResultsTimePlot_kk,strFileName,str_kk,".eps"));
        exportgraphics(ax,append(pathResultsTime,strFileName,str_kk,".png"));

        strParam1=pathParamAll{choiceParam1};
        %write parameters to file of connection to file
        writematrix(paramValues,append(pathResultsTimePlot_kk,strParam1,'_Values_',str_kk,'.csv'));
        %write probability of connection to file
        writematrix(probConnect,append(pathResultsTimePlot_kk,'probConnect_',str_kk,'.csv'));
        writematrix(probConnect,append(pathResultsTime,'probConnectAll_',strParam1,'.csv'),'WriteMode','append');
        writematrix(probConnect,append(pathResultsTime,'probConnectAll_',strParam1,'.xls'),'WriteMode','append');
        writematrix(paramValues,append(pathResultsTime,pathParamAll(choiceParam1),'_ValuesAll.csv'),'WriteMode','append');
        writematrix(paramValues,append(pathResultsTime,pathParamAll(choiceParam1),'_ValuesAll.xls'),'WriteMode','append');

        %record parameters
        tableParameters_kk=table(numbSimS,scaleLength,lambdaS,gammaS,ell_one,pMax,...
            U_Max,thetaMax,tauSINRMax,ratioNoiseMax,betaMax,kappaMax,...
            choiceParam1,choiceParam2);
        %save parametrs as csv file
        writetable(tableParameters_kk,append(pathResultsTimePlot_kk,'tableSimParameters_',str_kk,'.csv'));
        writetable(tableParameters_kk,append(pathResultsTimePlot_kk,'tableSimParameters_',str_kk,'.xls'));

        beta_kk=betaValues(kk);
        kappa_kk=kappaValues(kk);

        %save function as string
        str_funPathLoss=replace(func2str(funPathloss_B_K),'@(d)','f(d) = ');
        str_funPathLoss=append('The path loss function is ', str_funPathLoss);
        str_funPathLoss=append(str_funPathLoss,sprintf(',where beta = %0.3g',beta_kk),...
            sprintf(' and K = %0.3g',kappa_kk), '.');
        writelines(str_funPathLoss,append(pathResultsTimePlot_kk,'funPathLoss.txt'));

        close all;

    end



end
