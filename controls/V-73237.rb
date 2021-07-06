control 'V-73237' do
  title "Domain-joined systems must have a Trusted Platform Module (TPM)
  enabled and ready for use."
  desc "Credential Guard uses virtualization-based security to protect data
  that could be used in credential theft attacks if compromised. A number of
  system requirements must be met in order for Credential Guard to be configured
  and enabled properly. Without a TPM enabled and ready for use, Credential Guard
  keys are stored in a less secure method using software."
  impact 0.5
  tag "gtitle": 'SRG-OS-000480-GPOS-00227'
  tag "gid": 'V-73237'
  tag "rid": 'SV-87889r1_rule'
  tag "stig_id": 'WN16-00-000100'
  tag "fix_id": 'F-79681r1_fix'
  tag "cci": ['CCI-000366']
  tag "nist": ['CM-6 b', 'Rev_4']
  tag "documentable": false
  desc "check", "For standalone systems, this is NA.

  Current hardware and virtual environments may not support virtualization-based
  security features, including Credential Guard, due to specific supporting
  requirements including a TPM, UEFI with Secure Boot, and the capability to run
  the Hyper-V feature within a virtual machine.

  Verify the system has a TPM and it is ready for use.

  Run tpm.msc.

  Review the sections in the center pane.

  Status must indicate it has been configured with a message such as The
  TPM is ready for use or The TPM is on and ownership has been taken.

  TPM Manufacturer Information - Specific Version = 2.0 or 1.2

  If a TPM is not found or is not ready for use, this is a finding."
  desc "fix", "Ensure domain-joined systems have a TPM that is configured for
  use. (Versions 2.0 or 1.2 support Credential Guard.)

  The TPM must be enabled in the firmware.

  Run tpm.msc for configuration options in Windows."
  is_domain = command('wmic computersystem get domain | FINDSTR /V Domain').stdout.strip

  if is_domain == 'WORKGROUP'
    impact 0.0
    desc 'This system is not joined to a domain, therfore this control is not appliable as it does not apply to standalone systems'
  end

  if is_domain != 'WORKGROUP'
    tpm_ready = command('Get-Tpm | select -expand TpmReady').stdout.strip
    tpm_present = command('Get-Tpm | select -expand TpmPresent').stdout.strip
    describe 'Trusted Platform Module (TPM) TpmReady' do
      subject { tpm_ready }
      it { should eq 'True' }
    end
    describe 'Trusted Platform Module (TPM) TpmPresent' do
      subject { tpm_present }
      it { should eq 'True' }
    end
  end
end
