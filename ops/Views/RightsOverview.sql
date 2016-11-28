CREATE VIEW [ops].[LoginDatabaseRoles]
	AS 
SELECT 
       [DatabaseName]
       , [DatabaseRole]
       , l.LoginIdentity
FROM [ops].[DatabaseRoleMember] drm
INNER JOIN [ops].[Login] l
       ON drm.LoginId = l.Id

