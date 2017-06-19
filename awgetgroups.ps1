<# Execute-AWRestAPI Powershell Script Help
    
    .SYNOPSIS
        This Poweshell script make a REST API call to an AirWatch server.
        This particular script will retrieve groups information.
        
    .USAGE
        Ensure awupdaterc.ps1 is in the same directory. This file contains:
        Required:
            1. User to authenticate with.
            2. Password for the user.
            3. The endpoint URL.
        Optional:
            1. Proxy address (with/without port as needed)
            2. UserAgent send a custom user agent, required for some proxy
            implementations.
            
        Call this script to actually retreive the information. Options below:
    
    .PARAMETER outputFile (optional)
        This is not a required file, this just helps with printing out useful information.

    .PARAMETER configFile (optional)
        This is not a required file, this allows you to use a different awupdaterc.ps1 file if need be.

#>

[CmdletBinding()]
    Param(
        [Parameter()]
        [string]$outputFile,

        [Parameter()]
        [string]$configFile
)

# Set errors to silent if we are not in verbose mode.
If (!$PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
    $ErrorActionPreference = "SilentlyContinue"
}

# Set up default if configFile is not already set.
If (!$configFile) {
    $configFile = ".\awupdaterc.ps1"
}

# Set up default if outputFile is not already set.
If (!$outputFile) {
    $outputFile = ".\group_list.csv"
}

# Source in the config file and its settings.
. $configFile

# Set our base call for the api.
$baseURL = $endpointURL + "/API/"

# Source build headers function.
. ".\buildheaders.ps1"

# Source basic auth function.
. ".\basicauth.ps1"

# Source get object members function.
. ".\getobjectmembers.ps1"

# We know we're using json so set accept/content type as such.
$contentType = "application/json"

# Concatonate User information for processing.
$userInfo = $userName + ":" + $password
$restUser = Get-BasicUserForAuth $userInfo

# Get our headers.
$headers = Build-Headers $restUser $tenantAPIKey $contentType $contentType

# Setup our caller string to get the groups
$changeURL = $baseURL + "system/groups/search?pageSize=10000"

# Write out information for us to know what's going on.
Write-Verbose ""
Write-Verbose "---------- Caller URL ----------"
Write-Verbose ("URL: " + $changeURL)
Write-Verbose "--------------------------------"
Write-Verbose ""

# Perform Request
If ($Proxy) {
    If ($UserAgent) {
        $request = Invoke-RestMethod -Uri $changeURL -Headers $headers -Outfile ".\temp.json" -Proxy $Proxy -UserAgent $UserAgent
    } Else {
        $request = Invoke-RestMethod -Uri $changeURL -Headers $headers -Outfile ".\temp.json" -Proxy $Proxy
    }
} Else {
    If ($UserAgent) {
        $request = Invoke-RestMethod -Uri $changeURL -Headers $headers -Outfile ".\temp.json" -UserAgent $UserAgent
    } Else {
        $request = Invoke-RestMethod -Uri $changeURL -Headers $headers -Outfile ".\temp.json"
    }
}

# As we stored all the data into a file we need to read it in.
$data = Get-Content ".\temp.json" -Raw | ConvertFrom-Json

# Initialize array of data to store.
$dataSet = @()

# Loop our groups found.
foreach ($group in $data.LocationGroups) {
    $details = @{}
    $details = [ordered]@{
        GroupID = $group.Id.Value
        GroupLabelID = $group.GroupId
        GroupName = $group.Name
        GroupType = $group.LocationGroupType
        GroupDevices = $group.Devices
        GroupAdmins = $group.Admins
        GroupUsers = $group.Users
        GroupCountry = $group.Country
        GroupCreated = $group.CreatedOn
        GroupLocale = $group.Locale
    }
    $dataSet += New-Object PSObject -Property $details
}

# Create the CSV to process from.
$dataSet | Export-CSV -Path $outputFile -NoTypeInformation
