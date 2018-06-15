%% 2D Coupled Brusselator model
function u1=Brusselator_2D_CPU(h,hObject,hText,N,maxIter)

if nargin <= 2
    guiMode = false;
    N = h;
    if nargin == 1
        maxIter = 4000;
    else
        maxIter = hObject;
    end
else
    guiMode = true;
    
    on_state = get(hObject,'Max');
end

% CUDA
kernel=parallel.gpu.CUDAKernel('Brusselator_2D.ptx','Brusselator_2D.cu');
kernel.GridSize=[16 16];
kernel.ThreadBlockSize=[int64(N/16) int64(N/16) 1]; 

L=32;
dt=1e-3;
hxy=L/(N-1);
D=dt/(hxy*hxy);

%model param
a=4; b=12; eta=1;
d_1 = 0.37;
% du,v transform
d_u1=d_1; d_v1=1.0;

%initial value
u1=a+1*(2*rand(N,N)-1);
v1=b/a+1*(2*rand(N,N)-1);
t=1;
tic;

if guiMode
    
    plotstep=10;
    [xxx,yyy] = meshgrid(0:hxy:L,0:hxy:L); % grid for plotting
    sh= surf(h,xxx,yyy,u1);
    hold(h,'on')
    sh2= imagesc(h,xxx(1,:),yyy(:,1),u1);
    sh.ZData=u1;
    sh2.CData=u1;
    set(hText, 'String', '0');
    
end

for t=1:maxIter
    
    if guiMode && ~isequal(get(hObject, 'Value'), on_state)
      break;
    end
    
    [u1,v1]=feval(kernel,u1,v1,a,b,eta,d_u1,d_v1,dt,D,N);
    
     % plot every plotstep iterations
   if guiMode && mod(t,plotstep) == 0
      u1g=gather(u1);
      sh.ZData=u1g;
      sh2.CData=u1g;
%       caxis(h2, [a-1/2 a+1/2]);
      set(hText,'String',num2str(t));
      drawnow
   end
   
end


