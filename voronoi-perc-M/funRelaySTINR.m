
function [stinrEndStreetRelay_P_ss,stinrEndStreetRelay_Q_ss,interEndRelay_ss]...
    =funRelaySTINR(street_ss,relay_ss,booleEndRelay_ss,thetaInter_tt,ratioNoise_tt,sigEndStreetEnd_ss)


% street end indices using rows and columns
indexStreetEndABC_P_ss=street_ss.indexStreetEndABC_P_S;
indexStreetEndABC_Q_ss=street_ss.indexStreetEndABC_Q_S;
booleRelayStreetABC_ss=relay_ss.booleRelayStreetABC_R;


%%%START - Calculate STINR values for relays at street ends - START%%%
% booleRelayStreetABC_ss=booleEndStreetABC_ss;
% %a relay can only receive a signal if it is at a street end
booleRelayStreetABC_ss(~booleEndRelay_ss,:)=false;

%power values for current relays
sigEndStreetRelay_ss=sigEndStreetEnd_ss; %initial power values
sigEndStreetRelay_ss(~booleRelayStreetABC_ss)=0; %switch off relays

%total interference at street end
interEndRelay_ss=sum(sigEndStreetRelay_ss,2);

%calculatue the STINR at each street end using a function
stinrEndStreetRelay_ss=funSTINR_Relay(thetaInter_tt,ratioNoise_tt,sigEndStreetRelay_ss);
stinrEndStreetRelay_P_ss=stinrEndStreetRelay_ss(indexStreetEndABC_P_ss);
stinrEndStreetRelay_Q_ss=stinrEndStreetRelay_ss(indexStreetEndABC_Q_ss);
%%%END - Calculate STINR values for relays at street ends - END%%%

    function stinrEndStreetRelay=funSTINR_Relay(thetaInter,ratioNoise,sigEndStreetRelay)
        %STINR function (takes signals of relays at street ends)
        %funSTINR_Relay=@(theta,ratioNoise,P)(P./(theta*(repmat(sum(P,2),1,3))+ratioNoise));
        %stinrEndStreetRelay=funSTINR_Relay(thetaInter_tt,ratioNoise_tt,sigEndStreetRelay_ss);
        stinrEndStreetRelay=(sigEndStreetRelay./(thetaInter*(repmat(sum(sigEndStreetRelay,2),1,3))+ratioNoise));
        

    end


end