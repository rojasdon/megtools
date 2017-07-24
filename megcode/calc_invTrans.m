function Tinv = calc_invTrans(Tmtx)

r0 = Tmtx(1:3,4); %translation vector
A = Tmtx(1:3,1:3); %rotation matrix

%Invert rotation matrix
% Actually for rotation matrix it's just a transpose, but to be on a safe side
% (for example rotation and scaling) use inv()
Ainv = inv(A);  

%Add translation vector
Tinv = [Ainv -Ainv*r0];
