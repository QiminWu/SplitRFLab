function [errbar_phi,errbar_t,Ccrit] = geterrorbars(Tcomp, Cmatrix, Cresult)
% estimate Degrees-of-Freedom and calculate 95% confidence interval

ndf = getndf(Tcomp,length(Tcomp),length(Tcomp));
HatNDF = ndf/length(Tcomp);%In the absense of correlation, this number should approach 1.0 (HATNDF << 1.0 is bad)


K = 2;%Nuber of model parameters
if ndf <=K
    disp('  NDF <= K... There is no resolution of the 95% confidence region; Continuing')
    errbar_phi = [nan nan];
    errbar_t   = [nan nan];
    Ccrit = Cresult;
else
    
    %fisher transformation
    Z     = atanh(Cresult);
    Zcrit = Z + (  Z*K*sign(Z) / (ndf-K) * inv_f(K,ndf-K)  ) * sqrt(1/(ndf-3));

    %back transformation
    Ccrit = tanh(Zcrit);

    %% reconstruct grid
    f     = size(Cmatrix);
    dphi  = 180/(f(1)-1); %grid size in phi direction
    dt    = 4/(f(2)-1);   %grid size in dt direction

    [cols, rows] = incontour(Cmatrix,Ccrit);

    errbar_phi = (rows-1) * dphi-90;
    errbar_t   = (cols-1) * dt;
end









%%
function NDF = getndf(S, n, norig)
% A array is assumed to contain a possibly interpolated time series
% of length n.  The length of the original uninterpolated time series
% is NORIG.  ndf_spect computes the effective
% number of degrees of freedom in A, which for a gaussian white noise
% process should be equal to norig.  The true ndf should be less than
% NORIG

% First apply a cosine taper at the ends (taper length 20% of the time window)
tap = fliplr(linspace(0,1,n*0.2))';
A   = S;
A(1:length(tap))         = A(1:length(tap))         .* (cos(tap*pi)+1)/2;
A(end-length(tap)+1:end) = A(end-length(tap)+1:end) .* (cos(fliplr(tap)*pi)+1)/2;

OUT = fft(A);




%%
% calculate the Number of Degrees-Of-Freedom of a summed and squared time
% series with spectrum array A. A is assumed to be a complex function of
% frequency with A[0] corresponding to zero frequency and A[N-1]
% corresponding to the Nyquist frequency.  If A[t] is gaussian distributed
% then ndf_spect should be the points in the original time series 2*(N-1).

mag = abs(OUT);

F2 = sum(mag.^2);
F4 = sum(mag.^4);

F2 = F2-.5*mag(1).^2-.5*mag(end).^2;
F4 = F4-.5*mag(1).^4-.5*mag(end).^4;

% based on theory, the following expression should yield
% the correct number of degrees of freedom.(see appendix of silver
% and chan, 1990.  In practise, it gives a value that gives
% a df that is slightly too large.  eg 101 for an original time
% series of 100.  This is due to the fact that their is a slight
% positive bias to the estimate using only the linear term.

NDF = round(2*(2*F2*F2/F4 -1) + 0.5);

if NDF > norig
    error('get_ndf: NDF > NORIG')
    return
end



%%
function data = inv_f(nu1,  nu2)
%using tablelook up for finding the Inverse of the F cumulative
%distribution function. First Degree of Freedom in our case is always 2
%(2 independant parameter: phi, dt. The second degree of fredom was estimated
% from transverse component

if nu2>100, nu2 = 100; end %using last value in table, no big change

%table created with MATLAB statistics Toolbox Command:
% fdata = finv(0.95,2,1:100)';
data=[...
    199.5000
    19.0000
    9.5521
    6.9443
    5.7861
    5.1433
    4.7374
    4.4590
    4.2565
    4.1028
    3.9823
    3.8853
    3.8056
    3.7389
    3.6823
    3.6337
    3.5915
    3.5546
    3.5219
    3.4928
    3.4668
    3.4434
    3.4221
    3.4028
    3.3852
    3.3690
    3.3541
    3.3404
    3.3277
    3.3158
    3.3048
    3.2945
    3.2849
    3.2759
    3.2674
    3.2594
    3.2519
    3.2448
    3.2381
    3.2317
    3.2257
    3.2199
    3.2145
    3.2093
    3.2043
    3.1996
    3.1951
    3.1907
    3.1866
    3.1826
    3.1788
    3.1751
    3.1716
    3.1682
    3.1650
    3.1619
    3.1588
    3.1559
    3.1531
    3.1504
    3.1478
    3.1453
    3.1428
    3.1404
    3.1381
    3.1359
    3.1338
    3.1317
    3.1296
    3.1277
    3.1258
    3.1239
    3.1221
    3.1203
    3.1186
    3.1170
    3.1154
    3.1138
    3.1123
    3.1108
    3.1093
    3.1079
    3.1065
    3.1052
    3.1038
    3.1026
    3.1013
    3.1001
    3.0989
    3.0977
    3.0966
    3.0954
    3.0943
    3.0933
    3.0922
    3.0912
    3.0902
    3.0892
    3.0882
    3.0873];

data=data(nu2);

