<# Registers new devices based on the hostname received.
    Will set object up in AD based on the location as needed.
    (Should receive input from person injecting.)
    Will setup the item in AirWatch as well, using the same hostname
    as friendly.

    .SYNOPSIS
        Helps automate device registration and ad object creation.
        Should allow EUS to pre-register the device so it does not
        need to be removed from box. As its booted for the first
        time with the user, it would not require any interaction from
        the receiving person.

    .PARAMETER id (required)
        This is the user ID for the enrollment user.

    .PARAMETER baseCSV (required)
        This is the file that we will import to do our registration.
        Using a CSV allows us to ensure the placement is correct and
        automating the processes becomes much simpler.

    .PARAMETER outputFile (optional)
        This is not a required file, just helps with storing
        potentially useful information for us to use in debugging.

    .PARAMETER configFile (optional)
        This is not a required file, this allows you to use a different
        awupdaterc.ps1 file if need be.

#>
[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$id,

        [Parameter(Mandatory=$True)]
        [string]$baseCSV,

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
    $outputFile = ".\reg_error.csv"
}

# Source in the config file and its settings
. $configFile

# Set our base call for the api.
$baseURL = $endpointURL + "/API/"

# Source build headers function.
. ".\buildheaders.ps1"

# Source Basic auth function.
. ".\basicauth.ps1"

# We know we're using json to set accept/content type as such.
$contentType = "application/json"

# Concatonate User information for processing.
$userInfo = $userName + ":" + $password
$restUser = Get-BasicUserForAuth $userInfo

# Get our headers
$headers = Build-Headers $restUser $tenantAPIKey $contentType $contentType

# Setup our caller string to insert the devices.
$changeURL = $baseURL + "system/users/$id/registerdevice"

# Display what url we are calling to register the device.
Write-Verbose ""
Write-Verbose "---------- Caller URL ----------"
Write-Verbose ("URL: " + $changeURL)
Write-Verbose "--------------------------------"
Write-Verbose ""

# Get our list of items to insert.
$items = Import-CSV $baseCSV

# Initialize dataset
$dataSet = @()

# Initialize dataFailed
$dataFailed = @()

# Loop our items.
foreach ($item in $items) {
    # (Re) Initialize details and details failed elements.
    $details = @{}
    $detFailed = @{}
    
    # Store the items we need to update.
    $details = @{
        AssetNumber = $item.AssetNumber
        SerialNumber =  $item.SerialNumber.Trim().TrimStart('S')
        FriendlyName = $item.Hostname
    }
    
    # New Device insert
    $dets = ($details | ConvertTo-JSON)
    # Display the data it is going to be sending.
    Write-Verbose ""
    Write-Verbose "---------- Sending Body ----------"
    Write-Verbose $dets
    Write-Verbose "----------------------------------"
    Write-Verbose ""
    # Perform the action
    #If ($Proxy) {
    #    If ($UserAgent) {
    #        $ret = Invoke-RestMethod -Method Post -Uri $changeURL -Headers $headers -ContentType $contentType -Body $dets -Proxy $Proxy -UserAgent $UserAgent
    #    } Else {
    #        $ret = Invoke-RestMethod -Method Post -Uri $changeURL -Headers $headers -ContentType $contentType -Body $dets -Proxy $Proxy
    #    }
    #} Else {
    #    If ($UserAgent) {
    #        $ret = Invoke-RestMethod -Method Post -Uri $changeURL -Headers $headers -ContentType $contentType -Body $dets -UserAgent $UserAgent
    #    } Else {
    #        $ret = Invoke-RestMethod -Method Post -Uri $changeURL -Headers $headers -ContentType $contentType -Body $dets
    #    }
    #}
    #Write-Verbose $ret
    # Sleep a little bit so AW doesn't think we need to be blocked.
    #Start-Sleep -m 500
    # Test if 
    #If (@(Get-ADComputer $item.Hostname -ErrorAction SilentlyContinue).Count) {
    #    continue
    #}
    #If ($item.OU) {
    #    New-ADComputer -Name $item.Hostname -Enabled $True -Path $item.OU
    #} Else {
    #    New-ADComputer -Name $item.Hostname -Enabled $True
    #}
}
