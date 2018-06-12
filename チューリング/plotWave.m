function plotWave(h,h2,xx,yy,vv,vvold,xxx,yyy)
   % Copyright 2011 The MathWorks, Inc.
   vvv = interp2(xx,yy,vv,xxx,yyy);
   vvvdiff = interp2(xx,yy,vv-vvold,xxx,yyy);
   set(h,'ZData',vvv)
   set(h2,'ZData',vvvdiff)
   drawnow
end

