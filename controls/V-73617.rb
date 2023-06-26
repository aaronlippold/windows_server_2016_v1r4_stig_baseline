control 'V-73617' do
  title "Active Directory user accounts, including administrators, must be
  configured to require the use of a Common Access Card (CAC), Personal Identity
  Verification (PIV)-compliant hardware token, or Alternate Logon Token (ALT) for
  user authentication."
  desc "Smart cards such as the CAC support a two-factor authentication
  technique. This provides a higher level of trust in the asserted identity than
  use of the username and password for authentication.
  "
  impact 0.5
  tag "gtitle": 'SRG-OS-000105-GPOS-00052'
  tag "satisfies": ['SRG-OS-000105-GPOS-00052', 'SRG-OS-000106-GPOS-00053',
                    'SRG-OS-000107-GPOS-00054', 'SRG-OS-000108-GPOS-00055',
                    'SRG-OS-000375-GPOS-00160']
  tag "gid": 'V-73617'
  tag "rid": 'SV-88281r1_rule'
  tag "stig_id": 'WN16-DC-000310'
  tag "fix_id": 'F-80067r1_fix'
  tag "cci": ['CCI-000765', 'CCI-000766', 'CCI-000767', 'CCI-000768',
              'CCI-001948']
  tag "nist": ['IA-2 (1)', 'IA-2 (2)', 'IA-2 (3)', 'IA-2 (4)', 'IA-2 (11)', 'Rev_4']
  tag "documentable": false
  desc "check", "This applies to domain controllers. It is NA for other systems.

  Open PowerShell.

  Enter the following:

  Get-ADUser -Filter {(Enabled -eq $True) -and (SmartcardLogonRequired -eq
  $False)} | FT Name
  (DistinguishedName may be substituted for Name for more detailed
  output.)

  If any user accounts, including administrators, are listed, this is a finding.

  Alternately:

  To view sample accounts in Active Directory Users and Computers (available
  from various menus or run dsa.msc):

  Select the Organizational Unit (OU) where the user accounts are located. (By
  default, this is the Users node; however, accounts may be under other
  organization-defined OUs.)

  Right-click the sample user account and select Properties.

  Select the Account tab.

  If any user accounts, including administrators, do not have Smart card is
  required for interactive logon checked in the Account Options area, this
  is a finding."
  desc "fix", "Configure all user accounts, including administrator accounts, in
  Active Directory to enable the option Smart card is required for interactive
  logon.

  Run Active Directory Users and Computers (available from various menus or
  run dsa.msc):

  Select the OU where the user accounts are located. (By default this is the
  Users node; however, accounts may be under other organization-defined OUs.)

  Right-click the user account and select Properties.

  Select the Account tab.

  Check Smart card is required for interactive logon in the Account
  Options area."
  domain_role = command('wmic computersystem get domainrole | Findstr /v DomainRole').stdout.strip

  if domain_role == '4' || domain_role == '5'
    describe command("Get-ADUser -Filter {(Enabled -eq $True) -and (SmartcardLogonRequired -eq $False)} | FT Name | Findstr /v 'Name ---'") do
      its('stdout') { should eq '' }
    end
  end

  if !(domain_role == '4') && !(domain_role == '5')
    impact 0.0
    describe 'This system is not a domain controller, therefore this control is not applicable as it only applies to domain controllers' do
      skip 'This system is not a domain controller, therefore this control is not applicable as it only applies to domain controllers'
    end
  end
end
