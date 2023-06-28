control 'V-73221' do
  title "Only administrators responsible for the member server or standalone
  system must have Administrator rights on the system."
  desc "An account that does not have Administrator duties must not have
  Administrator rights. Such rights would allow the account to bypass or modify
  required security restrictions on that machine and make it vulnerable to attack.

  System administrators must log on to systems using only accounts with the
  minimum level of authority necessary.

    For domain-joined member servers, the Domain Admins group must be replaced
  by a domain member server administrator group (see V-36433 in the Active
  Directory Domain STIG). Restricting highly privileged accounts from the local
  Administrators group helps mitigate the risk of privilege escalation resulting
  from credential theft attacks.

  Systems dedicated to the management of Active Directory (AD admin
  platforms, see V-36436 in the Active Directory Domain STIG) are exempt from
  this. AD admin platforms may use the Domain Admins group or a domain
  administrative group created specifically for AD admin platforms (see V-43711
  in the Active Directory Domain STIG).

  Standard user accounts must not be members of the built-in Administrators
  group.
  "
  impact 0.7
  tag "gtitle": 'SRG-OS-000324-GPOS-00125'
  tag "gid": 'V-73221'
  tag "rid": 'SV-87873r1_rule'
  tag "stig_id": 'WN16-MS-000010'
  tag "fix_id": 'F-80263r1_fix'
  tag "cci": ['CCI-002235']
  tag "nist": ['AC-6 (10)', 'Rev_4']
  tag "documentable": false
  desc "check", "This applies to member servers and standalone systems. A
  separate version applies to domain controllers.

  Open Computer Management.

  Navigate to Groups under Local Users and Groups.

  Review the local Administrators group.

  Only administrator groups or accounts responsible for administration of the
  system may be members of the group.

  For domain-joined member servers, the Domain Admins group must be replaced by a
  domain member server administrator group.

  Systems dedicated to the management of Active Directory (AD admin platforms,
  see V-36436 in the Active Directory Domain STIG) are exempt from this. AD admin
  platforms may use the Domain Admins group or a domain administrative group
  created specifically for AD admin platforms (see V-43711 in the Active
  Directory Domain STIG).

  Standard user accounts must not be members of the local Administrator group.

  If accounts that do not have responsibility for administration of the system
  are members of the local Administrators group, this is a finding.

  If the built-in Administrator account or other required administrative accounts
  are found on the system, this is not a finding."
  desc "fix", "Configure the local \"Administrators\" group to include only
  administrator groups or accounts responsible for administration of the system.

  For domain-joined member servers, replace the Domain Admins group with a domain
  member server administrator group.

  Systems dedicated to the management of Active Directory (AD admin platforms,
  see V-36436 in the Active Directory Domain STIG) are exempt from this. AD admin
  platforms may use the Domain Admins group or a domain administrative group
  created specifically for AD admin platforms (see V-43711 in the Active
  Directory Domain STIG).

  Remove any standard user accounts."
  administrators = attribute('administrators')
  is_AD_only_system = input('is_AD_only_system')
  domain_role = command('wmic computersystem get domainrole | Findstr /v DomainRole').stdout.strip
  administrator_group = command("Get-LocalGroupMember -Group \"Administrators\" | select -ExpandProperty Name | ForEach-Object {$_ -replace \"$env:COMPUTERNAME\\\\\" -replace \"\"}").stdout.strip.split("\r\n")


  if (domain_role == '2' || domain_role == '3') && !is_AD_only_system
    administrator_group.each do |user|
      describe user.to_s do
        it { should be_in administrators }
      end
    end
  end

  if domain_role != '2' && domain_role != '3'
    impact 0.0
    describe 'This control applies to member servers and standalone systems. A separate version applies to domain controllers.' do
      skip 'This control applies to member servers and standalone systems. A separate version applies to domain controllers.'
    end
  end
  if is_AD_only_system
    impact 0.0
    describe 'This system is dedicated to the management of Active Directory, therefore this control is not applicable' do
      skip 'This system is dedicated to the management of Active Directory, therefore this control is not applicable'
    end
  end
  if administrator_group.empty?
    impact 0.0
    describe 'There are no users with administrative privileges on this system, therefore this control is not applicable' do
      skip 'There are no users with administrative privileges on this system, therefore this control is not applicable'
    end
  end
end
