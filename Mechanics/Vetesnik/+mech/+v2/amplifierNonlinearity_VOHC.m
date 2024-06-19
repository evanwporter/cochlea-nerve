function [ RHS ] = amplifierNonlinearity_VOHC( ~, vohc, N, ~, TMa, BMy, ~, nonlinearity, const_OHC_force)

fun  = BMy .* nonlinearity(const_OHC_force * vohc);
% fun  = - BMy .* nonlinearity(const_OHC_force * vohc);

RHS = [ ...
    zeros(N,1); ...
    -fun; ...
    zeros(N,1); ...
    TMa.*fun];

end