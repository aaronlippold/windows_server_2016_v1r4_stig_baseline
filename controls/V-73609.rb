control 'V-73609' do
  title "The US DoD CCEB Interoperability Root CA cross-certificates must be
  installed in the Untrusted Certificates Store on unclassified systems."
  desc "To ensure users do not experience denial of service when performing
  certificate-based authentication to DoD websites due to the system chaining to
  a root other than DoD Root CAs, the US DoD CCEB Interoperability Root CA
  cross-certificates must be installed in the Untrusted Certificate Store. This
  requirement only applies to unclassified systems.
  "
  impact 0.5
  tag "gtitle": 'SRG-OS-000066-GPOS-00034'
  tag "satisfies": ['SRG-OS-000066-GPOS-00034', 'SRG-OS-000403-GPOS-00182']
  tag "gid": 'V-73609'
  tag "rid": 'SV-88273r2_rule'
  tag "stig_id": 'WN16-PK-000030'
  tag "fix_id": 'F-87315r1_fix'
  tag "cci": ['CCI-000185', 'CCI-002470']
  tag "nist": ['IA-5 (2) (a)', 'SC-23 (5)', 'Rev_4']
  tag "documentable": false
  desc "check", "This is applicable to unclassified systems. It is NA for others.

  Open PowerShell as an administrator.

  Execute the following command:

  Get-ChildItem -Path Cert:Localmachine\\disallowed | Where Issuer -Like *CCEB
  Interoperability* | FL Subject, Issuer, Thumbprint, NotAfter

  If the following certificate Subject, Issuer, and Thumbprint
  information is not displayed, this is finding.

  If an expired certificate (NotAfter date) is not listed in the results,
  this is not a finding.

  Subject: CN=DoD Root CA 2, OU=PKI, OU=DoD, O=U.S. Government, C=US
  Issuer: CN=US DoD CCEB Interoperability Root CA 1, OU=PKI, OU=DoD, O=U.S.
  Government, C=US
  Thumbprint: DA36FAF56B2F6FBA1604F5BE46D864C9FA013BA3
  NotAfter: 3/9/2019

  Subject: CN=DoD Root CA 3, OU=PKI, OU=DoD, O=U.S. Government, C=US
  Issuer: CN=US DoD CCEB Interoperability Root CA 2, OU=PKI, OU=DoD, O=U.S.
  Government, C=US
  Thumbprint: 929BF3196896994C0A201DF4A5B71F603FEFBF2E
  NotAfter: 9/27/2019

  Alternately, use the Certificates MMC snap-in:

  Run MMC.

  Select File, Add/Remove Snap-in.

  Select Certificates and click Add.

  Select Computer account and click Next.

  Select Local computer: (the computer this console is running on) and click
  Finish.

  Click OK.

  Expand Certificates and navigate to Untrusted Certificates >>
  Certificates.

  For each certificate with US DoD CCEB Interoperability Root CA … under
  Issued By:

  Right-click on the certificate and select Open.

  Select the Details Tab.

  Scroll to the bottom and select Thumbprint.

  If the certificate below is not listed or the value for the Thumbprint
  field is not as noted, this is a finding.

  If an expired certificate (Valid to date) is not listed in the results,
  this is not a finding.

  Issued To: DoD Root CA 2
  Issued By: US DoD CCEB Interoperability Root CA 1
  Thumbprint: DA36FAF56B2F6FBA1604F5BE46D864C9FA013BA3
  Valid to: Saturday, March 9, 2019

  Issued To: DoD Root CA 3
  Issuer by: US DoD CCEB Interoperability Root CA 2
  Thumbprint: 929BF3196896994C0A201DF4A5B71F603FEFBF2E
  Valid: Friday, September 27, 2019"
  desc "fix", "Install the US DoD CCEB Interoperability Root CA
  cross-certificate on unclassified systems.

  Issued To - Issued By - Thumbprint
  DoD Root CA 2 - US DoD CCEB Interoperability Root CA 1 -
  DA36FAF56B2F6FBA1604F5BE46D864C9FA013BA3

  DoD Root CA 3 - US DoD CCEB Interoperability Root CA 2 -
  929BF3196896994C0A201DF4A5B71F603FEFBF2E

  Administrators should run the Federal Bridge Certification Authority (FBCA)
  Cross-Certificate Removal Tool once as an administrator and once as the current
  user.

  The FBCA Cross-Certificate Remover Tool and User Guide are available on IASE at
  http://iase.disa.mil/pki-pke/Pages/tools.aspx."

  is_unclassified_system = input('is_unclassified_system')
  dod_cceb_certificates = JSON.parse(input('dod_cceb_certificates').to_json)
  if is_unclassified_system
    query = json({command: 'Get-ChildItem -Path Cert:Localmachine\\\\disallowed | Where {$_.Issuer -Like "*CCEB Interoperability*"} | Select Subject, Issuer, Thumbprint, @{Name=\'NotAfter\';Expression={"{0:dddd, MMMM dd, yyyy}" -f [datetime]$_.NotAfter}} | ConvertTo-Json'})
    describe 'The US DoD CCEB Interoperability Root CA cross-certificates installed' do
      subject { query.params }
      it { should be_in dod_cceb_certificates }
    end
  else
    impact 0.0
    describe 'This is NOT an unclassified system, therefore this control is not applicable' do
      skip 'This is NOT an unclassified system, therefore this control is not applicable'
    end
  end
end 
