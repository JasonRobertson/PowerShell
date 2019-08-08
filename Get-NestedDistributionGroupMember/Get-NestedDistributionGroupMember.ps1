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
                    Write-Verbose "$Member is already added to the group list, skipping to mitigate an infinite loop"
                }
            }
            Write-Verbose "Entry Do-While Loop"
            do
            {
                If($Group.Count -gt 0){
                    Write-Verbose "Start - Enumeration for members in $($Group[0])"
                    Foreach($Member in (Get-DistributionGroupMember -Identity $Group[0].Identity)){
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
                                Write-Verbose "$Member is already added to the group list, skipped to mitigate infinite loop"
                            }
                        }
                        ElseIf ($Member.RecipientTypeDetails -eq 'MailUniversalSecurityGroup'){ 
                            Write-Verbose "Nested Mail-Enabled Security Group identified: $Member"
                            If (!($Group -contains $Member.PrimarySMTPAddress)){
                                $Group.Add($Member) | Out-Null
                            }
                            Else{
                                Write-Verbose "$Member is already added to the group list, skipped to mitigate infinite loop"
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