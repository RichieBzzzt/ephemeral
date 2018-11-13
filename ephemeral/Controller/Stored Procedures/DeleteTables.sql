CREATE PROCEDURE Controller.DeleteTables @TimeFrame INT

AS

DECLARE @sql NVARCHAR(MAX), @Id INT, @SchemName SYSNAME, @TableName SYSNAME;

SET NOCOUNT ON

DECLARE delete_cursor CURSOR FOR 

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
	AND IsAccessable = 0
	AND MaxDate < DATEADD(DAY, -@TimeFrame, CAST(current_timestamp AS DATE))

OPEN delete_cursor 
FETCH NEXT FROM delete_cursor INTO @Id, @SchemName, @TableName

WHILE @@FETCH_STATUS = 0  
BEGIN  
      SET @sql = (select ' DROP TABLE ' + quotename(@SchemName) + '.' + QUOTENAME(@TableName) + ';')
      EXECUTE sp_executesql @sql
		UPDATE Controller.TableHistory 
		SET DeletionDate = GETDATE (), IsDeleted = 1
		WHERE Id = @Id
      FETCH NEXT FROM delete_cursor INTO @Id, @SchemName, @TableName
END 

CLOSE delete_cursor
DEALLOCATE delete_cursor 

SET NOCOUNT OFF