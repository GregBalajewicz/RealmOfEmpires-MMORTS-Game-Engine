IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = '_PopulateDB')
BEGIN
	DROP  Procedure  _PopulateDB
END

GO


CREATE Procedure dbo._PopulateDB
	@MonetizationType smallint -- 0: Nobility Package, 1: Spells, 2: Subscription; 3 semi classic
	,@IsProductionRun bit
	,@RealmID int
	,@RealmType varchar(100) -- NOOB, MC, HC, X, CLASSIC, 6M
	,@RealmSubType varchar(100) -- Holiday14d, A, B, C, D, E, F, 31d
	,@RealmEnvAccessLimitations smallint -- 0 - open for all, 1 - mobile device only access, 2 - register via desktop access only but allow login on all'
	,@MaxGiftPerDay int
	,@EntryFee int = 0
	-- @RebelVillageCreationChance -- normally this is set automatically by RealmType, and if this is what you want to do, 
	--	just leave it null, however, you can OVERRIDE IT, by setting it to some value. 
	-- value 0 - 0.99  means % creation chance. 99 ->99% chance
	-- value >=1 means how many reble villages to add per new village created. Only whole numbers allowed when >=1. so 1, 2,3 - but not 1.5
	,@RebelVillageCreationChance float = null
	,@LOYALTY_DEC_BASE int =  13 -- Loyalty Decrease Base number. Originally 13
	,@LOYALTY_DEC_VAR int =  4 -- - Loyalty Decrease variance. Originally 4. 
	-- @MinWhenRealmClosesToNewPlayer  normally this is set automatically by RealmType, and if this is what you want to do, 
	--	just leave it null, however, you can OVERRIDE IT, by setting it to some value. 
	,@MinWhenRealmClosesToNewPlayer int = null
	,@MaxXPAllowedToEnter int = null -- leave null to take the default by realm type, or enter number
	,@Consolidation_VillageAbsorptionRatio int = 2	-- 'Village consolidation algorithm - village absorption ratio. # of villages that get absorbed to each promoted village
	,@BonusVillageTypes int = null
	,@Theme int = 0 -- 0 europe, 1, desert, 2 highlands
	,@IsVIPOnly int = 0 -- 0 no, 1 yes				
	,@Morale varchar(10) = null -- options: 'OFF', '30min', '1h', '2h', 'bonusonly', 'NOOB'

	AS
set nocount on
declare	@IsTournamentRealm bit
set @IsTournamentRealm = CASE WHEN @RealmType = 'X' THEN 1 WHEN @RealmType <> 'X'  THEN 0 END

--
-- 1 == standard. 
--	2 means 2 times as SLOW as 1
--	0.5 means 2 times as FAST. 
-- ie, 10min base time & 0.5 factor = 5 min build time. 
-- ie, the smaller the number, the faster the building builds
declare @BuildingBuildSpeedFactor float
declare @UnitRecruitmentSpeedFactor float
--
-- 1 == standard. 
--	2 means 2 times as fast as 1
--	0.5 means 2 times as slow. 
declare @UnitMovementSpeedFactor float
declare @CoinIncrementSpeedFactor float




set @BuildingBuildSpeedFactor = 1 
set @UnitRecruitmentSpeedFactor = 1 
set @UnitMovementSpeedFactor =  1
set @CoinIncrementSpeedFactor = 1



DECLARE @RealmSize int
DECLARE @BeginnerProtectionDays float
declare @SilverTransportSpeed int

set @RealmSize = 20 

--
--@BeginnerProtectionDays
--
set @BeginnerProtectionDays = 0.0083 -- ~ 12 min

--
-- @RebelVillageCreationChance
--
if @RebelVillageCreationChance is null BEGIN 
	set @RebelVillageCreationChance = 1 
END 
--
-- @SilverTransportSpeed
--
set @SilverTransportSpeed = 20 *@UnitMovementSpeedFactor
declare @TitleXPDivFactor int 

set @TitleXPDivFactor = 1


--
-- for populating building info
--
declare @counter bigint
declare @BaseCost int
declare @BaseBuildTime bigint
declare @BasePoints int
declare @CostFactor float
declare @BuildTimeFactor bigint
declare @PointsFactor int
declare @BuildingTypeID int




declare @Building_BarracksID integer
declare @Building_StableID integer
declare @Building_HQID integer
declare @Building_WallID integer
declare @Building_DefenseTowersID integer
declare @Building_CoinMineID integer
declare @Building_TreasuryID integer
declare @Building_FarmLandID integer
declare @Building_PalaceID integer
declare @Building_SiegeWorkshopID integer
declare @Building_TradingPostID integer
declare @Building_TavernID integer
declare @Building_HidingSpotID integer

declare @LevelProp_HQTimeFactor int
declare @LevelProp_CoinMineProduction int
declare @LevelProp_TreasuryCapacity int
declare @LevelProp_PopulationCapacity int
declare @LevelProp_StableRecruitTimeFactor int
declare @LevelProp_BarracksRecruitTimeFactor int
declare @LevelProp_WorkshopRecruitTimeFactor int
declare @LevelProp_PalaceRecruitTimeFactor int
declare @LevelProp_DefenseFactor int
declare @LevelProp_CoinTransportAmount int
declare @LevelProp_TavernRecruitTimeFactor int
declare @LevelProp_HidingSpotCapacity int


declare @Unit_infantry_ID int
declare @Unit_LC_ID int
declare @Unit_Knight_ID int
declare @Unit_Ram_ID int
declare @Unit_trab_ID int
declare @Unit_Lord_ID int
declare @Unit_CitizenMilitia_ID int
declare @Unit_Spy_ID int

declare @PA_V1_ID int
declare @PA_V2_ID int
declare @PB_V1_ID int

--set @realmID = 1

set @Building_BarracksID = 1
set @Building_StableID = 2
set @Building_HQID = 3
set @Building_WallID = 4
set @Building_CoinMineID = 5
set @Building_TreasuryID = 6
set @Building_DefenseTowersID = 7
set @Building_FarmLandID = 8
set @Building_PalaceID = 9
set @Building_SiegeWorkshopID = 10
set @Building_TradingPostID = 11
set @Building_TavernID = 12
set @Building_HidingSpotID= 13

set @Unit_infantry_ID = 2
set @Unit_LC_ID = 5
set @Unit_Knight_ID = 6
set @Unit_Ram_ID = 7
set @Unit_trab_ID = 8
set @Unit_Lord_ID = 10
set @Unit_CitizenMilitia_ID = 11
set @Unit_Spy_ID = 12
set @LevelProp_HQTimeFactor = 1
set @LevelProp_CoinMineProduction = 2
set @LevelProp_TreasuryCapacity = 3
set @LevelProp_PopulationCapacity = 4
set @LevelProp_StableRecruitTimeFactor = 5
set @LevelProp_BarracksRecruitTimeFactor = 6
set @LevelProp_WorkshopRecruitTimeFactor = 7
set @LevelProp_PalaceRecruitTimeFactor = 8
set @LevelProp_DefenseFactor = 9
set @LevelProp_CoinTransportAmount = 10
set @LevelProp_TavernRecruitTimeFactor = 12
set @LevelProp_HidingSpotCapacity = 13

--
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------
-- delete first
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------
--

	delete RaidRewardAcceptanceRecord
	delete RaidResults
	delete RaidUnitsMoving
	delete RaidUnitMovements

	delete RaidTemplatePossibleMonsters
	delete PrivateRaids 
	delete ClanRaids 

	delete RaidReward 
	delete RaidTemplate

	delete RaidMonster 
	delete RaidMonsterTemplate 
	
	delete Raids 

	delete Villages_absorbed
	delete Villages_Promoted
	delete VillageSpeedUpUsage
	delete CreditFarm_PlayerFoodChanceModifierFactor
	delete  CreditFarmLogTable
	delete PlayerMapEvents
	delete villageownershiphistory
	delete admin_attackLog
	delete ForumSharing
	delete ForumSharingWhiteListedClans
	delete PlayerNotificationsSent
	delete PlayerNotificationsNotSent
	delete ResearchItemSpriteLocation
	delete PlayerNotificationSettings
	delete NotificationSettings_Template
	delete from BuildingDowngradeQEntries
	delete PlayerCacheTimeStamps
	delete realmages
	delete VillageStartLevels_Units
	delete VillageStartLevels_Buildings
	delete VillageStartLevels_ResearchItems
	delete VillageStartLevels 

	delete NoTransportVillages
	delete VillageSemaphore
    delete ReportInfoFlag
    delete PlayerSuspensions
	delete ResearchInProgress
	delete playerresearchitems
	delete ResearchItemRequirements
	delete ResearchItemProperties
	delete UnitTypeRecruitmentResearchRequirements
	delete VillageStartLevels_ResearchItems
	delete  ResearchItems
	delete ResearchItemTypes
	delete ResearchItemPropertyTypes

    delete chat
	delete PlayerStats
	delete VillageTags
	delete FilterTags
	delete Tags
	delete Filters
	delete ReportAddressees
	delete PlayerRecentTargetStack
	delete newvillageq
	delete PlayerTitleHistory
	delete ClanInviteLog
	delete DefaultRoles
	delete LordUnitTypeCostMultiplier

	delete playersfriends
	delete playerflags
	delete realm 
	delete map
	delete MessageAddressees
	delete Messages
	delete Folders


	delete PlayersPFPackages
	delete PlayerPFTrials
	delete PFsInPackage
	delete PFPackages
	delete PFTrails
	delete PFs

	
	delete PlayerPostViews
	delete tbh_Posts
	delete tbh_Forums
	delete PlayerInRoles
	delete ClanDiplomacy
	delete ClanMembers
	delete ClanInvites
	delete clanevents
	delete Clans
	delete Roles
	delete SupportAttackedReports
	delete BattleReportSupportUnits
	delete BattleReportSupport
	delete BattleReportBuildingIntel
	delete BattleReportBuildings
	delete BattleReportUnits
	delete BattleReports
	delete ReportAddressees 
	delete Reports
	delete ReportTypes
	delete VillageSupportUnits
	delete from VillageUnits
	delete from UnitsMoving
	delete from UnitMovements
	delete from UnitRecruitments
	delete from BuildingUpgrades
	delete from Cointransports
	delete from BuildingDowngrades
	delete UnitMovements_Attributes
	delete from Events
	delete from buildings
	delete from villagenotes
	delete from playernotes
	delete BuildingUpgradeQEntries
	delete from capitalvillages
	delete from Villages
	delete from UnitOnBuildingAttack
	delete from UnitTypeDefense
	delete from UnitTypeRecruitmentRequirements
	delete from UnitTypes
	delete from LevelProperties
	delete VillageTypeProperties
	delete VillageTypePropertyTypes
	delete VillageTypes
	delete from LevelPropertyTypes
	delete from BuildingTypeRequirements
	delete from BuildingLevels
	delete from BuildingTypes
	delete from ClanMembers
	delete from Clans
	delete PlayerNotes
	delete specialplayers
	delete from MessagesBlockedPlayers
	delete AccountStewards
	delete from playerProfile
	delete PlayerNotifications
	delete PlayerNotifications
	delete Researchers
	delete from players 
	delete from Landmarks
	delete from LandMarkTypeParts
	delete from LandmarkTypes
	
	delete from PlayerTitleHistory
	delete from Titles
	delete from RealmAttributes 
	
	delete PFEventTypes
	delete VillageTypes
	delete SecurityLevelToRoles
--
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------
-- Inserts
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------
--

--
-- Realm Info
--
/*CancelAttackInMin - CoinTransportSpeed- RealmSize - MaxPlayers - BeginnerProtectionDays - OpenOn - RebelVillageCreationChance*/
insert into Realm values (20
	, @SilverTransportSpeed
	, @RealmSize
	, 100000
	, @BeginnerProtectionDays
	, getdate()
	, @RebelVillageCreationChance
	)


IF @UnitMovementSpeedFactor = 2 BEGIN
	insert into RealmAttributes values (1, 2, 'Village creation. AlgV4 : chance that a spot with bordering village will get village. Between 0 (no chance) and 1 (100% chance).') 
	insert into RealmAttributes values (2, 0.6, 'Village creation. AlgV4 : chance that a spot will get a village; regular spot  distance variance') 
END ELSE BEGIN 
	
	insert into RealmAttributes values (1, 3, 'Village creation. AlgV4 : chance that a spot with bordering village will get village. Between 0 (no chance) and 1 (100% chance).') 
	insert into RealmAttributes values (2, 0.8, 'Village creation. AlgV4 : chance that a spot will get a village; regular spot  distance variance') 
END
insert into RealmAttributes values (3, 4, 'Village creation - algorithm version. type 4 is the new algorithm as of  march 29 2017')
insert into RealmAttributes values (4, 2, 'Spy algorithm version.') -- v1 (realm 1&2) v2(realm 3)

insert into RealmAttributes values (5, 1, 'Battle Handicap') -- 0 (realm 1&2),  1 (realm 3)

insert into RealmAttributes values (6, 1, 'Rebel village algorithm version') -- 0 means no rebels (r1&2) 1 means there are rebels (r3)
--
-- 'Hours from opening when realm is to close to new players. 0 means the realm is open indefinatelly'
--
if @MinWhenRealmClosesToNewPlayer is not null BEGIN 
	insert into RealmAttributes values (7, @MinWhenRealmClosesToNewPlayer, 'Hours from opening when realm is to close to new players. 0 means the realm is open indefinatelly') 
END ELSE BEGIN
		insert into RealmAttributes values (7, 0, 'Hours from opening when realm is to close to new players. 0 means the realm is open indefinatelly') 

END
--
--'Overall realm speed factor'. 3x the troop movement factor typically. 
--
	insert into RealmAttributes values (8, @UnitMovementSpeedFactor, 'Overall realm speed factor') 

	
insert into RealmAttributes values (9, 0, 'Min title achieved that is required to enter this realm, 0 if for new players only') 

--
-- sleep mode
--
	insert into RealmAttributes values (16, 12, 'Sleep mode in hours. 0 means no sleep mode is available') 
	insert into RealmAttributes values (17, 2, 'Sleep mode - hours before sleep mode is active active from moment of activation') 
	insert into RealmAttributes values (18, 23.5, 'Sleep mode - hours betwen activations') 


insert into RealmAttributes values (19, 1, 'Are gifts active?') 

IF @MonetizationType > 0 BEGIN 
    insert into RealmAttributes values (20, @MonetizationType, 'Monetization Type. 0:NP, 1:Spells, 2:Subscription, 3:semi-classic') 
END 

	insert into RealmAttributes values (21, 100, 'Unit desertion scaling factor') 
	insert into RealmAttributes values (62, 300, 'Unit desertion - max population') 
	insert into RealmAttributes values (63, 13, 'Unit desertion - minimum distance') 

--
--  'Clan size'
--
	insert into RealmAttributes values (22, 5, 'Clan size') 


if @RealmSubType = 'Retro' OR  @RealmType = 'CLASSIC' BEGIN
	insert into RealmAttributes values (23, 3, 'Stewardship type') -- 0 classic, 1 defence only, 2 off all together, 3 defense only + no supporting others
END ELSE BEGIN
	insert into RealmAttributes values (23, 2, 'Stewardship type') -- 0 classic, 1 defence only, 2 off all together, 3 defense only + no supporting others
END


/*
0 - english
1 - polish
*/
insert into RealmAttributes values (24, 0, 'language') 

/*
0 - roe
1 - sw
*/
insert into RealmAttributes values (25, 0, 'theme') 
--
-- village types / bonus villages % creation chance. if 0 -no bonus villages on this realm. number between 0 and 100
--
IF @BonusVillageTypes is not null AND @BonusVillageTypes > 0 BEGIN
		insert into RealmAttributes values (26, 75, 'village types / bonus villages % creation chance. if 0 -no bonus villages on this realm. number between 0 and 100') 
END ELSE BEGIN 
	insert into RealmAttributes values (26, 0, 'village types / bonus villages % creation chance. if 0 -no bonus villages on this realm. number between 0 and 100') 
END 

