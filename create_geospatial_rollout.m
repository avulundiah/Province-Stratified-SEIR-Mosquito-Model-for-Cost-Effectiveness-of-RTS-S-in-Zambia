% Avulundiah Edwin Phiri: 26 August 2025
function create_geospatial_rollout()
    zambia_shp = shaperead('gadm41_ZMB_1.shp'); % From GADM.org
    fig = figure('Position', [100, 100, 1000, 800]);
    ax = usamap('zambia');
    geoshow(ax, zambia_shp, 'FaceColor', [0.9 0.9 0.9])
    title('Zambia Malaria Vaccination Rollout Strategy')
    
    % Plot priority levels
    priority_colors = [
        0.9 0.2 0.2;   % Phase 1 (Red)
        1.0 0.6 0.2;   % Phase 2 (Orange)
        1.0 0.9 0.3;   % Phase 3 (Yellow)
        0.6 0.8 0.4;   % Phase 4 (Light Green)
        0.3 0.7 0.5    % Phase 5 (Green)
    ];
    
    % Add province-level data
    for i = 1:length(zambia_shp)
        province_name = zambia_shp(i).NAME_1;
        idx = find(strcmp(provinceData(:,1), province_name));
        
        % Color by priority
        geoshow(zambia_shp(i), 'FaceColor', priority_colors(provinceData{idx,5},:))
        
        % Add EIR and ICER labels
        centroid = mean(zambia_shp(i).BoundingBox);
        textm(centroid(2), centroid(1), ...
            sprintf('EIR: %d\nICER: $%d', provinceData{idx,4}, provinceData{idx,6}), ...
            'HorizontalAlignment', 'center', 'FontSize', 9)
    end
    
    % Add transmission intensity heatmap
    [latgrid, longrid] = meshgrid(-18:0.5:-8, 22:0.5:34);
    eir_grid = create_transmission_surface(latgrid, longrid); % Custom function
    geoshow(latgrid, longrid, eir_grid, 'DisplayType', 'texturemap', 'FaceAlpha', 0.4)
    colormap(jet)
    c = colorbar;
    c.Label.String = 'Entomological Inoculation Rate (EIR)';
    
    % Add rollout phase legend
    legend_labels = {'Phase 1 (2024-2025)', 'Phase 2 (2025-2026)', ...
                    'Phase 3 (2026-2027)', 'Phase 4 (2027-2028)', 'Phase 5 (2029-2030)'};
    lgd = legend(legend_labels, 'Location', 'southoutside', ...
                'Orientation', 'horizontal', 'FontSize', 10);
    title(lgd, 'Vaccination Rollout Timeline')
    
    % Add policy annotations
    textm(-13.5, 25.5, 'Prioritize cold-chain\ninfrastructure', ...
          'BackgroundColor', 'white', 'FontSize', 8)
    textm(-10, 31, 'Pre-rainy season\nvaccination pulses', ...
          'BackgroundColor', 'white', 'FontSize', 8)
    
    % Add data sources
    annotation('textbox', [0.1 0.02 0.8 0.04], 'String', ...
        'Data Sources: Zambia Ministry of Health (2023), NMEC Surveillance Reports, GADM.org', ...
        'EdgeColor', 'none', 'FontSize', 8)
end

function eir_surface = create_transmission_surface(lat, lon)
    % Simulated EIR surface (replace with real spatial model)
    eir_base = 30 + 50*exp(-((lat+13).^2/5 + (lon-28).^2/15));
    rainfall_effect = 20*exp(-((lat+15).^2/8 + (lon-25).^2/10));
    eir_surface = eir_base + rainfall_effect;

end
