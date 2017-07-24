function h=meg_plot_dipoles(MEG,dpl,hs)

% plot headshape and sensors
figure;
if hs
    plot_hs_sens(MEG);
    hold on;
end

% plot dipoles from dip structure
dip=[[dpl.x]' [dpl.y]' [dpl.z]',[dpl.Qx]',[dpl.Qy]',[dpl.Qz]'];
scatter3(dip(:,1),dip(:,2),dip(:,3),'m.');
quiver3(dip(:,1),dip(:,2),dip(:,3),dip(:,4),dip(:,5),dip(:,6),2.5,'m');

end