--
-- Are capital villages active on this realm now? 1 yes, 0 or missing means no
--
	insert into RealmAttributes values (27, 1, 'Are capital villages active on this realm now? 1 yes, 0 or missing means no') 

	insert into RealmAttributes values (28, 2, 'Handicap param - ratio start point') 
	insert into RealmAttributes values (29, 0.75, 'Handicap param - max handicap') 
	insert into RealmAttributes values (30, 5, 'Handicap param - steepness') 

	insert into RealmAttributes values (31, 0, '1 = research is not active, ie give player all research items at start') 
	insert into RealmAttributes values (32, 0, 'Quests disabled') 

insert into RealmAttributes values (33, @RealmID, 'Realm ID - ID of this realm') 

insert into RealmAttributes values (34, @EntryFee, 'Realm entry cost in servants. 0 means no entry fee') 

/*
parameters that effect how gov effect (decrease) loyalty
Formular is DECREASE =  @LOYALTY_DEC_BASE + random between 1 and @LOYALTY_DEC_VAR 

You can remove those attributes if you want to leave the settings at default values of 13 and 4
*/
insert into RealmAttributes values (35, @LOYALTY_DEC_BASE, '@LOYALTY_DEC_BASE - Loyalty Decrease Base number. Originally 13') 
insert into RealmAttributes values (36, @LOYALTY_DEC_VAR, '@LOYALTY_DEC_VAR - Loyalty Decrease variance. Originally 4.  ') 

	insert into RealmAttributes values (39, 200, 'max gifts per day that can be used') 
	insert into RealmAttributes values (93, 9, 'gift limit carry over days. 0 assumed if the param not present') 

	insert into RealmAttributes values (40, 1, 'hide sleep icon on map when player is in sleep mode. 0 or missing, icons is displayed; 1 means the icon is not displayed') 
--
	insert into RealmAttributes values (41, @Consolidation_VillageAbsorptionRatio, 'Village consolidation algorithm - village absorption ratio. # of villages that get absorbed to each promoted village') 
--
-- government types 
-- 
	insert into RealmAttributes values (42, 1, 'government types enabled. 1 yes, 0 no') 


insert into RealmAttributes values (46,  0, 'New Daily Reward. set to 1 if you want the new daily reward ON in this realm') 

--
-- Realm access limitations. 0 - open for all, 1 - mobile device only access, 2 - register via desktop access only but allow login on all
--
insert into RealmAttributes values (47, @RealmEnvAccessLimitations, 'Realm access limitations. 0 - open for all, 1 - mobile device only access, 2 - register via desktop access only but allow login on all') 


insert into RealmAttributes values (50, 1, 'LocalDBVersion') -- do not change 

	insert into RealmAttributes values (51, 40, 'Duration of cacpital village protection in days. Ignored if Capital village protection is off for the realm') 

	insert into RealmAttributes values (52, '1', 'Vacation - base number of vacation days for a player. Typically it is 1. Set to 0 if you dont want vacation mode on this realm.') 
	insert into RealmAttributes values (53, '3', 'Vacation - number of days it takes for vacation mode to turn on after player activation') 
	insert into RealmAttributes values (54, '1', 'Vacation - Per Use Min: if canceled early, it deducts this many anyway!') 
	insert into RealmAttributes values (56, '7', 'Vacation - number of days must pass since last vacation ended, to allow reactivation') 



insert into RealmAttributes values (61, 2, 'battle simulator') 


insert into RealmAttributes values (67, @Theme, 'Realm Theme : 0-europe, 1-desert, missing-europe') 
insert into RealmAttributes values (68, @IsVIPOnly, 'Access limitation - VIP only? 1 means yes, only for VIPs') 
	insert into RealmAttributes values (69, 24*60, 'Max daily speed up in minutes') 

--
insert into RealmAttributes values (92, 10, 'Nubmer of caravans per day') 

--
--WeekendMode Realm Attributes
--
	delete RealmAttributes where attribid in (94,95,96)
	insert into RealmAttributes values (94, 2, 'WeekendMode days')
	insert into RealmAttributes values (95, 12, 'WeekendMode - minimum time it takes to activate')
	insert into RealmAttributes values (96, 4, 'WeekendMode - how many days after last end/cancel before reactivation')

-- limit clan invites - ids from 1000 to 1010 reserved
insert into RealmAttributes values (1000, 20, 30)
insert into RealmAttributes values (1001, 50, 20)
insert into RealmAttributes values (1002, 70, 15)
insert into RealmAttributes values (1003, 100, 10)
insert into RealmAttributes values (1004, 9999999, 5)

insert into RealmAttributes values (2000, @RealmType, 'NOTE - @RealmType')
insert into RealmAttributes values (2001, @RealmSubType, 'NOTE - @RealmSubType')



begin /*Building types*/

insert into BuildingTypes values(@Building_BarracksID, dbo.Translate('Barracks'), 20,0,'')
insert into BuildingTypes values(@Building_StableID, dbo.Translate('Stable'), 30,0,'')
insert into BuildingTypes values(@Building_HQID, dbo.Translate('Headquarters'), 0,1,dbo.Translate('Headquarters-desc'))
insert into BuildingTypes values(@Building_WallID, dbo.Translate('Wall'), 100,0,'')
insert into BuildingTypes values(@Building_CoinMineID, dbo.Translate('Silver Mine'), 10,1,'')
insert into BuildingTypes values(@Building_TreasuryID, dbo.Translate('Treasury'), 110,1,'')
insert into BuildingTypes values(@Building_DefenseTowersID, dbo.Translate('Defensive Towers'), 101,0,'')
insert into BuildingTypes values(@Building_FarmLandID, dbo.Translate('Farm Land'), 60,1,'')
insert into BuildingTypes values(@Building_PalaceID, dbo.Translate('Palace'), 90,0,'')
insert into BuildingTypes values(@Building_SiegeWorkshopID, dbo.Translate('Siege Workshop'), 40,0,'')
insert into BuildingTypes values(@Building_TradingPostID, dbo.Translate('Trading Post'), 45,0,'')
insert into BuildingTypes values(@Building_TavernID, dbo.Translate('Tavern'), 41,0,'')
insert into BuildingTypes values(@Building_HidingSpotID, dbo.Translate('Hiding Spot'), 111,0,'')

-- 
-- Creating building info. 
--
exec dbo.Temp_PopBuildingLevelInfo 
	 @BuildingBuildSpeedFactor
	, @Building_TradingPostID 
	, 550				-- @BaseCost				** TWEEKED 
	, 36000000000		-- @BaseBuildTime			// 30 min ** TWEEKED 
	, 10				-- @BasePoints				-- IGNORE THIS, IT IS AUTOCALCULATED
	, 400				-- @BaseLevelStrength		** TWEEKED 
	, 5					-- @BasePopulation 
	, 1.262				-- @CostFactor				** TWEEKED 
	, 1.2				-- @BuildTimeFactor			** TWEEKED 
	, 1.265				-- @PointsFactor			- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.045				-- @LevelStrengthFactor		** TWEEKED 
	, 1.16				-- @PopulationFactor
	, 25				-- @MaxLevel

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_BarracksID
	, 400				-- @BaseCost				** TWEEKED 
	, 36000000000		-- @BaseBuildTime // 30 min	** TWEEKED 
	, 10				-- @BasePoints				-- IGNORE THIS, IT IS AUTOCALCULATED
	, 400				-- @BaseLevelStrength		** TWEEKED 
	, 7					-- @BasePopulation
	, 1.27				-- @CostFactor				** TWEEKED 
	, 1.2				-- @BuildTimeFactor			** TWEEKED 
	, 1.265				-- @PointsFactor			-- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.045				-- @LevelStrengthFactor		** TWEEKED 
	, 1.16				-- @PopulationFactor
	, 25				-- @MaxLevel

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_StableID
	, 800				-- @BaseCost				** TWEEKED 
	, 72000000000		-- @BaseBuildTime 1h		** TWEEKED 
	, 14				-- @BasePoints				-- IGNORE THIS, IT IS AUTOCALCULATED
	, 400				-- @BaseLevelStrength		** TWEEKED 
	, 9					-- @BasePopulation
	, 1.26				-- @CostFactor				** TWEEKED 
	, 1.18				-- @BuildTimeFactor			** TWEEKED 
	, 1.265				-- @PointsFactor			-- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.045				-- @LevelStrengthFactor		** TWEEKED 
	, 1.16				-- @PopulationFactor
	, 25				-- @MaxLevel

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_SiegeWorkshopID
	, 1000				-- @BaseCost				** TWEEKED 
	, 108000000000		-- @BaseBuildTime //1.5h	** TWEEKED 
	, 18				-- @BasePoints				-- IGNORE THIS, IT IS AUTOCALCULATED
	, 400				-- @BaseLevelStrength		** TWEEKED 
	, 9					-- @BasePopulation
	, 1.25				-- @CostFactor				** TWEEKED 
	, 1.17				-- @BuildTimeFactor			** TWEEKED 
	, 1.265				-- @PointsFactor			-- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.045				-- @LevelStrengthFactor		** TWEEKED 
	, 1.16				-- @PopulationFactor
	, 25				-- @MaxLevel

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_HQID
	, 250				-- @BaseCost				** TWEEKED 
	, 18000000000		-- @BaseBuildTime//15 min	** TWEEKED 
	, 10				-- @BasePoints				-- IGNORE THIS, IT IS AUTOCALCULATED
	, 400				-- @BaseLevelStrength		** TWEEKED 
	, 7	     			-- @BasePopulation
	, 1.3				-- @CostFactor				** TWEEKED 
	, 1.2				-- @BuildTimeFactor			** TWEEKED 
	, 1.265				-- @PointsFactor			-- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.045				-- @LevelStrengthFactor		** TWEEKED 
	, 1.16				-- @PopulationFactor
	, 25				-- @MaxLevel


exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_WallID
	, 1000				-- @BaseCost				** TWEEKED 
	, 72000000000		-- @BaseBuildTimw 60 min	** TWEEKED 
	, 10				-- @BasePoints				-- IGNORE THIS, IT IS AUTOCALCULATED
	, 300				-- @BaseLevelStrength		** TWEEKED 
	, 10				-- @BasePopulation
	, 1.4				-- @CostFactor				** TWEEKED 
	, 1.4				-- @BuildTimeFactor			** TWEEKED 
	, 1.265				-- @PointsFactor			-- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.1				-- @LevelStrengthFactor		** TWEEKED 
	, 1.3				-- @PopulationFactor
	, 10				-- @MaxLevel

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_DefenseTowersID
	, 4000				-- @BaseCost			** TWEEKED 
	, 108000000000		-- @BaseBuildTime		-- 1.5h ** TWEEKED 
	, 10				-- @BasePoints			-- IGNORE THIS, IT IS AUTOCALCULATED
	, 300				-- @BaseLevelStrength	** TWEEKED 
	, 9					-- @BasePopulation
	, 1.3				-- @CostFactor
	, 1.3				-- @BuildTimeFactor		** TWEEKED 
	, 1.265				-- @PointsFactor		-- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.1				-- @LevelStrengthFactor ** TWEEKED 
	, 1.33				-- @PopulationFactor
	, 10				-- @MaxLevel

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_CoinMineID
	, 500				-- @BaseCost				** TWEEKED 
	, 24000000000		-- @BaseBuildTime //20min	** TWEEKED 
	, 10				-- @BasePoints				-- IGNORE THIS, IT IS AUTOCALCULATED
	, 800				-- @BaseLevelStrength		** TWEEKED 
	, 35				-- @BasePopulation
	, 1.163				-- @CostFactor				** TWEEKED 
	, 1.132 			-- @BuildTimeFactor			** TWEEKED 
	, 1.265				-- @PointsFactor			-- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.021				-- @LevelStrengthFactor		** TWEEKED 
	, 1.092     		-- @PopulationFactor
	, 45				-- @MaxLevel

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_TreasuryID
	, 125				-- @BaseCost				** TWEEKED 
	, 24000000000		-- @BaseBuildTime -- 20min	** TWEEKED 
	, 6 				-- @BasePoints				IGNORE THIS, IT IS AUTOCALCULATED
	, 400				-- @BaseLevelStrength		** TWEEKED 
	, 0					-- @BasePopulation			** TWEEKED 
	, 1.265				-- @CostFactor				** TWEEKED 
	, 1.2				-- @BuildTimeFactor			** TWEEKED  
	, 1.2				-- @PointsFactor			-- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.045				-- @LevelStrengthFactor		** TWEEKED 
	, 0					-- @PopulationFactor		** TWEEKED 
	, 30				-- @MaxLevel

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_FarmLandID
	, 100				-- @BaseCost			** TWEEKED 
	, 24000000000		-- @BaseBuildTime -- 20 min
	, 5					-- @BasePoints -- IGNORE THIS, IT IS AUTOCALCULATED
	, 400				-- @BaseLevelStrength	** TWEEKED 
	, 0					-- @BasePopulation		** TWEEKED 
	, 1.3				-- @CostFactor			** TWEEKED 
	, 1.2				-- @BuildTimeFactor		** TWEEKED 
	, 1.2				-- @PointsFactor -- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.045				-- @LevelStrengthFactor ** TWEEKED 
	, 0					-- @PopulationFactor	** TWEEKED 
	, 30				-- @MaxLevel

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_PalaceID
	, 150000			-- @BaseCost ** TWEEKED 
	, 3456000000000		-- @BaseBuildTime -- 48h ** TWEEKED 
	, 10				-- @BasePoints -- IGNORE THIS, IT IS AUTOCALCULATED
	, 4000				-- @BaseLevelStrength 
	, 100				-- @BasePopulation
	, 1.5				-- @CostFactor -- IRRELEVANT
	, 1.2				-- @BuildTimeFactor ** TWEEKED 
	, 1.265				-- @PointsFactor -- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.1				-- @LevelStrengthFactor -- IRRELEVANT 
	, 2				-- @PopulationFactor -- IRRELEVANT
	, 1			-- @MaxLevel

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_TavernID
	, 3000				-- @BaseCost			** TWEEKED 
	, 144000000000		-- @BaseBuildTime -- 2h ** TWEEKED 
	, 10				-- @BasePoints			-- IGNORE THIS, IT IS AUTOCALCULATED
	, 500				-- @BaseLevelStrength   ** TWEEKED 
	, 10				-- @BasePopulation 
	, 1.9				-- @CostFactor			** TWEEKED 
	, 2				-- @BuildTimeFactor		** TWEEKED 
	, 1.265				-- @PointsFactor		-- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.2				-- @LevelStrengthFactor ** TWEEKED 
	, 1.3				-- @PopulationFactor
	, 5					-- @MaxLevel			** TWEEKED 

exec dbo.Temp_PopBuildingLevelInfo 
	@BuildingBuildSpeedFactor 
	, @Building_HidingSpotID
	, 100				-- @BaseCost			** TWEEKED 
	, 400000000		    -- @BaseBuildTime -- 20 sec
	, 111					-- @BasePoints -- IGNORE THIS, IT IS AUTOCALCULATED
	, 1000				-- @BaseLevelStrength	** TWEEKED 
	, 2					-- @BasePopulation		** TWEEKED 
	, 1.27				-- @CostFactor			** TWEEKED 
	, 1.35				-- @BuildTimeFactor		** TWEEKED 
	, 1.265					-- @PointsFactor -- IGNORE THIS, IT IS AUTOCALCULATED
	, 1.1				-- @LevelStrengthFactor ** TWEEKED 
	, 1.2				-- @PopulationFactor	** TWEEKED 
	, 20				-- @MaxLevel


update BuildingLevels set LevelName = dbo.Translate('Stone Wall') where BuildingTypeID = @Building_WallID and level <= 10
update BuildingLevels set LevelName = dbo.Translate('Wooden Palisade') where BuildingTypeID = @Building_WallID and level <=5

update BuildingLevels set LevelName = dbo.Translate('Stone Towers') where BuildingTypeID = @Building_DefenseTowersID and level <=10
update BuildingLevels set LevelName = dbo.Translate('Wooden Towers') where BuildingTypeID = @Building_DefenseTowersID and level <=5



