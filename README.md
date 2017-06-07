# awpowershell
AirWatch Powershell API Scripts

## awdeviceget.ps1

 * Can take arguments (not required)
  
   1. `-configFile '\path\to\filename'`

    * The configuration file. Defaults to current location. Filename is awupdaterc.ps1 as default. (e.g. `.\awupdaterc.ps1`)

    * Used to change the location of your configuration file as needed.

   2. `-outputFile '\path\to\filename'`

    * The csv file to store the information. Defaults to current location. Filename is `device_list.csv`. (e.g. `.\device_list.csv`)

 * Downloads the current device list from your AirWatch environment.

 * Nothing is required for this script.

## awtagget.ps1

 * ### Required Arguments

   1. `-id #organizationalid`

    * The organization's identifier, this is not what aw will show you so you need to find it.

 * ### Optional Arguments

   1. `-configFile '\path\to\filename'`

    * The configuration file. Defaults to current location. Filename is awupdaterc.ps1 as default. (e.g. `.\awupdaterc.ps1`)

   2. `-outputFile '\path\to\filename'`

    * The csv file to store the information. Defaults to current location. Filename is `tag_list.csv`. (e.g. `.\tag_list.csv`)

  * Gets all the tags in your AirWatch environment.


## awupdaterc.ps1

 * Not a "functional" script, just stores configuration information.

 * ### Items contained

   1. $userName | This is the user to authenticate to AirWatch API

   2. $password | This is the password to the user for authenticating.

   3. $tenantAPIKey | This is the API key from the AirWatch console.

   4. $endpointURL | This is the DNS address to get ot your AirWatch Instance. (e.g. https://airwatchconsole.awmdm.com/)

## basicauth.ps1

 * Not a "functional" script, just creates a common file for the Get-BasicUserForAuth function used in other scripts.

 * As the name suggests, it just get's the basic authentication for the user/password pair.

## buildheaders.ps1

 * Not a "functional" script, just creates a common file for the Build-Headers function used in other scripts.

 * As the name of the file suggests, it is what builds our headers to send to the AW API Console.

## getobjectmembers.ps1

 * Not a "functional" script, just creates a common file for the Get-ObjectMembers function. This is not used currently but could be useful later on.

## processlocationadds.ps1

 * ### Required Arguments

   1. `-deviceCSV '\path\to\filename'`

    * The device file to iterate through. (See awdeviceget.ps1)

   2. `-locationCSV '\path\to\filename'`

    * The location/tag list. (See awtagget.ps1)

   3. `-baseCSV '\path\to\filename`

    * The file we're attempting to process information for/on.

 * ### Optional Arguments

   1. `-configFile '\path\to\filename'`

    * The configuration file. Defaults to current location. Filename is awupdaterc.ps1 as default. (e.g. `.\awupdaterc.ps1`)

   2. `-outputFile '\path\to\filename'`

    * The csv file to store the information. Defaults to current location. Filename is `update_tags.csv`. (e.g. `.\update_tags.csv`)

   * If you add the `-Verbose` argument it will output much more information.

   * This script will create a failure csv in `.\failureItems.csv`

    * If LocationName, LocationID, LocationType items are blank, failure = could not locate matching tag in airwatch locationCSV file. (Device labeled headers will also be blank)

    * If Device labeled headers are blank, device could not be found in airwatch.

## processlocationremoves.ps1

 * ### Required Arguments

   1. `-deviceCSV '\path\to\filename'`

    * The device file to iterate through. (See awdeviceget.ps1)

   2. `-locationCSV '\path\to\filename'`

    * The location/tag list. (See awtagget.ps1)

   3. `-baseCSV '\path\to\filename`

    * The file we're attempting to process information for/on.

 * ### Optional Arguments

   1. `-configFile '\path\to\filename'`

    * The configuration file. Defaults to current location. Filename is awupdaterc.ps1 as default. (e.g. `.\awupdaterc.ps1`)

   2. `-outputFile '\path\to\filename'`

    * The csv file to store the information. Defaults to current location. Filename is `remove_tags.csv`. (e.g. `.\remove_tags.csv`)

   * If you add the `-Verbose` argument it will output much more information.

   * This script will create a failure csv in `.\failureRemItems.csv`

    * If LocationName, LocationID, LocationType items are blank, failure = could not locate matching tag in airwatch locationCSV file. (Device labeled headers will also be blank)

    * If Device labeled headers are blank, device could not be found in airwatch.
