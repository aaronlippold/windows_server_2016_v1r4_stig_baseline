control 'V-73613' do
  title "Domain Controller PKI certificates must be issued by the DoD PKI or an
  approved External Certificate Authority (ECA)."
  desc "A PKI implementation depends on the practices established by the
  Certificate Authority (CA) to ensure the implementation is secure. Without
  proper practices, the certificates issued by a CA have limited value in
  authentication functions. The use of multiple CAs from separate PKI
  implementations results in interoperability issues. If servers and clients do
  not have a common set of root CA certificates, they are not able to
  authenticate each other."
  impact 0.7
  tag "gtitle": 'SRG-OS-000066-GPOS-00034'
  tag "gid": 'V-73613'
  tag "rid": 'SV-88277r1_rule'
  tag "stig_id": 'WN16-DC-000290'
  tag "fix_id": 'F-80063r1_fix'
  tag "cci": ['CCI-000185']
  tag "nist": ['IA-5 (2) (a)', 'Rev_4']
  tag "documentable": false
  desc "check", "This applies to domain controllers. It is NA for other systems.

  Run MMC.

  Select Add/Remove Snap-in from the File menu.

  Select Certificates in the left pane and click the Add > button.

  Select Computer Account and click Next.

  Select the appropriate option for Select the computer you want this snap-in
  to manage and click Finish.

  Click OK.

  Select and expand the Certificates (Local Computer) entry in the left pane.

  Select and expand the Personal entry in the left pane.

  Select the Certificates entry in the left pane.

  In the right pane, examine the Issued By field for the certificate to
  determine the issuing CA.

  If the Issued By field of the PKI certificate being used by the domain
  controller does not indicate the issuing CA is part of the DoD PKI or an
  approved ECA, this is a finding.

  If the certificates in use are issued by a CA authorized by the Component's
  CIO, this is a CAT II finding.

  There are multiple sources from which lists of valid DoD CAs and approved ECAs
  can be obtained:

  The Global Directory Service (GDS) website provides an online source. The
  address for this site is https://crl.gds.disa.mil.

  DoD Public Key Enablement (PKE) Engineering Support maintains the InstallRoot
  utility to manage DoD supported root certificates on Windows computers, which
  includes a list of authorized CAs. The utility package can be downloaded from
  the PKI and PKE Tools page on IASE:

  http://iase.disa.mil/pki-pke/function_pages/tools.html"
  desc "fix", "Obtain a server certificate for the domain controller issued by
  the DoD PKI or an approved ECA."
  domain_role = command('wmic computersystem get domainrole | Findstr /v DomainRole').stdout.strip

  if domain_role == '4' || domain_role == '5'
    describe command('Get-ChildItem -Path Cert:\\LocalMachine\\My | Format-List | Findstr Issuer') do
      its('stdout') { should include 'DoD' }
    end
  end

  if !(domain_role == '4') && !(domain_role == '5')
    impact 0.0
    describe 'This system is not a domain controller, therefore this control is not applicable as it only applies to domain controllers' do
      skip 'This system is not a domain controller, therefore this control is not applicable as it only applies to domain controllers'
    end
  end
end
