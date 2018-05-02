function f_out = crop_fit_size_center(f, target_size)
% size(f) and target_size must be odd

sf = size(f);
shift = (sf - target_size)/2;
f_out = f(ceil(shift(1))+1:end-floor(shift(1)), ceil(shift(2))+1:end-floor(shift(2)), ceil(shift(3))+1:end-floor(shift(3)));

end

