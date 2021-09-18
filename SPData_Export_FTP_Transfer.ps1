param (
    [string]$DatabaseServer = "test.domain.com",
    [string]$ServerName = "test1.domain.com",
    [string]$FTPPath = "/Test",
    [string]$Vendor = "Vendor"
 )

Import-Module JAMS

function Report {
 
$sql_Report =@"
exec [SPName] $Vendor
"@
 
    Invoke-Sqlcmd -ServerInstance $DatabaseServer -Database "DBName" -Query $sql_Report
}



function OrdersCount {
 
    $sql_Report1 =@"
    exec [SPName1] $Vendor
"@
     
        Invoke-Sqlcmd -ServerInstance $DatabaseServer -Database "DBName" -Query $sql_Report1
}

   $totalOrdersCount =  OrdersCount

 
# Results from the query mak be saved to disk.
$localDataDirectory = "C:\temp\$(New-Guid)"
New-Item $localDataDirectory -itemType directory

# Creating the CSV Files path 

$csvfiledata = "$localDataDirectory\BMI_AFIWAREHOUSE_OND_BULK.csv"

# Creating the Txt Files path 
 
$txtfiledata = "$localDataDirectory\BMI_AFIWAREHOUSE_OND_BULK.txt"

# Export the data to CSV
  
AFIReport | Export-Csv -Path $csvfiledata -NoTypeInformation

# Export the Data to Txt

(get-content $csvfiledata) -replace '"', ''| Set-Content $txtfiledata


#rename and append date
dir $txtfiledata | Rename-Item -NewName {"FileName"+(Get-Date -f yyyyMMdd)+".txt"}
#############################################
$txtfiledata = "$localDataDirectory\FileName"+(Get-Date -f yyyyMMdd)+".txt"
$txtfiledata1 ="FileName"+(Get-Date -f yyyyMMdd)+".txt"

# Using the JAMS Scheduler tool 
# Getting the credentials stored in JAMS Server 
# we retreive the data from Temp location and post it to FTP Server

try
 {
 	$sftpUserCredentials = Get-JAMSCredential -UserName "SFTPUSer" -Server $ServerName
     Connect-JSFTP -Credential $sftpUserCredentials -Name "sftp.domain.net" -UseCompression:$true -Binary -QueueLength 8 -BufferSize 60 -AcceptKey
     Set-JFSLocation -Location $FTPPath
     Send-JFSItem -Name $txtfiledata  -Destination $txtfiledata1
     Disconnect-JFS	
     Remove-Item $localDataDirectory -Recurse -Force   
    
}

catch [Exception]
{
    Write-Host ("Error: {0}" -f $_.Exception.Message)
}