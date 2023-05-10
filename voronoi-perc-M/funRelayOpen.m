
function [booleOpenRelay_ss_tt,booleOpenRelayP_Q_ss_tt,booleOpenRelayQ_P_ss_tt]...
    =funRelayOpen(tauSTINR_tt,stinrEndStreetRelay_P_ss,stinrEndStreetRelay_Q_ss)

%find which relay-to-relay connections are open in either direction
booleOpenRelayP_Q_ss_tt=stinrEndStreetRelay_P_ss>tauSTINR_tt;
booleOpenRelayQ_P_ss_tt=stinrEndStreetRelay_Q_ss>tauSTINR_tt;

%boolean for open streets
booleOpenRelay_ss_tt=booleOpenRelayP_Q_ss_tt&booleOpenRelayQ_P_ss_tt;

end