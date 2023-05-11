%This function checks that relay-to-user communication is possible.
%
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


function [booleOpenRelayUser_ss,booleOpenRelayUserP_Q_ss,booleOpenRelayUserQ_P_ss]=...
    funRelayUserOpen(street_ss,user_ss,relay_ss,...
    interEndRelayUser_ss,...
    countStreetUser_ss,indexStreetUserCell_ss,funOpen_User_Input)

booleEndRelay_ss=relay_ss.booleEndRelay_R;

% street lengths
lengthStreet_ss=street_ss.lengthStreet_S;
% add truncated street segments
lengthStreetP_ss=street_ss.lengthStreetP_S;
lengthStreetQ_ss=street_ss.lengthStreetQ_S;

% distance from street end Q to (possibly truncated) relay associated with P
distStreetRelayP_ss=-lengthStreetP_ss;
% similarly from street end P to (possibly truncated) relay associated with Q
distStreetRelayQ_ss=lengthStreet_ss+lengthStreetQ_ss;

%rows for street ends P and Q
rowStreetEndP_ss=street_ss.rowStreetEndP_S;
rowStreetEndQ_ss=street_ss.rowStreetEndQ_S;

distEndP_U_ss=user_ss.distEndP_U;
%distEndQ_U_ss=user_ss.distEndQ_U;

booleOpenRelayUserP_Q_ss=false(size(lengthStreet_ss));
booleOpenRelayUserQ_P_ss=false(size(lengthStreet_ss));
numbStreet_ss=numel(lengthStreet_ss);
for indexStreet_rr=1:numbStreet_ss
    countStreetUser_ss_rr=countStreetUser_ss(indexStreet_rr);

    %length of street
    lengthStreet_rr=lengthStreet_ss(indexStreet_rr);

    %retrieve indices for street ends P and Q
    indexEndP_rr=rowStreetEndP_ss(indexStreet_rr);
    indexEndQ_rr=rowStreetEndQ_ss(indexStreet_rr);

    %relative distances (from street ends to relays)
    distStreetRelayP_rr=distStreetRelayP_ss(indexStreet_rr);
    distStreetRelayQ_rr=distStreetRelayQ_ss(indexStreet_rr);

    if countStreetUser_ss_rr>0
        indexUser_ss_rr=indexStreetUserCell_ss{indexStreet_rr}(1:countStreetUser_ss_rr);
        %retrieve distances relative to street ends (inside simulation
        %window)
        distEndUserP_uu=distEndP_U_ss(indexUser_ss_rr);
        %retrieve and sort distances distances from street end P
        distEndP_U_uu=sort(distEndUserP_uu); %sort distances
        %distances from end P
        distEndP_U_Q_uu=[distStreetRelayP_rr;distEndP_U_uu;distStreetRelayQ_rr];

    else
        distEndP_U_Q_uu=[distStreetRelayP_rr;distStreetRelayQ_rr];
    end

    %distances from end Q
    distEndQ_U_P_uu=(lengthStreet_rr-distEndP_U_Q_uu);

    %streets to search (for checking connection both directions)
    booleEndQ_uu=[true(1),false(1)];
    for iiStreetWay=1:2
        %choose which street end (P or Q) for interference term
        if booleEndQ_uu(iiStreetWay)
            xz=distEndP_U_Q_uu;
            indexEndP_or_Q_uu=indexEndP_rr; %interference at P end
        else
            xz=distEndQ_U_P_uu;
            indexEndP_or_Q_uu=indexEndQ_rr; %interference at Q end
        end

        %check if any relays are missing at either street end P or Q
        booleNoRelay=any(~booleEndRelay_ss([indexEndP_rr,indexEndQ_rr]));

        %%%START Connection model check START%%%
        if booleNoRelay
            %no connection without a relay at each street end
            booleOpenPQ_or_QP_uu=false;
        else

            % For truncated streets, the next section chooses either:
            % 1) the relay associated to the truncated street end
            % 2) a single user (if one exists) that is closest to the
            % truncated street end. (This means that connectivity is
            % possible with a single user just outside box.)
            % It's also assumed that users and relays have same initial
            % signal strength.

            %find the second transmitter (ie first one inside the window)
            indexSecondTX=find(distEndP_U_Q_uu>0,1);
            indexFirstTX=indexSecondTX-1;
            %last transmitter inside box
            indexLastTX=find(distEndP_U_Q_uu<lengthStreet_rr,1,'last');
            %indices for user and relay transmitters/receivers
            indexTX_xz=indexFirstTX:(indexLastTX);  %transmitters (then receivers)
            indexRX_xz=indexTX_xz+1; %receivers (then transmittters)

            %additional interference terms (from possible adjacent streets)
            interEndPQ_or_QP_uu=zeros(size(indexTX_xz));
            %interference at street ends P or Q
            interEndPQ_or_QP_uu(end)=interEndRelayUser_ss(indexEndP_or_Q_uu);

            %check if street is open (via every hop) in one direction
            booleOpenPQ_or_QP_uu=...
                all(arrayfun(@(s,t,inter_xz)funOpen_User_Input(xz,s,t,inter_xz),...
                indexTX_xz, indexRX_xz,interEndPQ_or_QP_uu));
        end
        %%%END Connection model check END%%%

        %update connectivity
        if booleEndQ_uu(iiStreetWay)
            %receiver is at street end Q
            booleOpenRelayUserP_Q_ss(indexStreet_rr)=booleOpenPQ_or_QP_uu;
        else
            %receiver is at street end P
            booleOpenRelayUserQ_P_ss(indexStreet_rr)=booleOpenPQ_or_QP_uu;
        end
    end %(iiStreet loop)
end
%check connectivity in both directions
booleOpenRelayUser_ss=booleOpenRelayUserP_Q_ss&booleOpenRelayUserQ_P_ss;
end
