   IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'tbh_Forums_InsertClanToSharedForum')
	BEGIN
		DROP  Procedure  tbh_Forums_InsertClanToSharedForum
	END

GO
--
CREATE PROCEDURE [dbo].[tbh_Forums_InsertClanToSharedForum]
(
   @ForumID int,
   @ClanName nvarchar(30),
   @ClanID  int,
   @PlayerID int 
)
AS
SET NOCOUNT ON

	declare @SharedClanID as int ;
	set @SharedClanID=0;
	select @SharedClanID=ClanID from Clans where Name=@ClanName 
	if exists ( select * from ForumSharingWhiteListedClans where ClanID=@SharedClanID and WhiteListClanID=@ClanID) and not exists(select * from ForumSharing where ForumID =@ForumID and ClanID=@SharedClanID)
	
		begin
			insert into ForumSharing (ForumID,ClanID)values(@ForumID,@SharedClanID);
			select 1;
		end
	else
		select 0;
	
	




