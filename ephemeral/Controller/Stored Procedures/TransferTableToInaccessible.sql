
CREATE PROCEDURE Controller.TransferTableToInaccessible @TimeFrame INT

AS

DECLARE @sql NVARCHAR(MAX), @Id INT, @SchemName SYSNAME, @TableName SYSNAME;

SET NOCOUNT ON

DECLARE transfer_cursor CURSOR FOR 


SELECT Id
	,SchemaName
	,TableName
FROM Controller.TableHistory
CROSS APPLY (
	SELECT MAX(LastUpdateDate)
	FROM (
		VALUES (lastWrite)
			,(CreationDate)
			,(lastRead)
		) AS MAX(LastUpdateDate)
	) AS LastUpdateDate(MaxDate)
WHERE IsDeleted = 0
	AND IsAccessable = 1
	AND MaxDate < DATEADD(DAY, -@TimeFrame, CAST(current_timestamp AS DATE))



OPEN transfer_cursor 
FETCH NEXT FROM transfer_cursor INTO @Id, @SchemName, @TableName

WHILE @@FETCH_STATUS = 0  
BEGIN  
      SET @sql = (select ' ALTER SCHEMA [Inaccessible] TRANSFER ' + quotename(@SchemName) + '.' + QUOTENAME(@TableName) + ';')
      EXECUTE sp_executesql @sql
		UPDATE Controller.TableHistory 
		SET TransferDate = GETDATE (), IsAccessable = 0, SchemaName = 'Inaccessible'
		WHERE Id = @Id
      FETCH NEXT FROM transfer_cursor INTO @Id, @SchemName, @TableName
END 

CLOSE transfer_cursor
DEALLOCATE transfer_cursor 

SET NOCOUNT OFF