#sends a file vial email using config $m
function Send-FileViaEmail ($f,$m) {

    if (Test-Path $f){

        $sp = ConvertTo-SecureString $m.pass -AsPlainText -Force
        $c = New-Object pscredential ($m.user, $sp)
        $a = @{
            Port        = $m.port
            Credential  = $c
            UseSsl      = $true
            SmtpServer  = $m.smtp
            From        = $m.from
            To          = $m.to
            Bcc         = $m.bcc
            Subject     = $m.subject
            Attachments = $f
          }

        Send-MailMessage @a

        "Sent {0} to {1}" -f $f,($m.to -join " & ")

    }else{

        "Nothing to send"
        
    }    
}
Export-ModuleMember -Function * -Alias *