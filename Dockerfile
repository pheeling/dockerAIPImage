
# Specifies that the latest microsoft will be used as the base image
FROM mcr.microsoft.com/windows:1909
#FROM mcr.microsoft.com/powershell:lts-nanoserver-1909

# Copies contents of the AIPClient folder to the c:/Source
# folder in the new container image
ENV target="C:/source/"
RUN mkdir ${target}
COPY aipclient28850 ${target}
ENV git="C:/git/PEPMigrationAIPLabeledDocuments/"
RUN mkdir ${git}
COPY PEPMigrationAIPLabeledDocuments ${git}

# Set default repository
RUN powershell Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
RUN powershell Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted 

# Install AIPModule
RUN "C:/source/vcredist_x64_ee916012783024dac67fc606457377932c826f05.exe /Q"
RUN "C:/source/AzInfoProtection_UL.exe PowerShellOnly=true /quiet /log C:/source/install.log"
RUN powershell Install-Module AIPService
RUN powershell Set-ExecutionPolicy Unrestricted
RUN powershell Import-Module AIPService
RUN powershell Install-Module ExchangeOnlineManagement
RUN powershell Install-Module SharePointPnPPowerShellOnline
RUN powershell Add-content C:\Windows\System32\drivers\etc\hosts '"127.0.0.1 msoid.onmicrosoft.com"'
RUN powershell Add-content C:\Windows\System32\drivers\etc\hosts '"127.0.0.1 msoid.autorenplattform.ch"'
RUN powershell Add-content C:\Windows\System32\drivers\etc\hosts '"127.0.0.1 msoid.autorenplattform.onmicrosoft.com`n"'
RUN powershell Add-content C:\Windows\System32\drivers\etc\hosts '"127.0.0.1 msoid.*.onmicrosoft.com"'

#Create Service User for AIP Authentication
RUN NET USER svcuser /ADD
RUN NET LOCALGROUP "Administrators" "svcuser" /ADD

#Start each container as Service User
USER svcuser