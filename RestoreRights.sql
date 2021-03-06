USE MyJustRestoredDatabaseName -- Currently you need to execute this block once for every database you transfer.
GO

-- Drop user rights transferred along from other environment
DECLARE @DropStatement NVARCHAR(MAX) = '';

SELECT @DropStatement += 'DROP USER [' + [name] + ']; ' 
FROM MyJustRestoredDatabaseName.sys.sysusers
WHERE issqlrole = 0 AND sid IS NOT NULL
AND name NOT IN ('dbo', 'guest');

exec sp_executesql @DropStatement;

GO

-- Restore users according to metadata database
DECLARE @CreateUsersStatement NVARCHAR(MAX) = '';

SELECT @CreateUsersStatement += 'CREATE USER [' + LoginIdentity + '] FOR LOGIN [' + LoginIdentity + ']; '
FROM MetadataDatabase.[ops].[LoginDatabaseRoles]
WHERE DatabaseName = 'MyJustRestoredDatabaseName'
GROUP BY LoginIdentity

exec sp_executesql @CreateUsersStatement;

-- Restore roles according to metadata database
DECLARE @AlterRoleStatement NVARCHAR(MAX) = '';

SELECT @AlterRoleStatement += 'ALTER ROLE [' + DatabaseRole + '] ADD MEMBER [' + LoginIdentity + ']; '
FROM MetadataDatabase.[ops].[LoginDatabaseRoles]
WHERE DatabaseName = 'MyJustRestoredDatabaseName'
GROUP BY LoginIdentity, DatabaseRole

exec sp_executesql @AlterRoleStatement;