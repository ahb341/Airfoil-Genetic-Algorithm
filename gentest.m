genmaxs = [0.2,  0.2,    0.2,  0.2,   0.2,     0.2,  0.2,  0.1];
genmins = [0.0,  0.0,    0.0,  0.0,   0.0,     0.0,  0.0,  0.0];
num_coords = 100;
upx = [0 0 0.25 0.5 0.75 1];
downx = upx;

upy = zeros(1,6);
downy = zeros(1,6);

gen = [];
for i=1:length(genmaxs)
    gen(i) = rand*(genmaxs(i)-genmins(i))-genmins(i);
end

% Leading edge
upy(2) = gen(1);
downy(2) = -gen(2)

% Camber + thickness
upy(3) = gen(3) + gen(6);
upy(4) = gen(4) + gen(7);
upy(5) = gen(5) + gen(8);

downy(3) = gen(3) - gen(6);
downy(4) = gen(4) - gen(7);
downy(5) = gen(5) - gen(8);

upper = []; lower = [];
for i = 1:length(upx)
    upper(i,:) = [upx(i) upy(i)];
    lower(i,:) = [downx(i) downy(i)];
end
upperaf = Bezier(upper, num_coords);
loweraf = Bezier(lower, num_coords);
dna.af = [upperaf; loweraf];