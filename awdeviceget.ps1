<# Execute-AWRestAPI Powershell Script Help

    .SYNOPSIS
        This powershell script makes a REST API call to an AirWatch Server.
        This particular script will retrieve the device list infromation.

    .USAGE
        Ensure awupdaterc.ps1 is in the same directory. This file contains:
        1. User to authenticate with.
        2. Password for the user.
        3. The endpoint URL.

        Call this script to actually retreive the information. Options below:

    .PARAMETER outputFile (optional)
        This is not a required file, this just helps with printing out useful
        information.

    .PARAMETER configFile (optional)
        This is not a required file, this allows you to use a different
        awupdaterc.ps1 file if need be.

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
if (!$outputFile) {
    $outputFile = ".\device_list.csv"
}

# Source in the config file and its settings.
. $configFile

# Set our base call for the api.
$baseURL = $endpointURL + "/API/"

# Source build headers function.
. ".\buildheaders.ps1"

# Source Basic auth function.
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

# Setup our caller string to get the devices
$changeURL = $baseURL + "mdm/devices/search?pageSize=10000";

# Write out infromation for us to know what's going on.
Write-Verbose ""
Write-Verbose "---------- Caller URL ----------"
Write-Verbose ("URL: " + $changeURL)
Write-Verbose "--------------------------------"
Write-Verbose ""
If ($Proxy) {
    If ($UserAgent) {
        $request = Invoke-RestMethod -Uri $changeURL -Headers $headers -OutFile ".\temp.json" -Proxy $Proxy -UserAgent $UserAgent
    } Else {
        $request = Invoke-RestMethod -Uri $changeURL -Headers $headers -OutFile ".\temp.json" -Proxy $Proxy
    }
} Else {
    If ($UserAgent) {
        $request = Invoke-RestMethod -Uri $changeURL -Headers $headers -OutFile ".\temp.json" -UserAgent $UserAgent
    } Else {
        # Perform request
        $request = Invoke-RestMethod -Uri $changeURL -Headers $headers -OutFile ".\temp.json"
    }
}

# As we stored all the data into a file we need to read it in.
$data = Get-Content ".\temp.json" -Raw | ConvertFrom-Json

# Initialize array of data to store.
$dataSet = @()

# Loop our devices found.
foreach ($device in $data.Devices | Select DeviceFriendlyName,Id, LocationGroupId,SerialNumber,AssetNumber) {
    $details = @{}
    $id = $device.Id.Value
    $locationID = $device.LocationGroupID.Id.Value
    $locationName = $device.LocationGroupID.Name
    $details = [ordered]@{
        DeviceName = $device.DeviceFriendlyName
        DeviceID = $id
        DeviceLocationID = $locationID
        DeviceLocationName = $locationName
        DeviceSerial = $device.SerialNumber
        DeviceAsset = $device.AssetNumber
    }
    $dataSet += New-Object PSObject -Property $details
}
# Create the CSV to process from.
$dataSet | Export-CSV -Path $outputFile -NoTypeInformation
