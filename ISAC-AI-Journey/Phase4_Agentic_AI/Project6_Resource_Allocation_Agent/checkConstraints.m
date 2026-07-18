function status = checkConstraints(capacity_Mbps, resolution_m)
    % Checks if ISAC design targets are met
    if capacity_Mbps >= 100 && resolution_m <= 1.2
        status = "PASSED: Targets achieved.";
    else
        status = sprintf("FAILED: Capacity = %.1f Mbps, Res = %.2fm.", capacity_Mbps, resolution_m);
    end
end
