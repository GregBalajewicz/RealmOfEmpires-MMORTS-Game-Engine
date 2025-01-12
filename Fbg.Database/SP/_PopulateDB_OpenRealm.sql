IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = '_PopulateDB_OpenRealm')
BEGIN
	DROP  Procedure  _PopulateDB_OpenRealm
END

GO


CREATE Procedure dbo._PopulateDB_OpenRealm
	@RealmIDToValidate int
	, @Name nvarchar(100)
	, @Description nvarchar(200)
	, @ExtendedDesc nvarchar(max)
	, @AllowPrereg bit
	, @OpensOn datetime
	, @EndsOn datetime
AS	
set nocount on

--
-- without this, was getting :
-- Heterogeneous queries require the ANSI_NULLS and ANSI_WARNINGS options to be set for the connection. This ensures consistent query semantics. Enable these options and then reissue your query.
--
SET ANSI_WARNINGS ON
SET ANSI_NULLS ON 

/*
SPECIAL 'PLAYERS'
*/
declare @reoteam int
declare @abandoned int
declare @rebels int

declare @REALM_ID int
select @REALM_ID = AttribValue from RealmAttributes where AttribID = 33

if @RealmIDToValidate <> @REALM_ID BEGIN
	select 'Yo! you messed up, wrong realm ID!'
	print 'Yo! you messed up, wrong realm ID!'
	return 0
END

exec FBGC.FBGCommon.dbo._PopulateDB_OpenRealm @REALM_ID

delete  FBGC.FBGCommon.dbo.players where userid in ( '00000000-0000-0000-0000-000000000000'
	,  '00000000-0000-0000-0000-000000000001'
	, '00000000-0000-0000-0000-000000000002')  and RealmID = @REALM_ID

insert into FBGC.FBGCommon.dbo.players ( RealmID, UserID, Name, AvatarID) 
	values ( @REALM_ID, '00000000-0000-0000-0000-000000000000', 'Abandoned',1)
select @abandoned = playerid from FBGC.FBGCommon.dbo.players where RealmID=@REALM_ID and  UserID = '00000000-0000-0000-0000-000000000000'

insert into FBGC.FBGCommon.dbo.players (RealmID, UserID, Name, AvatarID) 
	values ( @REALM_ID, '00000000-0000-0000-0000-000000000001', 'roe_team',1)
select @reoteam = playerid from FBGC.FBGCommon.dbo.players where RealmID=@REALM_ID and  UserID = '00000000-0000-0000-0000-000000000001'

insert into FBGC.FBGCommon.dbo.players (RealmID, UserID, Name, AvatarID) 
	values ( @REALM_ID, '00000000-0000-0000-0000-000000000002', 'Rebels',1)
select @rebels  = playerid from FBGC.FBGCommon.dbo.players where RealmID=@REALM_ID and  UserID = '00000000-0000-0000-0000-000000000002'
 
delete from players where userid in ( '00000000-0000-0000-0000-000000000000'
	,  '00000000-0000-0000-0000-000000000001'
	, '00000000-0000-0000-0000-000000000002') 

insert into players(PlayerID, Name, REgisteredOn, Chests, Anonymous, TitleID, Sex, AvatarID, userid) 
	values ( @reoteam, 'roe_team',Getdate(), 0,0,1,1,1, '00000000-0000-0000-0000-000000000001')

insert into players(PlayerID, Name, REgisteredOn, Chests, Anonymous, TitleID, Sex, AvatarID, userid) 
	values ( @abandoned, 'Abandoned',Getdate(),0,0,1,1,1, '00000000-0000-0000-0000-000000000000')

insert into players(PlayerID, Name, REgisteredOn, Chests, Anonymous, TitleID, Sex, AvatarID, userid) 
	values ( @rebels, '*Rebels*',Getdate(),0,0,1,1,1, '00000000-0000-0000-0000-000000000002')

insert into SpecialPlayers values (@abandoned, 0)
insert into SpecialPlayers values (@reoteam, -1)
insert into SpecialPlayers values (@rebels, -2)




--
-- realm info
--
update FBGC.FBGCommon.dbo.realms set 
		ExtendedDesc = @ExtendedDesc
	, allowPrereg = @AllowPrereg
	, ActiveStatus = 1 
	, OpenOn = @OpensOn
	, EndsOn = @EndsOn
	, Name = @Name
	, [Description] = @Description
where realmid = @REALM_ID

Update Realm set OpenOn = (select OpenOn from FBGC.FBGCommon.dbo.realms where realmid = @REALM_ID)


---- CREATE VILLAGE FOR ROE_TEAM
declare @PlayerID int
select @PlayerID = playerid from players where userID = '00000000-0000-0000-0000-000000000001'
if @PlayerID  is not null BEGIN 
	exec iCreateVillage
		@PlayerID 
		,'roe_team'
		, null -- @StartCloseToPlayerID int = null -- only used for village creation algorithm v3	
		, null -- @InQuadrant smallint = null 	
		, 'roeteam vill' -- @VillageName	nvarchar(25) -- set to null or empty string if a default name is to be generated
		,0-- @ForRebellVillage bit = 0 -- if 1, indicates this is creating rebel village
		,0 --@AllowMultipleVillage bit = 0 -- if 1, SP will not check if player already has a village
END 
