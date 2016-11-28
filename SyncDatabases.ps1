Import-Module Sqlps -DisableNameChecking;

$databasesToSync = @("NameOfStagingDatabase", "NameOfDWHDatabase", "NameOfDMDatabase", "FeelFreeToAddAsMuchAsYouNeedHere")
$backupInst = "ProdServer\InstanceName"
$restoreInst = "AccServer\InstanceName"

$filesystem_prefix = "Microsoft.PowerShell.Core\FileSystem::"
$bdrive_local = "E:"
$bdrive_remote = "\\" + $backupInst + "\e$"
$bdir = "Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup"
$rdrive_local = "E:"
$rdir = $bdir
$rdrive_remote = "\\" + $restoreInst + "\e$"

$backupSvr = New-Object 'Microsoft.SqlServer.Management.SMO.Server' $backupInst

foreach($databaseToSync in $databasesToSync) {

$db = $backupSvr.Databases[$databaseToSync]

$dbname = $db.Name
$dt = get-date -format yyyyMMddHHmmss
$backupItem_remote = $bdrive_remote + "\" + $bdir + "\" + $dbname + "_db_" + $dt + ".bak"
$backupItem_local = $rdrive_local + "\" + $bdir + "\"  + $dbname + "_db_" + $dt + ".bak"
$restoreItem_remote = $rdrive_remote + "\" + $rdir + "\" + $dbname + "_db_" + $dt + ".bak"
$restoreItem_local = $rdrive_local + "\" + $rdir + "\"  + $dbname + "_db_" + $dt + ".bak"

$dbbk = new-object ('Microsoft.SqlServer.Management.Smo.Backup')
$dbbk.Action = 'Database'
$dbbk.BackupSetDescription = "Full backup of " + $dbname
$dbbk.BackupSetName = $dbname + " Backup"
$dbbk.Database = $dbname
$dbbk.MediaDescription = "Disk"
$dbbk.CompressionOption = 1
$dbbk.CopyOnly = $TRUE
$dbbk.Devices.AddDevice($backupItem_local, 'File')
Write-Host "Backup of" $databaseToSync "started @ " $backupInst
$dbbk.SqlBackup($backupSvr)
Write-Host "Backup finished "

Write-Host "Moving backup" $databaseToSync "across network"
Move-Item ($filesystem_prefix + $backupItem_remote) ($filesystem_prefix + $restoreItem_remote) -force
Write-Host "Move finished"

$restoreSvr = New-Object 'Microsoft.SqlServer.Management.SMO.Server' $restoreInst
$dbrs = new-object Microsoft.SqlServer.Management.Smo.Restore
$dbrs.Devices.AddDevice($restoreItem_local , [Microsoft.SqlServer.Management.Smo.DeviceType]::File)
$dbrs.Database = $dbname
$dbrs.ReplaceDatabase = $TRUE
$dbrs.NoRecovery = $FALSE

Write-Host "Setting" $databaseToSync "in single-user mode"
$restore_db = $restoreSvr.Databases[$databaseToSync]
if($restore_db.UserAccess -ne [Microsoft.SqlServer.Management.Smo.DatabaseUserAccess]::Single) 
{ 
  $restore_db.UserAccess = [Microsoft.SqlServer.Management.Smo.DatabaseUserAccess]::Single; 
  $restore_db.Alter([Microsoft.SqlServer.Management.Smo.TerminationClause]::RollbackTransactionsImmediately);
  $restore_db.Refresh();
}

Write-Host "Restoring " $databaseToSync "..."
$dbrs.SqlRestore($restoreSvr)
Write-Host "Restore finished."

Write-Host "Setting" $databaseToSync "in multi-user mode..."
$restore_db = $restoreSvr.Databases[$databaseToSync]
$restore_db.UserAccess = [Microsoft.SqlServer.Management.Smo.DatabaseUserAccess]::Multiple;
$restore_db.Alter([Microsoft.SqlServer.Management.Smo.TerminationClause]::RollbackTransactionsImmediately);
$restore_db.Refresh();

}

Write-Host "All done."

Write-Host "Press any key to exit."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
