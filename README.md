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

Optional `-bodyType Html` (or `Text`) sends the file's text as the message body instead of attaching it, for a report that is the email itself. Added in 2.1.0.0.

`Send-FileViaEmail report.html $config -bodyType Html`

# test

`pwsh ./tests/send.ps1` runs both modes against a stand-in for the graph calls, no network.
