function Get-SystemFirmwareUpdate {
    #=================================================
    #	MSCatalog PowerShell Module
    #   Ryan-Jan
    #   https://github.com/ryan-jan/MSCatalog
    #   This excellent work is a good way to gather information from MS
    #   Catalog
    #=================================================
    if (!(Get-Module -ListAvailable -Name MSCatalog)) {
        Install-Module MSCatalog -Force -SkipPublisherCheck -ErrorAction Ignore
    }
    #=================================================
    #	Make sure the Module was installed
    #=================================================
    if (Get-Module -ListAvailable -Name MSCatalog) {
        if (Test-MicrosoftUpdateCatalog) {
            Try {
                Get-MSCatalogUpdate -Search (Get-SystemFirmwareResource) -SortBy LastUpdated -Descending | Select-Object LastUpdated,Title,Version,Size,Guid -First 1
            }
            Catch {
                #Do nothing
            }
        }
        else {
            Write-Warning "Get-SystemFirmwareUpdate: Could not reach https://www.catalog.update.microsoft.com/"
        }
    }
    else {
        Write-Warning "Get-SystemFirmwareUpdate: Could not install required PowerShell Module MSCatalog"
    }
    #=================================================
}
