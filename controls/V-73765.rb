control 'V-73765' do
  title "The Deny log on as a service user right must be configured to include
  no accounts or groups (blank) on domain controllers."
  desc "Inappropriate granting of user rights can provide system,
  administrative, and other high-level capabilities.

    The Deny log on as a service user right defines accounts that are
  denied logon as a service.

    Incorrect configurations could prevent services from starting and result in
  a denial of service.
  "
  impact 0.5
  tag "gtitle": 'SRG-OS-000080-GPOS-00048'
  tag "gid": 'V-73765'
  tag "rid": 'SV-88429r1_rule'
  tag "stig_id": 'WN16-DC-000390'
  tag "fix_id": 'F-80215r1_fix'
  tag "cci": ['CCI-000213']
  tag "nist": ['AC-3', 'Rev_4']
  tag "documentable": false
  desc "check", "This applies to domain controllers. A separate version applies
  to other systems.

  Verify the effective setting in Local Group Policy Editor.

  Run gpedit.msc.

  Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings
  >> Security Settings >> Local Policies >> User Rights Assignment.

  If any accounts or groups are defined for the Deny log on as a service user
  right, this is a finding."
  desc "fix", "Configure the policy value for Computer Configuration >> Windows
  Settings >> Security Settings >> Local Policies >> User Rights Assignment >>
  Deny log on as a service to include no entries (blank)."
  domain_role = command('wmic computersystem get domainrole | Findstr /v DomainRole').stdout.strip

  if domain_role == '4' || domain_role == '5'
    describe security_policy do
      its('SeDenyServiceLogonRight') { should eq [] }
    end
  end

  if !(domain_role == '4') && !(domain_role == '5')
    impact 0.0
    describe 'This system is not a domain controller, therefore this control is not applicable as it only applies to domain controllers' do
      skip 'This system is not a domain controller, therefore this control is not applicable as it only applies to domain controllers'
    end
  end
end
