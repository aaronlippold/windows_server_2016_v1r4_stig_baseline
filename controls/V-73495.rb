control 'V-73495' do
  title "Local administrator accounts must have their privileged token filtered
  to prevent elevated privileges from being used over the network on domain
  systems."
  desc "A compromised local administrator account can provide means for an
  attacker to move laterally between domain systems.

    With User Account Control enabled, filtering the privileged token for local
  administrator accounts will prevent the elevated privileges of these accounts
  from being used over the network.
  "
  impact 0.5
  tag "gtitle": 'SRG-OS-000134-GPOS-00068'
  tag "gid": 'V-73495'
  tag "rid": 'SV-88147r1_rule'
  tag "stig_id": 'WN16-MS-000020'
  tag "fix_id": 'F-79937r1_fix'
  tag "cci": ['CCI-001084']
  tag "nist": ['SC-3', 'Rev_4']
  tag "documentable": false
  desc "check", "This applies to member servers. For domain controllers and
  standalone systems, this is NA.

  If the following registry value does not exist or is not configured as
  specified, this is a finding.

  Registry Hive:  HKEY_LOCAL_MACHINE
  Registry Path:  \\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System

  Value Name:  LocalAccountTokenFilterPolicy

  Type:  REG_DWORD
  Value: 0x00000000 (0)

  This setting may cause issues with some network scanning tools if local
  administrative accounts are used remotely. Scans should use domain accounts
  where possible. If a local administrative account must be used, temporarily
  enabling the privileged token by configuring the registry value to 1 may be
  required."
  desc "fix", "Configure the policy value for Computer Configuration >>
  Administrative Templates >> MS Security Guide >> Apply UAC restrictions to
  local accounts on network logons to Enabled.

  This policy setting requires the installation of the SecGuide custom templates
  included with the STIG package. SecGuide.admx and SecGuide.adml must
  be copied to the \\Windows\\PolicyDefinitions and
  \\Windows\\PolicyDefinitions\\en-US directories respectively."
  domain_role = command('wmic computersystem get domainrole | Findstr /v DomainRole').stdout.strip
  if !(domain_role == '4') && !(domain_role == '5') && !(domain_role == '2') 
    describe registry_key('HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System') do
      it { should have_property 'LocalAccountTokenFilterPolicy' }
      its('LocalAccountTokenFilterPolicy') { should cmp 0 }
    end
  end

  if domain_role == '4' || domain_role == '5'
    impact 0.0
    desc 'This system is a domain controller, therefore this control is not applicable as it only applies to member servers and standalone systems'
  end

  if domain_role == '2'
    impact 0.0
    describe 'This system is not joined to a domain, therfore this control is not appliable as it does not apply to standalone systems' do
      skip 'This system is not joined to a domain, therfore this control is not appliable as it does not apply to standalone systems'
    end
  end
end
