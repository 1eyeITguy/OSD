function Find-OSDCloudODTFile {
    [CmdletBinding()]
    param ()
    #=================================================
    #	Create the Array
    #=================================================
    $Results = @()
    #=================================================
    #	Search for Autopilot Profiles
    #=================================================
    $Results = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        Get-ChildItem "$($_.Name):\OSDCloud\ODT\*\*\*.xml" -File -Force -ErrorAction Ignore
    }
    #=================================================
    #	Results
    #=================================================
    $Results | Sort-Object -Property Name -Descending -Unique
    #=================================================
}
