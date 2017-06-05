<# Gets the location tags.
    .SYNOPSIS
        This script gets the location tags for our stuff.

    .USAGE
        Ensure awupdaterc.ps1 is in the same directory. This file contains
        1. User to authenticate with.
        2. Password for the user.
        3. Token for api access.
        4. The endpoint URL.

        Call this script to actually retrieve the information. Options below:

    .PARAMETER id (required)
        The id of the tag sublist to get.

    .PARAMETER outputFile (optional)
        This is not a required file, this just helps with printing out useful information.

    .PARAMETER configFile (optional)
        This is not a required file, this allows you to use a different
        awupdaterc.ps1 file if need be.

#>
[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$id,

        [Parameter()]
        [string]$outputFile,

        [Parameter()]
        [string]$configFile
    )

# Set errors to silent if we are not in verbose mode.
If (!$PSCmdlet.Myinvocation.BoundParameters["Verbose"].IsPresent) {
    $ErrorActionPreference = "SilentlyContinue"
}

# Set up default if configFile is not already set.
If (!$configFile) {
    $configFile = ".\awupdaterc.ps1"
}

# Set up default if outputFile is not already set.
If (!$outputFile) {
    $outputFile = ".\tag_list.csv"
}

# Source in the config file and its settings
. $configFile

# Set our base call for the api.
$baseURL = $endpointURL + "/API/"

# Source build headers function.
. ".\buildheaders.ps1"

# Source Basic auth function.
. ".\basicauth.ps1"

# We know we're using json so set accept/content type as such.
$contentType = "application/json"

# Concatonate User information for processing.
$userInfo = $userName + ":" + $password
$restUser = Get-BasicUserForAuth $userInfo

# Get our headers
$headers = Build-Headers $restUser $tenantAPIKey $contentType $contentType

# Setup our call string to get the tags
$changeURL = $baseURL + "system/groups/$id/tags?pageSize=0"

# Write out information for us to know what's going on.
Write-Verbose ""
Write-Verbose "---------- Caller URL ----------";
Write-Verbose ("URL: " + $changeURL)
Write-Verbose "--------------------------------";
write-Verbose ""

# Perform request
$request = Invoke-RestMethod -Uri $changeURL -Headers $headers -OutFile ".\temp_location.json"

# As we stored all the data into a file we need to read it in.
$data = Get-Content ".\temp_location.json" -Raw | ConvertFrom-Json

# Initialize array of data to store
$dataSet = @()

# Loop our locations found.
foreach ($location in $data.Tags) {
    $details = @{}
    $id = $location.Id
    $name = $location.TagName
    $type = $location.TagType
    $details = [ordered]@{
        LocationName = $name
        LocationID = $id
        LocationType = $type
    }
    $dataset += New-Object PSObject -Property $details
}
# Create the CSV to process from.
$dataSet | Export-CSV -Path $outputFile -NoTypeInformation
