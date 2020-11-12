clc;clear all;close all;
% Importera data
content1 = load('LosAlamos_NM_USA.txt');

Night_Temp1 = content1(:,[3]); %Importera natttemperaturerna i fahrenheit
Night_TempC = (Night_Temp1 - 32)*(5/9); %fahrenheit->celsius
Night_TempK = ((Night_Temp1 - 32)*(5/9))+273; %fahrenheit->kelvin

Day_Temp1 = content1(:,[5]); %Importera dagstemperaturerna i fahrenheit
Day_TempC = (Day_Temp1 - 32)*(5/9); %fahrenheit->celsius
Day_TempK = ((Day_Temp1 - 32)*(5/9))+273; %fahrenheit->kelvin

% Konstanter
indoorTemp = 20; %celsius
Lv = 2; % [MJ/h]
TL = 10+273; %Grundvattentemperaturen i kelvin

%Beräkning av temperaturen i radiatorerna T_H, från kurvan för dag och natt.
TH_Day = zeros(365,1);
for j = 1:size(Night_TempC)
    if Night_TempC(j) >= 3
        TH_Day(j,1) = (-1.6)*Night_TempC (j) + 45;
    elseif Night_TempC(j) <= -4
        TH_Day(j,1) = (-0.33)*Night_TempC (j) + 43;
    else
        TH_Day(j,1) = 39;
    end
end

TH_Night = zeros(365,1);
for j = 1:size(Day_TempC)
    if TH_Night >= 3
       TH_Night(j,1) = (-1.6)*Day_TempC(j) + 45;
    elseif TH_Night <= -4
        TH_Night(j,1) = (-0.33)*Day_TempC(j) + 43;
    else
        TH_Night(j,1) = 39;
    end
end

%dQ=24*Lv.*(indoorTemp - Night_TempC);
dQ = abs((indoorTemp -Night_TempC)*12+abs(indoorTemp - Day_TempC)*12)*Lv; %Årligt värmeläckage per dygn uppdelat på dag och natt.


COPhp = 1./(1-(TL)./(TH_Day+273)); % värmefaktor vid uppvärmning

%Beräkna COPhp för natttemperaturerna
for i = 1:365
 if (Night_TempC(i)-20<0)
        COPhpn(i) = 1/(1-(TL/(VattenTemp(Night_TempC(i))+273)));  %ideal carnotcykel 1/(1-(TH/TL))
    elseif (Night_TempC(i)-20>1)
        COPhpn(i) = 0;
    else
        COPhpn(i)=0;
 end
end


n=0;
%Beräkna COPhp för dagstemperaturerna för värmepumpen
for i = 1:365
    if (Day_TempC(i)-20<0)
        COPhpd(i) = 1/(1-(TL/(TH_Day(i)+273)));
    elseif(Day_TempC(i)-20>1)
        COPhpd(i) = 0;
    else
        COPhpd(i)=0;
    end
end

%Beräkna COPr
for i = 1:365
    if(Day_TempC(i)-20>1)
     COPrd(i) = 1./(((Day_TempC(i)+273)/293)-1); %COP_R = 1/((QH/QL)-1)
      n = n+1;
    else
         COPrd(i)=0;
    end
end

%Medelvärden för COPhp och COPr
disp('Average COPr:')
disp(sum(COPrd)/n);
disp('Average COPhp:')
disp(mean(COPhp));

%Beräkna effekten för dag och natt QL/COP_R=(L_v*DeltaT/COPhp)
for i=1:365
    dWN(i) = (20-Night_TempC(i))*12*Lv/COPhpn(i);
    if Day_TempC(i)-20 <= 0
        dWD(i) = (20-Day_TempC(i))*12*Lv/COPhpd(i);
    end
end
dWHP = dWN + dWD; %Värmepumpens effekt

%Radiatoreffekten QL/COP_R=(L_v*DeltaT/COPr)
for i=1:365
    if Day_TempC(i)-20>1
      dWr(i)=(Day_TempC(i)-20)*12*Lv/COPrd(i);
    else
      dWr(i)=0;
    end
end

disp('total energy required [MJ]')
sum1=sum(sum(dWHP)+sum(dWr));
disp(sum1);
disp('Relation between the energy production of the Heat Pump and the Cooling Machine')
sumdW =sum(sum(dWHP)+sum(dWr))/sum(dWr);
disp(sumdW);

%Plottar
figure (1)
plot(dQ)
xlim([1 365]);
xlabel('Day');
ylabel('Heat Leakage [MJ]');
title('Yearly Heat Leakage ')

figure (2)
plot(COPhp)
xlim([1 365]);
xlabel('Day');
ylabel('COPhp');
title('COP for the Heat Pump')

figure (4)
plot(COPrd);
title('COP for the Cooling Machine');
ylabel('COPr');
xlabel('Day');

figure(5)
plot(dWr);
xlim([1 365]);
xlabel('Day');
ylabel('Requiered Energy  [MJ]');
title('Requiered Energy  for the Cooling Machine')

figure(6)
plot(dWHP);
xlim([1 365]);
xlabel('Day');
ylabel('Requiered Energy  [MJ]');
title('Requiered Energy  for the Heat Pump')
