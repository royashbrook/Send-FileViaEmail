function Send-FileViaEmail{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        $f,
        [Parameter(Mandatory=$true)]
        $m,
        [Parameter(Mandatory=$false)]
        [Switch]
        $useGraph
    )

    if ($useGraph.IsPresent) {
        # we are merging in an existing graph function. that function uses the full config
        # because there is a section for graph config as well as a section for the mail details.
        # the existing function uses cfg first then the file, and we also need to set $m to
        # the mail property on the larger config object so the join will work later
        graph $m $f
        $m = $m.mail
    }
    else {
        nograph $f $m
    }

    "Sent {0} to {1}" -f $f, ($m.to -join " & ")

}
function nograph ($f, $m) {
    $sp = ConvertTo-SecureString $m.pass -AsPlainText -Force
    $c = New-Object pscredential ($m.user, $sp)
    $a = @{
        Port        = $m.port
        Credential  = $c
        UseSsl      = $true
        SmtpServer  = $m.smtp
        From        = $m.from
        To          = $m.to
        Subject     = $m.subject
        Attachments = $f
    }

    Send-MailMessage @a
}
function graph ($cfg, $file) {
    
    $file = (resolve-path $file).path

    $tokenParams = @{
        "URI"    = "https://login.microsoftonline.com/{0}/oauth2/v2.0/token" -f $cfg.msgraph.tenant_id
        "Method" = "POST"
        "Body"   = @{
            client_id     = $cfg.msgraph.client_id
            scope         = "https://graph.microsoft.com/.default"
            client_secret = $cfg.msgraph.client_secret
            grant_type    = "client_credentials"
        }
    }
    $tokenresponse = Invoke-RestMethod @tokenParams

    $emailParams = @{
        "URI"         = "https://graph.microsoft.com/v1.0/users/{0}/sendMail" -f $cfg.mail.from
        "Headers"     = @{
            'Content-Type'  = "application\json"
            'Authorization' = "Bearer {0}" -f $tokenresponse.access_token 
        }
        "Method"      = "POST"
        "ContentType" = 'application/json'
        "Body"        = (@{
                "message" = @{
                    "subject"      = $cfg.mail.subject
                    "attachments"  = @(
                        @{
                            "@odata.type"  = "#microsoft.graph.fileAttachment"
                            "name"         = $file
                            "contentType"  = [System.Web.MimeMapping]::GetMimeMapping($file)
                            "contentBytes" = [convert]::ToBase64String( [system.io.file]::readallbytes($file))
                        })  
                    "toRecipients" = @(
                        $cfg.mail.to | ForEach-Object {
                            @{
                                "emailAddress" = @{"address" = $_ }
                            }
                        }
                    ) 
                }
            }) | ConvertTo-JSON -Depth 6
    }

    Invoke-RestMethod @emailParams
}
Export-ModuleMember -Function Send-FileViaEmail