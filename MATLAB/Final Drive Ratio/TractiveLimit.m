function [tractive_limit] = TractiveLimit(velocity, effective_mass, tractive_data)
    % Tractive limit in newtons
    tractive_limit = interp1(tractive_data(2,:), tractive_data(1,:), velocity, 'spline');
    tractive_limit = tractive_limit * 9.8 * effective_mass;
    % tractive_limit = 10000;

end 