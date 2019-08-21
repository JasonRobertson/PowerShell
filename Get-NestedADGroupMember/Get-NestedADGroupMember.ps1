function Get-NestedADGroupMember
{
<#
    .Synopsis
    Get-NestedADGroupMember cmdlet is used to pull all members of a parent distribution group that includes nested distirbution groups.
    .DESCRIPTION
    Get-NestedADGroupMember cmdlet is used to pull all members of a parent distribution group that includes nested distirbution groups.
    .EXAMPLE
    PS C:\>  Get-NestedADGroupMember Administrators

    distinguishedName : CN=User1,OU=Contractors,OU=contoso,DC=corp,DC=contoso,DC=com
    name              : User1
    objectClass       : user
    objectGUID        : dfadhfq1-8744-3r98-qio1-904rtf7u8dfa
    SamAccountName    : User1
    SID               : S-1-5-21-4564564564-4564654564-783434173-41332

    distinguishedName : CN=drtsslvpn.svc,OU=Service Accounts,DC=contoso,DC=com
    name              : ServiceAccount1
    objectClass       : user
    objectGUID        : 4fab9dd5-f3ac-4910-a9be-8fdisvcajsjh
    SamAccountName    : ServiceAccount1
    SID               : S-1-5-21-4564564564-4564654564-121548578-484156

    This example show the cmdlet being used with no additonal parameters, but Identity
    .EXAMPLE
    PS C:\>  Get-NestedADGroupMember -Identity Administrators -ListGroups

    distinguishedName : CN=Enterprise Admins,CN=Users,DC=contoso,DC=com
    name              : Enterprise Admins
    objectClass       : group
    objectGUID        : fh348fda-fafd-2474-0kol-ti4568ug3y31
    SamAccountName    : Enterprise Admins
    SID               : S-1-5-21-4564564564-4564654564-879798451-849

    distinguishedName : CN=Domain Admins,OU=Admin Groups,OU=Admin Accounts,DC=corp,DC=contoso,DC=com
    name              : Domain Admins
    objectClass       : group
    objectGUID        : df4a56d4-347f-3876-a9be-8fdisvcajsjh
    SamAccountName    : Domain Admins
    SID               : S-1-5-21-4564564564-4564654564-879798451-849

    This example shows the use of the ListGroups switch to provide the list of the Nested AD groups instead of the users.
    .EXAMPLE
    PS C:\> Get-ADGroup Administrators | Get-NestedADGroupMember

    distinguishedName : CN=User1,OU=Contractors,OU=contoso,DC=corp,DC=contoso,DC=com
    name              : User1
    objectClass       : user
    objectGUID        : dfadhfq1-8744-3r98-qio1-904rtf7u8dfa
    SamAccountName    : User1
    SID               : S-1-5-21-4564564564-4564654564-783434173-41332

    distinguishedName : CN=drtsslvpn.svc,OU=Service Accounts,DC=contoso,DC=com
    name              : ServiceAccount1
    objectClass       : user
    objectGUID        : 4fab9dd5-f3ac-4910-a9be-8fdisvcajsjh
    SamAccountName    : ServiceAccount1
    SID               : S-1-5-21-4564564564-4564654564-121548578-484156

    This example show using the Get-DsitributionGroup cmdlet to verify the distirbution group exists and piping the results to Get-NestedDistributionGroup
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
        # The ListGroups parameter is a switch that can be used to display all of the Nested AD groups in a distribuition group. The Default Value is $false.
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
        Write-Verbose "Collect AD Domains"
        $DomainList = (Get-ADForest).domains | Get-ADDomain | Select-Object DistinguishedName, DNSRoot | Sort-Object
        Write-Verbose "EXIT - BEGIN BLOCK"
    }
    Process
    {
        Write-Verbose "ENTER - PROCESS BLOCK"
        Write-Verbose "ENTER - Foreach - $Identity"
        Foreach ($Member in (Get-ADGroupMember -Identity $Identity)){
            switch ($Member.ObjectClass) {
                Group {
                    Write-Verbose "Nested AD Group Identified: $($Member.Name)"
                    If ($Member.DistinguishedName -notin $Group.DistinguishedName) {
                        $Group.Add($Member) | Out-Null
                        IF ($ListGroups) {
                            $GroupList.Add($Member) | Out-Null
                        }
                    }
                    Else {
                        Write-Verbose "$($Member.Name) is already identified, skipping to mitigate duplicate entry"
                    }
                }
                default{
                    If ($Member.DistinguishedName -notin $User.DistinguishedName) {
                        $User.Add($Member) | Out-Null
                    }
                    Else {
                        Write-Verbose "$($Member.Name) is already identified, skipping to mitigate duplicate entry"
                    }
                }
            }
        }
        Write-Verbose "EXIT - Foreach - $Identity"
        If ($Group -gt 0){
            Write-Verbose "ENTER - Do-While"
            do {
                Write-Verbose "ENTER - Foreach - AD Domain"
                foreach ($Domain in $DomainList){
                    If ($Group[0].DistinguishedName.EndsWith($Domain.DistinguishedName)) {
                        $GetADGroup = @{
                            Identity = $Group[0].DistinguishedName
                            Server   = $Domain.DNSRoot
                        }
                    }
                }
                Write-Verbose "EXIT - Foreach - AD Domain"
                Write-Verbose "ENTER - Foreach - $($Group[0].Name) Group"
                Foreach ($Member in (Get-ADGroupMember @GetADGroup)){
                    switch ($Member.ObjectClass) {
                        Group {
                            Write-Verbose "Nested AD Group Identified: $($Member.Name)"
                            If ($Member.DistinguishedName -notin $Group.DistinguishedName) {
                                $Group.Add($Member) | Out-Null
                                IF ($ListGroups) {
                                    $GroupList.Add($Member) | Out-Null
                                }
                            }
                            Else {
                                Write-Verbose "$($Member.Name) is already identified, skipping to mitigate duplicate entry"
                            }
                        }
                        default{
                            If ($Member.DistinguishedName -notin $User.DistinguishedName) {
                                $User.Add($Member) | Out-Null
                            }
                            Else {
                                Write-Verbose "$($Member.Name) is already identified, skipping to mitigate duplicate entry"
                            }
                        }
                    }
                }
                Write-Verbose "EXIT - Foreach - $($Group[0].Name)"
                Try{
                    Write-Verbose "Remove $($Group[0].Identity) from Group list"
                    $Group.Remove($Group[0])
                }
                Catch{
                    Write-Verbose $_.exception.message
                    Write-Warning $_.exception.message
                }
                Write-verbose "Group Count: $group.Count"
            }
            While ($Group.Count -gt 0)
            Write-Verbose "EXIT - Do-While"
        }
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
