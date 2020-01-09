USE [AdventureWorksDW2017]
GO


CREATE PROCEDURE DBO.[DELETE_FOLDER] 
@CSV_FOLDER_Path NVARCHAR(250) 
,@ZIP_FOLDER_Path NVARCHAR(250) 

AS    
BEGIN 

--exec DBO.[DELETE_FOLDER] @CSV_FOLDER_Path='E:\SQL_ZIP_Test\ProductDetail',@ZIP_FOLDER_Path='E:\SQL_ZIP_Test\ProductDetail.zip'

	SET NOCOUNT ON
 
	DECLARE @line varchar(255)
			,@path varchar(255)
			,@command varchar(255)
	DECLARE @pre_Size BIGINT=0
			,@Size BIGINT = 0
			,@loop int=1



	DROP TABLE IF EXISTS #OUTPUT

	set @command = 'dir "' + @ZIP_FOLDER_Path +'"'

	
	while @loop = 1
	begin
		drop table if exists #output
	
		create table #output (line varchar(255))
	
		insert into #output
			exec master.dbo.xp_cmdshell @command
	
		select @line = ltrim(replace(substring(line, charindex(')', line)+1,len(line)), ',', ''))
			from #output where line like '%File(s)%bytes'
	
		select @line=replace(@line,'bytes','')

		select  @Size=cast(@line as BIGINT)
	
		if @Size > @pre_Size
		BEGIN
			set @pre_Size=@Size
			WAITFOR DELAY '00:00:15';
		END
		if @Size = @pre_Size
			set @loop=0
	end



	DECLARE @DeleteFolderQuery NVARCHAR (1000)

	set @DeleteFolderQuery= 'RD /S /Q '+ @CSV_FOLDER_Path
	exec master..xp_cmdshell @DeleteFolderQuery   

END
GO


