function Send-FileViaEmail ($file, $cfg, $contentType = "application/octet-stream") {

    $contentBytes = [convert]::ToBase64String( [system.io.file]::readallbytes((resolve-path $file).path) )

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
                            "contentType"  = $contentType
                            "contentBytes" = $contentBytes
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