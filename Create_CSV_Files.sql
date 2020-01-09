
USE [AdventureWorksDW2017]
GO


CREATE PROCEDURE DBO.[Create_CSV_Files]
 
@DBName VARCHAR(20),    
@CSV_OUTFILE_Path NVARCHAR(250)    
    
    
AS    
BEGIN 
     
--DECLARE @DBName VARCHAR(20)='AdventureWorksDW2017', 
--@CSV_OUTFILE_Path NVARCHAR(250)='E:\SQL_ZIP_Test\ProductDetail' 



---------------- CREATE Folder 
declare @CREATEFolderQuery NVARCHAR(200)
set @CREATEFolderQuery= 'MD '+ @CSV_OUTFILE_Path
exec master..xp_cmdshell @CREATEFolderQuery 



 
 /*GET Column Header */
DECLARE @columnHeader NVARCHAR(MAX)
	SELECT @columnHeader = COALESCE(@columnHeader+',' ,'')+ ''''+column_name +'''' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ProductDetails'     


/* INSERT unique Product category name to create files*/
create table #Tmp (id int identity(1,1),ProductCategory	nvarchar (200));
insert into #tmp (ProductCategory) select distinct EnglishProductCategoryName from dbo.ProductDetails;



DECLARE @Count int , @i int=1,@PC_Name NVARCHAR(200)

select @Count= max(id) from #tmp  

WHILE (@i <= @Count)
BEGIN


	select @PC_Name= ProductCategory from #tmp  where ID=@i   	
	
	/* Below charecter cannot be used in file name
		<,>,:,",/,\,|,?,*
		Replaced above char to '_'
	*/
	declare @PC_FILE_Name nvarchar(200)=replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(@PC_Name,'<','_'),'>','_'),':','_'),'"','_'),'/','_'),'\','_'),'|','_'),'?','_'),'*','_'),' ','_')



    Declare @FilePATH NVARCHAR(200) = @CSV_OUTFILE_Path +'\' +@PC_FILE_Name+'.csv'

		
  
    /*Query  to create files*/
	DECLARE @Query VARCHAR(8000)='bcp "SELECT '+@columnHeader+' UNION ALL select  * from '+@DBName+'.dbo.ProductDetails WHERE EnglishProductCategoryName='''+@PC_Name+'''" queryout '+ @FilePATH +' -t"," -T -c -C RAW'   
    exec master..xp_cmdshell @Query    

	set @i=@i+1
 
    
 END

	drop table #Tmp
    
END

GO


