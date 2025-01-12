   IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'tbh_Forums_GetSharedForumsWithClansByClanID')
	BEGIN
		DROP  Procedure  tbh_Forums_GetSharedForumsWithClansByClanID
	END

GO
--


create PROCEDURE [dbo].[tbh_Forums_GetSharedForumsWithClansByClanID]
(
   @ClanID  int,
   @PlayerID int 
)
AS
SET NOCOUNT ON

	--update that the player hae seen the foum page
	update players set ClanForumCheckedOn=getdate() where PlayerID=@PlayerID;

	SELECT  distinct 
		tbh_Forums.ForumID AS ID
		, tbh_Forums.AddedDate
		, tbh_Forums.AddedBy
		, tbh_Forums.Title
		, tbh_Forums.Moderated
		, tbh_Forums.Importance
		, tbh_Forums.Description
		, tbh_Forums.ImageUrl
		, Deleted
		, tbh_Forums.ClanID
		, tbh_Forums.AlertClanMembers as AlertClanMembers
		, tbh_Forums.SecurityLevel
		, dbo.fnGetForumIsViewed(@PlayerID,tbh_Forums.ForumID) as IsViewed
		
	FROM tbh_forums
	
	join Clans 
	on tbh_Forums.ClanID=Clans.ClanID
	 JOIN ClanMembers 
		ON Clans.ClanID = ClanMembers.ClanID
	
	WHERE  
		tbh_Forums.ClanID = @ClanID 
		and ClanMembers.PlayerID=@PlayerID
		and Deleted=0
		and (tbh_forums.SecurityLevel = 0
				OR exists (select * from PlayerInRoles PIR WHERE PIR.PlayerID = @PlayerID AND RoleID in (select ID from dbo.fnGetPlayerRolesFromSecurityLevel(tbh_forums.SecurityLevel)))
			) 
	ORDER BY tbh_Forums.Importance ASC

	SELECT c.ClanID,c.Name ,tbh_Forums.ForumID  FROM Clans c

	JOIN ForumSharing  
		ON c.ClanID = ForumSharing.ClanID
	JOIN tbh_Forums 
		ON 	tbh_Forums.ForumID=ForumSharing.ForumID 
	
	WHERE
		tbh_Forums.ClanID=@ClanID 


