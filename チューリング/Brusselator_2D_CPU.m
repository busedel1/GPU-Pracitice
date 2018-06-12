%% 2D Coupled Brusselator model
function u1=Brusselator_2D_CPU(h,hObject,hText,N,maxIter)

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

L=32;
dt=1e-3;
h=L/(N-1);
D=dt/(h*h);

%model param
a=4; b=12; eta=1;
eps_on=2.0;
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
%   [xxx,yyy] = meshgrid(1:L,1:L); % grid for plotting
%     sh  = surf(h , xxx, yyy, zeros(size(xxx)));
    surf(u1)
    axis([0 L 0 L a-1 a+1]);
%      caxis(h, [a-1 a+1]);
%     plotWave(sh,sh2,xx,yy,u1,xxx,yyy)
    set(hText, 'String', '0');
    
end

for t=1:maxIter
    
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
       surf(u1)
%       plotWave(sh,sh2,xx,yy,vv,vvold,xxx,yyy)
      set(hText,'String',num2str(t));
%        colorbar;
       caxis([a-1,a+1]);
      drawnow
   end
   
end


