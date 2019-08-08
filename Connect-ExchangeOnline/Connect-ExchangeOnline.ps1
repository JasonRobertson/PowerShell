function Connect-ExchangeOnline     {
    [CmdletBinding()]
    [Alias("Connect-EXO")]
    param (
    )

    begin {
        #Import the module, requires that you are administrator and are able to run the script
        Try{
            Import-Module -Name (Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse).Fullname[-1] -ErrorAction Stop -Verbose
        }
        Catch{
            Write-Warning $_.Exception.Message
        }
    }
    process {
        #Connect specifying username, if you already have authenticated to another moduel, you actually do not have to authenticate
        Try {
            Connect-ExoPSSession
        }
        Catch{
            Write-Warning $_.Exception.Message
        }
    }
    end {

        Remove-Module CreateExoPSSession
    }
}