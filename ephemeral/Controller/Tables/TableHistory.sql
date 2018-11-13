CREATE TABLE [Controller].[TableHistory] (
    [Id]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [CreationDate]    DATETIME       DEFAULT (getdate()) NULL,
    [OriginalLogin]   [sysname]      NOT NULL,
    [SchemaName]      [sysname]      NOT NULL,
    [TableName]       [sysname]      NOT NULL,
    [LastRead]        DATETIME       NULL,
    [LastWrite]       DATETIME       NULL,
    [CreateTableTSQL] NVARCHAR (MAX) NULL,
    [IsAccessable]    BIT            DEFAULT ((1)) NULL,
    [IsDeleted]       BIT            DEFAULT ((0)) NULL,
    [TransferDate]    DATETIME       NULL,
    [DeletionDate]    DATETIME       NULL,
    CONSTRAINT [PK_TableHistory_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