--
-- TWEEK SOME BUILDING LEVELS _ HQ
--
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_HQID
	, 50				-- @BaseCost	
	, 60000000   		-- @BaseBuildTime//6 sec	
	, 1.6				-- @CostFactor				
	, 1.7				-- @BuildTimeFactor			
	, 9				-- @MaxLevel
	, 0					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_HQID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.3				-- @CostFactor				
	, 1.7				-- @BuildTimeFactor			
	, 16				-- @MaxLevel
	, 9					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_HQID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.3				-- @CostFactor				
	, 1.25				-- @BuildTimeFactor			
	, 21				-- @MaxLevel
	, 16					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_HQID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.3				-- @CostFactor				
	, 1.1				-- @BuildTimeFactor			
	, 25				-- @MaxLevel
	, 21					  -- @PrevLevel

--
-- TWEEK SOME BUILDING LEVELS - COIN MINE
--
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_CoinMineID
	, 60				-- @BaseCost	
	, 60000000   		-- @BaseBuildTime//6 sec
	, 1.5				-- @CostFactor				
	, 1.7				-- @BuildTimeFactor			
	, 10				-- @MaxLevel
	, 0					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_CoinMineID
	, 0				-- ingored
	, 0   			-- ignorbed
	, 1.16				-- @CostFactor				
	, 1.7				-- @BuildTimeFactor			
	, 11				-- @MaxLevel
	, 10					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_CoinMineID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.16				-- @CostFactor				
	, 1.25				-- @BuildTimeFactor			
	, 28				-- @MaxLevel
	, 11					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_CoinMineID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.16				-- @CostFactor				
	, 1.1				-- @BuildTimeFactor			
	, 45				-- @MaxLevel
	, 28					-- @PrevLevel

--
-- TWEEK SOME BUILDING LEVELS - FARM LAND
--
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_FarmLandID
	, 55				-- @BaseCost	
	, 120000000   		-- @BaseBuildTime//12 sec
	, 1.4				-- @CostFactor				
	, 1.6				-- @BuildTimeFactor			
	, 9				-- @MaxLevel
	, 0					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_FarmLandID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.3				-- @CostFactor				
	, 1.6				-- @BuildTimeFactor			
	, 17 				-- @MaxLevel
	, 9				-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_FarmLandID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.3				-- @CostFactor				
	, 1.25				-- @BuildTimeFactor			
	, 17 				-- @MaxLevel
	, 9				-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_FarmLandID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.3				-- @CostFactor				
	, 1.25				-- @BuildTimeFactor			
	, 26				-- @MaxLevel
	, 17					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_FarmLandID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.3				-- @CostFactor				
	, 1.1				-- @BuildTimeFactor			
	, 30				-- @MaxLevel
	, 26				-- @PrevLevel




--
-- TWEEK SOME BUILDING LEVELS - FARM LAND
--
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_TreasuryID
	, 55				-- @BaseCost	
	, 60000000   		-- @BaseBuildTime//6 sec
	, 1.4				-- @CostFactor				
	, 1.6				-- @BuildTimeFactor			
	, 11				-- @MaxLevel
	, 0					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_TreasuryID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.25				-- @CostFactor				
	, 1.6				-- @BuildTimeFactor			
	, 20				-- @MaxLevel
	, 11					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_TreasuryID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.25				-- @CostFactor				
	, 1.25				-- @BuildTimeFactor			
	, 26				-- @MaxLevel
	, 20					-- @PrevLevel
exec dbo.Temp_PopBuildingLevelInfo_TWEEK 
	@BuildingBuildSpeedFactor 
	, @Building_TreasuryID
	, 0				-- ingored
	, 0   			-- ignored
	, 1.25				-- @CostFactor				
	, 1.1				-- @BuildTimeFactor			
	, 30				-- @MaxLevel
	, 26				-- @PrevLevel
 

--
-- manually adjust some level properties
--

if @MonetizationType = 1 AND @IsTournamentRealm = 0 BEGIN 
	-- set level 2 of SM to be 60 seconds - this is needed for tutorial that asks the player to speed it up
	update BuildingLevels set BuildTime = 600000000 where BuildingTypeID = @Building_CoinMineID and level = 2
END 




--
--
--
-- BUILDING LEVEL PROPERTIES
--
--
--
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_HQTimeFactor, dbo.Translate('Build Time Factor'), 3)
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_CoinMineProduction, dbo.Translate('Silver Production'), 1)
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_TreasuryCapacity, dbo.Translate('Treasury Capacity'), 1)
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_PopulationCapacity, dbo.Translate('Food Production'), 1)
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_BarracksRecruitTimeFactor, dbo.Translate('Recruitment Time Factor'), 3)
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_StableRecruitTimeFactor, dbo.Translate('Recruitment Time Factor'), 3)
insert into LevelPropertyTypes (PropertyID, Name, Type)  values (@LevelProp_WorkshopRecruitTimeFactor, dbo.Translate('Recruitment Time Factor'), 3)
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_PalaceRecruitTimeFactor, dbo.Translate('Recruitment Time Factor'), 3)
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_DefenseFactor, dbo.Translate('Defense Factor'), 3)
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_CoinTransportAmount, dbo.Translate('Max Silver to Transport'), 1)
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_TavernRecruitTimeFactor, dbo.Translate('Recruitment Time Factor'), 3)
insert into LevelPropertyTypes (PropertyID, Name, Type) values (@LevelProp_HidingSpotCapacity, dbo.Translate('Hiding Spot Capacity'), 1)



exec dbo.Temp_PopLevelProperties   --** TWEEKED
	@Building_TradingPostID
	, @LevelProp_CoinTransportAmount
	, 500
	, 1.2
	, 1 -- start level 
	, 25
	
exec dbo.Temp_PopLevelProperties  --** TWEEKED
	@Building_HQID
	, @LevelProp_HQTimeFactor
	, 100
	, 0.945
	, 1 -- start level 
	, 25

exec dbo.Temp_PopLevelProperties --** TWEEKED
	@Building_BarracksID
	, @LevelProp_BarracksRecruitTimeFactor
	, 100
	, 0.945
	, 1 -- start level 
	, 25

exec dbo.Temp_PopLevelProperties --** TWEEKED
	@Building_SiegeWorkshopID
	, @LevelProp_WorkshopRecruitTimeFactor
	, 100
	, 0.945
	, 1 -- start level 
	, 25

exec dbo.Temp_PopLevelProperties --** TWEEKED
	@Building_StableID
	, @LevelProp_StableRecruitTimeFactor
	, 100
	, 0.945
	, 1 -- start level 
	, 25


exec dbo.Temp_PopLevelProperties --** TWEEKED
	@Building_PalaceID
	, @LevelProp_PalaceRecruitTimeFactor
	, 100
	, 1
	, 1 -- start level 
	, 1

-- Populate coin mine levels 1-10
declare @CoinProduction int -- ** TWEEKED 
set @CoinProduction = 200 * @CoinIncrementSpeedFactor / 2 
exec dbo.Temp_PopLevelProperties  -- ** TWEEKED 
	@Building_CoinMineID
	, @LevelProp_CoinMineProduction
	, @CoinProduction					--@BaseValue
	, 1.2								-- @Factor
	, 1 -- start level 
	, 10								-- @MaxLevel

-- Populate coin mine levels 11-45
SELECT @CoinProduction = floor(PropertyValue) *  1.062 FROM  LevelProperties 
    WHERE BuildingTypeID = @Building_CoinMineID
    AND Level=10
    AND PropertyID= @LevelProp_CoinMineProduction
exec dbo.Temp_PopLevelProperties  -- ** TWEEKED 
	@Building_CoinMineID
	, @LevelProp_CoinMineProduction
	, @CoinProduction					--@BaseValue
	, 1.062								-- @Factor
	, 11 -- start level 
	, 45								-- @MaxLevel

exec dbo.Temp_PopLevelProperties  -- ** TWEEKED 
	@Building_TreasuryID
	, @LevelProp_TreasuryCapacity
	, 3000
	, 1.24
	, 1 -- start level 
	, 30

exec dbo.Temp_PopLevelProperties  -- ** TWEEKED 
	@Building_FarmLandID
	, @LevelProp_PopulationCapacity
	, 180
	, 1.187
	, 1 -- start level 
	, 30

exec dbo.Temp_PopLevelProperties  -- ** TWEEKED 
	@Building_WallID
	, @LevelProp_DefenseFactor
	, 105
	, 1.05		-- @Factor
	, 1 -- start level 
	, 10

exec dbo.Temp_PopLevelProperties  -- ** TWEEKED 
	@Building_DefenseTowersID
	, @LevelProp_DefenseFactor
	, 110
	, 1.03		-- @Factor
	, 1 -- start level 
	, 10


exec dbo.Temp_PopLevelProperties --** TWEEKED
	@Building_TavernID
	, @LevelProp_TavernRecruitTimeFactor
	, 100
	, 0.7
	, 1 -- start level 
	, 5

IF @RealmType = 'MC' BEGIN 
	exec dbo.Temp_PopLevelProperties  -- ** TWEEKED 
		@Building_HidingSpotID
		, @LevelProp_HidingSpotCapacity
		, 2500
		, 1.3
		, 1 -- start level 
		, 20
END ELSE IF @RealmType = 'HC' OR @RealmType = 'CLASSIC' BEGIN 
	exec dbo.Temp_PopLevelProperties  -- ** TWEEKED 
		@Building_HidingSpotID
		, @LevelProp_HidingSpotCapacity
		, 1000
		, 1.3
		, 1 -- start level 
		, 15
END ELSE BEGIN 
	exec dbo.Temp_PopLevelProperties  -- ** TWEEKED 
		@Building_HidingSpotID
		, @LevelProp_HidingSpotCapacity
		, 2500
		, 1.3
		, 1 -- start level 
		, 20
END 


--
-- Manual property tweeks
--
update LevelProperties set PropertyValue = 800000 WHERE BuildingTypeID = @Building_TreasuryID AND Level = 27 AND PropertyID = @LevelProp_TreasuryCapacity
update LevelProperties set PropertyValue = 1000000 WHERE BuildingTypeID = @Building_TreasuryID AND Level = 28 AND PropertyID = @LevelProp_TreasuryCapacity
update LevelProperties set PropertyValue = 1250000 WHERE BuildingTypeID = @Building_TreasuryID AND Level = 29 AND PropertyID = @LevelProp_TreasuryCapacity
update LevelProperties set PropertyValue = 1500000 WHERE BuildingTypeID = @Building_TreasuryID AND Level = 30 AND PropertyID = @LevelProp_TreasuryCapacity

update LevelProperties set PropertyValue = 40000 WHERE BuildingTypeID = @Building_TradingPostID AND Level = 25 AND PropertyID = @LevelProp_CoinTransportAmount
update LevelProperties set PropertyValue = 26000 WHERE BuildingTypeID = @Building_FarmLandID AND Level = 30 AND PropertyID = @LevelProp_PopulationCapacity

-- half farm & treasury  output and tweek early levels due to research 
update levelproperties set propertyvalue=cast(propertyvalue as real)/2 where buildingtypeid = @Building_FarmLandID and level >10
update levelproperties set propertyvalue=216        where buildingtypeid = @Building_FarmLandID and level = 1 
update levelproperties set propertyvalue=222        where buildingtypeid = @Building_FarmLandID and level = 2 
update levelproperties set propertyvalue=231        where buildingtypeid = @Building_FarmLandID and level = 3 
update levelproperties set propertyvalue=252        where buildingtypeid = @Building_FarmLandID and level = 4 
update levelproperties set propertyvalue=265        where buildingtypeid = @Building_FarmLandID and level = 5 
update levelproperties set propertyvalue=279        where buildingtypeid = @Building_FarmLandID and level = 6 
update levelproperties set propertyvalue=300        where buildingtypeid = @Building_FarmLandID and level = 7 
update levelproperties set propertyvalue=334        where buildingtypeid = @Building_FarmLandID and level = 8 
update levelproperties set propertyvalue=380        where buildingtypeid = @Building_FarmLandID and level = 9 
update levelproperties set propertyvalue=435        where buildingtypeid = @Building_FarmLandID and level = 10


-- cutting wall and tower property by 1/2 because of the research
update levelproperties set propertyvalue= 100+((cast(propertyvalue as real)-100)/2) where buildingtypeid = @Building_DefenseTowersID
update levelproperties set propertyvalue= 100+((cast(propertyvalue as real)-100)/2) where buildingtypeid = @Building_WallID

--
-- 
--
insert into BuildingTypeRequirements values(@Building_PalaceID, 1, @Building_HQID, 20)
insert into BuildingTypeRequirements values(@Building_PalaceID, 1, @Building_WallID, 5)
insert into BuildingTypeRequirements values(@Building_PalaceID, 1, @Building_StableID, 20)
insert into BuildingTypeRequirements values(@Building_PalaceID, 1, @Building_TradingPostID, 15)

IF @IsTournamentRealm = 0 BEGIN
	insert into BuildingTypeRequirements values(@Building_StableID, 1, @Building_BarracksID, 5)
	insert into BuildingTypeRequirements values(@Building_StableID, 1, @Building_HQID, 5)

	insert into BuildingTypeRequirements values(@Building_BarracksID, 1, @Building_CoinMineID, 5)

	insert into BuildingTypeRequirements values(@Building_SiegeWorkshopID, 1, @Building_BarracksID, 10)
	insert into BuildingTypeRequirements values(@Building_SiegeWorkshopID, 1, @Building_HQID, 10)
	insert into BuildingTypeRequirements values(@Building_SiegeWorkshopID, 1, @Building_StableID, 10)

	insert into BuildingTypeRequirements values(@Building_DefenseTowersID, 1, @Building_WallID, 3)

	insert into BuildingTypeRequirements values(@Building_DefenseTowersID, 6, @Building_WallID, 7)

	insert into BuildingTypeRequirements values(@Building_TradingPostID, 1, @Building_HQID, 15)
	insert into BuildingTypeRequirements values(@Building_TradingPostID, 1, @Building_TreasuryID, 15)

	insert into BuildingTypeRequirements values(@Building_TavernID, 1, @Building_BarracksID, 5)

	insert into BuildingTypeRequirements values(@Building_WallID, 1, @Building_HQID, 5)


	--Additional building requirements introduced for the NOOB Realm
	if @RealmType = 'NOOB' BEGIN 
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 10, @Building_FarmLandID, 2)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 10, @Building_TreasuryID, 2)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 10, @Building_HQID, 4)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 15, @Building_TreasuryID, 4)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 15, @Building_HQID, 5)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 15, @Building_BarracksID, 1)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 20, @Building_HQID, 6)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 20, @Building_BarracksID, 2)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 25, @Building_BarracksID, 3)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 25, @Building_HQID, 10)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 25, @Building_TreasuryID, 10)
		insert into BuildingTypeRequirements values(@Building_CoinMineID, 25, @Building_FarmLandID, 10)

		insert into BuildingTypeRequirements values(@Building_TavernID, 3, @Building_BarracksID, 6)
		insert into BuildingTypeRequirements values(@Building_BarracksID, 5, @Building_HidingSpotID, 1)
		insert into BuildingTypeRequirements values(@Building_BarracksID, 6, @Building_CoinMineID, 14)
		insert into BuildingTypeRequirements values(@Building_BarracksID, 6, @Building_HQID, 8)
		insert into BuildingTypeRequirements values(@Building_BarracksID, 10, @Building_HidingSpotID, 2)
		insert into BuildingTypeRequirements values(@Building_StableID, 10, @Building_HQID, 10)
		insert into BuildingTypeRequirements values(@Building_StableID, 10, @Building_HidingSpotID, 3)
		insert into BuildingTypeRequirements values(@Building_StableID, 20, @Building_CoinMineID, 25)

	END
END 

end/*Building types*/




begin /* units */

--
-- 
-- =======================================================================================
-- =======================================================================================
-- =======================================================================================
--
-- UNITS
--
-- =======================================================================================
-- =======================================================================================
--
--
--




