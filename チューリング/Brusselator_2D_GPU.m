%% 2D Coupled Brusselator model
function u1g=Brusselator_2D_GPU(h,hObject,hText,N,maxIter)

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

%gpu‚É•Ï”‚ðŠi”[
dt=gpuArray(dt);
eta=gpuArray(eta);
a=gpuArray(a);
b=gpuArray(b);
d_u1=gpuArray(d_u1);
d_v1=gpuArray(d_v1);
u1=gpuArray(u1);
v1=gpuArray(v1);

for t=1:maxIter
    
    if guiMode && ~isequal(get(hObject, 'Value'), on_state)
      break;
    end
   
    uu1c=u1;
    vv1c=v1;
    
    %lap
    uu1r_x=[uu1c(:,N) uu1c(:,1:N-1)];
    uu1l_x=[uu1c(:,2:N) uu1c(:,1) ];
    uu1u_y=[uu1c(N,:) ; uu1c(1:N-1,:)];
    uu1d_y=[uu1c(2:N,:) ; uu1c(1,:) ];
    lap_Du1=(uu1r_x+uu1l_x+uu1u_y+uu1d_y-4*uu1c);
    
    vv1r_x=[vv1c(:,N) vv1c(:,1:N-1)];
    vv1l_x=[vv1c(:,2:N) vv1c(:,1) ];
    vv1u_y=[vv1c(N,:) ; vv1c(1:N-1,:)];
    vv1d_y=[vv1c(2:N,:) ; vv1c(1,:) ];
    lap_Dv1=(vv1r_x+vv1l_x+vv1u_y+vv1d_y-4*vv1c);
    
    %main calc
    u1= uu1c...
        +dt*( eta*( a-(b+1.0)*uu1c + uu1c.*uu1c.*vv1c ) )...
        +d_u1*D*lap_Du1;
    
    v1= vv1c...
        +dt*( eta*( b*uu1c - uu1c.*uu1c.*vv1c ) )...
        +d_v1*D*lap_Dv1;
    
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
u1g=gather(u1);



