# MySQL Database Backup Script for Windows and Linux
$databasename = 'ReplaceWithYourDatabaseName'
$today = Get-Date -UFormat "%Y-%m-%d%T" |ForEach-Object { $_ -replace ":", "_" }
if ($IsLinux -eq $true) {
    $backuppath = '/Path/To/Folder/Where/You/Want/Dump/Your/files/'
} else {
    $backuppath = 'C:\Path\To\Folder\Where\You\Want\Dump\Your\files\'
}
$backupfilename = 'fulldb_'+ $databasename + '-' + $today + '.sql'
$backupfilenamefullpath = $backuppath + $backupfilename
$compressfilename = $backuppath + 'fulldb_'+  $databasename + '-' + $today + '.zip'
$errorlog = $backuppath + 'error.log'
$networkdrivebckfolder1='E:\Path\To\Folder\Where\You\Want\Dump\Your\files'
$networkdrivebckfolder1chck='True'
$networkdrivebckfolder2='\\[IP ADDRESS]\Path\To\Folder\Where\You\Want\Dump\Your\files'
$networkdrivebckfolder2chck='True'
C:\xampp\mysql\bin\mysqldump -u backupuser -pbackupuser -hlocalhost --log-error=$errorlog --result-file=$backupfilenamefullpath --databases $databasename
$errorfile = Get-ChildItem  -Path $errorlog
if ($errorfile[0].Length -eq 0) { 
    $EmailText = 'DB Dump Operation Successful'
	if(Copy-Item -Path $backupfilenamefullpath -Destination $networkdrivebckfolder1) {
    $networkdrivebckfolder1chck='False'
	}
	if(Copy-Item -Path $backupfilenamefullpath -Destination $networkdrivebckfolder2) {
    $networkdrivebckfolder2chck='False'
	} 
} else {
    $EmailText = Get-Content -Path $errorlog
}
*
if ($EmailText -eq 'DB Dump Operation Successful') {
$EmailText = 'DB Dump Successful. Copy saved to Local E:\Drive => ' 
+ $networkdrivebckfolder2chck + '. Copy saved to Network Folder [IP ADDRESS] '  
+ $networkdrivebckfolder2chck 
}
Set-Location -Path $backuppath
$fileselect = 'fulldb_'+$databasename + '*.sql'
$filelist = Get-ChildItem $fileselect | sort-object -Property name -Descending
$location = 0
foreach ($file in $filelist) {
    $location++
    if ($location -gt 7) {
        Remove-Item -Path $File.name
    }
}
$SMTPServer     = "mail.server.com.pg"
$EmailFrom      = "From@yourdomain.com.pg" 
$EmailTo        = "To@yourdomain.com.pg"
$EmailSubject   = "DB Backup File " + $backupfilename
$EMailSSL       = $false        # Use ssl for email, set email port
$EMailPort      = 25            # Standard port is 25, SSL port typically 587
$EMailAuth      = $false        # Email Server Requires login
$emaillogin     = "Sender@yourdomain.com.pg"
$emailpassword  = "Password"
$Message = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
$Message.Subject = $EmailSubject
$Message.IsBodyHTML = $false
$message.Body = $EmailText 
$SMTP = New-Object Net.Mail.SmtpClient($SMTPServer, $EMailPort)
if ($EMailSSL -eq $true) {
    $SMTP.EnableSSL = $true
}
if ($EMailAuth -eq $true) {
    $SMTP.Credentials = New-Object System.Net.NetworkCredential ($emaillogin, $emailpassword)
}
$SMTP.Send($Message)

 