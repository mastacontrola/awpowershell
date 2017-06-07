<# Parse the CSV items for information.

    .SYNOPSIS
        This powershell script will parse our CSV's as determined to get the data
        we need. This should help with updating our locations.

    .USAGE
        Ensure we have the files to parse through
        1. inputFile1 = File to lookup (With device serials)
        2. inputFile2 = File to lookup (With location information)
        3. inputFile3 = File to read in (This is the file we're basing our
        updates from.)
        4. outputFile = Where to store matches so we can do something with.

    .PARAMETER deviceCSV (required)
        The devices file.

    .PARAMETER locationCSV (required)
        The locations file.

    .PARAMETER baseCSV (required)
        The file to base lookups from.

    .PARAMETER outputFile (optional)
        The file to place our matches.

    .PARAMETER configFile (optional)
        The is not a required file, this allows you to use a different
        awupdaterc.ps1 file if need be.

#>
[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$deviceCSV,

        [Parameter(Mandatory=$True)]
        [string]$locationCSV,

        [Parameter(Mandatory=$True)]
        [string]$baseCSV,

        [Parameter()]
        [string]$outputFile,

        [Parameter()]
        [string]$configFile
    )

# Set errors to silent if we are not in verbose mode.
If ($PSCmdlet.Myinvocation.BoundParameters["Verbose"].IsPresent) {
    $ErrorActionPreference = "SilentlyContinue"
}

# Set up default if configFile is not already set.
If (!$configFile) {
    $configFile = ".\awupdaterc.ps1"
}

# Set up default if outputFile is not already set.
If (!$outputFile) {
    $outputFile = ".\update_tags.csv"
}

# Source in the config file and its settings.
. $configFile

# Set our base call for the api.
$baseURL = $endpointURL + "/API/"

# Source build headers function.
. ".\buildHeaders.ps1"

# Source Basic auth function.
. ".\basicauth.ps1"

# Source get object members function.
. ".\getobjectmemebers.ps1"

# We know we're using json to set accept/content type as such.
$contentType = "application/json"

# Concatonate User information for processing.
$userInfo = $userName + ":" + $password
$restUser = Get-BasicUserForAuth $userInfo

# Get our headers.
$headers = Build-Headers $restUser $tenantAPIKey $contentType $contentType

# Let people know we're working
Write-Output "This will take a while as we process the information given"
# AW Locations
$locations = Import-CSV $locationCSV
# AW Devices
$devices = Import-CSV $deviceCSV
# Base Items
$items = Import-CSV $baseCSV
# Initialize dataset
$dataSet = @()
$dataFailed = @()
# Loop our items.
foreach ($item in $items) {
    $details = @{}
    $detFailed = @{}
    $locationName = $item.Location
    $location = $locations | Where-Object {
        $locationName -contains $_.LocationName
    }
    $deviceSerial1 = $item.MSN.TrimStart('S')
    $deivceSerial2 = $item.'ESN/IMEI'.TrimStart('S')
    $device = $devices | Where-Object {
        $deviceSerial1 -contains $_.DeviceSerial
    }
    $deviceID = $device.DeviceID
    if (!$deviceID) {
        $device = $devices | Where-Object {
            $deviceSerial2 -contains $_.DeviceSerial
        }
    }
    $locationID = $location.LocationID
    $deviceID = $device.DeviceID
    If (!$locationID) {
        $detFailed = [ordered]@{
            Location = $item.Location
            'Asset Tag' = $item.'Asset Tag'
            MSN = $item.MSN
            'ESN/IMEI' = $item.'ESN/IMEI'
            LocationName = $location.LocationName
            LocationID = $location.LocationID
            LocationType = $location.LocationType
            DeviceName = $device.DeviceName
            DeviceID = $device.DeviceID
            DeviceLocationName = $device.DeviceLocationName
            DeviceSerial = $device.DeviceSerial
            DeviceAsset = $device.DeviceAsset
        }
        $dataFailed += New-Object PSObject -Property $detFailed
        continue;
    }
    if (!$deviceID) {
        $detFailed = [ordered]@{
            Location = $item.Location
            'Asset Tag' = $item.'Asset Tag'
            MSN = $item.MSN
            'ESN/IMEI' = $item.'ESN/IMEI'
            LocationName = $location.LocationName
            LocationID = $location.LocationID
            LocationType = $location.LocationType
            DeviceName = $device.DeviceName
            DeviceID = $device.DeviceID
            DeviceLocationName = $device.DeviceLocationName
            DeviceSerial = $device.DeviceSerial
            DeviceAsset = $device.DeviceAsset
        }
        $dataFailed += New-Object PSObject -Property $detFailed
        continue;
    }
    $details = [ordered]@{
        DeviceID = $deviceID
        LocationID = $locationID
    }
    Write-Verbose $details
    $dataSet += New-Object PSObject -Property $details
}
$dataSet | Export-CSV -Path $outputFile -NoTypeInformation
if ($dataFailed.Length) {
    $dataFailed | Export-CSV -Path ".\failureItems.csv" -NoTypeInformation
}
$det = @{}
# This just creates our simplified array.
$dataSet | Where-Object {
    $locations.LocationID -contains $_.LocationID
} | ForEach-Object {
    $det[$_.LocationID] += @($_.DeviceID)
}
Write-Output "Done processing the information preparing to update"
# This does similar but allows us to get the now set simplified
# IDs
$dev = @{}
$det.getEnumerator() | ForEach-Object {
    # Change our url calls for each set we need to update
    $changeURL = $baseURL + "mdm/tags/" + $_.Name + "/adddevices"

    # Write out information for us to know what's going on.
    Write-Verbose ""
    Write-Verbose "---------- Caller URL ----------"
    Write-Verbose ("URL: " + $changeURL)
    Write-Verbose "--------------------------------"
    Write-Verbose ""

    $dev['BulkValues'] = @{
        'Value' = $det[$_.Name]
    }
    $deviceIDs = ($dev | ConvertTo-JSON)
    Write-Verbose ""
    Write-Verbose "---------- Sending Body ----------"
    Write-Verbose $deviceIDs
    Write-Verbose "----------------------------------"
    Write-Verbose ""
    $ret = Invoke-RestMethod -Method Post -Uri $changeURL -Headers $headers -ContentType $contentType -Body $deviceIDs
    Write-Verbose $ret
    Start-Sleep -m 500
}
Write-Output "All Complete"
