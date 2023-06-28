control 'V-73771' do
  title "The Deny log on locally user right on member servers must be
  configured to prevent access from highly privileged domain accounts on domain
  systems and from unauthenticated access on all systems."
  desc "Inappropriate granting of user rights can provide system,
  administrative, and other high-level capabilities.

  The Deny log on locally user right defines accounts that are prevented
  from logging on interactively.

    In an Active Directory Domain, denying logons to the Enterprise Admins and
  Domain Admins groups on lower-trust systems helps mitigate the risk of
  privilege escalation from credential theft attacks, which could lead to the
  compromise of an entire domain.

  The Guests group must be assigned this right to prevent unauthenticated
  access.
  "
  impact 0.5
  tag "gtitle": 'SRG-OS-000080-GPOS-00048'
  tag "gid": 'V-73771'
  tag "rid": 'SV-88435r1_rule'
  tag "stig_id": 'WN16-MS-000400'
  tag "fix_id": 'F-80221r1_fix'
  tag "cci": ['CCI-000213']
  tag "nist": ['AC-3', 'Rev_4']
  tag "documentable": false
  desc "check", "This applies to member servers and standalone systems. A
  separate version applies to domain controllers.

  Verify the effective setting in Local Group Policy Editor.

  Run gpedit.msc.

  Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings
  >> Security Settings >> Local Policies >> User Rights Assignment.

  If the following accounts or groups are not defined for the Deny log on
  locally user right, this is a finding.

  Domain Systems Only:
  - Enterprise Admins Group
  - Domain Admins Group

  Systems dedicated to the management of Active Directory (AD admin platforms,
  see V-36436 in the Active Directory Domain STIG) are exempt from this.

  All Systems:
  - Guests Group"
  desc "fix", "Configure the policy value for Computer Configuration >> Windows
  Settings >> Security Settings >> Local Policies >> User Rights Assignment >>
  Deny log on locally to include the following:


  Domain Systems Only:
  - Enterprise Admins group 
  - Domain Admins group 

  Systems dedicated to the management of Active Directory (AD admin platforms,
  see V-36436 in the Active Directory Domain STIG) are exempt from this.

  All Systems:
  - Guests group "

  is_AD_only_system = input('is_AD_only_system')
  domain_role = command('wmic computersystem get domainrole | Findstr /v DomainRole').stdout.strip

  if domain_role == '4' || domain_role == '5'
    impact 0.0
    describe 'This system is a domain controller, therefore this control is not applicable as it only applies to member servers and standalone systems' do
      skip 'This system is a domain controller, therefore this control is not applicable as it only applies to member servers and standalone systems'
    end
  elsif is_AD_only_system
    impact 0.0
    describe 'This system is dedicated to the management of Active Directory, therefore this system is exempt from this control' do
      skip 'This system is dedicated to the management of Active Directory, therefore this system is exempt from this control'
    end
  else
    describe security_policy do
      its('SeDenyInteractiveLogonRight') { should include 'S-1-5-32-546' }
    end
    if domain_role == '3'
      domain_admin_sid_query = <<-EOH
        $group = New-Object System.Security.Principal.NTAccount('Domain Admins')
        $sid = $group.Translate([security.principal.securityidentifier]).value
        $sid | ConvertTo-Json
      EOH
      domain_admin_sid = json(command: domain_admin_sid_query).params
      
      enterprise_admin_sid_query = <<-EOH
        $group = New-Object System.Security.Principal.NTAccount('Enterprise Admins')
        $sid = $group.Translate([security.principal.securityidentifier]).value
        $sid | ConvertTo-Json
      EOH
      enterprise_admin_sid = json(command: enterprise_admin_sid_query).params

      describe security_policy do
        its('SeDenyInteractiveLogonRight') { should include "#{domain_admin_sid}" }
      end
      describe security_policy do
        its('SeDenyInteractiveLogonRight') { should include "#{enterprise_admin_sid}" }
      end
    end
  end
end