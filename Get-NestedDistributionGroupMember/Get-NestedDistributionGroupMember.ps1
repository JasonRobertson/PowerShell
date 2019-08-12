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
                Throw "ResultSize is limited to 9999, if you want to return all results that match the query, use unlimited for the value of this parameter."
            }
        })]
        [string]
        $ResultSize

    )
    Begin
    {
        Write-Verbose "ENTER - BEGIN BLOCK"
        Write-Verbose "Create required variables"
        [System.Collections.ArrayList]$User = @()
        [System.Collections.ArrayList]$Group = @()
        Write-Verbose "EXIT - BEGIN BLOCK"
    }
    Process
    {
        Write-Verbose "ENTER - PROCESS BLOCK"
        Foreach($Member in (Get-DistributionGroupMember -Identity $Identity -ResultSize $ResultSize)){
            If ($Member.RecipientTypeDetails -eq 'UserMailbox'){
                If (!($User -contains $Member.PrimarySMTPAddress)){
                    $User.Add($Member) | Out-Null
                }
                Else{
                    Write-Verbose "$Member is already added to the user list, skipping to mitigate duplicate entry"
                }
            }
            ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalDistributionGroup'){
                Write-Verbose "Nested Distribution Group Identified: $Member"
                If (!($Group -contains $Member.PrimarySMTPAddress)){
                    $Group.Add($Member) | Out-Null
                }
                Else{
                    Write-Verbose "$Member is already added to the group list, skipping to mitigate duplicate entry"
                }
            }
            ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalSecurityGroup'){ 
                Write-Verbose "Nested Mail-Enabled Security Group identified: $Member"
                If (!($Group -contains $Member.PrimarySMTPAddress)){
                    $Group.Add($Member) | Out-Null
                }
                Else{
                    Write-Verbose "$Member is already added to the group list, skipping to mitigate duplicate entry"
                }
            }
            Write-Verbose "Entry Do-While Loop"
            do
            {
                If($Group.Count -gt 0){
                    Write-Verbose "Start - Enumeration for members in $($Group[0])"
                    Foreach($Member in (Get-DistributionGroupMember -Identity $Group[0].Identity -ResultSize $ResultSize)){
                        If ($Member.RecipientTypeDetails -eq 'UserMailbox'){
                            If (!($User -contains $Member.PrimarySMTPAddress)){
                                $User.Add($Member) | Out-Null
                            }
                            Else{
                                Write-Verbose "$Member is already added to the user list, skipped to mitigate duplicate entry"
                            }
                        }
                        ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalDistributionGroup'){
                            Write-Verbose "Nested Distribution Group Identified: $Member"
                            If (!($Group -contains $Member.PrimarySMTPAddress)){
                                $Group.Add($Member) | Out-Null
                            }
                            Else{
                                Write-Verbose "$Member is already added to the group list, skipped to mitigate duplicate entry"
                            }
                        }
                        ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalSecurityGroup'){ 
                            Write-Verbose "Nested Mail-Enabled Security Group identified: $Member"
                            If (!($Group -contains $Member.PrimarySMTPAddress)){
                                $Group.Add($Member) | Out-Null
                            }
                            Else{
                                Write-Verbose "$Member is already added to the group list, skipped to mitigate duplicate entry"
                            }
                        }
                    }
                    Write-Verbose "Exit - Enumerate members from identified Groups"
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
            Write-Verbose "Exit Do-While Loop"
        }
        If ($ResultSize -ne 'Unlimited'){
            Write-Verbose "Enter - ResultSize - If statement"
            Write-Verbose "ResultSize value: $ResultSize."
            Write-Output $User[([int]$ResultSize)]
            Write-Verbose "Exit - ResultSize - If Statement"
        }
        Else{
            Write-Verbose "Enter - ResultSize - If statement, else variant"
            Write-Verbose "ResultSize value: $ResultSize."
            Write-Output $User
            Write-Verbose "Exit - ResultSize - If Statement, else variant"

        }
        Write-Verbose "EXIT - PROCESS BLOCK"

    }
    End
    {
        Write-Verbose "ENTER - END BLOCK"
        Write-Verbose "Remove created variables"
        Remove-Variable User
        Remove-Variable Group
        Write-Verbose "EXIT - END BLOCK"
    }
}
