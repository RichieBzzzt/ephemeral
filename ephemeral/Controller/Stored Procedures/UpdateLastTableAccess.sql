
CREATE PROCEDURE Controller.UpdateLastTableAccess

AS

SET ANSI_WARNINGS ON
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#temp', 'U') IS NOT NULL
DROP TABLE #temp

;WITH agg AS
(
    SELECT 
        [object_id],
        last_user_seek,
        last_user_scan,
        last_user_lookup,
        last_user_update
    FROM
        sys.dm_db_index_usage_stats
    WHERE
        database_id = DB_ID()
)
SELECT
    [NameOfSchema] = OBJECT_SCHEMA_NAME([object_id]),
    [NameOfTable] = OBJECT_NAME([object_id]),
    last_read = MAX(last_read),
    last_write = MAX(last_write)

	INTO #temp
FROM
(
    SELECT [object_id], last_user_seek, NULL FROM agg
    UNION ALL
    SELECT [object_id], last_user_scan, NULL FROM agg
    UNION ALL
    SELECT [object_id], last_user_lookup, NULL FROM agg
    UNION ALL
    SELECT [object_id], NULL, last_user_update FROM agg
) AS x ([object_id], last_read, last_write)
GROUP BY
    OBJECT_SCHEMA_NAME([object_id]),
    OBJECT_NAME([object_id])
ORDER BY 1,2
UPDATE Controller.TableHistory 
SET 
LastRead = #temp.last_read,
LastWrite = #temp.last_write
FROM #temp
WHERE Controller.TableHistory.SchemaName = #temp.NameOfSchema
AND Controller.TableHistory.TableName = #temp.NameOfTable
AND IsAccessable = 1 
AND IsDeleted = 0

DROP TABLE #temp

SET  NOCOUNT OFF