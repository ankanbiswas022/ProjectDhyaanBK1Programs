function makeShadedRegion(hPlot,x,y,color,faceAlphaVal)
% plot it at the end of all plots
    if ~exist('faceAlphaVal','var') faceAlphaVal=0.3;   end
    xx = [x(1) x(1) x(2) x(2)];
    yy = [y(1)  y(2) y(2) y(1)];
    axes(hPlot);
    patch(xx,yy,color,'LineStyle','none','FaceAlpha',faceAlphaVal);
     h = get(hPlot,'Children');
    set(hPlot,'Children',circshift(h,length(h)-1));
end