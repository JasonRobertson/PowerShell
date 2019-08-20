function Get-NestedDistributionGroupMember
{
<#
    .Synopsis
    Get-NestedDistributionGroupMember cmdlet is used to pull all members of a parent distribution group that includes nested distirbution groups.
    .DESCRIPTION
    Get-NestedDistributionGroupMember cmdlet is used to pull all members of a parent distribution group that includes nested distirbution groups.
    .EXAMPLE
    PS C:\>  Get-NestedDistributionGroupMember -Identity Parent-DG

    Name            RecipientType
    ----            -------------
    SharedMailbox14 UserMailbox
    SharedMailbox22 UserMailbox
    SharedMailbox23 UserMailbox
    SharedMailbox48 UserMailbox
    SharedMailbox78 UserMailbox
    SharedMailbox85 UserMailbox

    This example show the cmdlet being used with no additonal parameters, but Identity
    .EXAMPLE
    PS C:\> Get-DistributionGroup Parent-DG | Get-NestedDistributionGroupMember

    Name            RecipientType
    ----            -------------
    SharedMailbox14 UserMailbox
    SharedMailbox22 UserMailbox
    SharedMailbox23 UserMailbox
    SharedMailbox48 UserMailbox
    SharedMailbox78 UserMailbox
    SharedMailbox85 UserMailbox
    SharedMailbox94 UserMailbox
    SharedMailbox08 UserMailbox

    This example show using the Get-DsitributionGroup cmdlet to verify the distirbution group exists and piping the results to Get-NestedDistributionGroup
    .EXAMPLE
    PS C:\>  Get-NestedDistributionGroupMember -Identity Parent-DG -ListGroups

    Name       RecipientType
    ----       -------------
    Child-DG01 MailUniversalDistributionGroup
    Child-DG06 MailUniversalDistributionGroup
    Child-DG03 MailUniversalDistributionGroup
    Child-DG05 MailUniversalDistributionGroup
    Child-DG07 MailUniversalDistributionGroup

    This example shows the use of the ListGroups switch to provide the list of the nested distribution groups instead of the users.
    .EXAMPLE
    PS C:\> Get-NestedDistributionGroupMember -Identity Parent-DG -ResultSize 10
    WARNING: There are more results available than are currently displayed. To view them, increase the value for the ResultSize parameter.

    Name            RecipientType
    ----            -------------
    SharedMailbox14 UserMailbox
    SharedMailbox22 UserMailbox
    SharedMailbox23 UserMailbox
    SharedMailbox48 UserMailbox
    SharedMailbox78 UserMailbox
    SharedMailbox85 UserMailbox

    This example shows the use of using the Resultsize to limit the output to desired size. The default ResultSize is 1000.
#>
    [CmdletBinding()]
    [Alias()]
    [OutputType()]
    Param
    (
        # The Identity parameter specifies the distribution group or mail-enabled security group that you want to view. You can use any values that uniquely identifies the group. For example:
        # Name
        # Alias
        # Distinguished name (DN)
        # Canonical DN
        # Email address
        # GUID
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]
        $Identity,
        # The ResultSize parameter specifies the maximum number of results to return. If you want to return all requests that match the query, use unlimited for the value of this parameter. The default value is 1000
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$false,
                   Position=1)]
        [ValidateScript(
        {
            IF($_ -match "^\d[0-9]{0,3}$" -or $_ -match "Unlimited"){
                $true
            }
            Else{
                Write-Warning "ResultSize is limited to 9999, if you want to return all results that match the query, use unlimited for the value of this parameter."
            }
        })]
        [string]
        $ResultSize=1000,
        # The ListGroups parameter is a switch that can be used to display all of the nested distribution groups in a distribuition group. The Default Value is $false.
        [switch]
        $ListGroups

    )
    Begin
    {
        Write-Verbose "ENTER - BEGIN BLOCK"
        Write-Verbose "Create User, Group and GroupList variables"
        [System.Collections.ArrayList]$User = @()
        [System.Collections.ArrayList]$Group = @()
        [System.Collections.ArrayList]$GroupList = @()

        Write-Verbose "EXIT - BEGIN BLOCK"
    }
    Process
    {
        Write-Verbose "ENTER - PROCESS BLOCK"
        $GetDistributionGroup = @{
            Identity    = $Identity
            ResultSize  = $ResultSize
        }
        Write-Verbose "ENTER - Foreach - $Identity"
        Foreach ($Member in (Get-DistributionGroupMember @GetDistributionGroup)){
            switch ($Member.RecipientType) {
                MailUniversalDistributionGroup {
                    Write-Verbose "Nested Distribution Group Identified: $($Member.DisplayName)"
                    If ($Member.DistinguishedName -notin $Group.DistinguishedName) {
                        $Group.Add($Member) | Out-Null
                        IF ($ListGroups) {
                            $GroupList.Add($Member) | Out-Null
                        }
                    }
                    Else {
                        Write-Verbose "$($Member.DisplayName) is already identified, skipping to mitigate duplicate entry"
                    }
                }
                MailUniversalSecurityGroup {
                    Write-Verbose "Nested Mail-Enabled Security Group identified: $($Member.DisplayName)"
                    If ($Member.DistinguishedName -notin $Group.DistinguishedName){
                        $Group.Add($Member) | Out-Null
                        IF ($ListGroups) {
                            $GroupList.Add($Member) | Out-Null
                        }
                    }
                    Else{
                        Write-Verbose "$($Member.DisplayName) is already identified, skipping to mitigate duplicate entry"
                    }
                }
                default{
                    If ($Member.DistinguishedName -notin $User.DistinguishedName) {
                        $User.Add($Member) | Out-Null
                    }
                    Else {
                        Write-Verbose "$($Member.DisplayName) is already identified, skipping to mitigate duplicate entry"
                    }
                }
            }
        }
        Write-Verbose "EXIT - Foreach - $Idenity"
        Write-Verbose "ENTER - Do-While"
        do {
            $GetDistributionGroup = @{
                Identity    = $Group[0].DistinguishedName
                ResultSize  = $ResultSize
            }
            Write-Verbose "ENTER - Foreach - $($Group[0].DisplayName)"
            Foreach ($Member in (Get-DistributionGroupMember @GetDistributionGroup)){
                switch ($Member.RecipientType) {
                    MailUniversalDistributionGroup {
                        Write-Verbose "Nested Distribution Group Identified: $($Member.DisplayName)"
                        If ($Member.DistinguishedName -notin $Group.DistinguishedName) {
                            $Group.Add($Member) | Out-Null
                            IF ($ListGroups) {
                                $GroupList.Add($Member) | Out-Null
                            }
                        }
                        Else {
                            Write-Verbose "$($Member.DisplayName) is already identified, skipping to mitigate duplicate entry"
                        }
                    }
                    MailUniversalSecurityGroup {
                        Write-Verbose "Nested Mail-Enabled Security Group identified: $($Member.DisplayName)"
                        If ($Member.DistinguishedName -notin $Group.DistinguishedName){
                            $Group.Add($Member) | Out-Null
                            IF ($ListGroups) {
                                $GroupList.Add($Member) | Out-Null
                            }
                        }
                        Else{
                            Write-Verbose "$($Member.DisplayName) is already identified, skipping to mitigate duplicate entry"
                        }
                    }
                    default{
                        If ($Member.DistinguishedName -notin $User.DistinguishedName) {
                            $User.Add($Member) | Out-Null
                        }
                        Else {
                            Write-Verbose "$($Member.DisplayName) is already identified, skipping to mitigate duplicate entry"
                        }
                    }
                }
            }
            Write-Verbose "EXIT - Foreach - $($Group[0].DisplayName)"
            Try{
                Write-Verbose "Remove $($Group[0].Identity) from Group list"
                $Group.Remove($Group[0])
            }
            Catch{
                Write-Verbose $_.exception.message
                Write-Warning $_.exception.message
            }
        }
        While ($Group.Count -gt 0)
        Write-Verbose "EXIT - Do-While"
        Write-Verbose "ENTER - Switch - ListGroup"
        switch ($ListGroups) {
            True {
                Write-Output $GroupList
            }
            Default {
                Write-Output $user
            }
        }
        Write-Verbose "EXIT - Switch - ListGroup"
        Write-Verbose "EXIT - PROCESS BLOCK"
    }
    End
    {
        Write-Verbose "ENTER - END BLOCK"
        Write-Verbose "Remove created variables"
        Remove-Variable User, Group, GroupList
        Write-Verbose "EXIT - END BLOCK"
    }
}
