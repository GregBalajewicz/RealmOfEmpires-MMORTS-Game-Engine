IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[iGiveOffer2]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].iGiveOffer2
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE Procedure [dbo].iGiveOffer2
	@userID uniqueidentifier
       
AS
set nocount on 
begin try 
begin tran 

	--
	-- see if user has this offer 
	--
	declare @OfferGiven bit
	declare @ServantAmount int
	select @servantAmount = data from userflags where flagid = 15 /*Offers_HasBeenOfferedOfferNumber2 = 15*/ and userid = @userID

	if @ServantAmount > 0  BEGIN
		--
		-- not check if this offer has not been taken adventage of already 
		--
		if not exists (select * from userflags where flagid = 14 /*Offers_HasUsedServantOfferNumber2 = 14*/ and userid = @userID) BEGIN
			--
			-- note that the offer has been used up 
			insert into UserFlags values (@userID, 14 /*Offers_HasUsedServantOfferNumber2 = 14*/, getdate(), null)
			--
			-- give player the servants 
			exec uGiveServants @userid, @ServantAmount,  5/*promo*/

			SET @OfferGiven = 1
		END
	END
	 
	
commit tran
end try
begin catch

	DECLARE @ERROR_MSG AS VARCHAR(max)
	IF @@TRANCOUNT > 0 ROLLBACK

	
	SET @ERROR_MSG = 'iGiveOffer2 FAILED! '	+  CHAR(10)
		+ '   SOME PARAMETERS/VARIABLES:'	+ CHAR(10)
		+ '   @UserId'						+ ISNULL(CAST(@UserId AS VARCHAR(max)), 'Null') + CHAR(10)
		+ '   @ServantAmount'						+ ISNULL(CAST(@ServantAmount AS VARCHAR(max)), 'Null') + CHAR(10)
		+ '   ERROR_NUMBER():'				+ ISNULL(CAST(ERROR_NUMBER() AS VARCHAR(100)), 'Null') + CHAR(10)
		+ '   ERROR_SEVERITY():'			+ ISNULL(CAST(ERROR_SEVERITY() AS VARCHAR(100)), 'Null')+ CHAR(10)
		+ '   ERROR_STATE():'				+ ISNULL(CAST(ERROR_NUMBER() AS VARCHAR(100)), 'Null')+ CHAR(10)
		+ '   ERROR_PROCEDURE():'			+ ERROR_PROCEDURE()  + CHAR(10)
		+ '   ERROR_LINE():'				+ ISNULL(CAST(ERROR_LINE() AS VARCHAR(100)), 'Null') + CHAR(10)
		+ '   ERROR_MESSAGE():'				+ ERROR_MESSAGE() + CHAR(10)
	RAISERROR(@ERROR_MSG,11,1)	
end catch	

if @OfferGiven = 1  BEGIN
	--
	-- info message only - we dont care if it fails 
	--
	insert into usernotificationstosend	( 
				NotificationTypeID    ,
				UserId                ,
				Title                 ,
				Text                  ,
				TimeCreated           )
			VALUES (998, @UserId, 'Bonus Servants Delivered!', cast(@ServantAmount as varchar(max))+ ' servant bonus delivered. Thank you for playing!', getdate())

END




GO