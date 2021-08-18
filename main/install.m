% install.m 
toolboxFile = 'LSP.mltbx';
agreeToLicense = true;
matlab.addons.toolbox.installToolbox(toolboxFile,agreeToLicense);
status = 1; % OK
disp('OK');