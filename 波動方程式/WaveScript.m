%% Solving 2nd Order Wave Equation on the GPU Using Spectral Methods 
% This example solves a 2nd order wave equation: utt = uxx + uyy, with u =
% 0 on the boundaries. It uses a 2nd order central finite difference in
% time and a Chebyshev spectral method in space (using FFT). The code has
% been modified from an example in Spectral Methods in MATLAB by Trefethen,
% Lloyd N. It shows running on the GPU using gpu-arrays and built-in
% functions available for the GPU.

% Copyright 2011 The MathWorks, Inc.

%% Verifying Hardware
% To run this demo, you need to have a supported GPU card. See the
% documentation for more information. The command |gpuDevice| or
% |gpuDeviceCount| can be used to see if your machine has a supported GPU
% card.

try
   g = gpuDevice;
   g.Name
catch ME
   error(ME.identifier, ME.message);
end

%% Setting up Parameters
% The performance highly depends on the grid size of the problem.

N = 256;     % Solve on a NxN grid
Nstep = 100; % Number of time steps calculated

%% Running on the CPU

tic
vv = WaveEqn_CPU(N, Nstep);
t1a = toc;
fprintf('Elapsed time is %0.2f seconds.\n', t1a);

%% Running on the GPU

tic
vv2 = WaveEqn_GPU(N, Nstep);
t2a = toc;
fprintf('Elapsed time is %0.2f seconds.\n', t2a);

%% Small Grid Size (N = 64)

N = 64;
tic
vv = WaveEqn_CPU(N, Nstep);
t1b = toc;
fprintf('CPU: Elapsed time is %0.2f seconds.\n', t1b);

tic
vv = WaveEqn_GPU(N, Nstep);
t2b = toc;
fprintf('GPU: Elapsed time is %0.2f seconds.\n', t2b);

%% Large Grid Size (N = 512)

N = 512;
tic
vv = WaveEqn_CPU(N, Nstep);
t1b = toc;
fprintf('CPU: Elapsed time is %0.2f seconds.\n', t1b);

tic
vv = WaveEqn_GPU(N, Nstep);
t2b = toc;
fprintf('GPU: Elapsed time is %0.2f seconds.\n', t2b);

%% Show benchmark information
% Here is a plot of a benchmark study that was done previously. The two
% graphs are for the same benchmark data, plotted with different scales
% (linear and log). You can see that GPU shows a much better performance as
% you increase the size of data. For small data sizes, the overhead of
% transferring data back and forth between the main memory and the GPU device
% memory becomes significant, and CPU shows a better performance.

benchPlot()
