CREATE TABLE [ops].[Servers]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	ServerName SYSNAME,
	FriendlyName VARCHAR(255),
	Cores INT,
	MemoryBytes BIGINT,
	ActiveFrom DATETIME2,
	ActiveTo DATETIME2,
	CONSTRAINT PK_Servers_Id PRIMARY KEY (Id)
)
