% I es grayscale
function features = extractImageFeatures(Igray, radonTheta, invariantCount)

    radon_projections = 0:radonTheta:180;
    if 180/ radonTheta == 0
        radon_projections = radon_projections(1:end-1);
    end

    [R, xp] = radon(Igray, radon_projections);
    % figure; plot(xp,R(:,1:18)); title('R_{0^o} (x\prime)')

    % figure, imagesc(theta,xp,R)
    % colormap(hot)
    % colorbar
    % xlabel('Parallel Rotation Angle - \theta (degrees)');
    % ylabel('Parallel Sensor Position - x\prime (pixels)');

    % a_array = [1/18 4/18 8/18 13/18];
    a_array = 0:1/invariantCount:1;
    a_array = a_array(2:end);
    features = [];
    [~, cols] = size(R); % no interesa la cant de filas
    for proj = 1:cols
%         fprintf('calculating bispectrum for %d degress projection...\n', theta(proj));
        radon_data = R(:, proj);
        [B, w] = bispecd(radon_data);

        P_a = zeros(1,4); % 1 row, 4 columns

        n = 1;
        for a = a_array
            P_a(n) = extractInvariant(B, w, a);
            n = n + 1;
        end
%         fprintf('Feature values = '); fprintf('%f ', P_a); fprintf('\n');
        features = horzcat(features, P_a);
    end

    fprintf('Features = '); fprintf('%f ', features); fprintf('\n');
end