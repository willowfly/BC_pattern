function model_symmetrical()
    close all; clear all; clc;
    global h % handles for the gui 
    global p % parameters for the model
    p.IPD = linspace(-2*pi,2*pi,401);
    p.ILD = linspace(-16,16,321);
    p.Dc = zeros(321,401);
    p.cmap = [1,0,0;1,0.2,0.2;1,0.4,0.4;1,0.6,0.6;1,0.8,0.8;1,1,1;
              0.8,0.8,1;0.6,0.6,1;0.4,0.4,1;0.2,0.2,1;0,0,1];
    p.cmap = p.cmap(size(p.cmap,1):-1:1,:);
    p.para = [0];
    gui();
end 

function gui()
    global h p 
    % create the main figure / gui 
    h.main = figure('visible','off');
    h.main.Units = 'pixel';
    h.main.Position = [120,50,1000,410];
    h.main.Name = 'Cross-talk model - symmetrical skull';
    h.main.MenuBar = 'none';
    h.main.ToolBar = 'none';
    h.main.NumberTitle = 'off';
    % create the control objects
    params = {'TA'};
    for kk = 1:length(params)
        createControl(kk,length(params),params{kk});
    end 
    h.axis = axes(h.main,'units','pixel','position',[260,50,730,350]); 
    set(h.axis,'ydir','reverse');
    imagesc(h.axis,p.Dc,[-20,20]);
    xlabel(h.axis,'interaural phase difference, IPD, re PI');
    ylabel(h.axis,'interaural level difference, ILD, dB');
    xtl = num2str([-2:0.2:2]','%.1f'); 
    ytl = num2str([-16:2:16]','%.0f');
    set(h.axis,'xtick',[1:20:length(p.IPD)],'xticklabel',xtl);
    set(h.axis,'ytick',[1:20:length(p.ILD)],'yticklabel',ytl);
    colormap(p.cmap); colorbar(h.axis,'eastoutside');
    h.main.Visible = 'on';
end 

function createControl(i,N,string)
    global h p 
    h.panel(i).panel = uipanel('Title',string,'units','pixel',...
        'position',[5,(N-i+1)*100-100*N+300,200,100]);
    h.panel(i).amp = uicontrol(h.panel(i).panel,'style','slider',...
        'units','normalized','position',[0.01,0.66,0.6,0.3],...
        'Max',20,'Min',-20,'SliderStep',1/40*[1,1],...
        'tag',['S1',num2str(i)],'callback',@callbackControl);
    h.panel(i).phs = uicontrol(h.panel(i).panel,'style','slider',...
        'units','normalized','position',[0.01,0.33,0.6,0.3],...
        'Max',1,'Min',-1,'SliderStep',0.1/2*[1,1],...
        'tag',['S2',num2str(i)],'callback',@callbackControl);
    h.panel(i).ampText = uicontrol(h.panel(i).panel,'style','edit',...
        'units','normalized','position',[0.65,0.66,0.34,0.3],...
        'String','0',...
        'tag',['E1',num2str(i)],'callback',@callbackControl);
    h.panel(i).phsText = uicontrol(h.panel(i).panel,'style','edit',...
        'units','normalized','position',[0.65,0.33,0.34,0.3],...
        'String','0',...
        'tag',['E2',num2str(i)],'callback',@callbackControl);
    h.panel(i).complex = uicontrol(h.panel(i).panel,'style','text',...
        'units','normalized','position',[0.10,0.01,0.80,0.30],...
        'string','1.000+0.000*i');
end

function callbackControl(src,sv)
    global h p 
    tag = src.Tag;
    ii = str2num(tag(3)); pnl = h.panel(ii);
    switch tag(1:2)
        case 'S1'
            pnl.ampText.String = num2str( src.Value );
        case 'S2'
            pnl.phsText.String = num2str( src.Value );
        case 'E1'
            pnl.amp.Value = str2num( src.String );
        case 'E2'
            pnl.phs.Value = str2num( src.String );
        otherwise
            % empty
    end
    Z = 10.^(h.panel(ii).amp.Value/20); phi = h.panel(ii).phs.Value;
    h.panel(ii).complex.String = sprintf( '%.4f + %5.4f*i',Z*cos(phi*pi),Z*sin(phi*pi) );
    updatePara();
    calculate_and_update();
end 

% update parameters according to the UI 
function updatePara()
    global h p 
    for kk = 1:length(h.panel) 
        pnl = h.panel(kk);
        Z = 10.^(pnl.amp.Value/20); phi = pnl.phs.Value;
        p.para(kk) = Z*cos(phi*pi)+1i*Z*sin(phi*pi);
    end 
end

% calculate and update 
function calculate_and_update()
    global h p
    T = p.para(1);
    Dc = zeros(length(p.ILD),length(p.IPD));
    for ii = 1:length(p.ILD)
    for jj = 1:length(p.IPD)
        ild = 10.^(p.ILD(ii)/20);
        ipd = p.IPD(jj);
        Ds = ild*(cos(ipd)+1i*sin(ipd));
        Dc(ii,jj) = (1+Ds*T)/(Ds+T); 
    end
    end
    p.Dc = 20*log10(abs(Dc));
    set(h.axis,'NextPlot','replace');
    imagesc(h.axis,p.Dc,[-20,20]); set(h.axis,'xdir','reverse');
    xlabel(h.axis,'interaural phase difference, IPD, re PI');
    ylabel(h.axis,'interaural level difference, ILD, dB');
    xtl = num2str([-2:0.2:2]','%.1f'); 
    ytl = num2str([-16:2:16]','%.0f');
    set(h.axis,'xtick',[1:20:length(p.IPD)],'xticklabel',xtl);
    set(h.axis,'ytick',[1:20:length(p.ILD)],'yticklabel',ytl);
    colormap(p.cmap); colorbar(h.axis,'eastoutside');
end