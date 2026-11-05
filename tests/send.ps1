$ErrorActionPreference = 'Stop'
# the module runs for real, only its two graph calls are replaced
Import-Module "$PSScriptRoot/../Send-FileViaEmail/Send-FileViaEmail.psd1" -Force
& (Get-Module Send-FileViaEmail) {
    $script:messages = [Collections.Generic.List[object]]::new()
    function script:Invoke-RestMethod {
        param($URI, $Method, $Body, $Headers, $ContentType)
        if ($URI -like 'https://login.microsoftonline.com/*') { return @{ access_token = 'token' } }
        $script:messages.Add(($Body | ConvertFrom-Json -AsHashtable).message)
    }
}
function Assert($Condition, $Name) { if (!$Condition) { throw "FAIL: $Name" }; "ok: $Name" }

$dir = [IO.Directory]::CreateTempSubdirectory('sfve-').FullName
Push-Location $dir
try {
    '<p>report</p>' | Set-Content report.html -NoNewline
    $cfg = @{ msgraph = @{ tenant_id = 't'; client_id = 'c'; client_secret = 's' }; mail = @{ from = 'f@example.invalid'; to = @('t@example.invalid'); subject = 'subject' } }

    Send-FileViaEmail report.html $cfg
    Send-FileViaEmail report.html $cfg -bodyType Html
    $sent = @(& (Get-Module Send-FileViaEmail) { $script:messages.ToArray() })

    Assert ($sent[0].attachments[0].name -eq 'report.html' -and !$sent[0].body) 'default attaches the file, no body'
    Assert ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($sent[0].attachments[0].contentBytes)) -eq '<p>report</p>') 'attachment bytes'
    Assert ($sent[1].body.contentType -eq 'Html' -and $sent[1].body.content -eq '<p>report</p>') 'bodyType sends the text as the body'
    Assert (!$sent[1].attachments) 'bodyType attaches nothing'
}
finally { Pop-Location; Remove-Item $dir -Recurse -Force }