insert into UnitTypes values (@Unit_Knight_ID, dbo.Translate('Knight'), dbo.Translate('KnightDeff')
	, 6						-- SORT
	, 2000					-- cost													
	, 12					-- population 
	, @Building_StableID	-- BuildingTypeID	
	, 216000000000 * @UnitRecruitmentSpeedFactor		-- recruit time  180 min	** doubled with introduction of research
	, @LevelProp_StableRecruitTimeFactor			-- recruit time factor property ID
	, 6 * @UnitMovementSpeedFactor					-- speed - # of squares per hour CHANGE!
	, 400					-- Carry
	, 430					-- Attack Strength
	, 1.5					-- Survival Factor
	,dbo.Translate('Knight1'),dbo.Translate('Knight2') -- images 
	, 0						-- Spy ability 
	, 0						-- Counter Spy ability 
	)

insert into UnitTypes values (@Unit_LC_ID, dbo.Translate('Light Cavalry'),dbo.Translate('Light CavalryDeff')
	, 5						-- SORT
	, 700					-- cost
	, 6						-- population 
	, @Building_StableID	-- BuildingTypeID		
	, 84000000000  * @UnitRecruitmentSpeedFactor		-- recruit time -- 99 min ** doubled with introduction of research
	, @LevelProp_StableRecruitTimeFactor			-- recruit time factor property ID
	, 7 * @UnitMovementSpeedFactor					-- speed - # of squares per hour
	, 300					-- Carry
	, 190					-- Attack Strength
	, 1.5					-- Survival Factor
	,dbo.Translate('Cavalry1'),dbo.Translate('Cavalry2')  -- images 
	, 0						-- Spy ability 
	, 0						-- Counter Spy ability 
	)

insert into UnitTypes values (@Unit_infantry_ID, dbo.Translate('Infantry'), dbo.Translate('InfantryDeff')
	, 2						-- SORT
	, 150					-- cost					
	, 1						-- population 
	, @Building_BarracksID	-- BuildingTypeID	
	, (CASE WHEN @RealmType = 'MC' OR @RealmType = 'NOOB' THEN 15000000000 ELSE 20400000000 END) * @UnitRecruitmentSpeedFactor		-- recruit time -- 17 min ** doubled with introduction of research
	, @LevelProp_BarracksRecruitTimeFactor			-- recruit time factor property ID
	, 3 * @UnitMovementSpeedFactor					-- speed - # of squares per hour
	, 40					-- Carry
	, 25					-- Attack Strength
	, 1.5					-- Survival Factor
	,dbo.Translate('Infantry1'),dbo.Translate('Infantry2')  -- images 	
	, 0						-- Spy ability 
	, 0						-- Counter Spy ability 
	)


insert into UnitTypes values (@Unit_CitizenMilitia_ID, dbo.Translate('Citizen Militia'), dbo.Translate('Citizen MilitiaDeff')
	, 0						-- SORT
	, 25					-- cost
	, 1						-- population 
	, @Building_BarracksID	-- BuildingTypeID	
	, 5400000000 * @UnitRecruitmentSpeedFactor		-- recruit time 9minutes (was 17:08) 
	, @LevelProp_BarracksRecruitTimeFactor			-- recruit time factor property ID
	, 4 * @UnitMovementSpeedFactor					-- speed - # of squares per hour
	, 50					-- Carry
	, 7 					-- Attack Strength
	, 1.5					-- Survival Factor
	,dbo.Translate('Militia1'),dbo.Translate('Militia2')  -- images 
	, 0						-- Spy ability 
	, 0						-- Counter Spy ability 
	)

insert into UnitTypes values (@Unit_Ram_ID, dbo.Translate('Ram'), dbo.Translate('RamDeff')
	, 7						-- SORT
	, 1400					-- cost
	, 10						-- population 
	, @Building_SiegeWorkshopID	-- BuildingTypeID	
	, 192000000000 * @UnitRecruitmentSpeedFactor		-- recruit time -- 160 min ** doubled with introduction of research
	, @LevelProp_WorkshopRecruitTimeFactor			-- recruit time factor property ID
	, 2 * @UnitMovementSpeedFactor					-- speed - # of squares per hour
	, 0						-- Carry
	, 0						-- Attack Strength
	, 1.5					-- Survival Factor
	,dbo.Translate('Ram1'),dbo.Translate('Ram2')  -- images 
	, 0						-- Spy ability 
	, 0						-- Counter Spy ability 
	)
insert into UnitTypes values (@Unit_trab_ID, dbo.Translate('Trebuchet'), dbo.Translate('TrebuchetDeff')
	, 8						-- SORT
	, 2000					-- cost
	, 15					-- population 
	, @Building_SiegeWorkshopID	-- BuildingTypeID	
	,  216000000000 * @UnitRecruitmentSpeedFactor	-- recruit time -- 180 min ** doubled with introduction of research
	, @LevelProp_WorkshopRecruitTimeFactor			-- recruit time factor property ID
	, 2 * @UnitMovementSpeedFactor					-- speed - # of squares per hour
	, 0					-- Carry
	, 0					-- Attack Strength
	, 1.5					-- Survival Factor
	,dbo.Translate('Treb1'),dbo.Translate('Treb2')  -- images  
	, 0						-- Spy ability 
	, 0						-- Counter Spy ability 
	)

insert into UnitTypes values (@Unit_Lord_ID, dbo.Translate('Governor'), dbo.Translate('GovernorDeff')
	, 99						-- SORT
	, 75000					-- cost
	, 200						-- population 
	, @Building_PalaceID	-- BuildingTypeID	
	, 108000000000 * @UnitRecruitmentSpeedFactor	-- recruit time -- 3 h
	, @LevelProp_PalaceRecruitTimeFactor			-- recruit time factor property ID
	, 2 * @UnitMovementSpeedFactor					-- speed - # of squares per hour
	, 0						-- Carry
	, 0					-- Attack Strength
	, 1.5					-- Survival Factor
	,dbo.Translate('Governor1'),dbo.Translate('Governor2')  -- images 
	, 0						-- Spy ability 
	, 0						-- Counter Spy ability 
	)
	
insert into UnitTypes values (@Unit_Spy_ID, dbo.Translate('Spy'), dbo.Translate('SpyDeff')
	, 98					-- SORT
	, 700					-- cost
	, 10					-- population 
	, @Building_TavernID	-- BuildingTypeID	
	, 108000000000 * @UnitRecruitmentSpeedFactor	-- recruit time -- 1.5 h ** doubled with introduction of research
	, @LevelProp_TavernRecruitTimeFactor			-- recruit time factor property ID
	, 8 * @UnitMovementSpeedFactor					-- speed - # of squares per hour
	, 0						-- Carry
	, 0 					-- Attack Strength
	, 1.5					-- Survival Factor
	,dbo.Translate('Spy1'),dbo.Translate('Spy2')  -- images 
	, 7					-- Spy ability 
	, 10						-- Counter Spy ability 
	)
	
	
	
--
--
--
-- Units attack strength against buildings
--
--
--


-- treb strength varies based on target building

insert into UnitOnBuildingAttack values (@Building_BarracksID, @Unit_trab_ID, 40)		--** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_StableID, @Unit_trab_ID, 40)			--** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_HQID, @Unit_trab_ID, 40)				--** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_WallID, @Unit_trab_ID, 31)			-- 150 treb take down wall to 0  ** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_DefenseTowersID, @Unit_trab_ID, 95)	-- ~50 take down to level 0  ** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_CoinMineID, @Unit_trab_ID, 40)		--** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_TreasuryID, @Unit_trab_ID, 40)		--** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_FarmLandID, @Unit_trab_ID, 40)		--** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_PalaceID, @Unit_trab_ID, 40)			--** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_SiegeWorkshopID, @Unit_trab_ID, 40)	--** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_TradingPostID, @Unit_trab_ID, 40)	--** TWEEKED 
insert into UnitOnBuildingAttack values (@Building_TavernID, @Unit_trab_ID, 40)	--** TWEEKED 

--
-- ram strength based on level 10 wall cumul strength = 4700 
--
insert into UnitOnBuildingAttack values (@Building_WallID, @Unit_Ram_ID, 95)  --** TWEEKED 

--
--
--
-- Unit Defense against other units
--
--
--

-- militia defending
insert into UnitTypeDefense values (@Unit_CitizenMilitia_ID, @Unit_CitizenMilitia_ID, 14)
insert into UnitTypeDefense values (@Unit_CitizenMilitia_ID, @Unit_infantry_ID, 15)
insert into UnitTypeDefense values (@Unit_CitizenMilitia_ID, @Unit_Knight_ID, 20)
insert into UnitTypeDefense values (@Unit_CitizenMilitia_ID, @Unit_LC_ID, 20)
insert into UnitTypeDefense values (@Unit_CitizenMilitia_ID, @Unit_Lord_ID, 0)
insert into UnitTypeDefense values (@Unit_CitizenMilitia_ID, @Unit_trab_ID, 0)
insert into UnitTypeDefense values (@Unit_CitizenMilitia_ID, @Unit_Ram_ID, 0)
insert into UnitTypeDefense values (@Unit_CitizenMilitia_ID, @Unit_Spy_ID, 0)

-- infintry defending
insert into UnitTypeDefense values (@Unit_infantry_ID, @Unit_CitizenMilitia_ID, 25)
insert into UnitTypeDefense values (@Unit_infantry_ID, @Unit_infantry_ID, 27)
insert into UnitTypeDefense values (@Unit_infantry_ID, @Unit_Knight_ID, 33)
insert into UnitTypeDefense values (@Unit_infantry_ID, @Unit_LC_ID, 33)
insert into UnitTypeDefense values (@Unit_infantry_ID, @Unit_Lord_ID, 0)
insert into UnitTypeDefense values (@Unit_infantry_ID, @Unit_trab_ID, 0)
insert into UnitTypeDefense values (@Unit_infantry_ID, @Unit_Ram_ID, 0)
insert into UnitTypeDefense values (@Unit_infantry_ID, @Unit_Spy_ID, 0)

-- HCav/knight defending
insert into UnitTypeDefense values (@Unit_Knight_ID, @Unit_CitizenMilitia_ID, 305)
insert into UnitTypeDefense values (@Unit_Knight_ID, @Unit_infantry_ID, 305)
insert into UnitTypeDefense values (@Unit_Knight_ID, @Unit_Knight_ID, 290)
insert into UnitTypeDefense values (@Unit_Knight_ID, @Unit_LC_ID, 265)
insert into UnitTypeDefense values (@Unit_Knight_ID, @Unit_Lord_ID, 0)
insert into UnitTypeDefense values (@Unit_Knight_ID, @Unit_trab_ID, 0)
insert into UnitTypeDefense values (@Unit_Knight_ID, @Unit_Ram_ID, 0)
insert into UnitTypeDefense values (@Unit_Knight_ID, @Unit_Spy_ID, 0)

-- Cav/ Horseman defending
insert into UnitTypeDefense values (@Unit_LC_ID, @Unit_CitizenMilitia_ID, 150)
insert into UnitTypeDefense values (@Unit_LC_ID, @Unit_infantry_ID, 150)
insert into UnitTypeDefense values (@Unit_LC_ID, @Unit_Knight_ID, 145)
insert into UnitTypeDefense values (@Unit_LC_ID, @Unit_LC_ID, 115)
insert into UnitTypeDefense values (@Unit_LC_ID, @Unit_Lord_ID, 0)
insert into UnitTypeDefense values (@Unit_LC_ID, @Unit_trab_ID, 0)
insert into UnitTypeDefense values (@Unit_LC_ID, @Unit_Ram_ID, 0)
insert into UnitTypeDefense values (@Unit_LC_ID, @Unit_Spy_ID, 0)

-- Lord defending
insert into UnitTypeDefense values (@Unit_Lord_ID, @Unit_CitizenMilitia_ID, 300)
insert into UnitTypeDefense values (@Unit_Lord_ID, @Unit_infantry_ID, 300)
insert into UnitTypeDefense values (@Unit_Lord_ID, @Unit_Knight_ID, 300)
insert into UnitTypeDefense values (@Unit_Lord_ID, @Unit_LC_ID, 300)
insert into UnitTypeDefense values (@Unit_Lord_ID, @Unit_Lord_ID, 0)
insert into UnitTypeDefense values (@Unit_Lord_ID, @Unit_trab_ID, 0)
insert into UnitTypeDefense values (@Unit_Lord_ID, @Unit_Ram_ID, 0)
insert into UnitTypeDefense values (@Unit_Lord_ID, @Unit_Spy_ID, 0)

-- trebuchet defending
insert into UnitTypeDefense values (@Unit_trab_ID, @Unit_CitizenMilitia_ID, 50)
insert into UnitTypeDefense values (@Unit_trab_ID, @Unit_infantry_ID, 50)
insert into UnitTypeDefense values (@Unit_trab_ID, @Unit_Knight_ID, 50)
insert into UnitTypeDefense values (@Unit_trab_ID, @Unit_LC_ID, 50)
insert into UnitTypeDefense values (@Unit_trab_ID, @Unit_Lord_ID, 0)
insert into UnitTypeDefense values (@Unit_trab_ID, @Unit_trab_ID, 0)
insert into UnitTypeDefense values (@Unit_trab_ID, @Unit_Ram_ID, 0)
insert into UnitTypeDefense values (@Unit_trab_ID, @Unit_Spy_ID, 0)

-- Ram defending
insert into UnitTypeDefense values (@Unit_Ram_ID, @Unit_CitizenMilitia_ID, 10)
insert into UnitTypeDefense values (@Unit_Ram_ID, @Unit_infantry_ID, 10)
insert into UnitTypeDefense values (@Unit_Ram_ID, @Unit_Knight_ID, 10)
insert into UnitTypeDefense values (@Unit_Ram_ID, @Unit_LC_ID, 10)
insert into UnitTypeDefense values (@Unit_Ram_ID, @Unit_Lord_ID, 0)
insert into UnitTypeDefense values (@Unit_Ram_ID, @Unit_trab_ID, 0)
insert into UnitTypeDefense values (@Unit_Ram_ID, @Unit_Ram_ID, 0)
insert into UnitTypeDefense values (@Unit_Ram_ID, @Unit_Spy_ID, 0)


-- @Unit_Spy_ID defending
insert into UnitTypeDefense values (@Unit_Spy_ID, @Unit_CitizenMilitia_ID, 2)
insert into UnitTypeDefense values (@Unit_Spy_ID, @Unit_infantry_ID, 2)
insert into UnitTypeDefense values (@Unit_Spy_ID, @Unit_Knight_ID, 2)
insert into UnitTypeDefense values (@Unit_Spy_ID, @Unit_LC_ID, 2)
insert into UnitTypeDefense values (@Unit_Spy_ID, @Unit_Lord_ID, 0)
insert into UnitTypeDefense values (@Unit_Spy_ID, @Unit_trab_ID, 0)
insert into UnitTypeDefense values (@Unit_Spy_ID, @Unit_Ram_ID, 0)
insert into UnitTypeDefense values (@Unit_Spy_ID, @Unit_Spy_ID, 0)
--
-- UNIT requirements
--
--insert into dbo.UnitTypeRecruitmentRequirements values (@Unit_inf_ID, @Building_BarracksID, 1, 'level 1 barracks required to recruit infantry' )
insert into dbo.UnitTypeRecruitmentRequirements values (@Unit_CitizenMilitia_ID, @Building_BarracksID, 1, '')
insert into dbo.UnitTypeRecruitmentRequirements values (@Unit_infantry_ID, @Building_BarracksID, 10, '')
insert into dbo.UnitTypeRecruitmentRequirements values (@Unit_LC_ID, @Building_StableID, 1, '')
insert into dbo.UnitTypeRecruitmentRequirements values (@Unit_Knight_ID, @Building_StableID, 10, '')
insert into dbo.UnitTypeRecruitmentRequirements values (@Unit_trab_ID, @Building_SiegeWorkshopID, 10, '')
insert into dbo.UnitTypeRecruitmentRequirements values (@Unit_Ram_ID, @Building_SiegeWorkshopID, 1, '')
insert into dbo.UnitTypeRecruitmentRequirements values (@Unit_Spy_ID, @Building_TavernID, 1, '')



