function Get-NestedDistributionGroupMember
{
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    [Alias()]
    [OutputType()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Identity
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
        Foreach($Member in (Get-DistributionGroupMember -Identity $Identity)){
            If ($Member.RecipientTypeDetails -eq 'UserMailbox'){
                If (!($User -contains $Member.PrimarySMTPAddress)){
                    $User.Add($Member.PrimarySMTPAddress) | Out-Null
                }
                Else{
                    Write-Verbose "$Member is already added to the user list, skipping to mitigate duplicate entry"
                }
            }
            ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalDistributionGroup'){
                Write-Verbose "Nested Distribution Group Identified: $Member"
                If (!($Group -contains $Member.PrimarySMTPAddress)){
                    $Group.Add($Member.PrimarySMTPAddress) | Out-Null
                }
                Else{
                    Write-Verbose "$Member is already added to the group list, skipping to mitigate duplicate entry"
                }
            }
            ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalSecurityGroup'){ 
                Write-Verbose "Nested Mail-Enabled Security Group identified: $Member"
                If (!($Group -contains $Member.PrimarySMTPAddress)){
                    $Group.Add($Member.PrimarySMTPAddress) | Out-Null
                }
                Else{
                    Write-Verbose "$Member is already added to the group list, skipping to mitigate an infinite loop"
                }
            }
            Write-Verbose "Entry Do-While Loop"
            do
            {
                If($Group.Count -gt 0){
                    Write-Verbose "Start - Enumeration for members in $Group"
                    Foreach($Member in (Get-DistributionGroupMember -Identity $Group[0])){
                        If ($Member.RecipientTypeDetails -eq 'UserMailbox'){
                            If (!($User -contains $Member.PrimarySMTPAddress)){
                                $User.Add($Member.PrimarySMTPAddress) | Out-Null
                            }
                            Else{
                                Write-Verbose "$Member is already added to the user list, skipped to mitigate duplicate entry"
                            }
                        }
                        ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalDistributionGroup'){
                            Write-Verbose "Nested Distribution Group Identified: $Member"
                            If (!($Group -contains $Member.PrimarySMTPAddress)){
                                $Group.Add($Member.PrimarySMTPAddress) | Out-Null
                            }
                            Else{
                                Write-Verbose "$Member is already added to the group list, skipped to mitigate infinite loop"
                            }
                        }
                        ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalSecurityGroup'){ 
                            Write-Verbose "Nested Mail-Enabled Security Group identified: $Member"
                            If (!($Group -contains $Member.PrimarySMTPAddress)){
                                $Group.Add($Member.PrimarySMTPAddress) | Out-Null
                            }
                            Else{
                                Write-Verbose "$Member is already added to the group list, skipped to mitigate infinite loop"
                            }
                        }
                    }
                    Write-Verbose "Exit - Enumerate members from identified Groups"
                    $Group.Remove($Group[0])
                }
            }
            While ($Group -gt 0)
            Write-Verbose "Exit Do-While Loop"
        }
        Write-Output $User
        Write-Verbose "EXIT - PROCESS BLOCK"

    }
    End
    {
        Write-Verbose "ENTER - END BLOCK"
        Write-Verbose "Remove required variables"
        Remove-Variable User
        Remove-Variable Group
        Write-Verbose "EXIT - END BLOCK"
    }
}


#Orignial Code before the function

<# 
Write-Verbose "Identify members of $Identity"
Foreach($Member in (Get-DistributionGroupMember -Identity $Identity)){
    If ($Member.RecipientTypeDetails -eq 'UserMailbox'){
        If (!($User -contains $Member.PrimarySMTPAddress)){
            $User.Add($Member.PrimarySMTPAddress) | Out-Null
        }
        Else{
            Write-Verbose "$Member is already added to the user list, skipping to mitigate duplicate entry"
        }
    }
    ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalDistributionGroup'){
        Write-Verbose "Nested Distribution Group Identified: $Member"
        If (!($Group -contains $Member.PrimarySMTPAddress)){
            $Group.Add($Member.PrimarySMTPAddress) | Out-Null
        }
        Else{
            Write-Verbose "$Member is already added to the group list, skipping to mitigate duplicate entry"
        }
    }
    ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalSecurityGroup'){ 
        Write-Verbose "Nested Mail-Enabled Security Group identified: $Member"
        If (!($Group -contains $Member.PrimarySMTPAddress)){
            $Group.Add($Member.PrimarySMTPAddress) | Out-Null
        }
        Else{
            Write-Verbose "$Member is already added to the group list, skipping to mitigate an infinite loop"
        }
    }
    Write-Verbose "Entry Do-While Loop"
    do
    {
        Foreach($Member in (Get-DistributionGroupMember -Identity $Group[0])){
            If ($Member.RecipientTypeDetails -eq 'UserMailbox'){
                If (!($User -contains $Member.PrimarySMTPAddress)){
                    $User.Add($Member.PrimarySMTPAddress) | Out-Null
                }
                Else{
                    Write-Verbose "$Member is already added to the user list, skipped to mitigate duplicate entry"
                }
            }
            ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalDistributionGroup'){
                Write-Verbose "Nested Distribution Group Identified: $Member"
                If (!($Group -contains $Member.PrimarySMTPAddress)){
                    $Group.Add($Member.PrimarySMTPAddress) | Out-Null
                }
                Else{
                    Write-Verbose "$Member is already added to the group list, skipped to mitigate infinite loop"
                }
            }
            ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalSecurityGroup'){ 
                Write-Verbose "Nested Mail-Enabled Security Group identified: $Member"
                If (!($Group -contains $Member.PrimarySMTPAddress)){
                    $Group.Add($Member.PrimarySMTPAddress) | Out-Null
                }
                Else{
                    Write-Verbose "$Member is already added to the group list, skipped to mitigate infinite loop"
                }
            }
        }
        $Group.Remove($Group[0])
    }
    while ($Group -gt 0)
    Write-Verbose "Exit Do-While Loop"
}
#>