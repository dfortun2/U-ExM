function mat = eulerAnglesToRotation3d_zxz(phi, theta, psi, varargin)

if size(phi, 2) == 3
    theta   = phi(:, 2);
    psi     = phi(:, 3);
    phi     = phi(:, 1);
end

k = pi / 180;
rotX = createRz(psi * k);
rotY = createRx(theta * k);
rotZ = createRz(phi * k);

mat = rotZ * rotY * rotX;