end /* end unit declaration  */


--
-- Report Types
--
insert into ReportTypes (ReportTypeId, Name, Description, Sort) values (1, dbo.Translate('Attack'),dbo.Translate('Attack Report'), 10)
insert into ReportTypes (ReportTypeId, Name, Description, Sort) values (2, dbo.Translate('Support Attacked'),dbo.Translate('Support - Your supporting troops were attacked'), 20)
insert into ReportTypes (ReportTypeId, Name, Description, Sort) values (3, dbo.Translate('Silver Delivery'),dbo.Translate('Silver delivery'),30)
insert into ReportTypes (ReportTypeId, Name, Description, Sort) values (4, dbo.Translate('Misc.'),dbo.Translate('Miscellaneous'),40)
insert into ReportTypes (ReportTypeId, Name, Description, Sort) values (5, dbo.Translate('Your Support Arrived'),dbo.Translate('Support - Your support arrived at destination'),21)
insert into ReportTypes (ReportTypeId, Name, Description, Sort) values (6, dbo.Translate('Support Arrived'),dbo.Translate('Support - Support arrived at your village'),22)
insert into ReportTypes (ReportTypeId, Name, Description, Sort) values (7, dbo.Translate('Support Sent Back'),dbo.Translate('Support - Your support was sent back'),23)
insert into ReportTypes (ReportTypeId, Name, Description, Sort) values (8, dbo.Translate('Support Pulled Out'),dbo.Translate('Support - Support at your village was pulled back'),24)



--
/*Roles Table*/
--
INSERT [dbo].[Roles]([RoleID]) VALUES (0) -- owner
INSERT [dbo].[Roles]([RoleID]) VALUES (2) -- inviter
INSERT [dbo].[Roles]([RoleID]) VALUES (3) -- admin
INSERT [dbo].[Roles]([RoleID]) VALUES (4) -- forum admin
INSERT [dbo].[Roles]([RoleID]) VALUES (5) -- diplomat

insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (0,0,'All Members')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (0,2,'All Members')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (0,3,'All Members')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (0,4,'All Members')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (0,5,'All Members')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (1,0,'Only Owners and Admins')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (1,3,'Only Owners and Admins')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (2,0,'Only Owners, Admins & Diplomats')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (2,3,'Only Owners, Admins & Diplomats')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (2,5,'Only Owners, Admins & Diplomats')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (3,0,'Only Owners, Admins, Diplomats & Forum Admins')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (3,3,'Only Owners, Admins, Diplomats & Forum Admins')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (3,4,'Only Owners, Admins, Diplomats & Forum Admins')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (3,5,'Only Owners, Admins, Diplomats & Forum Admins')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (4,0,'Only Owners, Admins, Diplomats, Forum Admins & Inviters')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (4,2,'Only Owners, Admins, Diplomats, Forum Admins & Inviters')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (4,3,'Only Owners, Admins, Diplomats, Forum Admins & Inviters')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (4,4,'Only Owners, Admins, Diplomats, Forum Admins & Inviters')
insert into SecurityLevelToRoles (SecurityLevel, RoleID, Description) values (4,5,'Only Owners, Admins, Diplomats, Forum Admins & Inviters')

 



--
--
--
-- LandMarks
--
--
--
EXEC _PopulateDB_Map @Theme


--
--
--
-- Premium features
--
--
--
insert into PFEventTypes values (1, 'Player Buys Servants-PayPal','')
insert into PFEventTypes values (4, 'Player is give servants','')
insert into PFEventTypes values (5, 'Servants for promo/reward','')
insert into PFEventTypes values (6, 'Servants used up','')
insert into PFEventTypes values (7, 'Servants Refund','')
insert into PFEventTypes values (11, 'Servants via OfferPal','')
insert into PFEventTypes values (12, 'Servants via AdParlor','')
insert into PFEventTypes values (15, 'Servants Refund-UpgradeToNP','')
insert into PFEventTypes values (16, 'Transfer servants to player','this player transfered servants to someone else')
insert into PFEventTypes values (17, 'Get servants via transfer','')
insert into PFEventTypes values (18, 'Credits taken away by admin','')
insert into PFEventTypes values (2, 'Player activates feature/package','')
insert into PFEventTypes values (3, 'Player extends feature/package','')
insert into PFEventTypes values (8, 'player cancels a feature/package','Q.7.2 Second table is for "(b) full prorated refund - this is for depreciated features only"')
insert into PFEventTypes values (9, 'player cancels a feature/package','Q.7.1.1 (a) partial prorateated refund - for all all active, not depreciated features. For a sitaiton where user get a full refund for an extension')
insert into PFEventTypes values (10, 'player cancels a feature/package','Q.7.1.1 (a) partial prorateated refund - for all all active, not depreciated features. For a sitaiton where user get a partial refund - package expires in less than its duration')
insert into PFEventTypes values (14, 'player cancels a feature/package(NP)','Q.7.3 Special refund when activating the Nobility package')
insert into PFEventTypes values (19, 'Servants via SuperRewards','')
insert into PFEventTypes values (20, 'Servants via gWallet','')
insert into PFEventTypes values (21, 'Servants via LinkEx','')
insert into PFEventTypes values (22, 'player restarts village','')
insert into PFEventTypes values (23, 'player changes bonus village type','')


	--
	--
	--
	-- PREMIUM FEATURES for other realms, not super fast RXs
	--
	--
	--
	--
	-- giant map is in all realms, except the mobile only realm
	IF @RealmEnvAccessLimitations <> 1 -- if not mobile only access
		and @MonetizationType <> 3
	BEGIN 
		insert into PFs values (1, 'giantmap')
		insert into PFTrails values (9, 1, 'Giant Map', 3, 1) 
		insert into PFPackages values (1, 50, 30)
		insert into PFsInPackage values (1, 1)
	END


	insert into PFs values (100, 'Buy Researcher')
	--insert into PFPackages values (100, 50, 0)
	insert into PFPackages values (100, 1, 0)
	insert into PFsInPackage values (100, 100)

	IF @MonetizationType = 0 BEGIN 

		
		insert into PFs values (3, 'BuildingQ')
		insert into PFTrails values (2, 3, 'Unlimited Building Q - 1st trial', 7, 1) 
		insert into PFTrails values (3, 3, 'Unlimited Building Q - 2nd village', 3, 1) 
		insert into PFTrails values (4, 3, 'Unlimited Building Q - 3rd village', 3, 1) 
		insert into PFTrails values (5, 3, 'Unlimited Building Q - 5th village', 3, 1) 
		insert into PFTrails values (6, 3, 'Unlimited Building Q - 10th village', 3, 1) 

		insert into PFs values (4, 'LargeMap')
		--insert into PFTrails values (8, 4, 'Large Map - Beta 2 constant trial', 21, 1) -- DEPRECIATED
		insert into PFTrails values (23, 4, 'Large Map', 21, 1)

		insert into PFs values (5, 'SummaryPages') -- incoming troops list on the other village overview. This shows your troops traveling to this village
		insert into PFTrails values (17, 5, 'SummaryPages', 14, 1)  -- incoming troops list on the other village overview. This shows your troops traveling to this village

		--insert into PFs values (8, 'UpgradeMax')-- DEPRECIATED
		--insert into PFTrails values (7, 8, 'Upgrade to max level - Beta 2 constant trial', 21, 1) -- DEPRECIATED


		insert into PFs values (9, 'IncomingTroopsToFromVillagePlayer') -- incoming troops list on the other village overview. This shows your troops traveling to this village
		insert into PFTrails values (11, 9, 'IncomingTroopsToFromVillagePlayer', 3, 1)  -- incoming troops list on the other village overview. This shows your troops traveling to this village

		insert into PFs values (10, 'Notes') -- Notes on village or player
		insert into PFTrails values (12, 10, 'Notes', 7, 1)  -- Notes on village or player


		insert into PFs values (12, 'Incoming/Outgoing Enhancements') -- 
		insert into PFTrails values (14, 12, 'Incoming/Outgoing Enhancements', 7, 1)  -- 

		--insert into PFs values (13, 'IncomingOutgoingAllVillages') -- 
		--insert into PFTrails values (15, 13, 'IncomingOutgoingAllVillages', 7, 1)  -- 

		insert into PFs values (14, 'SupportAllVillage') -- 
		insert into PFTrails values (16, 14, 'SupportAllVillage', 7, 1)  -- 


		insert into PFs values (15, 'TagsAndFilters') -- 
		insert into PFTrails values (18, 15, 'TagsAndFilters', 21, 1)  -- 
		insert into PFTrails values (25, 15, 'Tags And Filters 5th Village', 3, 1)  -- 


		insert into PFs values (16, 'ImprovedVOV') -- 
		insert into PFTrails values (19, 16, 'ImprovedVOV', 7, 1)  -- 

		insert into PFs values (17, 'ConvinientSilverTransport') -- 
		insert into PFTrails values (20, 17, 'ConvinientSilverTransport', 7, 1) 


		insert into PFs values (18, 'ReportImprovements') -- 
		insert into PFTrails values (21, 18, 'ReportImprovements', 21, 1) 

		insert into PFs values (19, 'MessageImprovements') -- 
		insert into PFTrails values (22, 19, 'MessageImprovements', 21, 1) 


		insert into PFs values (20, 'BattleSimImprovements') -- 
		insert into PFTrails values (24, 20, 'BattleSimImprovements', 7, 1) 

		insert into PFs values (21, 'Command Troops Enhancements') -- 
		insert into PFTrails values (26, 21, 'Command Troops Enhancements', 7, 1) 

		insert into PFs values (22, 'rewardNowTM') -- allows you to get a reward to a quest now. CRITICAL!!! :this feature can ONLY be part of NP!! See Bll.User.HasNPInSomeRealm

		insert into PFs values (23, 'Mass Upgrade and Recruit') 


		insert into PFPackages values (2, 15, 30)
		insert into PFPackages values (3, 5, 30)



		insert into PFPackages values (4,  25,  30) -- insert into PFs values (3, 'BuildingQ')
		insert into PFsInPackage values (4, 3)

		insert into PFPackages values (5,  25,  30) -- insert into PFs values (4, 'LargeMap')
		insert into PFsInPackage values (5, 4)

		insert into PFPackages values (6,  20,  30) -- insert into PFs values (5, 'SummaryPages')
		insert into PFsInPackage values (6, 5)

		insert into PFPackages values (7,  10,  30) -- insert into PFs values (9, 'IncomingTroopsToFromVillagePlayer') 
		insert into PFsInPackage values (7, 9)

		insert into PFPackages values (8,  5,   30) -- insert into PFs values (10, 'Notes') -- Notes on village or player
		insert into PFsInPackage values (8, 10)

		--insert into PFPackages values (10, 10,  30) -- insert into PFs values (13, 'IncomingOutgoingAllVillages') -- 
		--insert into PFsInPackage values (10, 13)

		insert into PFPackages values (11, 25,   30) -- insert into PFs values (12, 'IncomingOutgoing enhancements') -- 
		insert into PFsInPackage values (11, 12)

		insert into PFPackages values (12, 10,  30) -- insert into PFs values (14, 'SupportAllVillage') -- 
		insert into PFsInPackage values (12, 14)

		insert into PFPackages values (13, 20,  30) -- insert into PFs values (15, 'TagsAndFilters') -- 
		insert into PFsInPackage values (13, 15)

		insert into PFPackages values (14, 10,   30) -- insert into PFs values (16, 'ImprovedVOV') --
		insert into PFsInPackage values (14, 16)

		insert into PFPackages values (15, 25,  30) -- insert into PFs values (17, 'ConvinientSilverTransport') -- 
		insert into PFsInPackage values (15, 17)

		insert into PFPackages values (16, 10,  30) --  insert into PFs values (18, 'ReportImprovements') -- 
		insert into PFsInPackage values (16, 18)

		insert into PFPackages values (17, 10,  30) --  insert into PFs values (19, 'MessageImprovements') -- 
		insert into PFsInPackage values (17, 19)

		insert into PFPackages values (18, 10,  30) --  insert into PFs values (20, 'BattleSimImprovements') -- 
		insert into PFsInPackage values (18, 20)

		insert into PFPackages values (19, 25,  30) --  insert into PFs values (21, 'Command Troops Enhancements')
		insert into PFsInPackage values (19, 21)		



		insert into PFPackages values (999,  200, 30) -- essential / nobility package
		insert into PFsInPackage values (999, 3)
		insert into PFsInPackage values (999, 4)
		insert into PFsInPackage values (999, 5)
		insert into PFsInPackage values (999, 9)
		insert into PFsInPackage values (999, 10)
		insert into PFsInPackage values (999, 12)
		--insert into PFsInPackage values (999, 13)
		insert into PFsInPackage values (999, 14)
		insert into PFsInPackage values (999, 15)
		insert into PFsInPackage values (999, 16)
		insert into PFsInPackage values (999, 17)
		insert into PFsInPackage values (999, 18)
		insert into PFsInPackage values (999, 19)
		insert into PFsInPackage values (999, 20) -- insert into PFs values (20, 'BattleSimImprovements')
		insert into PFsInPackage values (999, 21) -- insert into PFs values (21, 'Command Troops Enhancements')
		insert into PFsInPackage values (999, 22) -- insert into PFs values (22, 'rewardNowTM') --  *** NOTE!!! *** this feature can ONLY be part of NP!! See Bll.User.HasNPInSomeRealm
		insert into PFsInPackage values (999, 23) -- insert into PFs values (23, 'Mass Upgrade and and Recruit') 

	END

	IF @MonetizationType = 1 BEGIN 
        
		insert into PFs values (24, '25% more silver') 
		insert into PFPackages values (22, 15, 1) 
		insert into PFsInPackage values (22, 24)

		insert into PFs values (25, '20% defence bonus') 
		insert into PFPackages values (23, 20,  1) 
		insert into PFsInPackage values (23, 25)

		insert into PFs values (26, '20% attack bonus') 
		insert into PFPackages values (24, 20,  1) 
		insert into PFsInPackage values (24, 26)

		insert into PFs values (27, 'Cut 1 min of build time') 
		insert into PFPackages values (25, 1,  0) 
		insert into PFsInPackage values (25, 27)
		insert into PFs values (28, 'Cut 15 min of build time') 
		insert into PFPackages values (26, 5,  0) 
		insert into PFsInPackage values (26, 28)
		insert into PFs values (29, 'Cut 60 min of build time') 
		insert into PFPackages values (27, 10,  0) 
		insert into PFsInPackage values (27, 29)
		insert into PFs values (30, 'Cut 240 min of build time') 
		insert into PFPackages values (28, 30,  0) 
		insert into PFsInPackage values (28, 30)
    
		insert into PFs values (31, 'Downgrade building level now') 
		insert into PFPackages values (29, 15,  0) 
		insert into PFsInPackage values (29, 31)
    
		insert into PFs values (32, 'Speed up support return') 
		insert into PFPackages values (30, 5,  1) 
		insert into PFsInPackage values (30, 32)    

		insert into PFs values (33, 'Boost Loyalty') 
		insert into PFPackages values (31, 200,  0) 
		insert into PFsInPackage values (31, 33)

		if  @RealmType <> 'X'   BEGIN
			insert into PFs values (34, 'Rebel Rush') 
			insert into PFPackages values (32, 10,  0.083333) 
			insert into PFsInPackage values (32, 34)			
		END ELSE BEGIN -- this is a tournament realm
			IF @RealmSubType = '31d' OR @RealmSubType = 'Holiday14d' BEGIN 
				insert into PFs values (34, 'Rebel Rush') 
				insert into PFPackages values (32, 10,  0.041666) 
				insert into PFsInPackage values (32, 34)
		END 
	END 
	END 


	/*

		SUBSCRIPTION PLAY

	*/
	IF @MonetizationType = 2 BEGIN 
		insert into PFs values (1000, 'Subscription') 
		insert into PFPackages values (1000, 200,  31) -- changed it to 200. WAS :  400 servants. roughly < $10/month with the purchase of the largest package
		insert into PFsInPackage values (1000, 1000)
	END


	IF @MonetizationType = 3 BEGIN 
        
		insert into PFs values (24, '25% more silver') 
		insert into PFPackages values (22, 100, 31) 
		insert into PFsInPackage values (22, 24)

		insert into PFs values (25, '20% defence bonus') 
		insert into PFPackages values (23, 100,  31) 
		insert into PFsInPackage values (23, 25)

		insert into PFs values (26, '20% attack bonus') 
		insert into PFPackages values (24, 100,  31) 
		insert into PFsInPackage values (24, 26)

		insert into PFs values (32, 'Speed up support return') 
		insert into PFPackages values (30, 50,  31) 
		insert into PFsInPackage values (30, 32)    


		if  @RealmType <> 'X'   BEGIN
			insert into PFs values (34, 'Rebel Rush') 
			insert into PFPackages values (32, 100,  31) 
			insert into PFsInPackage values (32, 34)			
		END ELSE BEGIN -- this is a tournament realm
			IF @RealmSubType = '31d' OR @RealmSubType = 'Holiday14d' BEGIN 
				insert into PFs values (34, 'Rebel Rush') 
				insert into PFPackages values (32, 10,  0.041666) 
				insert into PFsInPackage values (32, 34)
		END 
	END 
	END 


































	insert into LordUnitTypeCostMultiplier values (1, 1, 1)
	insert into LordUnitTypeCostMultiplier values (5, 6, 2)
	insert into LordUnitTypeCostMultiplier values (15, 27, 3);
	insert into LordUnitTypeCostMultiplier values (40, 103, 4);
	insert into LordUnitTypeCostMultiplier values (60, 184, 5)
	insert into LordUnitTypeCostMultiplier values (100, 385, 0)


