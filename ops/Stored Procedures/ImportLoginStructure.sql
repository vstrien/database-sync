CREATE PROCEDURE [ops].[ImportLoginStructure]
AS

DELETE FROM ops.ServerRoleMember;
DELETE FROM ops.DatabaseRoleMember;
DELETE FROM ops.Login;




-- Add logins as they're currently configured
INSERT INTO ops.Login (LoginIdentity)
SELECT DISTINCT name AS Login_Name
FROM master.sys.server_principals 
WHERE [type] IN ('U', 'S', 'G')
and name not like '%##%';




-- Add database role members
CREATE TABLE #tempww (
	DBName nvarchar(max),
    LoginName nvarchar(max),
    DatabaseRoleName nvarchar(max)
);

exec master.sys.sp_MSforeachdb 'use [?]
INSERT INTO #tempww
	(DBName, DatabaseRoleName, LoginName)
SELECT      ''?'' AS DBName,
			dp1.name AS DatabaseRoleName,
            DP2.name AS DatabaseUserName
FROM        sys.database_principals AS dp1
INNER JOIN  sys.database_role_members AS drm
      ON    drm.role_principal_id = dp1.principal_id
INNER JOIN  sys.database_principals AS dp2
      ON    dp2.principal_id = drm.member_principal_id
WHERE       dp1.type = ''R'';';

INSERT INTO ops.DatabaseRoleMember (LoginId, DatabaseName, DatabaseRole)
SELECT DISTINCT l.Id, t.DBName, t.DatabaseRoleName
FROM #tempww t
INNER JOIN ops.[Login] l
	ON t.LoginName COLLATE SQL_Latin1_General_CP1_CI_AS = l.LoginIdentity
WHERE t.DBName NOT IN ('master', 'model', 'msdb', 'tempdb', 'ReportServer', 'ReportServerTempDb');

DROP TABLE #tempww;




-- Add server role members
INSERT INTO ops.ServerRoleMember (LoginId, ServerRole)
SELECT DISTINCT l.Id,
    role.name
FROM master.sys.server_role_members
INNER JOIN master.sys.server_principals AS role
    ON server_role_members.role_principal_id = role.principal_id
INNER JOIN master.sys.server_principals AS member
    ON server_role_members.member_principal_id = member.principal_id
INNER JOIN ops.Login l
	ON member.name COLLATE SQL_Latin1_General_CP1_CI_AS = l.LoginIdentity;


RETURN 0
