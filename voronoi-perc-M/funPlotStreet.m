
function funPlotStreet(streetInput,windowTrunc,indexPlot)

if nargin<3
    indexPlot=1;
end

if nargin<2
    windowTrunc=[-1,-1,1,1]/2;
end

%retrieve dimensions of simulation window
xMin=windowTrunc(1);
yMin=windowTrunc(2);
xMax=windowTrunc(3);
yMax=windowTrunc(4);

xDelta=xMax-xMin;
yDelta=yMax-yMin;


dimBox=[xMin, yMin, xDelta, yDelta];

%prepare to plot streets
xxStreetEnd=[streetInput(indexPlot).xxEndP_S,...
    streetInput(indexPlot).xxEndQ_S]';
yyStreetEnd=[streetInput(indexPlot).yyEndP_S,...
    streetInput(indexPlot).yyEndQ_S]';

figure;
%plot streets
plot(xxStreetEnd,yyStreetEnd, '--k');
rectangle('Position',dimBox,'EdgeColor','k','LineWidth',2);
%remove ticks on x and y axes
xticks([]);
yticks([]);
set(gca,'xcolor','none','ycolor','none'); %remove axis lines
%square axis
%axis square;
%hold on;

end