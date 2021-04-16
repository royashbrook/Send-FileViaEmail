# Send-FileViaEmail

Sends a file via email using passed in values. Currently normally jobs are using o365. Pass in file path and mail config. Mail config structure is generally read in from a json file and looks like:

```json
 "mail": {
    "from": "email from",
    "to": "email to",
    "bcc": "email bcc",
    "subject": "email subject",
    "smtp": "smtp.office365.com",
    "port": "587",
    "user": "office 365 id",
    "pass": "office 365 password"
}
```

Currently requires a bcc. I have included the smtp info for o365 use.

After having a config, can be called like:

`Send-FileViaEmail .\somefile.txt $mailconfig`
