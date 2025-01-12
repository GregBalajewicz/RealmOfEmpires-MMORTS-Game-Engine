﻿    
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'VillageStartLevels_BuildingSpeedup_i')
	BEGIN
		DROP  Procedure  VillageStartLevels_BuildingSpeedup_i
	END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].VillageStartLevels_BuildingSpeedup_i
		 @userid uniqueidentifier 
	, @PlayerID int
	, @StartLevelID int
	, @RealmID int

AS

begin try 

	declare @receivedOn datetime
	set @receivedOn = getdate()

	-- get the building speedups to give
	select * into #T from VillageStartLevels_BuildingSpeedup where StartLevelID <= @StartLevelID and realmid = @RealmID

	-- create Items 
	insert into Items (userid, playerid, receivedon) select @userid, @PlayerID, @receivedOn  from #T 

	-- get temp tables with dummy key so that we can join them 
	select *, row_number() over (order by StartLevelID) tempID into #T2 from #t 
	select itemid, row_number() over (order by itemid) tempID into #I2 from Items where ReceivedOn = @receivedOn

	insert into Items_BuildingSpeedup (itemID, MinutesAmount) select I.ItemID, minuntesOfSpeedup from #T2 T join #I2 I on I.tempID = T.tempID


end try

begin catch
	DECLARE @ERROR_MSG AS VARCHAR(max) 

	IF @@TRANCOUNT > 0 ROLLBACK

	
	SET @ERROR_MSG = 'VillageStartLevels_BuildingSpeedup_i FAILED! ' +  + CHAR(10)
		+ '   SOME PARAMETERS/VARIABLES:' + CHAR(10)
		+ '   @userid' + ISNULL(CAST(@userid AS VARCHAR(max)), 'Null') + CHAR(10)
		+ '   ERROR_NUMBER():' + ISNULL(CAST(ERROR_NUMBER() AS VARCHAR(100)), 'Null') + CHAR(10)
		+ '   ERROR_SEVERITY():' + ISNULL(CAST(ERROR_SEVERITY() AS VARCHAR(100)), 'Null')+ CHAR(10)
		+ '   ERROR_STATE():' + ISNULL(CAST(ERROR_NUMBER() AS VARCHAR(100)), 'Null')+ CHAR(10)
		+ '   ERROR_PROCEDURE():' + ERROR_PROCEDURE()  + CHAR(10)
		+ '   ERROR_LINE():' + ISNULL(CAST(ERROR_LINE() AS VARCHAR(100)), 'Null') + CHAR(10)
		+ '   ERROR_MESSAGE():' +  ERROR_MESSAGE() + CHAR(10)
	RAISERROR(@ERROR_MSG,11,1)	

end catch	



 