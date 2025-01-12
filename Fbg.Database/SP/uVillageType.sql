IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uVillageType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uVillageType]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE Procedure [dbo].[uVillageType]
	@VillageID int
	,@NewVillageTypeID SMALLINT
	, @cost int
	, @PlayerID int
AS

BEGIN TRY
	declare @oldVillageTypeID smallint

	select @oldVillageTypeID = [VillageTypeID] from Villages where VillageID = @VillageID

	-- change the village type
	update Villages set [VillageTypeID] = @NewVillageTypeID
		where VillageID = @VillageID

	insert into PlayerPFLog
    	(PlayerID,Time ,EventType,Credits ,Cost,notes)
		values
	    (@PlayerID,getdate(),3,@Cost,-1
	    	, 'VID=' + Cast(@VillageID as varchar(max)) + ', OldVillageTypeID=' + Cast(@oldVillageTypeID as varchar(max)) + ', NewVillageTypeID=' + Cast(@NewVillageTypeID as varchar(max))
	    )
	    		    


end try
begin catch
	DECLARE @ERROR_MSG AS VARCHAR(8000)
	 IF @@TRANCOUNT > 0 ROLLBACK

	SET @ERROR_MSG = 'uVillageName FAILED! ' +  + CHAR(10)
		+ '   SOME PARAMETERS/VARIABLES:' + CHAR(10)
		
		+ '   @VillageID' + ISNULL(CAST(@VillageID AS VARCHAR(10)), 'Null') + CHAR(10)
		+ '   @NewVillageTypeID' + ISNULL(CAST(@NewVillageTypeID AS VARCHAR(max)), 'Null') + CHAR(10)
		+ '   @PlayerID' + ISNULL(CAST(@PlayerID AS VARCHAR(max)), 'Null') + CHAR(10)
		+ '   @cost' + ISNULL(CAST(@cost AS VARCHAR(max)), 'Null') + CHAR(10)

		+ '   ERROR_NUMBER():' + ISNULL(CAST(ERROR_NUMBER() AS VARCHAR(100)), 'Null') + CHAR(10)
		+ '   ERROR_SEVERITY():' + ISNULL(CAST(ERROR_SEVERITY() AS VARCHAR(100)), 'Null')+ CHAR(10)
		+ '   ERROR_STATE():' + ISNULL(CAST(ERROR_NUMBER() AS VARCHAR(100)), 'Null')+ CHAR(10)
		+ '   ERROR_PROCEDURE():' + ERROR_PROCEDURE()  + CHAR(10)
		+ '   ERROR_LINE():' + ISNULL(CAST(ERROR_LINE() AS VARCHAR(100)), 'Null') + CHAR(10)
		+ '   ERROR_MESSAGE():' +  ERROR_MESSAGE() + CHAR(10)
	RAISERROR(@ERROR_MSG,11,1)	

end catch	

--
-- say that the village has changed. this is done deliberately outside of the main tran and try 
--
UPDATE VillageCacheTimeStamps SET TimeStamp = getdate() where PlayerID = @PlayerID and VillageID = @VillageID and CachedItemID = 0
IF (@@rowcount < 1 ) BEGIN
	INSERT INTO VillageCacheTimeStamps values (@PlayerID, @VillageID, 0, getdate())
END

GO
