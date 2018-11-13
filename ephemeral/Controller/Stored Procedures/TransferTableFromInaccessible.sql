CREATE PROCEDURE Controller.TransferTableFromInaccessible @tableName SYSNAME, @sourceSchemaName SYSNAME, @targetSchemaName SYSNAME
AS
DECLARE @sql NVARCHAR(MAX)

SELECT @sql = 'ALTER SCHEMA ' + quotename(@targetSchemaName) + ' TRANSFER ' + quotename(@sourceSchemaName) + '.' + QUOTENAME(@TableName) + ';'
EXECUTE sp_executesql @sql

UPDATE Controller.TableHistory 
SET SchemaName = @targetSchemaName,
IsAccessable = 1,
LastWrite = GETDATE(),
LastRead = GETDATE()
WHERE SchemaName = @sourceSchemaName
AND TableName = @tableName
AND IsAccessable = 0
AND IsDeleted = 0
AND TransferDate IS NOT NULL
AND DeletionDate IS NULL