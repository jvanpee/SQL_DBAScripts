/*******************************************************************************************************************
* Create Date: 2016-02-13
* Created By: Jason Van Pee
* Description: A wrapper around sp_send_dbmail that accepts 
* Alter History:
*******************************************************************************************************************/
CREATE PROCEDURE [dbo].[usp_send_operator_dbmail] (
	@profile_name sysname = NULL
	,@operator sysname /* the operator to be notified */
	,@NotifyMethod TINYINT = 1 /*1=Email, 2=Page, 3=Email and Page*/
	,@subject NVARCHAR(255) = NULL
	,@body NVARCHAR(MAX) = NULL
	,@body_format VARCHAR(20) = NULL
	,@importance VARCHAR(6) = 'NORMAL'
	,@sensitivity VARCHAR(12) = 'NORMAL'
	,@file_attachments NVARCHAR(MAX) = NULL
	,@query NVARCHAR(MAX) = NULL
	,@execute_query_database sysname = NULL
	,@attach_query_result_as_file BIT = 0
	,@query_attachment_filename NVARCHAR(260) = NULL
	,@query_result_header BIT = 1
	,@query_result_width INT = 256
	,@query_result_separator CHAR(1) = ' '
	,@exclude_query_output BIT = 0
	,@append_query_error BIT = 0
	,@query_no_truncate BIT = 0
	,@mailitem_id INT = NULL OUTPUT
)
AS
BEGIN
	DECLARE	@sEmail AS VARCHAR(MAX);

	-- get the email of the operator
	SELECT TOP 1
		@sEmail = CASE
			WHEN @NotifyMethod = 1 THEN a.email_address
			WHEN @NotifyMethod = 2 THEN a.pager_address
			WHEN @NotifyMethod = 3 THEN NULLIF(COALESCE(a.email_address + ';','') + COALESCE(a.pager_address,''),'')
		END
	FROM msdb.dbo.sysoperators a
	WHERE
		a.name = @operator;

	IF @sEmail IS NULL
	BEGIN
		RAISERROR ('Operator or notification method not found.',18,1);
		RETURN;
	END;

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @profile_name
		,@recipients = @sEmail
		,@subject = @subject
		,@body = @body
		,@body_format = @body_format
		,@importance = @importance
		,@sensitivity = @sensitivity
		,@file_attachments = @file_attachments
		,@query = @query
		,@execute_query_database = @execute_query_database
		,@attach_query_result_as_file = @attach_query_result_as_file
		,@query_attachment_filename = @query_attachment_filename
		,@query_result_header = @query_result_header
		,@query_result_width = @query_result_width
		,@query_result_separator = @query_result_separator
		,@exclude_query_output = @exclude_query_output
		,@append_query_error = @append_query_error
		,@query_no_truncate = @query_no_truncate
		,@mailitem_id = @mailitem_id OUTPUT;
END
