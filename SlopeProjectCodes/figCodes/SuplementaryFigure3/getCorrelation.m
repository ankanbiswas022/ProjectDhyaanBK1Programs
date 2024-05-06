function getCorrelation(data1,subjects1,data2,subjects2,hPlot,hColor)

if ~exist('hPlot','var');  hPlot=gca;    end

d1 = []; d2 = [];
for i=1:length(subjects1)
    if ~isnan(data1(i))
        posS2 = find(strcmp(subjects1{i},subjects2));
        if ~isempty(posS2)
            if ~isnan(data2(posS2))
                d1 = cat(2,d1,data1(i));
                d2 = cat(2,d2,data2(posS2));
            end
        end
    end
end

% plot the data
scatter(hPlot,d1,d2,[],hColor,'filled','o');
[r,p]= corrcoef(d1,d2);
text(max(d1),max(d2),['r=' num2str(r(1,2)) ',p=' num2str(p(1,2)) ',N=' num2str(length(d1))],'Color',hColor,'parent',hPlot);
% linear fit of the line
hold(hPlot,'on');
linearCoefficients = polyfit(d1,d2, 1);
xFit = linspace(min(d1), max(d1), 100);
yFit = polyval(linearCoefficients, xFit);
plot(hPlot,xFit, yFit,'LineStyle',":",'Color',hColor,'MarkerSize', 15,'LineWidth', 2);
end