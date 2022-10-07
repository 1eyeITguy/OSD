function Save-MyDriverPack {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.String]$DownloadPath = 'C:\Drivers',
        [System.Management.Automation.SwitchParameter]$Expand,
        [System.String]$Manufacturer = (Get-MyComputerManufacturer -Brief),
        [System.String]$Product = (Get-MyComputerProduct),
        [System.String]
        $Guid
    )
    Write-Verbose "Manufacturer: $Manufacturer"
    Write-Verbose "Product: $Product"
    #=================================================
    #   Block
    #=================================================
    if ($Expand) {
        Block-StandardUser
    }
    Block-WindowsVersionNe10
    #=================================================
    #   Get-MyDriverPack
    #=================================================
    if ($Guid) {
        $GetMyDriverPack = Get-OSDCloudDriverPacks | Where-Object {$_.Guid -eq $Guid} | Select-Object -First 1
    }
    else {
        $GetMyDriverPack = Get-MyDriverPack -Manufacturer $Manufacturer -Product $Product
    }

    if ($GetMyDriverPack) {
        $OutFile = Join-Path $DownloadPath $GetMyDriverPack.FileName
        #=================================================
        #   Save-WebFile
        #=================================================
        if (-NOT (Test-Path "$DownloadPath")) {
            New-Item $DownloadPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        Write-Verbose -Message "CatalogVersion: $($GetMyDriverPack.CatalogVersion)"
        Write-Verbose -Message "Name: $($GetMyDriverPack.Name)"
        Write-Verbose -Message "Product: $($GetMyDriverPack.Product)"
        Write-Verbose -Message "Url: $($GetMyDriverPack.Url)"
        Write-Verbose -Message "OutFile: $OutFile"
        
        Save-WebFile -SourceUrl $GetMyDriverPack.Url -DestinationDirectory $DownloadPath -DestinationName $GetMyDriverPack.FileName

        if (! (Test-Path $OutFile)) {
            Write-Warning "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Driver Pack failed to download"
        }
        else {
            $GetItemOutFile = Get-Item $OutFile
        }
        $GetMyDriverPack | ConvertTo-Json | Out-File "$OutFile.json" -Encoding ascii -Width 2000 -Force
        #=================================================
        #   Expand
        #=================================================
        if ($GetItemOutFile) {
            if ($PSBoundParameters.ContainsKey('Expand')) {
    
                $ExpandFile = $GetItemOutFile.FullName
                Write-Verbose -Message "DriverPack: $ExpandFile"
                #=================================================
                #   Cab
                #=================================================
                if ($GetItemOutFile.Extension -eq '.cab') {
                    $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
        
                    if (-NOT (Test-Path "$DestinationPath")) {
                        New-Item $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    
                        Write-Verbose -Verbose "Expanding CAB Driver Pack to $DestinationPath"
                        Expand -R "$ExpandFile" -F:* "$DestinationPath" | Out-Null
                    }
                }
                #=================================================
                #   Dell
                #=================================================
                if ($GetItemOutFile.Extension -eq '.exe') {
                    if ($GetItemOutFile.VersionInfo.FileDescription -match 'Dell') {
                        Write-Verbose -Verbose "FileDescription: $($GetItemOutFile.VersionInfo.FileDescription)"
                        Write-Verbose -Verbose "ProductVersion: $($GetItemOutFile.VersionInfo.ProductVersion)"
    
                        $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
    
                        if (-NOT (Test-Path "$DestinationPath")) {
                            Write-Verbose -Verbose "Expanding Dell Driver Pack to $DestinationPath"
                            $null = New-Item -Path $DestinationPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
                            Start-Process -FilePath $ExpandFile -ArgumentList "/s /e=`"$DestinationPath`"" -Wait
                        }
                    }
                }
                #=================================================
                #   HP
                #=================================================
                if (($GetItemOutFile.Extension -eq '.exe') -and ($env:SystemDrive -ne 'X:')) {
                    if (($GetItemOutFile.VersionInfo.InternalName -match 'hpsoftpaqwrapper') -or ($GetItemOutFile.VersionInfo.OriginalFilename -match 'hpsoftpaqwrapper.exe') -or ($GetItemOutFile.VersionInfo.FileDescription -like "HP *")) {
                        Write-Verbose -Message "FileDescription: $($GetItemOutFile.VersionInfo.FileDescription)"
                        Write-Verbose -Message "InternalName: $($GetItemOutFile.VersionInfo.InternalName)"
                        Write-Verbose -Message "OriginalFilename: $($GetItemOutFile.VersionInfo.OriginalFilename)"
                        Write-Verbose -Message "ProductVersion: $($GetItemOutFile.VersionInfo.ProductVersion)"
                        
                        $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
    
                        if (-NOT (Test-Path "$DestinationPath")) {
                            Write-Verbose -Verbose "Expanding HP Driver Pack to $DestinationPath"
                            Start-Process -FilePath $ExpandFile -ArgumentList "/s /e /f `"$DestinationPath`"" -Wait
                        }
                    }
                }
                #=================================================
                #   Lenovo
                #=================================================
                if (($GetItemOutFile.Extension -eq '.exe') -and ($env:SystemDrive -ne 'X:')) {
                    if (($GetItemOutFile.VersionInfo.FileDescription -match 'Lenovo') -or ($GetItemOutFile.Name -match 'tc_') -or ($GetItemOutFile.Name -match 'tp_') -or ($GetItemOutFile.Name -match 'ts_') -or ($GetItemOutFile.Name -match '500w') -or ($GetItemOutFile.Name -match 'sccm_') -or ($GetItemOutFile.Name -match 'm710e') -or ($GetItemOutFile.Name -match 'tp10') -or ($GetItemOutFile.Name -match 'tp8') -or ($GetItemOutFile.Name -match 'yoga')) {
                        Write-Verbose -Message "FileDescription: $($GetItemOutFile.VersionInfo.FileDescription)"
                        Write-Verbose -Message "ProductVersion: $($GetItemOutFile.VersionInfo.ProductVersion)"
    
                        $DestinationPath = Join-Path $GetItemOutFile.Directory 'SCCM'
    
                        if (-NOT (Test-Path "$DestinationPath")) {
                            Write-Verbose -Verbose "Expanding Lenovo Driver Pack to $DestinationPath"
                            Start-Process -FilePath $ExpandFile -ArgumentList "/SILENT /SUPPRESSMSGBOXES" -Wait
                        }
                    }
                }
                #=================================================
                #   MSI
                #=================================================
                if (($GetItemOutFile.Extension -eq '.msi') -and ($env:SystemDrive -ne 'X:')) {
                    $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
    
                    if (-NOT (Test-Path "$DestinationPath")) {
                        #Need to sort out what to do here
                    }
                }
                #=================================================
                #   Zip
                #=================================================
                if ($GetItemOutFile.Extension -eq '.zip') {
                    $DestinationPath = Join-Path $GetItemOutFile.Directory $GetItemOutFile.BaseName
    
                    if (-NOT (Test-Path "$DestinationPath")) {
                        Write-Verbose -Verbose "Expanding ZIP Driver Pack to $DestinationPath"
                        Expand-Archive -Path $ExpandFile -DestinationPath $DestinationPath -Force
                    }
                }
                #=================================================
                #   Everything Else
                #=================================================
                #Write-Warning "Unable to expand $ExpandFile"
            }
        }
    }
}