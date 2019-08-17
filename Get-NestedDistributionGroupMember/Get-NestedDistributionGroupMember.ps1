function Get-NestedDistributionGroupMember
{
<#
.Synopsis
   Get-NestedDistributionGroupMember cmdlet is used to pull all members of a parent distribution group that includes nested distirbution groups.
.DESCRIPTION
      Get-NestedDistributionGroupMember cmdlet is used to pull all members of a parent distribution group that includes nested distirbution groups.
.EXAMPLE
   PS C:\> Get-DistributionGroup all | Get-NestedDistributionGroupMember

   This example shows the user confirming the distribution group exists and piping the values to Get-NestedDistributionGroup.
.EXAMPLE
   Another example of how to use this cmdlet
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
            IF($_ -match "^\d[0-9]{0,3}$"){
                $true
            }
            ElseIf($_ -match "Unlimited"){
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
        $GetDistributionGroup = @{
            Identity    = $Identity
            ResultSize  = $ResultSize
        }
        Write-Verbose "EXIT - BEGIN BLOCK"
    }
    Process
    {
        Write-Verbose "ENTER - PROCESS BLOCK"
        Write-Verbose "ENTER - Foreach - $Identity"
        Foreach ($Member in (Get-DistributionGroupMember @GetDistributionGroup)){
            switch ($Member.RecipientType) {
                MailUniversalDistributionGroup {
                    Write-Verbose "Nested Distribution Group Identified: $($Member.DisplayName)"
                    If ($Member.DistinguishedName -notin $Group) {
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
                    If ($Member.DistinguishedName -notin $Group){
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
                    If ($Member.DistinguishedName -notin $User) {
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
            If($Group.Count -gt 0){
                $GetDistributionGroup = @{
                    Identity    = $Group[0].DistinguishedName
                    ResultSize  = $ResultSize
                }
                Write-Verbose "ENTER - Foreach - $($Group[0].DisplayName)"
                Foreach ($Member in (Get-DistributionGroupMember @GetDistributionGroup)){
                    switch ($Member.RecipientType) {
                        MailUniversalDistributionGroup {
                            Write-Verbose "Nested Distribution Group Identified: $($Member.DisplayName)"
                            If ($Member.DistinguishedName -notin $Group) {
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
                            If ($Member.DistinguishedName -notin $Group){
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
                            If ($Member.DistinguishedName -notin $User) {
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
