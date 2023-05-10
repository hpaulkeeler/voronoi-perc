
function booleEndRelay_ss=funRelayThin(pRelay_tt,relay_ss,end_ss)

numbEnd_R=relay_ss.numbEnd_R;

% find shared ends
indexEndCrossExtSharedJ_ss=end_ss.indexEndCrossExtSharedJ_E;
indexEndCrossExtSharedK_ss=end_ss.indexEndCrossExtSharedK_E;

%randomly select a subset of relays
booleRelayRand=rand(numbEnd_R,1)<=pRelay_tt;
% two truncated ends can share a common trunucated crossroads /relay
booleRelayRand(indexEndCrossExtSharedJ_ss)=booleRelayRand(indexEndCrossExtSharedK_ss);
indexEndRelay_ss_tt=relay_ss.indexEndRelay_R(booleRelayRand);
booleEndRelay_ss=false(numbEnd_R,1);
booleEndRelay_ss(indexEndRelay_ss_tt)=true;



end