function plotcorr(series)
    subplot(211); autocorr(series);
    subplot(212); parcorr(series);
end