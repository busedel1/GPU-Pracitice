#include <stdio.h>
#include <cuda_runtime.h>

__global__ void Kernel

(
    double* u1,
    double* v1,
    double a,
    double b,
    double eta,
    double d_u1,
    double d_v1,
    double dt,
    double D,
    int N
)

{
      
    int tidx = threadIdx.x;
    int tidy = threadIdx.y;
    int bidx = blockIdx.x;
    int bidy = blockIdx.y;
    int bdimx = blockDim.x;
    int bdimy = blockDim.y;

    int x = tidx+bidx*bdimx;
    int y = tidy+bidy*bdimy;
    int id = x + y*N;
    
    double u1_c,v1_c;
    
    u1_c=u1[id];
    v1_c=v1[id];

    //lap_Du1R
    double u1_l,u1_r,u1_u,u1_d,lap_Du1;
    if(x==0)   u1_l=u1[id+(N-1)];
    else       u1_l=u1[id-1]; 
    if(x==N-1) u1_r=u1[id-(N-1)];
    else       u1_r=u1[id+1];
    if(y==0)   u1_u=u1[id+N*(N-1)];
    else       u1_u=u1[id-N];
    if(y==N-1) u1_d=u1[id-N*(N-1)];
    else       u1_d=u1[id+N];
    lap_Du1=u1_l+u1_r+u1_u+u1_d-u1_c*4.0;

    //lap_Du1I
    double v1_l,v1_r,v1_u,v1_d,lap_Dv1;
    if(x==0)   v1_l=v1[id+(N-1)];
    else       v1_l=v1[id-1]; 
    if(x==N-1) v1_r=v1[id-(N-1)];
    else       v1_r=v1[id+1];
    if(y==0)   v1_u=v1[id+N*(N-1)];
    else       v1_u=v1[id-N]; 
    if(y==N-1) v1_d=v1[id-N*(N-1)];
    else       v1_d=v1[id+N];
    lap_Dv1=v1_l+v1_r+v1_u+v1_d-v1_c*4.0;


    //reaction
    double react_u1,react_v1;
    react_u1=eta*( a-(b+1.0)*u1_c + u1_c*u1_c*v1_c );
    react_v1=eta*( b*u1_c - u1_c*u1_c*v1_c );

    //main
    u1[id] = u1_c+dt*react_u1+d_u1*D*lap_Du1;
    v1[id] = v1_c+dt*react_v1+d_v1*D*lap_Dv1;
  

}
