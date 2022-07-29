# Send-FileViaEmail

Sends a file via email using MS Graph. This requires setup beforehand.

[graph api documentation](https://docs.microsoft.com/en-us/graph/api/user-sendmail)


# to use

`Send-FileViaEmail somefile.txt $config`
    
$config can be read in from a json file that looks like:

```json
    "mail": {
        "from": "email from",
        "to": ["email to"],
        "subject": "email subject"
    },
    "msgraph": {
        "tenant_id": "your tenantid",
        "client_id": "your clientid, from azure app",
        "client_secret": "your client secret, from azure app"
    }
```

Optional third argument that allows you to use a different content type. By default `$contentType = "application/octet-stream"`

[supported mimetypes](https://github.com/Microsoft/referencesource/blob/master/System.Web/MimeMapping.cs)