/*

TITLES

*/

insert into titles values (0, dbo.Translate('Peasant'), dbo.Translate('Peasant'), '', 17, 0)
insert into Titles values (1, dbo.Translate('Yeoman'), dbo.Translate('Yeoman'), '', 24,200/@TitleXPDivFactor)
insert into Titles values (2, dbo.Translate('Freeman'), dbo.Translate('Freeman'), '', 49,200/@TitleXPDivFactor)
insert into Titles values (3, dbo.Translate('Steward'), dbo.Translate('Stewardess'), '', 99,200/@TitleXPDivFactor)
insert into Titles values (4, dbo.Translate('Merchant'), dbo.Translate('Merchant'), '', 199,400/@TitleXPDivFactor)
insert into Titles values (5, dbo.Translate('Great Merchant'), dbo.Translate('Great Merchant'), '', 499,400/@TitleXPDivFactor)
insert into Titles values (6, dbo.Translate('Knight''s Squire'), dbo.Translate('Dame''s Maid'), '',999,400/@TitleXPDivFactor)
insert into Titles values (7, dbo.Translate('Knight'), dbo.Translate('Dame'), '',2499,400/@TitleXPDivFactor)
insert into Titles values (8, dbo.Translate('Grand Knight'), dbo.Translate('Grand Dame'), '', 4999,600/@TitleXPDivFactor)
insert into Titles values (9, dbo.Translate('Baronet'), dbo.Translate('Baronetess'), '',9999 ,600/@TitleXPDivFactor)
insert into Titles values (10, dbo.Translate('Baron'), dbo.Translate('Baroness'), '',19999,800/@TitleXPDivFactor)
insert into Titles values (11, dbo.Translate('Lord'), dbo.Translate('Lady'), '', 39999,1000/@TitleXPDivFactor)
insert into Titles values (12, dbo.Translate('Viscount'), dbo.Translate('Viscountess'), '', 59999,1200/@TitleXPDivFactor)
insert into Titles values (13, dbo.Translate('Count'), dbo.Translate('Countess'), '', 79999,1400/@TitleXPDivFactor)
insert into Titles values (14, dbo.Translate('Marquess'), dbo.Translate('Marchioness'), '', 99999,1600/@TitleXPDivFactor)
insert into Titles values (15, dbo.Translate('Duke'), dbo.Translate('Duchess'), '',124999,1800/@TitleXPDivFactor)
insert into Titles values (16, dbo.Translate('Grand Duke'), dbo.Translate('Grand Duchess'), '', 149999,2000/@TitleXPDivFactor)
insert into Titles values (17, dbo.Translate('Archduke'), dbo.Translate('Archduchess'), '', 199999,2200/@TitleXPDivFactor)
insert into Titles values (18, dbo.Translate('Prince'), dbo.Translate('Princess'), '', 299999,2600/@TitleXPDivFactor)
insert into Titles values (19, dbo.Translate('Crown Prince'), dbo.Translate('Crown Princess'), '', 499999,3600/@TitleXPDivFactor)
insert into Titles values (20, dbo.Translate('King'), dbo.Translate('Queen'), '', 699999,5600/@TitleXPDivFactor)
insert into Titles values (21, dbo.Translate('High King'), dbo.Translate('High Queen'), '', 999999,7600/@TitleXPDivFactor)
insert into Titles values (22, dbo.Translate('Emperor'), dbo.Translate('Empress'), '',1999999,9600/@TitleXPDivFactor)
insert into Titles values (23, dbo.Translate('Great Emperor'), dbo.Translate('Great Empress'), '', 4999999,11600/@TitleXPDivFactor)
insert into Titles values (24, dbo.Translate('Divine Emperor'), dbo.Translate('Divine Empress'), '', 9999999,19600/@TitleXPDivFactor)
insert into Titles values (25, dbo.Translate('Deity'), dbo.Translate('Deity'), '', 19999999,29600/@TitleXPDivFactor)
insert into Titles values (26, dbo.Translate('Supreme Deity'), dbo.Translate('Supreme Deity'), '', 49999999,39600/@TitleXPDivFactor)
insert into Titles values (27, dbo.Translate('RoE God'), dbo.Translate('RoE Goddess'), '',        999999999,49600/@TitleXPDivFactor)


--
--
--
--notification definitions
--
--
--
insert into NotificationSettings_Template ( NotificationID ,Vibrate ,SoundID,isActive, name, description) values (1,1,1,1,'New Mail', 'Notification informing you of a new mail in your ingame inbox')
insert into NotificationSettings_Template ( NotificationID ,Vibrate ,SoundID,isActive, name, description) values (2,1,1,1,'Incoming Attack', 'Notification informing you a new incoming attack to one of your villages')
IF @RealmEnvAccessLimitations <> 1 BEGIN -- if not mobile only access BEGIN
	insert into NotificationSettings_Template ( NotificationID ,Vibrate ,SoundID,isActive, name, description) values (3,1,1,1,'Incoming Attack - Steward', 'Notification informing you that the account you are stewarding is under attack.') -- NOTE - this one only on realms that have stewardship
END
insert into NotificationSettings_Template ( NotificationID ,Vibrate ,SoundID,isActive, name, description) values (4,1,1,1,'Building Upgrade Completed', 'Notification informing you of an upgrade completed - sent only when your building queue is idle')
insert into NotificationSettings_Template ( NotificationID ,Vibrate ,SoundID,isActive, name, description) values (5,1,1,1,'Research Completed', 'Notification informing you that research has completed and hence, there is an idle researcher')



--
-- POPULATE CORDS TABLE. 
--
truncate table  AvailableVillageCords

declare @xc int 
declare @yc int
declare @currentStep int

set @xc = @RealmSize
set @yc = @RealmSize
set @currentStep = @RealmSize
while (1=1) BEGIN   
	if not (@xc = 0 and @yc=0) BEGIN
		insert into AvailableVillageCords values (@xc, @yc, SQRT(power(abs(@xc),2) + power( abs(@yc),2)))  
	END
	if @xc = -@currentStep AND @yc = -@currentStep BEGIN 
		
		break;
	END ELSE IF @yc = -@currentStep BEGIN 
		SET @xc = @xc - 1
		SET @yc = @currentStep
	END ELSE BEGIN 
		SET @yc = @yc -1
	END
	
END

-- delete any cord that is taken by a landmark
DELETE A
FROM AvailableVillageCords A
	INNER JOIN landmarks L 
		on L.xcord = a.x and L.ycord = A.y
	JOIN LandmarkTypeParts LTP 
		on L.LandmarkTypePartID = LTP.LandmarkTypePartID 
	where AllowVillage is null or AllowVillage = 0
	  
--
-- Seed the new village Q
--
Declare @x as integer
Declare @y as integer
Declare @i int
declare @ms int 
declare @waitforduration varchar(11) 
declare @maxvillages int

IF @IsProductionRun =1 BEGIN	
	if  @RealmType = 'X' BEGIN
		set @maxvillages =  300
	END ELSE BEGIN
		set @maxvillages =  1000
	END
END ELSE BEGIN
	set @maxvillages =  50 
END

set @i = 0
WHILE @i < @maxvillages BEGIN
    exec  qGetCordinatesForNewVillage_Generate @x out,@y out
    insert into NewVillageQ (XCord, YCord) values (@X, @Y)
	delete AvailableVillageCords where x = @x and y = @y  -- this spot is taken, so remove it from availalbe spots
	set @i = @i + 1 

	set @ms = rand() * 100
	--print @ms
	set @waitforduration = '00:00:00:' + cast(@ms as varchar(max))
	--print @waitforduration 
	waitfor delay @waitforduration
END 
--delete newvillageq
--select * from newvillageQ





--
-- *************************************************************
-- Village Types
--	first we enter default types, then perhaps we overide it for some realm types
-- *************************************************************
--
EXEC _PopulateDB_BonusVillages @RealmType, @RealmSubType, @BonusVillageTypes


