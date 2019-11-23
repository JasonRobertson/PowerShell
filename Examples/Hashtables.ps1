#region Build the Web Request v1
$webRequest = @{
  Uri             = -join ('https://',$domain,'.okta.com/api/v1/users')
  Body            = $parameters
  Method          = 'GET'
  Headers         = $headers
  UseBasicParsing = $true
}
#endregion
#region Build the Web Request v2
$webRequest = New-object -TypeName System.Collections.Hashtable
$webRequest.Add('Uri',-join ('https://',$domain,'.okta.com/api/v1/users'))
$webRequest.Add('Body', $parameters)
$webRequest.Add('Method','GET')
$webRequest.Add('Headers', $headers)
$webRequest.Add('UseBasicParsing', $true)
#endregion
#region Build the Web Request v3
$webRequest                     = New-object -TypeName System.Collections.Hashtable
$webRequest['URI']              = -join ('https://',$domain,'.okta.com/api/v1/users')
$webRequest['Body']             = $parameters
$webRequest['Method']           = 'GET'
$webRequest['Headers']          = $headers
$webRequest['UseBasicParsing']  = $true
#endregion
#region Build the Web Request v4
$webRequest                   = New-object -TypeName System.Collections.Hashtable
$webRequest.Uri               = -join ('https://',$domain,'.okta.com/api/v1/users')
$webRequest.Body              = $parameters
$webRequest.Method            = 'GET'
$webRequest.Headers           = $headers
$webRequest.UseBasicParsing   = $true
#endregion
