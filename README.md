# Send-FileViaEmail

Sends a file via email using passed in values. Currently using o365. Pass in file path and mail config. Mail config structure is generally read in from a json file, although it can be constructed and passed in.

Example json string:

```json
 "mail": {
    "from": "email from",
    "to": ["email to"],
    "subject": "email subject",
    "smtp": "smtp.office365.com",
    "port": "587",
    "user": "office 365 id",
    "pass": "office 365 password"
}
```

I have included the smtp info for o365 use.

After having a config, can be called like:

`Send-FileViaEmail .\somefile.txt $mailconfig`

In typical use this is used by a scheduled job like so:

```ps1
#import the module
Import-Module Send-FileViaEmail
#get config from settings.json which usually has json like {mail:{}}
$cfg = Get-Content settings.json -Raw | ConvertFrom-Json
#set file name based on format in config, generally fed a date
$file = $cfg.file_format -f (get-date)
#some data is retrieved, formatted, and output to a file
Get-Data | Format-Data | Set-Content $file
#file is emailed
Send-FileViaEmail $file $cfg.mail
```

## MS Graph Email Support

As of 1.1, can utilize MS Graph for email. This requires some setup beforehand. See graph api documentation here:

https://docs.microsoft.com/en-us/graph/api/user-sendmail

Config requirements are different and json should look like:

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

Can be called like:

`Send-FileViaEmail .\somefile.txt $config -useGraph`
