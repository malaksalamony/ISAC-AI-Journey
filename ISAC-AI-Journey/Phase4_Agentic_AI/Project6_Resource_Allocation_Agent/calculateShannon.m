function capacity = calculateShannon(bandwidth_MHz, snr_dB)
    % Calculates Shannon Capacity in Mbps
    bandwidth = bandwidth_MHz * 1e6;
    snr_linear = 10^(snr_dB / 10);
    capacity = (bandwidth * log2(1 + snr_linear)) / 1e6; % Convert to Mbps
end
