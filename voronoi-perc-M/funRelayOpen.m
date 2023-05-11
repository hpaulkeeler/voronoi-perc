
function [booleOpenRelay_ss_tt,booleOpenRelayP_Q_ss_tt,booleOpenRelayQ_P_ss_tt]...
    =funRelayOpen(tauSTINR_tt,stinrEndStreetRelay_PQ_ss_tt)

%find which relay-to-relay connections are open in either direction
booleOpenRelayP_Q_ss_tt=stinrEndStreetRelay_PQ_ss_tt(:,1)>tauSTINR_tt;
booleOpenRelayQ_P_ss_tt=stinrEndStreetRelay_PQ_ss_tt(:,2)>tauSTINR_tt;

%boolean for open streets
booleOpenRelay_ss_tt=booleOpenRelayP_Q_ss_tt&booleOpenRelayQ_P_ss_tt;

end