# ephemeral

A database that stores tables for a very short time.

Ephemeral is sort-of-like a persistant tempdb - it's a dumping ground for tables to be created that need to exist for a period of time. There is a ddl trigger on "CREATE_TABLE" that inserts some data about the table into Controller.TableHistory. 

There are some stored procedures to manage the movement/deletion of the tables. Ideally you should run the stored procedures on a regular schedule in the following order - 

* UpdateTableHistoryWhereManualDelete
* UpdateTableLastAccess
* TransferTableToInaccessible @TimeFrame
* DeleteTables @TimeFrame

So the process is to move the tables to an inaccessible schema for the end users after a set period of days from last read, lastwritten or creationdate. What determiines what is used is which of these is the latest date - so if a table is created but never read or written to, then after say 90 days it is moved to the inaccessible schema. After that it is deleted using the same logic. So the timeframe for moving tables can be 90 days, and the timeframe for deleting tables can be 120 days. If however it is written to once but regularly read from, then it is not going to be moved even if the written to and created date go past the 90 days.

If a table is moved to inaccessible it can be moved back by running the TransferTableFromInaccessible stored procedure.

It is important to only use the stored prcedures supplied to delete/move tables. Currently there is only support to rewrite the tableHistory if a table is manually deleted as leaving orphaned records will cause the deleteTables stored procedure to fail. So I've not yet implemented a way to update the tableHistory if a table is manually moved across schemas.

This project was really just a bit of fun, and was me revisiting a problem I had as a DBA at a job I had years ago where tables needed to be moved and deleted on a schedule. 

This is a Visual Studio 2017 solution and the database target platform is set to SQL Server 2016.
