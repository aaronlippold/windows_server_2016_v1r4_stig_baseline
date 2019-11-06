control 'V-73375' do
  title "The Active Directory Domain Controllers Organizational Unit (OU)
  object must have the proper access control permissions."
  desc "When Active Directory objects do not have appropriate access control
  permissions, it may be possible for malicious users to create, read, update, or
  delete the objects and degrade or destroy the integrity of the data. When the
  directory service is used for identification, authentication, or authorization
  functions, a compromise of the database objects could lead to a compromise of
  all systems that rely on the directory service.

      The Domain Controllers OU object requires special attention as the Domain
  Controllers are central to the configuration and management of the domain.
  Inappropriate access permissions defined for the Domain Controllers OU could
  allow an intruder or unauthorized personnel to make changes that could lead to
  the compromise of the domain.
  "
  impact 0.7
  tag "gtitle": 'SRG-OS-000324-GPOS-00125'
  tag "gid": 'V-73375'
  tag "rid": 'SV-88027r2_rule'
  tag "stig_id": 'WN16-DC-000100'
  tag "fix_id": 'F-84911r1_fix'
  tag "cci": ['CCI-002235']
  tag "nist": ['AC-6 (10)', 'Rev_4']
  tag "documentable": false
  tag "check": "This applies to domain controllers. It is NA for other systems.

  Review the permissions on the Domain Controllers OU.

  Open Active Directory Users and Computers (available from various menus or
  run dsa.msc).

  Select Advanced Features in the View menu if not previously selected.

  Select the Domain Controllers OU (folder in folder icon).

  Right-click and select Properties.

  Select the Security tab.

  If the permissions on the Domain Controllers OU do not restrict changes to
  System, Domain Admins, Enterprise Admins and Administrators, this is a finding.

  The default permissions listed below satisfy this requirement.

  Domains supporting Microsoft Exchange will have additional Exchange related
  permissions on the Domain Controllers OU.  These may include some change
  related permissions and are not a finding.

  The permissions shown are at the summary level. More detailed permissions can
  be viewed by selecting the Advanced button, the desired Permission entry,
  and the View or Edit button.

  Except where noted otherwise, the special permissions may include a wide range
  of permissions and properties and are acceptable for this requirement.

  CREATOR OWNER - Special permissions

  SELF - Special permissions

  Authenticated Users - Read, Special permissions

  The special permissions for Authenticated Users are Read types.

  If detailed permissions include any Create, Delete, Modify, or Write
  Permissions or Properties, this is a finding.

  SYSTEM - Full Control

  Domain Admins - Read, Write, Create all child objects, Generate resultant set
  of policy (logging), Generate resultant set of policy (planning), Special
  permissions

  Enterprise Admins - Full Control

  Key Admins - Special permissions

  Enterprise Key Admins - Special permissions

  Administrators - Read, Write, Create all child objects, Generate resultant set
  of policy (logging), Generate resultant set of policy (planning), Special
  permissions

  Pre-Windows 2000 Compatible Access - Special permissions

  The Special permissions for Pre-Windows 2000 Compatible Access are Read types.

  If detailed permissions include any Create, Delete, Modify, or Write
  Permissions or Properties, this is a finding.

  ENTERPRISE DOMAIN CONTROLLERS - Read, Special permissions"
  tag "fix": "Limit the permissions on the Domain Controllers OU to restrict
  changes to System, Domain Admins, Enterprise Admins and Administrators.

  The default permissions listed below satisfy this requirement.

  Domains supporting Microsoft Exchange will have additional Exchange related
  permissions on the Domain Controllers OU.  These may include some change
  related permissions.

  CREATOR OWNER - Special permissions

  SELF - Special permissions

  Authenticated Users - Read, Special permissions

  The special permissions for Authenticated Users are Read types.

  SYSTEM - Full Control

  Domain Admins - Read, Write, Create all child objects, Generate resultant set
  of policy (logging), Generate resultant set of policy (planning), Special
  permissions

  Enterprise Admins - Full Control

  Key Admins - Special permissions

  Enterprise Key Admins - Special permissions

  Administrators - Read, Write, Create all child objects, Generate resultant set
  of policy (logging), Generate resultant set of policy (planning), Special
  permissions

  Pre-Windows 2000 Compatible Access - Special permissions

  The special permissions for Pre-Windows 2000 Compatible Access are Read types.

  ENTERPRISE DOMAIN CONTROLLERS - Read, Special permissions"
  domain_role = command('wmic computersystem get domainrole | Findstr /v DomainRole').stdout.strip
  if domain_role == '4' || domain_role == '5'
    distinguishedName = json(command: '(Get-ADDomain).DistinguishedName | ConvertTo-JSON').params
    netbiosname = json(command: 'Get-ADDomain | Select NetBIOSName | ConvertTo-JSON').params['NetBIOSName']
    acl_rules = json(command: "(Get-ACL -Path AD:'#{distinguishedName}').Access | ConvertTo-CSV | ConvertFrom-CSV | ConvertTo-JSON").params

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "CREATOR OWNER" }
          its(['ActiveDirectoryRights']) { should match (/(genericwrite)|(genericread)|(genericall)|(genericall)|(delete)|(create)|(extendedright)/i) }
        end
      end
    end

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "SELF" }
          its(['ActiveDirectoryRights']) { should match (/(genericwrite)|(genericread)|(genericall)|(genericall)|(delete)|(create)|(extendedright)/i) }
        end
      end
    end

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "NT AUTHORITY\\Authenticated Users" }
          its(['ActiveDirectoryRights']) { should match (/(read)/i) }
          its(['ActiveDirectoryRights']) { should_not match (/(write)|(delete)|(create)|(extendedright)/i) }
        end
      end
    end

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "NT AUTHORITY\\System" }
          its(['ActiveDirectoryRights']) { should cmp "GenericAll" }
        end
      end
    end

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "#{netbiosname}\\Domain Admins" }
          its(['ActiveDirectoryRights']) { should match (/(read)|(write)|(create)|(extendedright)/i) }
        end
      end
    end

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "#{netbiosname}\\Key Admins" }
          its(['ActiveDirectoryRights']) { should_not cmp "GenericAll" }
          its(['ActiveDirectoryRights']) { should_not cmp "GenericWrite" }
          its(['ActiveDirectoryRights']) { should_not cmp "GenericRead" }
          its(['ActiveDirectoryRights']) { should_not cmp "GenericExecute" }
        end
      end
    end
 
    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "#{netbiosname}\\Enterprise Key Admins" }
          its(['ActiveDirectoryRights']) { should_not cmp "GenericAll" }
          its(['ActiveDirectoryRights']) { should_not cmp "GenericWrite" }
          its(['ActiveDirectoryRights']) { should_not cmp "GenericRead" }
          its(['ActiveDirectoryRights']) { should_not cmp "GenericExecute" }
        end
      end
    end

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "#{netbiosname}\\Enterprise Admins" }
          its(['ActiveDirectoryRights']) { should cmp "GenericAll" }
        end
      end
    end

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "BUILTIN\\Administrators" }
          its(['ActiveDirectoryRights']) { should match (/(read)|(write)|(create)|(extendedright)/i) }
        end
      end
    end

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "BUILTIN\\Pre-Windows 2000 Compatible Access" }
          its(['ActiveDirectoryRights']) { should cmp "ReadProperty" }
          its(['ActiveDirectoryRights']) { should_not match (/(write)|(delete)|(create)|(extendedright)/i) }
        end
      end
    end

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "BUILTIN\\Pre-Windows 2000 Compatible Access" }
          its(['ActiveDirectoryRights']) { should cmp "GenericRead" }
          its(['ActiveDirectoryRights']) { should_not match (/(write)|(delete)|(create)|(extendedright)/i) }
        end
      end
    end

    describe.one do
      acl_rules.each do |acl_rule|
        describe "The #{acl_rule['IdentityReference']} principal\'s access rule property" do
          subject { acl_rule }
          its(['AccessControlType']) { should cmp "Allow" }
          its(['IdentityReference']) { should cmp "BUILTIN\\Pre-Windows 2000 Compatible Access" }
          its(['ActiveDirectoryRights']) { should cmp "ListChildren" }
          its(['ActiveDirectoryRights']) { should_not match (/(write)|(delete)|(create)|(extendedright)/i) }
        end
      end
    end
  else
    impact 0.0
    desc 'This system is not a domain controller, therefore this control is not applicable as it only applies to domain controllers'
    describe 'This system is not a domain controller, therefore this control is not applicable as it only applies to domain controllers' do
      skip 'This system is not a domain controller, therefore this control is not applicable as it only applies to domain controllers'
    end
  end
end
