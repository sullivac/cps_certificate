#
# Cookbook:: cps_certificate
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

certificate_path = win_friendly_path(File.join(Chef::Config['file_cache_path'], 'certificate.pfx'))

cookbook_file certificate_path do
  source 'certificate.pfx'
  action :create
end

# Only adds to the CurrentUser stores
# windows_certificate certificate_path do
#   pfx_password node['cps_certificate']['password']
#   store_name   'CA'
#   action       :create
# end

# Only works on Windows Server 2012+ and Windows 10
# an improvement would be to wrap this in a custom resource
powershell_script 'Install PFX Certificate' do
  code <<-EOH
  # Unnecessary but here for demonstration purposes; provides ConvertTo-SecureString
  Import-Module -Name Microsoft.PowerShell.Security
  # Provides Import-PfxCertificate
  Import-Module -Name PKI

  $importArguments = @{
    CertStoreLocation = '#{node['cps_certificate']['store_path']}';
    FilePath = '#{certificate_path}'
    Password = $(ConvertTo-SecureString -AsPlainText -Force -String #{node['cps_certificate']['password']});
  }

  # PowerShell syntax: argument splatting for readability
  Import-PfxCertificate @importArguments
  EOH
  only_if <<-EOH
  # Provides certificate store PSProvider (pathing)
  Import-Module -Name PKI

  $certificatePath =
    '#{node['cps_certificate']['store_path']}' |
    Join-Path -ChildPath '#{node['cps_certificate']['thumbprint']}'

  $(Get-Item -Path $certificatePath -ErrorAction SilentlyContinue) -eq $null
  EOH
end
