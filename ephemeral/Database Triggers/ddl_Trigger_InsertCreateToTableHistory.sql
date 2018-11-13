

CREATE TRIGGER ddl_Trigger_InsertCreateToTableHistory ON DATABASE
	WITH EXECUTE AS 'dbo'
FOR CREATE_TABLE AS

SET NOCOUNT ON;;

EXEC Controller.UpdateTableHistoryWhereManualDelete

DECLARE @ddltriggerxml XML;

SELECT @ddltriggerxml = EVENTDATA();

INSERT Controller.TableHistory (
	OriginalLogin
	,SchemaName
	,TableName
	,CreateTableTSQL
	)
SELECT ORIGINAL_LOGIN()
	,@ddltriggerxml.value('(/EVENT_INSTANCE/SchemaName)[1]', 'nvarchar(128)')
	,@ddltriggerxml.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(128)')
	,@ddltriggerxml.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(MAX)');