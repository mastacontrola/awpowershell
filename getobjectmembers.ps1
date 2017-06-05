<# Helper to turn PSCustomObject into a list of Key/Value Pairs.
    .SYNOPSIS
        This just sources the Get-ObjectMembers function.

    .USAGE
        None available.
#>
Function Get-ObjectMembers {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [PSCustomObject]$obj
    )
    $obj | Get-Member -MemberType NoteProperty | ForEach-Object {
        $key = $_.Name
        [PSCustomObject]@{Key = $key; Value = $obj."$key"}
    }
}
