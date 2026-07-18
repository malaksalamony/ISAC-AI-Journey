function resolution = calculateRadarRes(bandwidth_MHz)
    % Calculates radar range resolution in meters
    c = 3e8; % Speed of light
    bandwidth = bandwidth_MHz * 1e6;
    resolution = c / (2 * bandwidth);
end
