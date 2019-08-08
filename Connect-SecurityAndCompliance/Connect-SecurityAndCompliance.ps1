function Connect-SecurityAndCompliance {
    [CmdletBinding()]
    [Alias("Connect-IPP")]
    param (
    )
    begin {
        #Import the module, requires that you are administrator and are able to run the script
        Import-Module (Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse).Fullname[-1]
    }
    process {
        #Connect specifying username, if you already have authenticated to another moduel, you actually do not have to authenticate
        Try {
            Connect-IPPSSession
        }
        Catch{
            Write-Warning $_.Exception.Message
        }
    }
    end {

        Remove-Module CreateExoPSSession
    }
}