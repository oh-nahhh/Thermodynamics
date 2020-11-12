%Assignment Rankine
%Niklas Bergqvist

clear;close all;clc;

i = 1;
% Beräkna olika stadier
while i<90

%1-2: Isentrop kompression i pump
%Stadie 1
P1(i) = 0.1; %P1= 0.1 bar
s1(i) = XSteam('sL_p', P1(i));
h1(i) = XSteam('hL_p', P1(i));

%Stadie 2
P2(i) = 90;%P2=90 bar
s2(i) = s1(i);
h2(i) = XSteam('h_ps', P2(i), s2(i));

%2-3: Isobar, tillförsel av värme i kokare
%Stadie 3
P3(i) = P2(i); %P2=P3 bar
T3(i) = 500;
s3(i) = XSteam('s_pT', P3(i), T3(i));
h3(i) = XSteam('h_ps', P3(i), s3(i));

%3-4: Turbin 1 (högtrycksturbin): ångan expanderas isentropt till ett medelhögt tryck.
%Stadie 4
P4(i) = i;
s4(i) = s3(i);
h4(i) = XSteam('h_ps', P4(i), s4(i));
x4(i) = XSteam('x_ps', P4(i), s4(i));

%4-5: Ångan går tillbaka till kokaren och återvärms vid konstant tryck.
%Stadie 5
P5(i) = P4(i); %P5=P4
T5(i) = 500; %Värmer upp till samma temeratur som innan.
s5(i) = XSteam('s_pT', P5(i), T5(i));
h5(i) = XSteam('h_ps', P5(i), s5(i));

%5-6:  Turbin 2 (lågtrycksturbin): ångan expanderas isentropt till ett
%lågt tryck
%Stadie 6
P6(i) = 0.1; %P6=P1
s6(i) = s5(i); %samma entropi för stadie 6 och 5.
x6(i) = XSteam('x_ps', P6(i), s6(i));
h6(i) = XSteam('h_ps', P6(i), s6(i));
%T6(i) = XSteam('T_hs', h6(i), s6(i));
%6-1:  Isobar: bortförsel av värme i kondensorn

% Beräknar tillförseln av värme, ånghalt och verkningsgrad.
Qin(i) = (h3(i)-h2(i))+(h5(i)-h4(i));
Qut(i) = h6(i)-h1(i);
nth(i) = 1-(Qut(i)/Qin(i));
i = i+1;
end

W = (h3-h4)+(h5-h6); %total turbineffekt
%Grafer
figure
plot(P4./P2,W);
title('Turbineffekt som funktion av P4/P2');
xlabel('Tryck (kvot P4/P2)');
ylabel('Arbete (Watt)');

figure
plot(P4./P2, nth,'o-')
title('Verkningsgrad som funktion av P4/P2');
xlabel('Tryck (kvot P4/P2)');
ylabel('Verknigsgrad');

figure
plot(P4./P2, x6,'DisplayName','x6')
hold on
plot(P4./P2, x4,'DisplayName','x4')
title('Ångkvalitet som funktion av P4/P2');
xlabel('Tryck (kvot P4/P2)');
ylabel('Ångkvalitet');
legend('show')
