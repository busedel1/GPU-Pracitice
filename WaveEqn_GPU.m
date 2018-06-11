function vvg = WaveEqn_GPU(h,h2,hObject,hText,N,maxIter)
%% Solving 2nd Order Wave Equation Using Spectral Methods
% This example solves a 2nd order wave equation: utt = uxx + uyy, with u =
% 0 on the boundaries. It uses a 2nd order central finite difference in
% time and a Chebyshev spectral method in space (using FFT). The code has
% been modified from an example in Spectral Methods in MATLAB by Trefethen,
% Lloyd N.

% Copyright 2011 The MathWorks, Inc.

if nargin <= 2
   guiMode = false;
   N = h;
   if nargin == 1
      maxIter = 4000;
   else
      maxIter = h2;
   end
else
   guiMode = true;
   
   on_state = get(hObject,'Max');
end

x = cos(pi*(0:N)/N); % using Chebyshev points
y = x';
dt = 6/N^2;

[xx,yy] = meshgrid(x,y);

vv = exp(-40*((xx-.4).^2 + yy.^2));
vvold = vv;
ii = 2:N;

if guiMode
   plotstep = 10;
   
   [xxx,yyy] = meshgrid(-1:1/16:1,-1:1/16:1); % grid for plotting
   ylim = 5e4*10^-(log2(N));
   
   sh  = surf(h , xxx, yyy, zeros(size(xxx)));
   sh2 = surf(h2, xxx, yyy, zeros(size(xxx)));
   axis(h , [-1 1 -1 1 -0.1 1]);
   axis(h2, [-1 1 -1 1 -ylim ylim]);
   
   caxis(h, [-0.5 0.5]);
   caxis(h2, [-ylim/5 ylim/5]);
   
   plotWave(sh,sh2,xx,yy,vv,vvold,xxx,yyy)
   set(hText, 'String', '0');
end

% Weights used for spectral differentiation via FFT
index1 = 1i*[0:N-1 0 1-N:-1];
W1T = repmat(index1,length(ii),1);
index2 = -[0:N 1-N:-1].^2;
W2T = repmat(index2,length(ii),1);
index3 = 1i*[0:N-1 0 1-N:-1]';
W3T = repmat(index3,1,length(ii));
index4 = -[0:N 1-N:-1]'.^2;
W4T = repmat(index4,1,length(ii));

WuxxT1 = repmat((1./(1-x(ii).^2)),length(ii),1);
WuxxT2 = repmat(x(ii)./(1-x(ii).^2).^(3/2),length(ii),1);
WuyyT1 = repmat(1./(1-y(ii).^2),1,length(ii));
WuyyT2 = repmat(y(ii)./(1-y(ii).^2).^(3/2),1,length(ii));

uxx = parallel.gpu.GPUArray.zeros(N+1,N+1);
uyy = parallel.gpu.GPUArray.zeros(N+1,N+1);

% Converting variables to gpuArrays to get variables in GPU memory
dt = gpuArray(dt);
vv = gpuArray(vv);
W1T = gpuArray(W1T);
W2T = gpuArray(W2T);
W3T = gpuArray(W3T);
W4T = gpuArray(W4T);
WuxxT1 = gpuArray(WuxxT1);
WuxxT2 = gpuArray(WuxxT2);
WuyyT1 = gpuArray(WuyyT1);
WuyyT2 = gpuArray(WuyyT2);

% Start time-stepping
for n = 1:maxIter
   
   if guiMode && ~isequal(get(hObject, 'Value'), on_state)
      break;
   end
   
   V = [vv(ii,:) vv(ii,N:-1:2)];
   U = real(fft(V.')).';
   
   W1test = (U.*W1T).';
   W2test = (U.*W2T).';
   W1 = (real(ifft(W1test))).';
   W2 = (real(ifft(W2test))).';
   
   uxx(ii,ii) = W2(:,ii).* WuxxT1 - W1(:,ii).*WuxxT2;
   
   V = [vv(:,ii); vv((N:-1:2),ii)];
   U = real(fft(V));
   
   W1 = real(ifft(U.*W3T));
   W2 = real(ifft(U.*W4T));
   
   uyy(ii,ii) = W2(ii,:).* WuyyT1 - W1(ii,:).*WuyyT2;
   vvnew = 2*vv - vvold + dt*dt*(uxx+uyy);
   vvold = vv; vv = vvnew;
   
   % plot every plotstep iterations
   if guiMode && mod(n,plotstep) == 0
      vvg = gather(vv);
      vvoldg = gather(vvold);
      plotWave(sh,sh2,xx,yy,vvg,vvoldg,xxx,yyy)
      set(hText,'String',num2str(n));
   end
end

vvg = gather(vv);