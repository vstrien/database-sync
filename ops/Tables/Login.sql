﻿CREATE TABLE [ops].[Login]
(
	[Id] INT NOT NULL IDENTITY(1,1),
	LoginIdentity VARCHAR(200) NOT NULL,
	CONSTRAINT PK_Login PRIMARY KEY (Id)
)