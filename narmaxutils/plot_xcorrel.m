function plot_xcorrel(e,u,titulo)
% plota testes de correlação

maxlag = 25;

N = length(u);

% --- plots
conf_factor = 1.96/sqrt(N);
lag_vec = -maxlag:maxlag;
conf = [ones(length(lag_vec),1).*conf_factor ones(length(lag_vec),1).*-conf_factor];

% --- V1
subplot(5,1,1)
EE = crosscorr(e,e,maxlag);
plot(lag_vec,EE,'k',lag_vec,conf,'k:')
xlim([-maxlag maxlag]);
ylim([-1 1]);
% title(titulo);
% ylabel('(a)')%,'FontSize',16)
ylabel('$\phi_{\xi\xi}(\tau)$','Interpreter','LaTex')%,'FontSize',16)

subplot(5,1,2)
UE = crosscorr(u,e,maxlag);
plot(lag_vec,UE,'k',lag_vec,conf,'k:')
xlim([-maxlag maxlag]);
ylim([-1 1]);
% ylabel('(b)')
ylabel('$\phi_{u\xi}(\tau)$','Interpreter','LaTex')

subplot(5,1,3)
EEU = crosscorr(e(1:end-1,1),e(2:end,1).*u(2:end,1),maxlag);
plot(lag_vec,EEU,'k',lag_vec,conf,'k:')
xlim([0 maxlag]);
ylim([-1 1]);
% ylabel('(c)')
ylabel('$\phi_{\xi(\xi u)}(\tau)$','Interpreter','LaTex')
% 
subplot(5,1,4)
U2E = crosscorr(u.^2 - mean(u.^2),e,maxlag);
plot(lag_vec,U2E,'k',lag_vec,conf,'k:')
xlim([-maxlag maxlag]);
ylim([-1 1]);
% ylabel('(d)')
ylabel('$\phi_{(u^2)'' \xi}(\tau)$','Interpreter','LaTex')

subplot(5,1,5)
U2E2 = crosscorr(u.^2 - mean(u.^2),e.^2,maxlag);
plot(lag_vec,U2E2,'k',lag_vec,conf,'k:')
xlim([-maxlag maxlag]);
ylim([-1 1]);
% ylabel('(e)')
ylabel('$\phi_{(u^2)'' \xi^2}(\tau)$','Interpreter','LaTex')
xlabel('$\tau$','Interpreter','LaTex')

% WARNINGS
%{
%}

%flag_w_EE   = conf_teste(EE, conf_factor); flag_w_EE(maxlag+1) = 0; % delta
%flag_w_UE   = conf_teste(UE, conf_factor);
%flag_w_EEU   = conf_teste(EEU, conf_factor); flag_w_EEU(1:maxlag) = 0; % tau >=0
%flag_w_U2E   = conf_teste(U2E, conf_factor);
%flag_w_U2E2   = conf_teste(U2E2, conf_factor);

%teste_flag(flag_w_EE,  'EE',  lag_vec);
%teste_flag(flag_w_UE,  'UE',  lag_vec);
%teste_flag(flag_w_EEU, 'EEU', lag_vec);
%teste_flag(flag_w_U2E, 'U2E', lag_vec);
%teste_flag(flag_w_U2E2,'U2E2',lag_vec);
% PLOTA os coefs que exceram o limite
% subplot(5,1,1)
% hold on
% plot(lag_vec(flag_w_EE),EE(flag_w_EE),'go')
% hold off
% 
% subplot(5,1,2)
% hold on
% plot(lag_vec(flag_w_UE),UE(flag_w_UE),'go')
% hold off
% 
% subplot(5,1,3)
% hold on
% plot(lag_vec(flag_w_EEU),EEU(flag_w_EEU),'go')
% hold off
% 
% subplot(5,1,4)
% hold on
% plot(lag_vec(flag_w_U2E),U2E(flag_w_U2E),'go')
% hold off
% 
% subplot(5,1,5)
% hold on
% plot(lag_vec(flag_w_U2E2),U2E2(flag_w_U2E2),'go')
% hold off

% V2
% figure
% subplot(5,1,1)
% EE = crosscorr(e,e,maxlag);
% rectangle('Position',[-maxlag,-conf_factor,2*maxlag,2*conf_factor],'EdgeColor',[0 0 0],'FaceColor',[0.9 0.9 0.9])
% hold on
% stem(lag_vec,EE,'ko');
% xlim([-maxlag maxlag]);
% ylim([-1 1]);
% ylabel('$\phi_{\xi\xi}(\tau)$','Interpreter','LaTex')%,'FontSize',16)
% grid on
% 
% subplot(5,1,2)
% UE = crosscorr(u,e,maxlag);
% rectangle('Position',[-maxlag,-conf_factor,2*maxlag,2*conf_factor],'EdgeColor',[0 0 0],'FaceColor',[0.9 0.9 0.9])
% hold on
% stem(lag_vec,UE,'k')
% xlim([-maxlag maxlag]);
% ylim([-1 1]);
% ylabel('$\phi_{u\xi}(\tau)$','Interpreter','LaTex')
% grid on
% 
% subplot(5,1,3)
% EEU = crosscorr(e(1:end-1,1),e(2:end,1).*u(2:end,1),maxlag);
% rectangle('Position',[-maxlag,-conf_factor,2*maxlag,2*conf_factor],'EdgeColor',[0 0 0],'FaceColor',[0.9 0.9 0.9])
% hold on
% stem(lag_vec,EEU,'k')
% xlim([0 maxlag]);
% ylim([-1 1]);
% ylabel('$\phi_{\xi(\xi u)}(\tau)$','Interpreter','LaTex')
% grid on
% 
% subplot(5,1,4)
% U2E = crosscorr(u.^2 - mean(u.^2),e,maxlag);
% rectangle('Position',[-maxlag,-conf_factor,2*maxlag,2*conf_factor],'EdgeColor',[0 0 0],'FaceColor',[0.9 0.9 0.9])
% hold on
% stem(lag_vec,U2E,'k')
% xlim([-maxlag maxlag]);
% ylim([-1 1]);
% ylabel('$\phi_{(u^2)'' \xi}(\tau)$','Interpreter','LaTex')
% grid on
% 
% subplot(5,1,5)
% U2E2 = crosscorr(u.^2 - mean(u.^2),e.^2,maxlag);
% rectangle('Position',[-maxlag,-conf_factor,2*maxlag,2*conf_factor],'EdgeColor',[0 0 0],'FaceColor',[0.9 0.9 0.9])
% hold on
% stem(lag_vec,U2E2,'k')
% xlim([-maxlag maxlag]);
% ylim([-1 1]);
% ylabel('$\phi_{(u^2)'' \xi^2}(\tau)$','Interpreter','LaTex')
% grid on
% xlabel('$\tau$','Interpreter','LaTex')

    function teste_flag(flag,teste,lag_vec)        
        if any(flag)
            disp(['Teste ' teste ' violado nos lags:'])
            disp(lag_vec(flag));
        else
            disp('Tese EE ok!');
        end        
    end

    function flag = conf_teste(coefs, conf_const)
        flag = coefs > conf_const | coefs < -conf_const;
    end

end
