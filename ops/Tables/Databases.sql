CREATE TABLE [ops].[Databases]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	DatabaseName SYSNAME NOT NULL,
	CONSTRAINT PK_Databases_ID PRIMARY KEY (Id)
)
