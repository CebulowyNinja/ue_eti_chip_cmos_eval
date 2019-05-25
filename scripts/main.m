close all
clear all
clc
output_dir = "../output/"
data_dir = "../data/"
% dir to output
fet_types=["n" "p"]


files = glob('..\data\*.csv')
for i=1:numel(files)
  [~, name] = fileparts (files{i});
  eval(sprintf('%s = load("%s", "-ascii");', name, files{i}));
endfor

% sweep_types=???

for fet_type=fet_types
  fet_data_dir = [ data_dir  fet_type "fet/"]
  fet_output_dir = [ output_dir fet_type "fet/"]
  input_file_name1 = [fet_data_dir "reg_01_sat.csv"]
  input_file_name2 = [fet_data_dir "reg_01_nsat.csv"]
  input_file_name3 = [fet_data_dir "reg_01_out.csv"]
  data_sat=csvread(input_file_name1);
  data_nsat=csvread(input_file_name2);
  data_out=csvread(input_file_name3);
  %w=data(1,1);
  w=440e-9;
  %l=data(1,2);
  L=180e-9;
  vds=0.09;
  fi=0.35;
  % choosing linear range for sat in volts
  down_sat=0.5;
  up_sat=0.9;
  % choosing linear range for nsat in volts
  down_nsat=1;
  up_nsat=1.8;
  % choosing linear range for out in volts
  down_out=0.8;
  up_out=1.8;
  
  %square root
  figure
  num_series=6;
  for j=1:num_series
    data_sat(:,2*j)=sqrt(abs(data_sat(:,2*j)));
    plot(data_sat(:,2*j-1),data_sat(:,2*j));
    hold on
    plot([down_sat,down_sat],[0,data_sat(180,2)]);
    hold on
    plot([up_sat,up_sat],[0,data_sat(180,2)]);
  endfor
  
  figure
  plot(data_nsat(:,1),data_nsat(:,2));
  hold on
  plot([down_nsat,down_nsat],[0,data_nsat(180,2)]);
  hold on
  plot([up_nsat,up_nsat],[0,data_nsat(180,2)]);
  
  figure
  plot(data_out(:,1),data_out(:,2));
  hold on
  plot([down_out,down_out],[0,data_out(180,2)]);
  hold on
  plot([up_out,up_out],[0,data_out(180,2)]);
  
  
  valid_data_sat=data_sat(down_sat*100+2: up_sat*100+2,:); % choosing linear range for sat
  valid_data_nsat=data_nsat(down_nsat*100+2:up_nsat*100+2,:); % choosing linear range for nsat
  valid_data_out=data_out(down_out*100+2:up_out*100+2,:); % choosing linear range for out
  
  %xi=valid_data(:,1);
  % calculate
  for j=1:num_series
    m(j,:)=polyfit(valid_data_sat(:,2*j-1),valid_data_sat(:,2*j),1);
    vt(j)=-m(j,2)/m(j,1);
  endfor
  
  vsb=[0:0.1:0.5];
  gamma_tab=polyfit(sqrt(vsb+2*abs(fi))-sqrt(2*abs(fi)),vt,1);
  %[p, e_var, r, p_var, fit_var] = LinearRegression (valid_data(:,1),valid_data(:,2))
  m_nsat=polyfit(valid_data_nsat(:,1),valid_data_nsat(:,2),1);
  m_out=polyfit(valid_data_out(:,1),valid_data_out(:,2),1);
  
  
  ks=2*m(1)^2*L/w;
  kl=m_nsat(1)*L/(vds*w);
  gamma=gamma_tab(1);
  lambda=m_out(1)/m_out(2)
  % save to output file
  
  output_file_name = [fet_output_dir "1.txt"];
  
  save([fet_output_dir "reg_01.txt"],'ks','kl','gamma','lambda');
  %save([fet_output_dir "reg_01.txt"],'kl');
  
  
  
endfor
