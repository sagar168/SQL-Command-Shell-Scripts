USE [AdventureWorksDW2017]
GO


CREATE PROCEDURE DBO.[CompressFile] 
                @ZipFile   VARCHAR(255), 
                @FileToZip VARCHAR(255) 
AS 
BEGIN

  DECLARE  @hr           INT, 
           @folderObject INT, 
           @shellObject  INT, 
           @src          VARCHAR(255), 
           @desc         VARCHAR(255), 
           @command      VARCHAR(255)
    
  
  --exec DBO.[CompressFile] @FileToZip='E:\SQL_ZIP_Test\ProductDetail',@ZipFile='E:\SQL_ZIP_Test\ProductDetail.zip'
  
  
   
  --Create table to save dummy text to create zip file 
  CREATE TABLE ##DummyTable ( [DummyColumn] [VARCHAR](255)) 
   
  --header of a zip file 
  DECLARE  @zipHeader VARCHAR(22)    
  SET @zipHeader = CHAR(80) + CHAR(75) + CHAR(5) + CHAR(6) + REPLICATE(CHAR(0),18) 
   
  --insert zip header 
  INSERT INTO ##DummyTable (DummyColumn) VALUES (@zipHeader) 

   
  --save/create target zip 

  SET @command = 'bcp "..##DummyTable" out "' + @ZipFile + '" -T"'    
  EXEC MASTER..xp_cmdshell @command 
   
  --Drop used temporary table 
  DROP TABLE ##DummyTable 
   
  --get shell object 
  EXEC @hr = sp_OACreate 
    'Shell.Application' , 
    @shellObject OUT 
   
  IF @hr <> 0 
    BEGIN 
      EXEC sp_OAGetErrorInfo @shellObject , @src OUT , @desc OUT 
       
      SELECT hr = convert(VARBINARY(4),@hr), 
             Source = @src, 
             DESCRIPTION = @desc 
       
      RETURN 
    END 
   
  --get folder 
  SET @command = 'NameSpace("' + @ZipFile + '")'    
  EXEC @hr = sp_OAMethod @shellObject , @command , @folderObject OUT    
  IF @hr <> 0 
    BEGIN 
      EXEC sp_OAGetErrorInfo @shellObject , @src OUT , @desc OUT 
       
      SELECT hr = convert(VARBINARY(4),@hr), 
             Source = @src, 
             DESCRIPTION = @desc 
       
      RETURN 
    END 
   
  --copy file to zip file 
  SET @command = 'CopyHere("' + @FileToZip + '")'    
  EXEC @hr = sp_OAMethod @folderObject , @command 
  IF @hr <> 0 
    BEGIN 
      EXEC sp_OAGetErrorInfo @folderObject , @src OUT , @desc OUT 
       
      SELECT hr = convert(VARBINARY(4),@hr), 
             Source = @src, 
             DESCRIPTION = @desc 
       
      RETURN 
    END 
   
  --Destroy the objects used. 
  EXEC sp_OADestroy @shellObject    
  EXEC sp_OADestroy @folderObject 

END

GO


