function Install-Font {
	
	param(
		[Parameter( Mandatory, ValueFromPipeline )]
		[System.IO.FileInfo[]]
		$FontFile,
		
		[switch]
		$WhatIf
	)
	
	begin {
		$shell = New-Object -ComObject 'Shell.Application';
	}
	
	process {
		foreach( $file in $FontFile ) {
			if( $WhatIf ) {
				Write-Host -Message(
					'Installing font "{0}".' -f $file.Name
				);
			} else {
				$shell.NameSpace(
					$file.Directory.FullName
				).ParseName(
					$file.Name
				).Verbs() | ForEach-Object {
					if( $_.Name -eq 'Install for &all users' ) {
						$_.DoIt();
					}
				};
			}
		}
	}
}

#If the file does not exist, create it.
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        if ($PSVersionTable.PSEdition -eq "Core" ) { 
            if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
                New-Item -Path ($env:userprofile + "\Documents\Powershell") -ItemType "directory"
		$pwspath = $env:userprofile + "\Documents\Powershell\quick-term.omp.json"
		curl https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/quick-term.omp.json -o $pwspath
            }
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
                New-Item -Path ($env:userprofile + "\Documents\WindowsPowerShell") -ItemType "directory"
            }
        }
        
	$pspath = $env:userprofile + "\Documents\WindowsPowerShell\quick-term.omp.json"
	curl https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/quick-term.omp.json -o $pspath
	Invoke-RestMethod https://raw.githubusercontent.com/l4rm4nd/powershell-profile/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
}
# If the file already exists, show the message and do nothing.
 else {
		 Get-Item -Path $PROFILE | Move-Item -Destination oldprofile.ps1
		 Invoke-RestMethod https://raw.githubusercontent.com/l4rm4nd/powershell-profile/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
		 Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
 }
& $profile

# OMP Install
#
winget install -e --accept-source-agreements --accept-package-agreements JanDeDobbeleer.OhMyPosh

# Font Install
# You need to set your Nerd Font of choice in your window defaults or in the Windows Terminal Settings.
# download fonts
Invoke-RestMethod https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip?WT.mc_id=-blog-scottha -o cove.zip
# extract zip
Expand-Archive .\cove.zip -DestinationPath cove
# install fonts
Get-ChildItem -LiteralPath "cove" -File -Filter *.ttf | Install-Font

# Choco install
#
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Terminal Icons Install
#
Install-Module -Name Terminal-Icons -Repository PSGallery
