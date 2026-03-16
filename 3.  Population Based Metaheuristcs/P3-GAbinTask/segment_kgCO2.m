function e_kgCO2 = segment_kgCO2(dist_i, slope_i, speed_i, time_i, accel_i, params)
    m_truck    = params(1);
    A_n        = params(2);
    g          = params(3);
    rho_air    = params(4);
    C_rr       = params(5);
    C_df       = params(6);
    eta_IC_peak = params(11);
    kgCO2_conv = params(12);
    eta_IC_min = params(13);
    v_opt      = params(14);
    v_scale    = params(15);
    alpha_v    = params(16);
    P_rated    = params(17);
    load_opt   = params(18);
    load_scale = params(19);
    alpha_l    = params(20);

    % Forces [N]
    Fd = (rho_air * A_n * C_df / 2) * speed_i^2;
    Fr = g * C_rr * cos(slope_i) * m_truck;
    Fh = g * sin(slope_i) * m_truck;
    Fa = accel_i * m_truck;

    % Power [W]
    P = (Fd + Fr + Fh + Fa) * speed_i;

    % Variable ICE efficiency
    f_speed = max(0.3, min(1.0, 1 - alpha_v * ((speed_i - v_opt) / v_scale)^2));
    P_norm  = min(1.5, max(0.01, abs(P) / P_rated));
    f_load  = max(0.4, min(1.0, 1 - alpha_l * ((P_norm - load_opt) / load_scale)^2));
    eta_IC  = max(eta_IC_min, min(eta_IC_peak, eta_IC_peak * f_speed * f_load));

    % CO2 emissions [kgCO2]
    e_kgCO2 = (P / eta_IC) * (time_i / 1000) * kgCO2_conv;

    % No negative emissions
    if e_kgCO2 < 0
        e_kgCO2 = 0;
    end
end