--
-- for noob realms, we tweek some levels etc to allow a quick first 45 min of play
--
IF @RealmType = 'NOOB' BEGIN 

	---SilverMine Timings
	update BuildingLevels set BuildTime = 300000000 where BuildingTypeID = @Building_CoinMineID and level = 1 --30s
	update BuildingLevels set BuildTime = 600000000 where BuildingTypeID = @Building_CoinMineID and level = 2 --60s
	update BuildingLevels set BuildTime = 450000000 where BuildingTypeID = @Building_CoinMineID and level = 3 --30s
	update BuildingLevels set BuildTime = 450000000 where BuildingTypeID = @Building_CoinMineID and level = 4 --45s
	update BuildingLevels set BuildTime = 600000000 where BuildingTypeID = @Building_CoinMineID and level = 5 --1m
	update BuildingLevels set BuildTime = 720000000 where BuildingTypeID = @Building_CoinMineID and level = 6 --1m:12s
	update BuildingLevels set BuildTime = 750000000 where BuildingTypeID = @Building_CoinMineID and level = 7 --1m:15s
	update BuildingLevels set BuildTime = 780000000 where BuildingTypeID = @Building_CoinMineID and level = 8 --1m:18s
	update BuildingLevels set BuildTime = 810000000 where BuildingTypeID = @Building_CoinMineID and level = 9 --1m:21s
	update BuildingLevels set BuildTime = 840000000 where BuildingTypeID = @Building_CoinMineID and level = 10 --1m:24s
	update BuildingLevels set BuildTime = 870000000 where BuildingTypeID = @Building_CoinMineID and level = 11 --1m:27s
	update BuildingLevels set BuildTime = 900000000 where BuildingTypeID = @Building_CoinMineID and level = 12 --1m:30s
	update BuildingLevels set BuildTime = 960000000 where BuildingTypeID = @Building_CoinMineID and level = 13 --1m:36s
	update BuildingLevels set BuildTime = 1020000000 where BuildingTypeID = @Building_CoinMineID and level = 14 --1m:42s
	update BuildingLevels set BuildTime = 1080000000 where BuildingTypeID = @Building_CoinMineID and level = 15 --1m:48s
	update BuildingLevels set BuildTime = 1200000000 where BuildingTypeID = @Building_CoinMineID and level = 16 --2m:0s
	update BuildingLevels set BuildTime = 1320000000 where BuildingTypeID = @Building_CoinMineID and level = 17 --2m:12s
	update BuildingLevels set BuildTime = 1500000000 where BuildingTypeID = @Building_CoinMineID and level = 18 --2m:30s
	update BuildingLevels set BuildTime = 1800000000 where BuildingTypeID = @Building_CoinMineID and level = 19 --3m:0s
	update BuildingLevels set BuildTime = 3000000000 where BuildingTypeID = @Building_CoinMineID and level = 20 --5m:0s
	update BuildingLevels set BuildTime = 9000000000 where BuildingTypeID = @Building_CoinMineID and level = 21 --15m:0s
	update BuildingLevels set BuildTime = 18000000000 where BuildingTypeID = @Building_CoinMineID and level = 22 --30m
	
	update BuildingLevels set BuildTime = 36000000000 where BuildingTypeID = @Building_CoinMineID and level = 23 --1h
	update BuildingLevels set BuildTime = 72000000000 where BuildingTypeID = @Building_CoinMineID and level = 24 --2h
	update BuildingLevels set BuildTime = 144000000000 where BuildingTypeID = @Building_CoinMineID and level = 25 --4h
	update BuildingLevels set BuildTime = 216000000000 where BuildingTypeID = @Building_CoinMineID and level = 26 --6h
	update BuildingLevels set BuildTime = 288000000000 where BuildingTypeID = @Building_CoinMineID and level = 27 --8h
	update BuildingLevels set BuildTime = 360000000000 where BuildingTypeID = @Building_CoinMineID and level = 28 --10h
	update BuildingLevels set BuildTime = 432000000000 where BuildingTypeID = @Building_CoinMineID and level = 29 --12h
	update BuildingLevels set BuildTime = 504000000000 where BuildingTypeID = @Building_CoinMineID and level = 30 --14h
	update BuildingLevels set BuildTime = 576000000000 where BuildingTypeID = @Building_CoinMineID and level = 31 --16h
	update BuildingLevels set BuildTime = 648000000000 where BuildingTypeID = @Building_CoinMineID and level = 32 --18h
	update BuildingLevels set BuildTime = 720000000000 where BuildingTypeID = @Building_CoinMineID and level = 33 --20h
	update BuildingLevels set BuildTime = 792000000000 where BuildingTypeID = @Building_CoinMineID and level = 34 --22h
	update BuildingLevels set BuildTime = 864000000000 where BuildingTypeID = @Building_CoinMineID and level = 35 --24h
	update BuildingLevels set BuildTime = 936000000000 where BuildingTypeID = @Building_CoinMineID and level = 36 --26h
	update BuildingLevels set BuildTime = 1008000000000 where BuildingTypeID = @Building_CoinMineID and level = 37 --28h
	update BuildingLevels set BuildTime = 1152000000000 where BuildingTypeID = @Building_CoinMineID and level = 38 --32h
	update BuildingLevels set BuildTime = 1296000000000 where BuildingTypeID = @Building_CoinMineID and level = 39 --36h
	update BuildingLevels set BuildTime = 1512000000000 where BuildingTypeID = @Building_CoinMineID and level = 40 --42h
	update BuildingLevels set BuildTime = 1728000000000 where BuildingTypeID = @Building_CoinMineID and level = 41 --48h
	update BuildingLevels set BuildTime = 1944000000000 where BuildingTypeID = @Building_CoinMineID and level = 42 --54h
	update BuildingLevels set BuildTime = 2160000000000 where BuildingTypeID = @Building_CoinMineID and level = 43 --60h
	update BuildingLevels set BuildTime = 2376000000000 where BuildingTypeID = @Building_CoinMineID and level = 44 --66h
	update BuildingLevels set BuildTime = 2592000000000 where BuildingTypeID = @Building_CoinMineID and level = 45 --72h
	

	--HQ Timings
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_HQID and level = 1 --40s
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_HQID and level = 2 --40s
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_HQID and level = 3 --40s
	update BuildingLevels set BuildTime = 520000000 where BuildingTypeID = @Building_HQID and level = 4 --52s
	update BuildingLevels set BuildTime = 640000000 where BuildingTypeID = @Building_HQID and level = 5 --1m:4s
	update BuildingLevels set BuildTime = 720000000 where BuildingTypeID = @Building_HQID and level = 6 --1m:12s
	update BuildingLevels set BuildTime = 780000000 where BuildingTypeID = @Building_HQID and level = 7 --1m:18s
	update BuildingLevels set BuildTime = 840000000 where BuildingTypeID = @Building_HQID and level = 8 --1m:24s
	update BuildingLevels set BuildTime = 900000000 where BuildingTypeID = @Building_HQID and level = 9 --1m:30s
	update BuildingLevels set BuildTime = 960000000 where BuildingTypeID = @Building_HQID and level = 10 --1m:36s
	update BuildingLevels set BuildTime = 1050000000 where BuildingTypeID = @Building_HQID and level = 11 --1m:45s
	update BuildingLevels set BuildTime = 1200000000 where BuildingTypeID = @Building_HQID and level = 12 --2m:0s
	update BuildingLevels set BuildTime = 3000000000 where BuildingTypeID = @Building_HQID and level = 13 --5m:0s
	update BuildingLevels set BuildTime = 6000000000 where BuildingTypeID = @Building_HQID and level = 14 --10m:0s
	update BuildingLevels set BuildTime = 9000000000 where BuildingTypeID = @Building_HQID and level = 15 --15m:0s
	
	update BuildingLevels set BuildTime = 36000000000 where BuildingTypeID = @Building_HQID and level = 16 --1h:00m
	update BuildingLevels set BuildTime = 72000000000 where BuildingTypeID = @Building_HQID and level = 17 --2h:00m
	update BuildingLevels set BuildTime = 144000000000 where BuildingTypeID = @Building_HQID and level = 18 --4h:00m
	update BuildingLevels set BuildTime = 216000000000 where BuildingTypeID = @Building_HQID and level = 19 --6h:00m
	update BuildingLevels set BuildTime = 288000000000 where BuildingTypeID = @Building_HQID and level = 20 --8h:0m
	update BuildingLevels set BuildTime = 360000000000 where BuildingTypeID = @Building_HQID and level = 21 --10h:0m
	update BuildingLevels set BuildTime = 432000000000 where BuildingTypeID = @Building_HQID and level = 22 --12h:0m
	update BuildingLevels set BuildTime = 540000000000 where BuildingTypeID = @Building_HQID and level = 23 --15h:0m
	update BuildingLevels set BuildTime = 648000000000 where BuildingTypeID = @Building_HQID and level = 24 --18h:0m
	update BuildingLevels set BuildTime = 720000000000 where BuildingTypeID = @Building_HQID and level = 25 --20h:0m
	

	--Farm Timings
	update BuildingLevels set BuildTime = 450000000 where BuildingTypeID = @Building_FarmLandID and level = 1 --45s
	update BuildingLevels set BuildTime = 450000000 where BuildingTypeID = @Building_FarmLandID and level = 2 --45s
	update BuildingLevels set BuildTime = 450000000 where BuildingTypeID = @Building_FarmLandID and level = 3 --45s
	update BuildingLevels set BuildTime = 600000000 where BuildingTypeID = @Building_FarmLandID and level = 4 --1m
	update BuildingLevels set BuildTime = 720000000 where BuildingTypeID = @Building_FarmLandID and level = 5 --1m:12s
	update BuildingLevels set BuildTime = 780000000 where BuildingTypeID = @Building_FarmLandID and level = 6 --1m:18s
	update BuildingLevels set BuildTime = 840000000 where BuildingTypeID = @Building_FarmLandID and level = 7 --1m:24s
	update BuildingLevels set BuildTime = 900000000 where BuildingTypeID = @Building_FarmLandID and level = 8 --1m:30s
	update BuildingLevels set BuildTime = 960000000 where BuildingTypeID = @Building_FarmLandID and level = 9 --1m:36s
	update BuildingLevels set BuildTime = 1200000000 where BuildingTypeID = @Building_FarmLandID and level = 10 --2m:0s
	update BuildingLevels set BuildTime = 2400000000 where BuildingTypeID = @Building_FarmLandID and level = 11 --4m:0s
	update BuildingLevels set BuildTime = 3600000000 where BuildingTypeID = @Building_FarmLandID and level = 12 --6m:0s
	
	update BuildingLevels set BuildTime = 4800000000 where BuildingTypeID = @Building_FarmLandID and level = 13 --00:08:00
	update BuildingLevels set BuildTime = 6000000000 where BuildingTypeID = @Building_FarmLandID and level = 14 --00:10:00
	update BuildingLevels set BuildTime = 7200000000 where BuildingTypeID = @Building_FarmLandID and level = 15 --00:12:00
	update BuildingLevels set BuildTime = 9000000000 where BuildingTypeID = @Building_FarmLandID and level = 16 --00:15:00
	update BuildingLevels set BuildTime = 12000000000 where BuildingTypeID = @Building_FarmLandID and level = 17 --00:20:00
	update BuildingLevels set BuildTime = 18000000000 where BuildingTypeID = @Building_FarmLandID and level = 18 --00:30:00
	update BuildingLevels set BuildTime = 27000000000 where BuildingTypeID = @Building_FarmLandID and level = 19 --00:45:00
	update BuildingLevels set BuildTime = 36000000000 where BuildingTypeID = @Building_FarmLandID and level = 20 --01:00:00
	update BuildingLevels set BuildTime = 54000000000 where BuildingTypeID = @Building_FarmLandID and level = 21 --01:30:00
	update BuildingLevels set BuildTime = 72000000000 where BuildingTypeID = @Building_FarmLandID and level = 22 --02:00:00
	update BuildingLevels set BuildTime = 90000000000 where BuildingTypeID = @Building_FarmLandID and level = 23 --02:30:00
	update BuildingLevels set BuildTime = 108000000000 where BuildingTypeID = @Building_FarmLandID and level = 24 --03:00:00
	update BuildingLevels set BuildTime = 126000000000 where BuildingTypeID = @Building_FarmLandID and level = 25 --03:30:00
	update BuildingLevels set BuildTime = 144000000000 where BuildingTypeID = @Building_FarmLandID and level = 26 --04:00:00
	update BuildingLevels set BuildTime = 180000000000 where BuildingTypeID = @Building_FarmLandID and level = 27 --05:00:00
	update BuildingLevels set BuildTime = 216000000000 where BuildingTypeID = @Building_FarmLandID and level = 28 --06:00:00
	update BuildingLevels set BuildTime = 288000000000 where BuildingTypeID = @Building_FarmLandID and level = 29 --08:00:00
	update BuildingLevels set BuildTime = 360000000000 where BuildingTypeID = @Building_FarmLandID and level = 30 --010:00:00
	

	--Barracks Timings
	update BuildingLevels set BuildTime = 780000000 where BuildingTypeID = @Building_BarracksID and level = 1 --1m:18s
	update BuildingLevels set BuildTime = 810000000 where BuildingTypeID = @Building_BarracksID and level = 2 --1m:21s
	update BuildingLevels set BuildTime = 840000000 where BuildingTypeID = @Building_BarracksID and level = 3 --1m:24s
	update BuildingLevels set BuildTime = 870000000 where BuildingTypeID = @Building_BarracksID and level = 4 --1m:27s
	update BuildingLevels set BuildTime = 1020000000 where BuildingTypeID = @Building_BarracksID and level = 5 --1m:42s
	update BuildingLevels set BuildTime = 1140000000 where BuildingTypeID = @Building_BarracksID and level = 6 --1m:54s
	update BuildingLevels set BuildTime = 1260000000 where BuildingTypeID = @Building_BarracksID and level = 7 --2m:6s
	update BuildingLevels set BuildTime = 1800000000 where BuildingTypeID = @Building_BarracksID and level = 8 --3m:0s
	update BuildingLevels set BuildTime = 3000000000 where BuildingTypeID = @Building_BarracksID and level = 9 --5m:0s
	update BuildingLevels set BuildTime = 9000000000 where BuildingTypeID = @Building_BarracksID and level = 10 --15m:0s
	
	update BuildingLevels set BuildTime = 18000000000 where BuildingTypeID = @Building_BarracksID and level = 11 --30m:0s
	update BuildingLevels set BuildTime = 36000000000 where BuildingTypeID = @Building_BarracksID and level = 12 --1h:0m
	update BuildingLevels set BuildTime = 72000000000 where BuildingTypeID = @Building_BarracksID and level = 13 --2h:0m
	update BuildingLevels set BuildTime = 144000000000 where BuildingTypeID = @Building_BarracksID and level = 14 --4h:0m
	update BuildingLevels set BuildTime = 216000000000 where BuildingTypeID = @Building_BarracksID and level = 15 --6h:0m
	update BuildingLevels set BuildTime = 360000000000 where BuildingTypeID = @Building_BarracksID and level = 16 --10h:0m
	update BuildingLevels set BuildTime = 504000000000 where BuildingTypeID = @Building_BarracksID and level = 17 --14h:0m
	update BuildingLevels set BuildTime = 648000000000 where BuildingTypeID = @Building_BarracksID and level = 18 --18h:0m
	update BuildingLevels set BuildTime = 792000000000 where BuildingTypeID = @Building_BarracksID and level = 19 --22h:0m
	update BuildingLevels set BuildTime = 936000000000 where BuildingTypeID = @Building_BarracksID and level = 20 --26h:0m
	update BuildingLevels set BuildTime = 1080000000000 where BuildingTypeID = @Building_BarracksID and level = 21 --30h:0m
	update BuildingLevels set BuildTime = 1296000000000 where BuildingTypeID = @Building_BarracksID and level = 22 --36h:0m
	update BuildingLevels set BuildTime = 1728000000000 where BuildingTypeID = @Building_BarracksID and level = 23 --48h:0m
	update BuildingLevels set BuildTime = 2160000000000 where BuildingTypeID = @Building_BarracksID and level = 24 --60h:0m
	update BuildingLevels set BuildTime = 2592000000000 where BuildingTypeID = @Building_BarracksID and level = 25 --72h:0m
	

	--Stables Timing
	update BuildingLevels set BuildTime = 1200000000 where BuildingTypeID = @Building_StableID and level = 1 --2m:00s
	update BuildingLevels set BuildTime = 1500000000 where BuildingTypeID = @Building_StableID and level = 2 --2m:30s
	update BuildingLevels set BuildTime = 1800000000 where BuildingTypeID = @Building_StableID and level = 3 --3m:0s
	update BuildingLevels set BuildTime = 2400000000 where BuildingTypeID = @Building_StableID and level = 4 --4m:0s
	update BuildingLevels set BuildTime = 3000000000 where BuildingTypeID = @Building_StableID and level = 5 --5m:0s
	update BuildingLevels set BuildTime = 6000000000 where BuildingTypeID = @Building_StableID and level = 6 --10m:0s
	update BuildingLevels set BuildTime = 12000000000 where BuildingTypeID = @Building_StableID and level = 7 --20m:0s
	update BuildingLevels set BuildTime = 27000000000 where BuildingTypeID = @Building_StableID and level = 8 --45m:0s
	update BuildingLevels set BuildTime = 36000000000 where BuildingTypeID = @Building_StableID and level = 9 --1h:0m
	update BuildingLevels set BuildTime = 72000000000 where BuildingTypeID = @Building_StableID and level = 10 --2h:0m
	
	update BuildingLevels set BuildTime = 144000000000 where BuildingTypeID = @Building_StableID and level = 11 --4h:0m
	update BuildingLevels set BuildTime = 288000000000 where BuildingTypeID = @Building_StableID and level = 12 --8h:0m
	update BuildingLevels set BuildTime = 360000000000 where BuildingTypeID = @Building_StableID and level = 13 --10h:0m
	update BuildingLevels set BuildTime = 432000000000 where BuildingTypeID = @Building_StableID and level = 14 --12h:0m
	update BuildingLevels set BuildTime = 504000000000 where BuildingTypeID = @Building_StableID and level = 15 --14h:0m
	update BuildingLevels set BuildTime = 576000000000 where BuildingTypeID = @Building_StableID and level = 16 --16h:0m
	update BuildingLevels set BuildTime = 720000000000 where BuildingTypeID = @Building_StableID and level = 17 --20h:0m
	update BuildingLevels set BuildTime = 864000000000 where BuildingTypeID = @Building_StableID and level = 18 --24h:0m
	update BuildingLevels set BuildTime = 1080000000000 where BuildingTypeID = @Building_StableID and level = 19 --30h:0m
	update BuildingLevels set BuildTime = 1296000000000 where BuildingTypeID = @Building_StableID and level = 20 --36h:0m
	update BuildingLevels set BuildTime = 1512000000000 where BuildingTypeID = @Building_StableID and level = 21 --42h:0m
	update BuildingLevels set BuildTime = 1800000000000 where BuildingTypeID = @Building_StableID and level = 22 --50h:0m
	update BuildingLevels set BuildTime = 2160000000000 where BuildingTypeID = @Building_StableID and level = 23 --60h:0m
	update BuildingLevels set BuildTime = 2880000000000 where BuildingTypeID = @Building_StableID and level = 24 --80h:0m
	update BuildingLevels set BuildTime = 3240000000000 where BuildingTypeID = @Building_StableID and level = 25 --90h:0m
	

	--Treasury Timing
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_TreasuryID and level = 1 --40s
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_TreasuryID and level = 2 --40s
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_TreasuryID and level = 3 --40s
	update BuildingLevels set BuildTime = 500000000 where BuildingTypeID = @Building_TreasuryID and level = 4 --50s
	update BuildingLevels set BuildTime = 600000000 where BuildingTypeID = @Building_TreasuryID and level = 5 --60s
	update BuildingLevels set BuildTime = 700000000 where BuildingTypeID = @Building_TreasuryID and level = 6 --1m:10s
	update BuildingLevels set BuildTime = 780000000 where BuildingTypeID = @Building_TreasuryID and level = 7 --1m:18s
	update BuildingLevels set BuildTime = 840000000 where BuildingTypeID = @Building_TreasuryID and level = 8 --1m:24s
	update BuildingLevels set BuildTime = 900000000 where BuildingTypeID = @Building_TreasuryID and level = 9 --1m:30s
	update BuildingLevels set BuildTime = 960000000 where BuildingTypeID = @Building_TreasuryID and level = 10 --1m:36s
	update BuildingLevels set BuildTime = 1020000000 where BuildingTypeID = @Building_TreasuryID and level = 11 --1m:42s
	update BuildingLevels set BuildTime = 1080000000 where BuildingTypeID = @Building_TreasuryID and level = 12 --1m:48s
	update BuildingLevels set BuildTime = 1200000000 where BuildingTypeID = @Building_TreasuryID and level = 13 --2m:0s
	update BuildingLevels set BuildTime = 2400000000 where BuildingTypeID = @Building_TreasuryID and level = 14 --4m:0s
	update BuildingLevels set BuildTime = 3600000000 where BuildingTypeID = @Building_TreasuryID and level = 15 --6m:0s
	
	update BuildingLevels set BuildTime = 6000000000 where BuildingTypeID = @Building_TreasuryID and level = 16 --10m:0s
	update BuildingLevels set BuildTime = 18000000000 where BuildingTypeID = @Building_TreasuryID and level = 17 --30m:0s
	update BuildingLevels set BuildTime = 36000000000 where BuildingTypeID = @Building_TreasuryID and level = 18 --1h:0m
	update BuildingLevels set BuildTime = 72000000000 where BuildingTypeID = @Building_TreasuryID and level = 19 --2h:0m
	update BuildingLevels set BuildTime = 144000000000 where BuildingTypeID = @Building_TreasuryID and level = 20 --4h:0m
	update BuildingLevels set BuildTime = 288000000000 where BuildingTypeID = @Building_TreasuryID and level = 21 --8h:0m
	update BuildingLevels set BuildTime = 432000000000 where BuildingTypeID = @Building_TreasuryID and level = 22 --12h:0m
	update BuildingLevels set BuildTime = 576000000000 where BuildingTypeID = @Building_TreasuryID and level = 23 --16h:0m
	update BuildingLevels set BuildTime = 720000000000 where BuildingTypeID = @Building_TreasuryID and level = 24 --20h:0m
	update BuildingLevels set BuildTime = 864000000000 where BuildingTypeID = @Building_TreasuryID and level = 25 --24h:0m
	update BuildingLevels set BuildTime = 1080000000000 where BuildingTypeID = @Building_TreasuryID and level = 26 --30h:0m
	update BuildingLevels set BuildTime = 1296000000000 where BuildingTypeID = @Building_TreasuryID and level = 27 --36h:0m
	update BuildingLevels set BuildTime = 1728000000000 where BuildingTypeID = @Building_TreasuryID and level = 28 --48h:0m
	update BuildingLevels set BuildTime = 2160000000000 where BuildingTypeID = @Building_TreasuryID and level = 29 --60h:0m
	update BuildingLevels set BuildTime = 2592000000000 where BuildingTypeID = @Building_TreasuryID and level = 30 --72h:0m
	

	--Tavern Timing
	update BuildingLevels set BuildTime = 6000000000 where BuildingTypeID = @Building_TavernID and level = 1 --10m:0s
	update BuildingLevels set BuildTime = 30000000000 where BuildingTypeID = @Building_TavernID and level = 2 --30m:0s
	
	update BuildingLevels set BuildTime = 72000000000 where BuildingTypeID = @Building_TavernID and level = 3 --2h:0m
	update BuildingLevels set BuildTime = 360000000000 where BuildingTypeID = @Building_TavernID and level = 4 --6h:0m
	update BuildingLevels set BuildTime = 432000000000 where BuildingTypeID = @Building_TavernID and level = 5 --12h:0m
	

	--Siege Workshop Timing
	
	update BuildingLevels set BuildTime = 6000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 1 --10m:0s
	update BuildingLevels set BuildTime = 12000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 2 --20m:0s
	update BuildingLevels set BuildTime = 18000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 3 --30m:0s
	update BuildingLevels set BuildTime = 24000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 4 --40m:0s
	update BuildingLevels set BuildTime = 30000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 5 --50m:0s
	update BuildingLevels set BuildTime = 36000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 6 --1h:0m
	update BuildingLevels set BuildTime = 72000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 7 --2h:0m
	update BuildingLevels set BuildTime = 144000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 8 --4h:0m
	update BuildingLevels set BuildTime = 216000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 9 --6h:0m
	update BuildingLevels set BuildTime = 288000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 10 --8h:0m
	update BuildingLevels set BuildTime = 360000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 11 --10h:0m
	update BuildingLevels set BuildTime = 432000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 12 --12h:0m
	update BuildingLevels set BuildTime = 576000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 13 --16h:0m
	update BuildingLevels set BuildTime = 720000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 14 --20h:0m
	update BuildingLevels set BuildTime = 864000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 15 --24h:0m
	update BuildingLevels set BuildTime = 1008000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 16 --28h:0m
	update BuildingLevels set BuildTime = 1152000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 17 --32h:0m
	update BuildingLevels set BuildTime = 1296000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 18 --36h:0m
	update BuildingLevels set BuildTime = 1440000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 19 --40h:0m
	update BuildingLevels set BuildTime = 1584000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 20 --44h:0m
	update BuildingLevels set BuildTime = 1728000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 21 --48h:0m
	update BuildingLevels set BuildTime = 1872000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 22 --52h:0m
	update BuildingLevels set BuildTime = 2232000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 23 --62h:0m
	update BuildingLevels set BuildTime = 3060000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 24 --85h:0m
	update BuildingLevels set BuildTime = 3600000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 25 --100h:0m
	

	--TradingPost Timing
	
	update BuildingLevels set BuildTime = 6000000000 where BuildingTypeID = @Building_TradingPostID and level = 1 --10m:0s
	update BuildingLevels set BuildTime = 12000000000 where BuildingTypeID = @Building_TradingPostID and level = 2 --20m:0s
	update BuildingLevels set BuildTime = 18000000000 where BuildingTypeID = @Building_TradingPostID and level = 3 --30m:0s
	update BuildingLevels set BuildTime = 36000000000 where BuildingTypeID = @Building_TradingPostID and level = 4 --1h:0m
	update BuildingLevels set BuildTime = 54000000000 where BuildingTypeID = @Building_TradingPostID and level = 5 --1h:30m
	update BuildingLevels set BuildTime = 72000000000 where BuildingTypeID = @Building_TradingPostID and level = 6 --2h:0m
	update BuildingLevels set BuildTime = 90000000000 where BuildingTypeID = @Building_TradingPostID and level = 7 --2h:30m
	update BuildingLevels set BuildTime = 108000000000 where BuildingTypeID = @Building_TradingPostID and level = 8 --3h:0m
	update BuildingLevels set BuildTime = 126000000000 where BuildingTypeID = @Building_TradingPostID and level = 9 --3h:30m
	update BuildingLevels set BuildTime = 144000000000 where BuildingTypeID = @Building_TradingPostID and level = 10 --4h:00m
	update BuildingLevels set BuildTime = 180000000000 where BuildingTypeID = @Building_TradingPostID and level = 11 --5h:0m
	update BuildingLevels set BuildTime = 216000000000 where BuildingTypeID = @Building_TradingPostID and level = 12 --6h:0m
	update BuildingLevels set BuildTime = 288000000000 where BuildingTypeID = @Building_TradingPostID and level = 13 --8h:0m
	update BuildingLevels set BuildTime = 360000000000 where BuildingTypeID = @Building_TradingPostID and level = 14 --10h:0m
	update BuildingLevels set BuildTime = 432000000000 where BuildingTypeID = @Building_TradingPostID and level = 15 --12h:0m
	update BuildingLevels set BuildTime = 540000000000 where BuildingTypeID = @Building_TradingPostID and level = 16 --15h:0m
	update BuildingLevels set BuildTime = 648000000000 where BuildingTypeID = @Building_TradingPostID and level = 17 --18h:0m
	update BuildingLevels set BuildTime = 540000000000 where BuildingTypeID = @Building_TradingPostID and level = 18 --15h:0m
	update BuildingLevels set BuildTime = 648000000000 where BuildingTypeID = @Building_TradingPostID and level = 19 --18h:0m
	update BuildingLevels set BuildTime = 756000000000 where BuildingTypeID = @Building_TradingPostID and level = 20 --21h:0m
	update BuildingLevels set BuildTime = 864000000000 where BuildingTypeID = @Building_TradingPostID and level = 21 --24h:0m
	update BuildingLevels set BuildTime = 1080000000000 where BuildingTypeID = @Building_TradingPostID and level = 22 --30h:0m
	update BuildingLevels set BuildTime = 1440000000000 where BuildingTypeID = @Building_TradingPostID and level = 23 --40h:0m
	update BuildingLevels set BuildTime = 1800000000000 where BuildingTypeID = @Building_TradingPostID and level = 24 --50h:0m
	update BuildingLevels set BuildTime = 2160000000000 where BuildingTypeID = @Building_TradingPostID and level = 25 --60h:0m
	
	--Walls Timing
	
	update BuildingLevels set BuildTime = 9000000000 where BuildingTypeID = @Building_WallID and level = 1 --15m:0s
	update BuildingLevels set BuildTime = 36000000000 where BuildingTypeID = @Building_WallID and level = 2 --1h:0m
	update BuildingLevels set BuildTime = 72000000000 where BuildingTypeID = @Building_WallID and level = 3 --2h:0m
	update BuildingLevels set BuildTime = 144000000000 where BuildingTypeID = @Building_WallID and level = 4 --4h:0m
	update BuildingLevels set BuildTime = 216000000000 where BuildingTypeID = @Building_WallID and level = 5 --6h:0m
	update BuildingLevels set BuildTime = 288000000000 where BuildingTypeID = @Building_WallID and level = 6 --8h:0m
	update BuildingLevels set BuildTime = 432000000000 where BuildingTypeID = @Building_WallID and level = 7 --12h:0m
	update BuildingLevels set BuildTime = 648000000000 where BuildingTypeID = @Building_WallID and level = 8 --18h:0m
	update BuildingLevels set BuildTime = 864000000000 where BuildingTypeID = @Building_WallID and level = 9 --24h:0m
	update BuildingLevels set BuildTime = 1296000000000 where BuildingTypeID = @Building_WallID and level = 10 --36h:0m
	

