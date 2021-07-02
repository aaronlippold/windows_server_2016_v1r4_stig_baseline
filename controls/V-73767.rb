control 'V-73767' do
  title "The Deny log on as a service user right on member servers must be
  configured to prevent access from highly privileged domain accounts on domain
  systems. No other groups or accounts must be assigned this right."
  desc "Inappropriate granting of user rights can provide system,
  administrative, and other high-level capabilities.

  The Deny log on as a service user right defines accounts that are
  denied logon as a service.

  In an Active Directory Domain, denying logons to the Enterprise Admins and
  Domain Admins groups on lower-trust systems helps mitigate the risk of
  privilege escalation from credential theft attacks, which could lead to the
  compromise of an entire domain.

  Incorrect configurations could prevent services from starting and result in
  a DoS.
  "
  impact 0.5
  tag "gtitle": 'SRG-OS-000080-GPOS-00048'
  tag "gid": 'V-73767'
  tag "rid": 'SV-88431r1_rule'
  tag "stig_id": 'WN16-MS-000390'
  tag "fix_id": 'F-80217r1_fix'
  tag "cci": ['CCI-000213']
  tag "nist": ['AC-3', 'Rev_4']
  tag "documentable": false
  desc "check", "This applies to member servers and standalone systems. A
  separate version applies to domain controllers.

  Verify the effective setting in Local Group Policy Editor.

  Run gpedit.msc.

  Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings
  >> Security Settings >> Local Policies >> User Rights Assignment.

  If the following accounts or groups are not defined for the Deny log on as a
  service user right on domain-joined systems, this is a finding.

  - Enterprise Admins Group
  - Domain Admins Group

  If any accounts or groups are defined for the Deny log on as a service user
  right on non-domain-joined systems, this is a finding."
  desc "fix", "Configure the policy value for Computer Configuration >> Windows
  Settings >> Security Settings >> Local Policies >> User Rights Assignment >>
  Deny log on as a service to include the following:

  Domain systems:
  - Enterprise Admins Group
  - Domain Admins Group"
  is_domain = command('wmic computersystem get domain | FINDSTR /V Domain').stdout.strip
  domain_role = command('wmic computersystem get domainrole | Findstr /v DomainRole').stdout.strip
  if !(domain_role == '4') && !(domain_role == '5')
    if is_domain == 'WORKGROUP'
      describe security_policy do
        its('SeDenyServiceLogonRight') { should eq [] }
      end

    else
        ### Enable PowerShell Active Directory feature so we can get the domain SID
        enable_ADPWSH_script = <<-EOH
        Enable-WindowsOptionalFeature -FeatureName ActiveDirectory-Powershell -Online -All
        EOH
        ### Actually run the script, need to add error checking here if command fails
        enable_ADPWSH_result = powershell(enable_ADPWSH_script)

        ### Get this host's domain SID that will be used in security policy comparison
        get_SID_script = <<-EOH
        Get-ADDomain | select DomainSID
        EOH
        ### Actually run the script and assign output to variable, need to add error checking here if command fails
        get_SID_result = powershell(get_SID_script)
        domain_sid = get_SID_result.stdout.gsub(/DomainSID|---------|\s/, "")

      describe security_policy do
        its('SeDenyServiceLogonRight') { should include "#{domain_sid}-512" }
      end
      describe security_policy do
        its('SeDenyServiceLogonRight') { should include "#{domain_sid}-519" }
      end
    end
  end

  if domain_role == '4' || domain_role == '5'
    impact 0.0
    desc 'This system is a domain controller, therefore this control is not applicable as it only applies to member servers and standalone systems'
    describe 'This system a domain controller, therefore this control is not applicable as it only applies to member servers and standalone systems' do
      skip 'This system a domain controller, therefore this control is not applicable as it only applies to member servers and standalone systems'
    end
  end
end
