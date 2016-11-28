CREATE TABLE [ops].[DatabaseRoleMember]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	LoginId INT NOT NULL,
	[DatabaseName] SYSNAME NOT NULL,
	[DatabaseRole] NVARCHAR(200) NOT NULL,
	CONSTRAINT PK_DatabaseRoleMember PRIMARY KEY (Id),
	CONSTRAINT FK_DatabaseRoleMember_Login FOREIGN KEY (LoginId) REFERENCES ops.[Login] (Id)
)