END 

--
-- for MC  realms, we tweek some early levels
--
ELSE IF @RealmType = 'MC' OR @RealmType = 'HC' BEGIN 

	---SilverMine Timings
	update BuildingLevels set BuildTime = 300000000 where BuildingTypeID = @Building_CoinMineID and level = 1 --30s
	update BuildingLevels set BuildTime = 600000000 where BuildingTypeID = @Building_CoinMineID and level = 2 --60s
	update BuildingLevels set BuildTime = 450000000 where BuildingTypeID = @Building_CoinMineID and level = 3 --30s
	update BuildingLevels set BuildTime = 450000000 where BuildingTypeID = @Building_CoinMineID and level = 4 --45s
	update BuildingLevels set BuildTime = 600000000 where BuildingTypeID = @Building_CoinMineID and level = 5 --1m
	update BuildingLevels set BuildTime = 720000000 where BuildingTypeID = @Building_CoinMineID and level = 6 --1m:12s
	update BuildingLevels set BuildTime = 750000000 where BuildingTypeID = @Building_CoinMineID and level = 7 --1m:15s
	update BuildingLevels set BuildTime = 780000000 where BuildingTypeID = @Building_CoinMineID and level = 8 --1m:18s
	update BuildingLevels set BuildTime = 810000000 where BuildingTypeID = @Building_CoinMineID and level = 9 --1m:21s
	update BuildingLevels set BuildTime = 840000000 where BuildingTypeID = @Building_CoinMineID and level = 10 --1m:24s
	

	--HQ Timings
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_HQID and level = 1 --40s
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_HQID and level = 2 --40s
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_HQID and level = 3 --40s
	update BuildingLevels set BuildTime = 520000000 where BuildingTypeID = @Building_HQID and level = 4 --52s
	update BuildingLevels set BuildTime = 640000000 where BuildingTypeID = @Building_HQID and level = 5 --1m:4s

	--Farm Timings
	update BuildingLevels set BuildTime = 450000000 where BuildingTypeID = @Building_FarmLandID and level = 1 --45s
	update BuildingLevels set BuildTime = 450000000 where BuildingTypeID = @Building_FarmLandID and level = 2 --45s
	update BuildingLevels set BuildTime = 450000000 where BuildingTypeID = @Building_FarmLandID and level = 3 --45s
	update BuildingLevels set BuildTime = 600000000 where BuildingTypeID = @Building_FarmLandID and level = 4 --1m
	update BuildingLevels set BuildTime = 720000000 where BuildingTypeID = @Building_FarmLandID and level = 5 --1m:12s

	--Barracks Timings
	update BuildingLevels set BuildTime = 780000000 where BuildingTypeID = @Building_BarracksID and level = 1 --1m:18s
	update BuildingLevels set BuildTime = 810000000 where BuildingTypeID = @Building_BarracksID and level = 2 --1m:21s
	update BuildingLevels set BuildTime = 840000000 where BuildingTypeID = @Building_BarracksID and level = 3 --1m:24s
	update BuildingLevels set BuildTime = 870000000 where BuildingTypeID = @Building_BarracksID and level = 4 --1m:27s
	update BuildingLevels set BuildTime = 1020000000 where BuildingTypeID = @Building_BarracksID and level = 5 --1m:42s

	--Stables Timing
	update BuildingLevels set BuildTime = 1200000000 where BuildingTypeID = @Building_StableID and level = 1 --2m:00s
	update BuildingLevels set BuildTime = 1500000000 where BuildingTypeID = @Building_StableID and level = 2 --2m:30s
	update BuildingLevels set BuildTime = 1800000000 where BuildingTypeID = @Building_StableID and level = 3 --3m:0s
	update BuildingLevels set BuildTime = 2400000000 where BuildingTypeID = @Building_StableID and level = 4 --4m:0s
	update BuildingLevels set BuildTime = 3000000000 where BuildingTypeID = @Building_StableID and level = 5 --5m:0s
	

	--Treasury Timing
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_TreasuryID and level = 1 --40s
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_TreasuryID and level = 2 --40s
	update BuildingLevels set BuildTime = 400000000 where BuildingTypeID = @Building_TreasuryID and level = 3 --40s
	update BuildingLevels set BuildTime = 500000000 where BuildingTypeID = @Building_TreasuryID and level = 4 --50s
	update BuildingLevels set BuildTime = 600000000 where BuildingTypeID = @Building_TreasuryID and level = 5 --60s

	--Tavern Timing
	update BuildingLevels set BuildTime = 6000000000 where BuildingTypeID = @Building_TavernID and level = 1 --10m:0s
	

	--Siege Workshop Timing
	
	update BuildingLevels set BuildTime = 6000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 1 --10m:0s
	update BuildingLevels set BuildTime = 12000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 2 --20m:0s
	update BuildingLevels set BuildTime = 18000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 3 --30m:0s
	update BuildingLevels set BuildTime = 24000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 4 --40m:0s
	update BuildingLevels set BuildTime = 30000000000 where BuildingTypeID = @Building_SiegeWorkshopID and level = 5 --50m:0s

	--TradingPost Timing	
	update BuildingLevels set BuildTime = 6000000000 where BuildingTypeID = @Building_TradingPostID and level = 1 --10m:0s
	update BuildingLevels set BuildTime = 12000000000 where BuildingTypeID = @Building_TradingPostID and level = 2 --20m:0s
	update BuildingLevels set BuildTime = 18000000000 where BuildingTypeID = @Building_TradingPostID and level = 3 --30m:0s
	update BuildingLevels set BuildTime = 36000000000 where BuildingTypeID = @Building_TradingPostID and level = 4 --1h:0m
	--Walls Timing
	
	update BuildingLevels set BuildTime = 9000000000 where BuildingTypeID = @Building_WallID and level = 1 --15m:0s
END 


delete CreditFarm_TodaysChance 
insert into CreditFarm_TodaysChance values (1, 1)
insert into CreditFarm_TodaysChance values (2, 1)
insert into CreditFarm_TodaysChance values (3, 1)
insert into CreditFarm_TodaysChance values (4, 1)
insert into CreditFarm_TodaysChance values (5, 0.91)
insert into CreditFarm_TodaysChance values (6, 0.82)
insert into CreditFarm_TodaysChance values (7, 0.73)
insert into CreditFarm_TodaysChance values (8, 0.64)
insert into CreditFarm_TodaysChance values (9, 0.55)
insert into CreditFarm_TodaysChance values (10, 0.46)
insert into CreditFarm_TodaysChance values (11, 0.4525)
insert into CreditFarm_TodaysChance values (12, 0.43)
insert into CreditFarm_TodaysChance values (13, 0.4075)
insert into CreditFarm_TodaysChance values (14, 0.385)
insert into CreditFarm_TodaysChance values (15, 0.3625)
insert into CreditFarm_TodaysChance values (16, 0.34)
insert into CreditFarm_TodaysChance values (17, 0.3175)
insert into CreditFarm_TodaysChance values (18, 0.295)
insert into CreditFarm_TodaysChance values (19, 0.2725)
insert into CreditFarm_TodaysChance values (20, 0.25)
insert into CreditFarm_TodaysChance values (21, 0.248)
insert into CreditFarm_TodaysChance values (22, 0.236)
insert into CreditFarm_TodaysChance values (23, 0.224)
insert into CreditFarm_TodaysChance values (24, 0.212)
insert into CreditFarm_TodaysChance values (25, 0.2)
insert into CreditFarm_TodaysChance values (26, 0.1429)
insert into CreditFarm_TodaysChance values (27, 0.1429)
insert into CreditFarm_TodaysChance values (28, 0.1429)
insert into CreditFarm_TodaysChance values (29, 0.1429)
insert into CreditFarm_TodaysChance values (30, 0.1429)
insert into CreditFarm_TodaysChance values (31, 0.02)


EXEC _PopulateDB_Morale @Morale

EXEC _PopulateDB_Raids