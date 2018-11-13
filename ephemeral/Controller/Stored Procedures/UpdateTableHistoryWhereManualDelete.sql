CREATE PROCEDURE Controller.UpdateTableHistoryWhereManualDelete
AS
WITH cte
AS (
	SELECT SCHEMA_NAME(schema_id) AS schema_name
		,name AS table_name
	FROM sys.tables ST
	WHERE name != 'TableHistory'
		AND SCHEMA_NAME(schema_id) != 'Controller'
	)
UPDATE Controller.TableHistory
SET DeletionDate = GETDATE()
	,IsDeleted = 1
	,IsAccessable = 0
WHERE NOT EXISTS (
		SELECT schema_name
			,table_name
		FROM cte
		WHERE schema_name = Controller.TableHistory.SchemaName
			AND table_name = Controller.TableHistory.TableName
			AND Controller.TableHistory.IsDeleted = 0
		)