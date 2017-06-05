<# Build headers script help

    .SYNOPSIS
        This powershell script just creates a single point for building headers
        rather than constantly rewriting the same script over and over.

    .USAGE
        This just sources the function so there is no real usage here.

#>
function Build-Headers {
    Param(
        [string]$authorizationString,
        [string]$tenantCode,
        [string]$acceptType,
        [string]$contentType
    )
    
    $header = @{
        "Authorization" = $authorizationString;
        "aw-tenant-code" = $tenantCode;
        #"Accept" = $accept;
        "Content-Type" = $contentType
    }

    Write-Verbose("");
    Write-Verbose("---------- Headers ----------");
    Write-Verbose("Authorization: " + $authorizationString);
    Write-Verbose("aw-tenant-code: " + $tenantCode);
    Write-Verbose("Accept: " + $acceptType);
    Write-Verbose("Content-Type: " + $contentType);
    Write-Verbose("-----------------------------");
    Write-Verbose("");

    Return $header
}
