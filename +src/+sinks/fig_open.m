function [fig1,ax1,dcm_obj] = fig_open()
  
  import GenerFigs.*
    
  set(0,'defaultfigurecolor',[1 1 1]) % white background
  scrn_size = get(0,'ScreenSize'); % get size of screen
  shrink_pct = .01; % shrink the figure by 1%
  %
  fig1 = figure('Name', 'Change point detection', 'NumberTitle', 'off', ...
    'Visible','off','DefaultAxesFontSize',20,'Position',...
    [scrn_size(1)+(scrn_size(3)*shrink_pct) scrn_size(2)+(scrn_size(4)*shrink_pct)...
    scrn_size(3)-(scrn_size(3)*2*shrink_pct) scrn_size(4)-(scrn_size(4)*2*shrink_pct)]);
  
  ax1 = gca;
  dcm_obj = datacursormode(fig1); % enable control of datatips
  
  % set(dcm_obj,'UpdateFcn',@myupdatefcn) % this will be used to configure
  % data tips
  set(ax1,'fontsize',20,'Color',[0.8 0.8 0.8],'gridcolor',[1 1 1],'gridalpha',0.9) % set the axis color
  hold all
  grid on
end