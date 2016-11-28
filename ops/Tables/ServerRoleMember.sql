CREATE TABLE [ops].[ServerRoleMember]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	LoginId INT NOT NULL,
	ServerRole SYSNAME NOT NULL,
	CONSTRAINT PK_ServerRoleMember PRIMARY KEY (Id),
	CONSTRAINT FK_ServerRoleMember_Login FOREIGN KEY (LoginId) REFERENCES ops.[Login](Id)
)
