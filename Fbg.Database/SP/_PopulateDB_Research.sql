IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = '_PopulateDB_Research')
BEGIN
	DROP  Procedure  _PopulateDB_Research
END

GO


CREATE Procedure dbo._PopulateDB_Research
	@firstARAge int = 2
	,@secondARAge int = 3
	,@thirdARAge int =4 
AS

set nocount on



 
 DECLARE @AGE INT
 DECLARE @NO_REQUIREMENTS BIT
 DECLARE @COST_FACTOR int 
 DECLARE @TIME_FACTOR int 
 DECLARE @BONUS_FACTOR real -- applies too all research except farm, wall, towers
 DECLARE @IsTournamentRealm bit 
 declare @RealmType varchar(100)
 DECLARE @BASIC_RES_TIME_FACTOR int 
 --
 --
 -- IMPORTANT PARAMS TO SET DEPENDING ON AGE
 --
 --
SET @NO_REQUIREMENTS = 0
SET @COST_FACTOR = 1 -- set to 1 to have default. set to a higher number to divide the research cost by this number
SET @TIME_FACTOR = 1 -- set to 1 to have default. set to a higher number to divide the research time by this number
SET @BONUS_FACTOR = 1
SELECT @IsTournamentRealm = attribvalue FROM RealmAttributes WHERE attribID = 14 /*Temporary Tournament Realm? 0 means no, 1 means yes'*/
SELECT @RealmType = attribvalue FROM RealmAttributes WHERE attribID = 2000 

declare @RealmSubType varchar(100) -- Holiday14d etc
select @RealmSubType =  attribvalue from RealmAttributes where attribid =2001


	SET @BASIC_RES_TIME_FACTOR  = 2

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
-- 
-- =======================================================================================
-- =======================================================================================
-- =======================================================================================
--
-- Research Items
--
-- =======================================================================================
-- =======================================================================================
--
--
--
declare @RITLP_CoinMineProductionPerc int
set @RITLP_CoinMineProductionPerc = 1
declare @RITLP_HQTimeFactorPerc int
set @RITLP_HQTimeFactorPerc = 2
declare @RITLP_TreasuryCapacityPerc int
set @RITLP_TreasuryCapacityPerc = 3
declare @RITLP_PopulationCapacityPerc int
set @RITLP_PopulationCapacityPerc = 4
declare @RITLP_StableRecruitTimeFactorPerc int
set @RITLP_StableRecruitTimeFactorPerc = 5
declare @RITLP_BarracksRecruitTimeFactorPerc int
set @RITLP_BarracksRecruitTimeFactorPerc = 6
declare @RITLP_WorkshopRecruitTimeFactorPerc int
set @RITLP_WorkshopRecruitTimeFactorPerc = 7
declare @RITLP_DefenseFactorPerc int
set @RITLP_DefenseFactorPerc = 8
declare @RITLP_CoinTransportAmountPerc int
set @RITLP_CoinTransportAmountPerc = 9
declare @RITLP_TavernRecruitTimeFactorPerc int
set @RITLP_TavernRecruitTimeFactorPerc = 10
declare @RITLP_HidingSpotCapacityPerc int
set @RITLP_HidingSpotCapacityPerc = 11
declare @RITLP_VillageDefenseFactorPerc int 
set @RITLP_VillageDefenseFactorPerc = 12
declare @RITLP_AttackFactorPerc int
set @RITLP_AttackFactorPerc = 13

declare @RIT int
set @RIT =1

delete ResearchItemRequirements
delete UnitTypeRecruitmentResearchRequirements
delete ResearchItemProperties
delete from PlayerResearchItems
delete ResearchInProgress
delete ResearchItemSpriteLocation
delete ResearchItems
delete ResearchItemPropertyTypes 
delete ResearchItemTypes


INSERT INTO ResearchItemPropertyTypes values (@RITLP_CoinMineProductionPerc, 'Silver Production', 3, @LevelProp_CoinMineProduction)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_HQTimeFactorPerc, 'Construction Speed', 3, @LevelProp_HQTimeFactor)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_TreasuryCapacityPerc, 'Treasury Capacity', 3, @LevelProp_TreasuryCapacity)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_PopulationCapacityPerc, 'Farm Output', 3, @LevelProp_PopulationCapacity)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_StableRecruitTimeFactorPerc, 'Stables Recruit Speed', 3, @LevelProp_StableRecruitTimeFactor)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_BarracksRecruitTimeFactorPerc, 'Barracks Recruit Speed', 3, @LevelProp_BarracksRecruitTimeFactor)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_WorkshopRecruitTimeFactorPerc, 'Workshop Recruit Speed', 3, @LevelProp_WorkshopRecruitTimeFactor)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_DefenseFactorPerc, 'Defense Factor', 3, @LevelProp_DefenseFactor)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_CoinTransportAmountPerc, 'TradePost Capacity', 3, @LevelProp_CoinTransportAmount)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_TavernRecruitTimeFactorPerc, 'Tavern Recruit Speed', 3, @LevelProp_TavernRecruitTimeFactor)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_HidingSpotCapacityPerc, 'HidingSpot Capacity', 3, @LevelProp_HidingSpotCapacity)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_VillageDefenseFactorPerc, 'Village Defense Factor', 3, null)
INSERT INTO ResearchItemPropertyTypes values (@RITLP_AttackFactorPerc, 'Attack Factor', 3, null)

INSERT INTO ResearchItemTypes values (@RIT, dbo.Translate('research'))  




-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------Research-----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- -- AGE 1 -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
--Translation Inserts--
--Headquarters--
INSERT INTO ResearchItems values (@RIT, 1, 50, dbo.Translate('Forestry'), 600000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 2, 50, dbo.Translate('Writing'), 600000000, '', dbo.Translate('research2'), dbo.Translate('research2L'),null)
INSERT INTO ResearchItems values (@RIT, 7, 300, dbo.Translate('Mathematics'), 600000000, '', dbo.Translate('research7'), dbo.Translate('research7L'),null)
INSERT INTO ResearchItems values (@RIT, 9, 300, dbo.Translate('Management'), 600000000, '', dbo.Translate('research9'), dbo.Translate('research9L'),null)
INSERT INTO ResearchItems values (@RIT, 12, 800, dbo.Translate('Engineering'), 216000000000, '', dbo.Translate('research12'), dbo.Translate('research12L'),null)
INSERT INTO ResearchItems values (@RIT, 42, 800, dbo.Translate('Carpentry'), 9000000000, '', dbo.Translate('research42'), dbo.Translate('research42L'),null)
INSERT INTO ResearchItems values (@RIT, 75, 1000, dbo.Translate('Architecture'), 216000000000, '', dbo.Translate('research75'), dbo.Translate('research75L'),null)--#75
INSERT INTO ResearchItems values (@RIT, 76, 2900, dbo.Translate('Construction'), 432000000000, '', dbo.Translate('research76'), dbo.Translate('research76L'),null)
INSERT INTO ResearchItems values (@RIT, 77, 3950, dbo.Translate('Scaffolding'), 18000000000, '', dbo.Translate('research77'), dbo.Translate('research77L'),null)
INSERT INTO ResearchItems values (@RIT, 110, 1200, dbo.Translate('Centralized Government'), 18000000000, '', dbo.Translate('research110'), dbo.Translate('research110L'),null)--#110
INSERT INTO ResearchItems values (@RIT, 111, 6000, dbo.Translate('Feudalism'), 432000000000, '', dbo.Translate('research111'), dbo.Translate('research111L'),null)
INSERT INTO ResearchItems values (@RIT, 115, 10000, dbo.Translate('Propaganda'), 216000000000, '', dbo.Translate('research115'), dbo.Translate('research115L'),null)--#115
INSERT INTO ResearchItems values (@RIT, 129, 3100, dbo.Translate('Religion'), 600000000, '', dbo.Translate('research129'), dbo.Translate('research129L'),null)
--INSERT INTO ResearchItems values (@RIT, 151, 4150, dbo.Translate('Theocracy'), 216000000000, '', dbo.Translate('research151'), dbo.Translate('research151L'),null)
INSERT INTO ResearchItems values (@RIT, 152, 10000, dbo.Translate('Divine Right'), 216000000000, '', dbo.Translate('research152'), dbo.Translate('research152L'),null)
INSERT INTO ResearchItems values (@RIT, 153, 18000, dbo.Translate('Legal Code'), 9000000000, '', dbo.Translate('research153'), dbo.Translate('research153L'),null)


INSERT INTO ResearchItems values (@RIT, 500, 0, dbo.Translate('Forestry II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 501, 0, dbo.Translate('Forestry III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 502, 0, dbo.Translate('Mathematics II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 503, 0, dbo.Translate('Mathematics III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 504, 0, dbo.Translate('Writing II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 505, 0, dbo.Translate('Writing III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 506, 0, dbo.Translate('Management II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 507, 0, dbo.Translate('Management III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 508, 0, dbo.Translate('Religion II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 509, 0, dbo.Translate('Religion III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 510, 0, dbo.Translate('Construction II'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 511, 0, dbo.Translate('Construction III'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 512, 0, dbo.Translate('Feudalism II'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 513, 0, dbo.Translate('Feudalism III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 514, 0, dbo.Translate('Theocracy II'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 515, 0, dbo.Translate('Theocracy III'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)


--Silver Mines--
INSERT INTO ResearchItems values (@RIT, 3, 75, dbo.Translate('Obedience'), 600000000, '', dbo.Translate('research3'), dbo.Translate('research3L'),null)
INSERT INTO ResearchItems values (@RIT, 4, 75, dbo.Translate('Alchemy'), 600000000, '', dbo.Translate('research4'), dbo.Translate('research4L'),null)
--INSERT INTO ResearchItems values (@RIT, 5, 75, dbo.Translate('Copper Working'), 18000000000, '', dbo.Translate('research5'), dbo.Translate('research5L'),null)
--INSERT INTO ResearchItems values (@RIT, 6, 450, dbo.Translate('Mining Carts'), 3000000000, '', dbo.Translate('research6'), dbo.Translate('research6L'),null)
INSERT INTO ResearchItems values (@RIT, 10, 450, dbo.Translate('Smelting'), 9000000000, '', dbo.Translate('research10'), dbo.Translate('research10L'),null)
INSERT INTO ResearchItems values (@RIT, 14, 450, dbo.Translate('Refining'), 18000000000, '', dbo.Translate('research14'), dbo.Translate('research14L'),null)
INSERT INTO ResearchItems values (@RIT, 15, 900, dbo.Translate('Shovel'), 600000000, '', dbo.Translate('research15'), dbo.Translate('research15L'),null)
INSERT INTO ResearchItems values (@RIT, 16, 900, dbo.Translate('Iron Working'), 216000000000, '', dbo.Translate('research16'), dbo.Translate('research16L'),null)
--INSERT INTO ResearchItems values (@RIT, 17, 900, dbo.Translate('Copper Rails'), 216000000000, '', dbo.Translate('research17'), dbo.Translate('research17L'),null)
INSERT INTO ResearchItems values (@RIT, 18, 1500, dbo.Translate('Water Extraction'), 600000000, '', dbo.Translate('research18'), dbo.Translate('research18L'),null)
INSERT INTO ResearchItems values (@RIT, 19, 1800, dbo.Translate('Pulleys'), 600000000, '', dbo.Translate('research19'), dbo.Translate('research19L'),null)
INSERT INTO ResearchItems values (@RIT, 24, 4000, dbo.Translate('Iron Rails'), 432000000000, '', dbo.Translate('research24'), dbo.Translate('research24L'),null)
INSERT INTO ResearchItems values (@RIT, 25, 21000, dbo.Translate('Deep Mining'), 1728000000000, '', dbo.Translate('research25'), dbo.Translate('research25L'),null)
INSERT INTO ResearchItems values (@RIT, 26, 1200, dbo.Translate('Beasts of Burden'), 9000000000, '', dbo.Translate('research26'), dbo.Translate('research26L'),null)
INSERT INTO ResearchItems values (@RIT, 27, 4800, dbo.Translate('Mine Security'), 18000000000, '', dbo.Translate('research27'), dbo.Translate('research27L'),null)
INSERT INTO ResearchItems values (@RIT, 28, 3200,dbo.Translate('Steel Pick'), 864000000000, '', dbo.Translate('research28'), dbo.Translate('research28L'),null)
INSERT INTO ResearchItems values (@RIT, 29, 5200,dbo.Translate('Steel Rails'), 864000000000 , '', dbo.Translate('research29'), dbo.Translate('research29L'),null)
INSERT INTO ResearchItems values (@RIT, 30, 23000, dbo.Translate('Collective Punishment'), 216000000000, '', dbo.Translate('research30'), dbo.Translate('research30L'),null)
INSERT INTO ResearchItems values (@RIT, 40, 16000, dbo.Translate('Watermill'), 18000000000, '', dbo.Translate('research40'), dbo.Translate('research40L'),null)--#40
INSERT INTO ResearchItems values (@RIT, 121, 4800, dbo.Translate('Open-pit Mining'), 864000000000, '', dbo.Translate('research121'), dbo.Translate('research121L'),null)
--INSERT INTO ResearchItems values (@RIT, 122, 12000, dbo.Translate('Shaft Bracing'), 3000000000, '', dbo.Translate('research122'), dbo.Translate('research122L'),null)
--INSERT INTO ResearchItems values (@RIT, 123, 5000, dbo.Translate('Bellows'), 432000000000, '', dbo.Translate('research123'), dbo.Translate('research123L'),null)
--INSERT INTO ResearchItems values (@RIT, 124, 21000, dbo.Translate('Black Powder'), 864000000000, '', dbo.Translate('research124'), dbo.Translate('research124L'),null)
--INSERT INTO ResearchItems values (@RIT, 125, 105000, dbo.Translate('Fire-setting'), 216000000000, '', dbo.Translate('research125'), dbo.Translate('research125L'),null)--#125
INSERT INTO ResearchItems values (@RIT, 126, 13500, dbo.Translate('Mine-hoist'), 9000000000, '', dbo.Translate('research126'), dbo.Translate('research126L'),null)
INSERT INTO ResearchItems values (@RIT, 127, 9000, dbo.Translate('Cupellation'), 432000000000, '', dbo.Translate('research127'), dbo.Translate('research127L'),null)
--INSERT INTO ResearchItems values (@RIT, 128, 16000, dbo.Translate('Crucible'), 216000000000, '', dbo.Translate('research128'), dbo.Translate('research128L'),null)
INSERT INTO ResearchItems values (@RIT, 154, 30000, dbo.Translate('Arrastra'), 216000000000, '', dbo.Translate('research154'), dbo.Translate('research154L'),null)
INSERT INTO ResearchItems values (@RIT, 155, 18000, dbo.Translate('Auger Conveyer'), 432000000000, '', dbo.Translate('research155'), dbo.Translate('research155L'),null)
INSERT INTO ResearchItems values (@RIT, 156, 24000, dbo.Translate('Work Camps'), 432000000000, '', dbo.Translate('research156'), dbo.Translate('research156L'),null)

INSERT INTO ResearchItems values (@RIT, 516, 0, dbo.Translate('Obedience II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 517, 0, dbo.Translate('Obedience III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 518, 0, dbo.Translate('Alchemy II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 519, 0, dbo.Translate('Alchemy III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 520, 0, dbo.Translate('Shovel II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 521, 0, dbo.Translate('Shovel III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 522, 0, dbo.Translate('Water Extraction II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 523, 0, dbo.Translate('Water Extraction III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 524, 0, dbo.Translate('Pulleys II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 525, 0, dbo.Translate('Pulleys III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 526, 0, dbo.Translate('Crucible II'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 527, 0, dbo.Translate('Crucible III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 528, 0, dbo.Translate('Steel Rails II'), 3456000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 529, 0, dbo.Translate('Steel Rails III'), 5184000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 530, 0, dbo.Translate('Deep Mining II'), 2592000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 531, 0, dbo.Translate('Deep Mining III'), 3456000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 532, 0, dbo.Translate('Open-pit Mining II'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 533, 0, dbo.Translate('Open-pit Mining III'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)

--Farms--
INSERT INTO ResearchItems values (@RIT, 8, 50, dbo.Translate('Medicine'), 864000000000, '', dbo.Translate('research8'), dbo.Translate('research8L'),null)
INSERT INTO ResearchItems values (@RIT, 33, 50, dbo.Translate('Crop Rotation'), 600000000, '', dbo.Translate('research33'), dbo.Translate('research33L'),null)
INSERT INTO ResearchItems values (@RIT, 34, 300, dbo.Translate('Granary'), 600000000, '', dbo.Translate('research34'), dbo.Translate('research34L'),null)
INSERT INTO ResearchItems values (@RIT, 35, 300, dbo.Translate('Scythe'), 600000000, '', dbo.Translate('research35'), dbo.Translate('research35L'),null)--#35
INSERT INTO ResearchItems values (@RIT, 36, 1100, dbo.Translate('Harrow'), 600000000, '', dbo.Translate('research36'), dbo.Translate('research36L'),null)
--INSERT INTO ResearchItems values (@RIT, 37, 900, dbo.Translate('Mouldboard Plough'), 3000000000, '', dbo.Translate('research37'), dbo.Translate('research37L'),null)
INSERT INTO ResearchItems values (@RIT, 38, 700, dbo.Translate('Pitchforks'), 9000000000, '', dbo.Translate('research38'), dbo.Translate('research38L'),null)
INSERT INTO ResearchItems values (@RIT, 39, 5000, dbo.Translate('Animal Husbandry'), 600000000, '', dbo.Translate('research39'), dbo.Translate('research39L'),null)
INSERT INTO ResearchItems values (@RIT, 41, 16200, dbo.Translate('Windmill'), 18000000000, '', dbo.Translate('research41'), dbo.Translate('research41L'),null)
INSERT INTO ResearchItems values (@RIT, 118, 3200, dbo.Translate('Wheeled Plough'), 432000000000, '', dbo.Translate('research118'), dbo.Translate('research118L'),null)
INSERT INTO ResearchItems values (@RIT, 119, 4750, dbo.Translate('Horse Collar'), 216000000000, '', dbo.Translate('research119'), dbo.Translate('research119L'),null)
--INSERT INTO ResearchItems values (@RIT, 120, 3250, dbo.Translate('Flail'), 18000000000, '', dbo.Translate('research120'), dbo.Translate('research120L'),null)--#120
INSERT INTO ResearchItems values (@RIT, 147, 600, dbo.Translate('Domestication'), 18000000000, '', dbo.Translate('research147'), dbo.Translate('research147L'),null)
INSERT INTO ResearchItems values (@RIT, 148, 9000, dbo.Translate('Irrigation'), 9000000000, '', dbo.Translate('research148'), dbo.Translate('research148L'),null)
INSERT INTO ResearchItems values (@RIT, 149, 2800, dbo.Translate('Cisterns'), 216000000000, '', dbo.Translate('research149'), dbo.Translate('research149L'),null)
INSERT INTO ResearchItems values (@RIT, 150, 11800, dbo.Translate('Aquaducts'), 432000000000, '', dbo.Translate('research150'), dbo.Translate('research150L'),null)

INSERT INTO ResearchItems values (@RIT, 534, 0, dbo.Translate('Crop Rotation II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 535, 0, dbo.Translate('Crop Rotation III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 536, 0, dbo.Translate('Granary II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 537, 0, dbo.Translate('Granary III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 538, 0, dbo.Translate('Animal Husbandry II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 539, 0, dbo.Translate('Animal Husbandry III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 540, 0, dbo.Translate('Scythe II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 541, 0, dbo.Translate('Scythe III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 542, 0, dbo.Translate('Horse Collar II'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 543, 0, dbo.Translate('Horse Collar III'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 544, 0, dbo.Translate('Harrow II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 545, 0, dbo.Translate('Harrow III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 546, 0, dbo.Translate('Medicine II'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 547, 0, dbo.Translate('Medicine III'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 548, 0, dbo.Translate('Wheeled Plough II'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 549, 0, dbo.Translate('Wheeled Plough III'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 550, 0, dbo.Translate('Flail II'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 551, 0, dbo.Translate('Flail III'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 552, 0, dbo.Translate('Aquaducts II'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 553, 0, dbo.Translate('Aquaducts III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)

--Trading Post--
INSERT INTO ResearchItems values (@RIT, 11, 100, dbo.Translate('Wheels'), 600000000, '', dbo.Translate('research11'), dbo.Translate('research11L'),null)
INSERT INTO ResearchItems values (@RIT, 43, 600, dbo.Translate('Currency'), 600000000, '', dbo.Translate('research43'), dbo.Translate('research43L'),null)
INSERT INTO ResearchItems values (@RIT, 46, 500, dbo.Translate('Barter'), 18000000000, '', dbo.Translate('research46'), dbo.Translate('research46L'),null)
INSERT INTO ResearchItems values (@RIT, 47, 550, dbo.Translate('Caravan'), 600000000, '', dbo.Translate('research47'), dbo.Translate('research47L'),null)
INSERT INTO ResearchItems values (@RIT, 79, 3800, dbo.Translate('Caravan Protection'), 432000000000, '', dbo.Translate('research79'), dbo.Translate('research79L'),null)
INSERT INTO ResearchItems values (@RIT, 132, 1600, dbo.Translate('Ox Driven Carts'), 18000000000, '', dbo.Translate('research132'), dbo.Translate('research132L'),null)
INSERT INTO ResearchItems values (@RIT, 133, 1800, dbo.Translate('Horse Driven Carts'), 216000000000	, '', dbo.Translate('research133'), dbo.Translate('research133L'),null)
INSERT INTO ResearchItems values (@RIT, 134, 2500, dbo.Translate('Double Horse Wagon'), 432000000000, '', dbo.Translate('research134'), dbo.Translate('research134L'),null)
--INSERT INTO ResearchItems values (@RIT, 135, 100000, dbo.Translate('Fortified Wagon I'), 864000000000, '', dbo.Translate('research135'), dbo.Translate('research135L'),null)--#135

INSERT INTO ResearchItems values (@RIT, 554, 0, dbo.Translate('Currency II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 555, 0, dbo.Translate('Currency III'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 556, 0, dbo.Translate('Caravan II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 557, 0, dbo.Translate('Caravan III'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 558, 0, dbo.Translate('Wheels II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 559, 0, dbo.Translate('Wheels III'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 560, 0, dbo.Translate('Barter II'), 18000000000	, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 561, 0, dbo.Translate('Barter III'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 562, 0, dbo.Translate('Caravan Protection II'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 563, 0, dbo.Translate('Caravan Protection III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 564, 0, dbo.Translate('Improved Fortified Wagon'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 565, 0, dbo.Translate('Greater Fortified Wagon'), 2592000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)

--Treasury--
INSERT INTO ResearchItems values (@RIT, 13, 600, dbo.Translate('Scales'), 600000000, '', dbo.Translate('research13'), dbo.Translate('research13L'),null)
INSERT INTO ResearchItems values (@RIT, 20, 100, dbo.Translate('Record Keeping'), 600000000, '', dbo.Translate('research20'), dbo.Translate('research20L'),null)
INSERT INTO ResearchItems values (@RIT, 21, 650, dbo.Translate('Gilding'), 432000000000, '', dbo.Translate('research21'), dbo.Translate('research21L'),null)
INSERT INTO ResearchItems values (@RIT, 22, 500, dbo.Translate('Coin Minting'), 216000000000, '', dbo.Translate('research22'), dbo.Translate('research22L'),null)
INSERT INTO ResearchItems values (@RIT, 31,1800, dbo.Translate('Reeding'), 432000000000, '', dbo.Translate('research31'), dbo.Translate('research31L'),null)
INSERT INTO ResearchItems values (@RIT, 68, 3000, dbo.Translate('Storage Vault'), 600000000, '', dbo.Translate('research68'), dbo.Translate('research68L'),null)
INSERT INTO ResearchItems values (@RIT, 136, 4200, dbo.Translate('Professional Guards'), 18000000000, '', dbo.Translate('research136'), dbo.Translate('research136L'),null)
INSERT INTO ResearchItems values (@RIT, 137, 2000, dbo.Translate('Professional Scribes'), 18000000000, '', dbo.Translate('research137'), dbo.Translate('research137L'),null)

INSERT INTO ResearchItems values (@RIT, 566, 0, dbo.Translate('Record Keeping II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 567, 0, dbo.Translate('Record Keeping III'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 568, 0, dbo.Translate('Storage Vault II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 569, 0, dbo.Translate('Storage Vault III'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 570, 0, dbo.Translate('Scales II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 571, 0, dbo.Translate('Scales III'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 572, 0, dbo.Translate('Professional Scribes II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 573, 0, dbo.Translate('Professional Scribes III'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 574, 0, dbo.Translate('Professional Guards II'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 575, 0, dbo.Translate('Professional Guards III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 576, 0, dbo.Translate('Reeding II'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 577, 0, dbo.Translate('Reeding III'), 2592000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)

--Barracks--
INSERT INTO ResearchItems values (@RIT, 23, 300, dbo.Translate('Steel Working'), 18000000000, '', dbo.Translate('research23'), dbo.Translate('research23L'),null)
INSERT INTO ResearchItems values (@RIT, 32, 50, dbo.Translate('Blacksmith'), 600000000, '', dbo.Translate('research32'), dbo.Translate('research32L'),null)
INSERT INTO ResearchItems values (@RIT, 54, 5500, dbo.Translate('Pike'), 216000000000, '', dbo.Translate('research54'), dbo.Translate('research54L'),null)
INSERT INTO ResearchItems values (@RIT, 59, 15000, dbo.Translate('Chainmail'), 216000000000, '', dbo.Translate('research59'), dbo.Translate('research59L'),null)
INSERT INTO ResearchItems values (@RIT, 65, 50, dbo.Translate('Military Discipline'), 600000000, '', dbo.Translate('research65'), dbo.Translate('research65L'),null)--#65
INSERT INTO ResearchItems values (@RIT, 66, 300, dbo.Translate('Military Training'), 9000000000, '', dbo.Translate('research66'), dbo.Translate('research66L'),null)
INSERT INTO ResearchItems values (@RIT, 94, 800, dbo.Translate('Crossbow'), 600000000, '', dbo.Translate('research94'), dbo.Translate('research94L'),null)
INSERT INTO ResearchItems values (@RIT, 95, 1200, dbo.Translate('Poleaxe'), 432000000000, '', dbo.Translate('research95'), dbo.Translate('research95L'),null)--#95
INSERT INTO ResearchItems values (@RIT, 96, 3000, dbo.Translate('Spear'), 600000000, '', dbo.Translate('research96'), dbo.Translate('research96L'),null)
INSERT INTO ResearchItems values (@RIT, 97, 4400, dbo.Translate('Javelin'), 18000000000, '', dbo.Translate('research97'), dbo.Translate('research97L'),null)
INSERT INTO ResearchItems values (@RIT, 103, 3600, dbo.Translate('Professional Military'), 432000000000, '', dbo.Translate('research103'), dbo.Translate('research103L'),null)
INSERT INTO ResearchItems values (@RIT, 104, 3000, dbo.Translate('Standing Army'), 864000000000, '', dbo.Translate('research104'), dbo.Translate('research104L'),null)
INSERT INTO ResearchItems values (@RIT, 108, 800, dbo.Translate('Fishmongering'), 600000000, '', dbo.Translate('research108'), dbo.Translate('research108L'),null)
INSERT INTO ResearchItems values (@RIT, 109, 1300, dbo.Translate('Scutage'), 18000000000, '', dbo.Translate('research109'), dbo.Translate('research109L'),null)
INSERT INTO ResearchItems values (@RIT, 144, 6500, dbo.Translate('Conscription'), 432000000000, '', dbo.Translate('research144'), dbo.Translate('research144L'),null)
INSERT INTO ResearchItems values (@RIT, 146, 13000, dbo.Translate('Officer Training'), 216000000000, '', dbo.Translate('research146'), dbo.Translate('research146L'),null)

INSERT INTO ResearchItems values (@RIT, 578, 0, dbo.Translate('Blacksmith II'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 579, 0, dbo.Translate('Blacksmith III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 580, 0, dbo.Translate('Steel Working II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 581, 0, dbo.Translate('Steel Working III'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 582, 0, dbo.Translate('Crossbow II'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 583, 0, dbo.Translate('Crossbow III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 584, 0, dbo.Translate('Javelin II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 585, 0, dbo.Translate('Javelin III'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 586, 0, dbo.Translate('Spear II'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 587, 0, dbo.Translate('Spear III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 588, 0, dbo.Translate('Pike II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 589, 0, dbo.Translate('Pike III'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 590, 0, dbo.Translate('Poleaxe II'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 591, 0, dbo.Translate('Poleaxe III'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 592, 0, dbo.Translate('Military Discipline II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 593, 0, dbo.Translate('Military Discipline III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 594, 0, dbo.Translate('Military Training II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 595, 0, dbo.Translate('Military Training III'), 72000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 596, 0, dbo.Translate('Officer Training II'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 597, 0, dbo.Translate('Officer Training III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 598, 0, dbo.Translate('Fishmongering II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 599, 0, dbo.Translate('Fishmongering III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 600, 0, dbo.Translate('Scutage II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 601, 0, dbo.Translate('Scutage III'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 602, 0, dbo.Translate('Conscription II'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 603, 0, dbo.Translate('Conscription III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)

--Tavern--
INSERT INTO ResearchItems values (@RIT, 44, 100, dbo.Translate('Winemaking'), 600000000, '', dbo.Translate('research44'), dbo.Translate('research44L'),null)
INSERT INTO ResearchItems values (@RIT, 45, 600, dbo.Translate('Beer Brewing'), 18000000000, '', dbo.Translate('research45'), dbo.Translate('research45L'),null)--#45
INSERT INTO ResearchItems values (@RIT, 67, 800, dbo.Translate('Music'), 216000000000, '', dbo.Translate('research67'), dbo.Translate('research67L'),null)
INSERT INTO ResearchItems values (@RIT, 72, 700, dbo.Translate('Blackmail'), 18000000000, '', dbo.Translate('research72'), dbo.Translate('research72L'),null)
INSERT INTO ResearchItems values (@RIT, 78, 1600, dbo.Translate('Bribery'), 600000000, '', dbo.Translate('research78'), dbo.Translate('research78L'),null)
INSERT INTO ResearchItems values (@RIT, 130, 2000, dbo.Translate('Sabotage'), 600000000, '', dbo.Translate('research130'), dbo.Translate('research130L'),null)--#130
INSERT INTO ResearchItems values (@RIT, 131, 4000, dbo.Translate('Assassination'), 432000000000, '', dbo.Translate('research131'), dbo.Translate('research131L'),null)
INSERT INTO ResearchItems values (@RIT, 162, 6000, dbo.Translate('Seduction'), 216000000000, '', dbo.Translate('research162'), dbo.Translate('research162L'),null)

INSERT INTO ResearchItems values (@RIT, 604, 0, dbo.Translate('Winemaking II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 605, 0, dbo.Translate('Winemaking III'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 606, 0, dbo.Translate('Beer Brewing II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 607, 0, dbo.Translate('Beer Brewing III'), 36000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 608, 0, dbo.Translate('Music II'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 609, 0, dbo.Translate('Music III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 610, 0, dbo.Translate('Blackmail II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 611, 0, dbo.Translate('Blackmail III'), 36000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 612, 0, dbo.Translate('Bribery II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 613, 0, dbo.Translate('Bribery III'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 614, 0, dbo.Translate('Seduction II'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 615, 0, dbo.Translate('Seduction III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 616, 0, dbo.Translate('Sabotage II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
INSERT INTO ResearchItems values (@RIT, 617, 0, dbo.Translate('Sabotage III'), 9000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 618, 0, dbo.Translate('Assassination II'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 619, 0, dbo.Translate('Assassination III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)

--Walls--
INSERT INTO ResearchItems values (@RIT, 48, 100, dbo.Translate('Masonry'), 600000000, '', dbo.Translate('research48'), dbo.Translate('research48L'),null)
INSERT INTO ResearchItems values (@RIT, 49, 3600, dbo.Translate('Moat'), 18000000000, '', dbo.Translate('research49'), dbo.Translate('research49L'),null)
INSERT INTO ResearchItems values (@RIT, 50, 100, dbo.Translate('Arrow Slits'), 1200000000, '', dbo.Translate('research50'), dbo.Translate('research50L'),null)--#50
INSERT INTO ResearchItems values (@RIT, 51, 5000, dbo.Translate('Drawbridge'), 216000000000, '', dbo.Translate('research51'), dbo.Translate('research51L'),null)
INSERT INTO ResearchItems values (@RIT, 69, 6500, dbo.Translate('Hot Oil Cauldrons'), 18000000000, '', dbo.Translate('research69'), dbo.Translate('research69L'),null)
INSERT INTO ResearchItems values (@RIT, 83, 600, dbo.Translate('Murder Hole'), 9000000000, '', dbo.Translate('research83'), dbo.Translate('research83L'),null)
INSERT INTO ResearchItems values (@RIT, 84, 200, dbo.Translate('Hoarding'), 18000000000, '', dbo.Translate('research84'), dbo.Translate('research84L'),null)
INSERT INTO ResearchItems values (@RIT, 85, 2000, dbo.Translate('Sally Port'), 18000000000, '', dbo.Translate('research85'), dbo.Translate('research85L'),null)--#85
INSERT INTO ResearchItems values (@RIT, 88, 1000, dbo.Translate('Yett'), 9000000000, '', dbo.Translate('research88'), dbo.Translate('research88L'),null)
INSERT INTO ResearchItems values (@RIT, 91, 600, dbo.Translate('Barbican'), 216000000000, '', dbo.Translate('research91'), dbo.Translate('research91L'),null)
INSERT INTO ResearchItems values (@RIT, 92, 300, dbo.Translate('Keep'), 432000000000, '', dbo.Translate('research92'), dbo.Translate('research92L'),null)
INSERT INTO ResearchItems values (@RIT, 93, 400, dbo.Translate('Citadel'), 864000000000, '', dbo.Translate('research93'), dbo.Translate('research93L'),null)
INSERT INTO ResearchItems values (@RIT, 163, 150, dbo.Translate('Watchtower'), 1200000000, '', dbo.Translate('research163'), dbo.Translate('research163L'),null)
INSERT INTO ResearchItems values (@RIT, 164, 2000, dbo.Translate('Bartizan'), 432000000000, '', dbo.Translate('research164'), dbo.Translate('research164L'),null)
INSERT INTO ResearchItems values (@RIT, 165, 1500, dbo.Translate('Gate House'), 9000000000, '', dbo.Translate('research165'), dbo.Translate('research165L'),null)
INSERT INTO ResearchItems values (@RIT, 168, 100, dbo.Translate('Manor House'), 216000000000, '', dbo.Translate('research168'), dbo.Translate('research168L'),null)

--INSERT INTO ResearchItems values (@RIT, 620, 0, dbo.Translate('Masonry II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 621, 0, dbo.Translate('Masonry III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 622, 0, dbo.Translate('Moat II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 623, 0, dbo.Translate('Moat III'), 36000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 624, 0, dbo.Translate('Arrow Slits II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 625, 0, dbo.Translate('Arrow Slits III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 626, 0, dbo.Translate('Murder Hole II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 627, 0, dbo.Translate('Murder Hole III'), 36000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 628, 0, dbo.Translate('Yett II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 629, 0, dbo.Translate('Yett III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 630, 0, dbo.Translate('Gate House II'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 631, 0, dbo.Translate('Gate House III'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 632, 0, dbo.Translate('Watchtower II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 633, 0, dbo.Translate('Watchtower III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 634, 0, dbo.Translate('Manor House II'), 36000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 635, 0, dbo.Translate('Manor House III'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 636, 0, dbo.Translate('Keep II'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 637, 0, dbo.Translate('Keep III'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)

--Stables--
INSERT INTO ResearchItems values (@RIT, 63, 50, dbo.Translate('Horse Training'), 1200000000, '', dbo.Translate('research63'), dbo.Translate('research63L'),null)
INSERT INTO ResearchItems values (@RIT, 64, 600, dbo.Translate('Horse Breaking'), 9000000000, '', dbo.Translate('research64'), dbo.Translate('research64L'),null)
INSERT INTO ResearchItems values (@RIT, 70, 3500, dbo.Translate('Chivalry'), 864000000000, '', dbo.Translate('research70'), dbo.Translate('research70L'),null)--#70
INSERT INTO ResearchItems values (@RIT, 98, 50, dbo.Translate('Shield'), 18000000000, '', dbo.Translate('research98'), dbo.Translate('research98L'),null)
INSERT INTO ResearchItems values (@RIT, 99, 600, dbo.Translate('Helmet'), 18000000000, '', dbo.Translate('research99'), dbo.Translate('research99L'),null)
INSERT INTO ResearchItems values (@RIT, 100, 1600, dbo.Translate('Plate Mail'), 432000000000, '', dbo.Translate('research100'), dbo.Translate('research100L'),null)--#100
INSERT INTO ResearchItems values (@RIT, 102, 1650, dbo.Translate('Military Punishment'), 1200000000, '', dbo.Translate('research102'), dbo.Translate('research102L'),null)
INSERT INTO ResearchItems values (@RIT, 105, 2400, dbo.Translate('Fair loot distribution'), 600000000, '', dbo.Translate('research105'), dbo.Translate('research105L'),null)--#105
INSERT INTO ResearchItems values (@RIT, 107, 1800, dbo.Translate('Cheesemongering'), 9000000000, '', dbo.Translate('research107'), dbo.Translate('research107L'),null)
INSERT INTO ResearchItems values (@RIT, 112, 800, dbo.Translate('Leather Armor'), 216000000000, '', dbo.Translate('research112'), dbo.Translate('research112L'),null)
INSERT INTO ResearchItems values (@RIT, 113, 7200, dbo.Translate('Mercenary Army'), 864000000000, '', dbo.Translate('research113'), dbo.Translate('research113L'),null)
INSERT INTO ResearchItems values (@RIT, 116, 4500, dbo.Translate('Religious Fanaticism '), 432000000000, '', dbo.Translate('research116'), dbo.Translate('research116L'),null)
INSERT INTO ResearchItems values (@RIT, 117, 3150, dbo.Translate('Horseman''s Pick'), 432000000000, '', dbo.Translate('research117'), dbo.Translate('research117L'),null)
INSERT INTO ResearchItems values (@RIT, 159, 800, dbo.Translate('Spurs'), 18000000000, '', dbo.Translate('research159'), dbo.Translate('research159L'),null)
INSERT INTO ResearchItems values (@RIT, 160, 2400, dbo.Translate('Squirehood'), 9000000000, '', dbo.Translate('research160'), dbo.Translate('research160L'),null)
INSERT INTO ResearchItems values (@RIT, 161, 600, dbo.Translate('Destrier'), 216000000000, '', dbo.Translate('research161'), dbo.Translate('research161L'),null)

--INSERT INTO ResearchItems values (@RIT, 638, 0, dbo.Translate('Horse Training II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 639, 0, dbo.Translate('Horse Training III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 640, 0, dbo.Translate('Horse Breaking II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 641, 0, dbo.Translate('Horse Breaking III'), 36000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 642, 0, dbo.Translate('Spurs II'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 643, 0, dbo.Translate('Spurs III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 644, 0, dbo.Translate('Cheesemongering II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 645, 0, dbo.Translate('Cheesemongering III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 646, 0, dbo.Translate('Fair loot distribution II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 647, 0, dbo.Translate('Fair loot distribution III'), 36000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 648, 0, dbo.Translate('Military Punishment II'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 649, 0, dbo.Translate('Military Punishment III'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 650, 0, dbo.Translate('Shield II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 651, 0, dbo.Translate('Shield III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 652, 0, dbo.Translate('Helmet II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 653, 0, dbo.Translate('Helmet III'), 36000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 654, 0, dbo.Translate('Leather Armor II'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 655, 0, dbo.Translate('Leather Armor III'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 656, 0, dbo.Translate('Horseman''s Pick II'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 657, 0, dbo.Translate('Horseman''s Pick III'), 2592000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 658, 0, dbo.Translate('Squirehood II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 659, 0, dbo.Translate('Squirehood III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 660, 0, dbo.Translate('Chivalry II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 661, 0, dbo.Translate('Chivalry III'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)

--Siege Workshop--
INSERT INTO ResearchItems values (@RIT, 71, 100, dbo.Translate('Sawmill'), 600000000, '', dbo.Translate('research71'), dbo.Translate('research71L'),null)
INSERT INTO ResearchItems values (@RIT, 73, 2000, dbo.Translate('Physics'), 216000000000, '', dbo.Translate('research73'), dbo.Translate('research73L'),null)
INSERT INTO ResearchItems values (@RIT, 74, 600, dbo.Translate('Machinery'), 1200000000, '', dbo.Translate('research74'), dbo.Translate('research74L'),null)
INSERT INTO ResearchItems values (@RIT, 101, 800, dbo.Translate('Military Logistics'), 18000000000, '', dbo.Translate('research101'), dbo.Translate('research101L'),null)
INSERT INTO ResearchItems values (@RIT, 106, 2000, dbo.Translate('Military Rewards'), 216000000000, '', dbo.Translate('research106'), dbo.Translate('research106L'),null)
INSERT INTO ResearchItems values (@RIT, 114, 1800, dbo.Translate('Supply Trains'), 432000000000, '', dbo.Translate('research114'), dbo.Translate('research114L'),null)
INSERT INTO ResearchItems values (@RIT, 157, 6000, dbo.Translate('Hinged Counterweight'), 9000000000, '', dbo.Translate('research157'), dbo.Translate('research157L'),null)
INSERT INTO ResearchItems values (@RIT, 158, 10000, dbo.Translate('Hide Canopy'), 18000000000, '', dbo.Translate('research158'), dbo.Translate('research158L'),null)

--INSERT INTO ResearchItems values (@RIT, 662, 0, dbo.Translate('Sawmill II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 664, 0, dbo.Translate('Machinery II'), 36000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 665, 0, dbo.Translate('Machinery III'), 72000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 666, 0, dbo.Translate('Physics II'), 432000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 667, 0, dbo.Translate('Physics III'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 668, 0, dbo.Translate('Military Logistics II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 669, 0, dbo.Translate('Military Logistics III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 670, 0, dbo.Translate('Military Rewards II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 671, 0, dbo.Translate('Military Rewards III'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 672, 0, dbo.Translate('Supply Trains II'), 864000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 673, 0, dbo.Translate('Supply Trains III'), 1728000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 674, 0, dbo.Translate('Hinged Counterweight II'), 1200000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 675, 0, dbo.Translate('Hinged Counterweight III'), 1800000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 676, 0, dbo.Translate('Hide Canopy II'), 18000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)
--INSERT INTO ResearchItems values (@RIT, 677, 0, dbo.Translate('Hide Canopy III'), 216000000000, '', dbo.Translate('research1'),dbo.Translate('research1L'),null)



IF @IsTournamentRealm = 0 and @RealmSubType <> 'Retro' BEGIN 
	--Attack--
	INSERT INTO ResearchItems values (@RIT, 371, 75, 'Refined Metals', 18000000000, '', dbo.Translate('research341'), dbo.Translate('research341L'),null)
	INSERT INTO ResearchItems values (@RIT, 372, 50, 'Hammer The Steel', 216000000000, '', dbo.Translate('research342'), dbo.Translate('research342L'),null)
	INSERT INTO ResearchItems values (@RIT, 373, 105000, 'Burn It All', 432000000000, '', dbo.Translate('research343'), dbo.Translate('research343L'),null)
	INSERT INTO ResearchItems values (@RIT, 374, 5500, 'Endless Blades', 432000000000, '', dbo.Translate('research344'), dbo.Translate('research344L'),null)
	INSERT INTO ResearchItems values (@RIT, 375, 800, 'Flaming Archers', 864000000000, '', dbo.Translate('research345'), dbo.Translate('research345L'),null)
	INSERT INTO ResearchItems values (@RIT, 376, 3250, 'Brutality', 864000000000, '', dbo.Translate('research346'), dbo.Translate('research346L'),null)
	INSERT INTO ResearchItems values (@RIT, 377, 12000, 'Siegebreakers', 864000000000, '', dbo.Translate('research347'), dbo.Translate('research347L'),null)
	INSERT INTO ResearchItems values (@RIT, 378, 4150, 'Lord Of War', 1296000000000, '', dbo.Translate('research348'), dbo.Translate('research348L'),null)

	--Defense--
	INSERT INTO ResearchItems values (@RIT, 379, 0, 'Signal Towers', 18000000000, '', dbo.Translate('research349'), dbo.Translate('research349L'),null)
	INSERT INTO ResearchItems values (@RIT, 380, 600, 'Reinforced Gates', 216000000000, '', dbo.Translate('research350'), dbo.Translate('research350L'),null)
	INSERT INTO ResearchItems values (@RIT, 89, 300, dbo.Translate('Boiling Water Cauldrons'), 432000000000, '', dbo.Translate('research89'), dbo.Translate('research89L'),null)
	INSERT INTO ResearchItems values (@RIT, 381, 0, 'Imposing Towers', 432000000000, '', dbo.Translate('research351'), dbo.Translate('research351L'),null)
	INSERT INTO ResearchItems values (@RIT, 382, 16000, 'Molten Steel', 864000000000, '', dbo.Translate('research352'), dbo.Translate('research352L'),null)
	INSERT INTO ResearchItems values (@RIT, 86, 800, dbo.Translate('Deep Water Wells'), 864000000000, '', dbo.Translate('research86'), dbo.Translate('research86L'),null)
	INSERT INTO ResearchItems values (@RIT, 383, 800, 'Walls Like Mountains', 864000000000, '', dbo.Translate('research353'), dbo.Translate('research353L'),null)
	INSERT INTO ResearchItems values (@RIT, 90, 1200, dbo.Translate('Greek Fire Cauldrons'), 1296000000000, '', dbo.Translate('research90'), dbo.Translate('research90L'),null)


	INSERT INTO ResearchItemProperties VALUES (@RIT, 371, @RITLP_AttackFactorPerc, 0.01)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 372, @RITLP_AttackFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 373, @RITLP_AttackFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 374, @RITLP_AttackFactorPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 375, @RITLP_AttackFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 376, @RITLP_AttackFactorPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 377, @RITLP_AttackFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 378, @RITLP_AttackFactorPerc, 0.05)

	INSERT INTO ResearchItemProperties VALUES (@RIT, 379, @RITLP_VillageDefenseFactorPerc, 0.01)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 380, @RITLP_VillageDefenseFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 89, @RITLP_VillageDefenseFactorPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 381, @RITLP_VillageDefenseFactorPerc, 0.04)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 382, @RITLP_VillageDefenseFactorPerc, 0.04)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 86, @RITLP_VillageDefenseFactorPerc, 0.04)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 383, @RITLP_VillageDefenseFactorPerc, 0.05)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 90, @RITLP_VillageDefenseFactorPerc, 0.07)


	--Attack--
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 372, @RIT, 371)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 373, @RIT, 372)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 374, @RIT, 372)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 375, @RIT, 373)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 376, @RIT, 374)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 377, @RIT, 374)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 378, @RIT, 375)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 378, @RIT, 376)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 378, @RIT, 377)

	--Defense--
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 380, @RIT, 379)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 89, @RIT, 380)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 381, @RIT, 380)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 382, @RIT, 89)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 86, @RIT, 381)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 383, @RIT, 381)
	INSERT INTO ResearchItemRequirements VALUES (@RIT, 90, @RIT, 382)

	--Attack & Defense--
	INSERT INTO ResearchItemSpriteLocation values (1,371, 410,2)
	INSERT INTO ResearchItemSpriteLocation values (1,372, 104,308)	
	INSERT INTO ResearchItemSpriteLocation values (1,373, 410,1226)
	INSERT INTO ResearchItemSpriteLocation values (1,374, 308,512)
	INSERT INTO ResearchItemSpriteLocation values (1,375, 206,512)
	INSERT INTO ResearchItemSpriteLocation values (1,376, 920,1124)
	INSERT INTO ResearchItemSpriteLocation values (1,377, 104,1226)
	INSERT INTO ResearchItemSpriteLocation values (1,378, 2,1532)
	INSERT INTO ResearchItemSpriteLocation values (1,379, 206,1634)
	INSERT INTO ResearchItemSpriteLocation values (1,380, 614,818)
	INSERT INTO ResearchItemSpriteLocation values (1,89, 818,818)
	INSERT INTO ResearchItemSpriteLocation values (1,381, 410,1634)
	INSERT INTO ResearchItemSpriteLocation values (1,382, 716,1226)
	INSERT INTO ResearchItemSpriteLocation values (1,86, 512,818)
	INSERT INTO ResearchItemSpriteLocation values (1,383, 104,818)
	INSERT INTO ResearchItemSpriteLocation values (1,90, 920,818)

END


/*******
*************************************************************************************
*************************************************************************************

ALL BASIC research items, except for unit unlocks, get the time factor applied to them. 
ATM, this is 2x for all but the noob realms.

We only do research items that are over 2 min as we need those for early quests

*************************************************************************************
*************************************************************************************
********/

UPDATE REsearchItems set ResearchTime = ResearchTime * @BASIC_RES_TIME_FACTOR where ResearchTime >  1200000000




/*******
*************************************************************************************
*************************************************************************************

UNIT UNLOCKS

*************************************************************************************
*************************************************************************************
********/
--Infantry Unlock--
INSERT INTO ResearchItems values (@RIT, 52, 600, dbo.Translate('Axe'), 18000000000, '', dbo.Translate('research52'), dbo.Translate('research52L'),null)
INSERT INTO ResearchItems values (@RIT, 53, 800, dbo.Translate('Bow'), 216000000000, '', dbo.Translate('research53'), dbo.Translate('research53L'),null)
INSERT INTO ResearchItems values (@RIT, 55, 600, dbo.Translate('Sword'), 18000000000, '', dbo.Translate('research55'), dbo.Translate('research55L'),null)--#55

--Knight Unlock--
INSERT INTO ResearchItems values (@RIT, 56, 1250, dbo.Translate('Horse Armor'), 216000000000, '', dbo.Translate('research56'), dbo.Translate('research56L'),null)
INSERT INTO ResearchItems values (@RIT, 57, 800, dbo.Translate('Horseshoes'), 18000000000, '', dbo.Translate('research57'), dbo.Translate('research57L'),null)
INSERT INTO ResearchItems values (@RIT, 58, 800, dbo.Translate('Saddles'), 18000000000, '', dbo.Translate('research58'), dbo.Translate('research58L'),null)
INSERT INTO ResearchItems values (@RIT, 80, 1000, dbo.Translate('Knight''s Lance'), 216000000000, '', dbo.Translate('research80'), dbo.Translate('research80L'),null)--#80
INSERT INTO ResearchItems values (@RIT, 138, 3000, dbo.Translate('Stirrup'), 432000000000, '', dbo.Translate('research138'), dbo.Translate('research138L'),null)

--Light Cavalry Unlock--
INSERT INTO ResearchItems values (@RIT, 60, 600, dbo.Translate('Horseback Riding'), 18000000000, '', dbo.Translate('research60'), dbo.Translate('research60L'),null)--#60
INSERT INTO ResearchItems values (@RIT, 169, 500, dbo.Translate('Horse Archer'), 216000000000, '', dbo.Translate('research169'), dbo.Translate('research169L'),null)
INSERT INTO ResearchItems values (@RIT, 170, 600, dbo.Translate('Cavalry Scouts'), 18000000000, '', dbo.Translate('research170'), dbo.Translate('research170L'),null)

--Spy Unlock--
INSERT INTO ResearchItems values (@RIT, 61, 250, dbo.Translate('Interrogation'), 18000000000, '', dbo.Translate('research61'), dbo.Translate('research61L'),null)
INSERT INTO ResearchItems values (@RIT, 62, 600, dbo.Translate('Optics'), 18000000000, '', dbo.Translate('research62'), dbo.Translate('research62L'),null)
INSERT INTO ResearchItems values (@RIT, 81, 500, dbo.Translate('Espionage'), 216000000000, '', dbo.Translate('research81'), dbo.Translate('research81L'),null)

--Trebuchet Unlock--
INSERT INTO ResearchItems values (@RIT, 139, 1000, dbo.Translate('Sling'), 18000000000, '', dbo.Translate('research139'), dbo.Translate('research139L'),null)
INSERT INTO ResearchItems values (@RIT, 140, 2000, dbo.Translate('Counterweight Lever'), 216000000000, '', dbo.Translate('research140'), dbo.Translate('research140L'),null)--#140
INSERT INTO ResearchItems values (@RIT, 141, 3000, dbo.Translate('Windlass'), 216000000000, '', dbo.Translate('research141'), dbo.Translate('research141L'),null)
INSERT INTO ResearchItems values (@RIT, 142, 5000, dbo.Translate('High Stress Trigger'), 432000000000, '', dbo.Translate('research142'), dbo.Translate('research142L'),null)

--
-- Unit research req
-- 

INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_infantry_ID, @RIT, 52)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_infantry_ID, @RIT, 53)
--INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_infantry_ID, @RIT, 54)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_infantry_ID, @RIT, 55)


INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_Knight_ID, @RIT, 138)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_Knight_ID, @RIT, 80)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_Knight_ID, @RIT, 56)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_Knight_ID, @RIT, 57)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_Knight_ID, @RIT, 58)
--INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_Knight_ID, @RIT, 59)

INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_LC_ID, @RIT, 60)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_LC_ID, @RIT, 169)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_LC_ID, @RIT, 170)

INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_Spy_ID, @RIT, 81)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_Spy_ID, @RIT, 61)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_Spy_ID, @RIT, 62)

INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_trab_ID, @RIT, 139)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_trab_ID, @RIT, 140)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_trab_ID, @RIT, 141)
INSERT INTO UnitTypeRecruitmentResearchRequirements VALUES (@Unit_trab_ID, @RIT, 142)



--Unit Dependencies--

INSERT INTO ResearchItemRequirements VALUES (@RIT, 169, @RIT, 60)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 169, @RIT, 170)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 53, @RIT, 52)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 53, @RIT, 55)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 56, @RIT, 57)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 80, @RIT, 57)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 138, @RIT, 56)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 138, @RIT, 80)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 62, @RIT, 61)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 81, @RIT, 62)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 140, @RIT, 139)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 141, @RIT, 139)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 142, @RIT, 140)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 142, @RIT, 141)
/*******
*************************************************************************************
*************************************************************************************

   END     UNIT UNLOCKS

*************************************************************************************
*************************************************************************************
********/


--Properties--

INSERT INTO ResearchItemProperties VALUES (@RIT, 1, @RITLP_HQTimeFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 500, @RITLP_HQTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 501, @RITLP_HQTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 2, @RITLP_HQTimeFactorPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 504, @RITLP_HQTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 505, @RITLP_HQTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 7, @RITLP_HQTimeFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 502, @RITLP_HQTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 503, @RITLP_HQTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 9, @RITLP_HQTimeFactorPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 506, @RITLP_HQTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 507, @RITLP_HQTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 12, @RITLP_HQTimeFactorPerc, 0.07)
INSERT INTO ResearchItemProperties VALUES (@RIT, 42, @RITLP_HQTimeFactorPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 75, @RITLP_HQTimeFactorPerc, 0.09)
INSERT INTO ResearchItemProperties VALUES (@RIT, 76, @RITLP_HQTimeFactorPerc, 0.12)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 510, @RITLP_HQTimeFactorPerc, 0.06)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 511, @RITLP_HQTimeFactorPerc, 0.08)
INSERT INTO ResearchItemProperties VALUES (@RIT, 77, @RITLP_HQTimeFactorPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 110, @RITLP_HQTimeFactorPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 111, @RITLP_HQTimeFactorPerc, 0.10)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 512, @RITLP_HQTimeFactorPerc, 0.06)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 513, @RITLP_HQTimeFactorPerc, 0.08)
INSERT INTO ResearchItemProperties VALUES (@RIT, 115, @RITLP_HQTimeFactorPerc, 0.08)
INSERT INTO ResearchItemProperties VALUES (@RIT, 129, @RITLP_HQTimeFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 508, @RITLP_HQTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 509, @RITLP_HQTimeFactorPerc, 0.03)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 151, @RITLP_HQTimeFactorPerc, 0.06)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 514, @RITLP_HQTimeFactorPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 515, @RITLP_HQTimeFactorPerc, 0.12)
INSERT INTO ResearchItemProperties VALUES (@RIT, 152, @RITLP_HQTimeFactorPerc, 0.08)
INSERT INTO ResearchItemProperties VALUES (@RIT, 153, @RITLP_HQTimeFactorPerc, 0.04)


INSERT INTO ResearchItemProperties VALUES (@RIT, 3, @RITLP_CoinMineProductionPerc, 0.01)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 516, @RITLP_CoinMineProductionPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 517, @RITLP_CoinMineProductionPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 4, @RITLP_CoinMineProductionPerc, 0.01)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 518, @RITLP_CoinMineProductionPerc, 0.01)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 519, @RITLP_CoinMineProductionPerc, 0.02)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 5, @RITLP_CoinMineProductionPerc, 0.02)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 6, @RITLP_CoinMineProductionPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 10, @RITLP_CoinMineProductionPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 14, @RITLP_CoinMineProductionPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 15, @RITLP_CoinMineProductionPerc, 0.01)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 520, @RITLP_CoinMineProductionPerc, 0.01)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 521, @RITLP_CoinMineProductionPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 16, @RITLP_CoinMineProductionPerc, 0.05)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 17, @RITLP_CoinMineProductionPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 18, @RITLP_CoinMineProductionPerc, 0.01)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 522, @RITLP_CoinMineProductionPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 523, @RITLP_CoinMineProductionPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 19, @RITLP_CoinMineProductionPerc, 0.01)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 524, @RITLP_CoinMineProductionPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 525, @RITLP_CoinMineProductionPerc, 0.01)
INSERT INTO ResearchItemProperties VALUES (@RIT, 24, @RITLP_CoinMineProductionPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 25, @RITLP_CoinMineProductionPerc, 0.10)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 530, @RITLP_CoinMineProductionPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 531, @RITLP_CoinMineProductionPerc, 0.08)
INSERT INTO ResearchItemProperties VALUES (@RIT, 26, @RITLP_CoinMineProductionPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 27, @RITLP_CoinMineProductionPerc, 0.04)
INSERT INTO ResearchItemProperties VALUES (@RIT, 28, @RITLP_CoinMineProductionPerc, 0.07)
INSERT INTO ResearchItemProperties VALUES (@RIT, 29, @RITLP_CoinMineProductionPerc, 0.06)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 528, @RITLP_CoinMineProductionPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 529, @RITLP_CoinMineProductionPerc, 0.07)
INSERT INTO ResearchItemProperties VALUES (@RIT, 30, @RITLP_CoinMineProductionPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 40, @RITLP_CoinMineProductionPerc, 0.04)
INSERT INTO ResearchItemProperties VALUES (@RIT, 121, @RITLP_CoinMineProductionPerc, 0.07)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 532, @RITLP_CoinMineProductionPerc, 0.05)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 533, @RITLP_CoinMineProductionPerc, 0.08)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 122, @RITLP_CoinMineProductionPerc, 0.02)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 123, @RITLP_CoinMineProductionPerc, 0.03)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 124, @RITLP_CoinMineProductionPerc, 0.02)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 125, @RITLP_CoinMineProductionPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 126, @RITLP_CoinMineProductionPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 127, @RITLP_CoinMineProductionPerc, 0.04)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 128, @RITLP_CoinMineProductionPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 526, @RITLP_CoinMineProductionPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 527, @RITLP_CoinMineProductionPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 154, @RITLP_CoinMineProductionPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 155, @RITLP_CoinMineProductionPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 156, @RITLP_CoinMineProductionPerc, 0.07)

INSERT INTO ResearchItemProperties VALUES (@RIT, 8, @RITLP_PopulationCapacityPerc, 0.14)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 546, @RITLP_PopulationCapacityPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 547, @RITLP_PopulationCapacityPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 33, @RITLP_PopulationCapacityPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 534, @RITLP_PopulationCapacityPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 535, @RITLP_PopulationCapacityPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 34, @RITLP_PopulationCapacityPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 536, @RITLP_PopulationCapacityPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 537, @RITLP_PopulationCapacityPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 35, @RITLP_PopulationCapacityPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 540, @RITLP_PopulationCapacityPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 541, @RITLP_PopulationCapacityPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 36, @RITLP_PopulationCapacityPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 544, @RITLP_PopulationCapacityPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 545, @RITLP_PopulationCapacityPerc, 0.02)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 37, @RITLP_PopulationCapacityPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 38, @RITLP_PopulationCapacityPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 39, @RITLP_PopulationCapacityPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 538, @RITLP_PopulationCapacityPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 539, @RITLP_PopulationCapacityPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 41, @RITLP_PopulationCapacityPerc, 0.07)
INSERT INTO ResearchItemProperties VALUES (@RIT, 118, @RITLP_PopulationCapacityPerc, 0.10)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 548, @RITLP_PopulationCapacityPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 549, @RITLP_PopulationCapacityPerc, 0.04)
INSERT INTO ResearchItemProperties VALUES (@RIT, 119, @RITLP_PopulationCapacityPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 542, @RITLP_PopulationCapacityPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 543, @RITLP_PopulationCapacityPerc, 0.04)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 120, @RITLP_PopulationCapacityPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 550, @RITLP_PopulationCapacityPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 551, @RITLP_PopulationCapacityPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 147, @RITLP_PopulationCapacityPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 148, @RITLP_PopulationCapacityPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 149, @RITLP_PopulationCapacityPerc, 0.07)
INSERT INTO ResearchItemProperties VALUES (@RIT, 150, @RITLP_PopulationCapacityPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 552, @RITLP_PopulationCapacityPerc, 0.06)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 553, @RITLP_PopulationCapacityPerc, 0.07)

INSERT INTO ResearchItemProperties VALUES (@RIT, 11, @RITLP_CoinTransportAmountPerc, 0.10)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 558, @RITLP_CoinTransportAmountPerc, 0.12)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 559, @RITLP_CoinTransportAmountPerc, 0.16)
INSERT INTO ResearchItemProperties VALUES (@RIT, 43, @RITLP_CoinTransportAmountPerc, 0.06)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 554, @RITLP_CoinTransportAmountPerc, 0.08)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 555, @RITLP_CoinTransportAmountPerc, 0.10)
INSERT INTO ResearchItemProperties VALUES (@RIT, 46, @RITLP_CoinTransportAmountPerc, 0.14)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 560, @RITLP_CoinTransportAmountPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 561, @RITLP_CoinTransportAmountPerc, 0.12)
INSERT INTO ResearchItemProperties VALUES (@RIT, 47, @RITLP_CoinTransportAmountPerc, 0.08)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 556, @RITLP_CoinTransportAmountPerc, 0.10)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 557, @RITLP_CoinTransportAmountPerc, 0.14)
INSERT INTO ResearchItemProperties VALUES (@RIT, 79, @RITLP_CoinTransportAmountPerc, 0.30)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 562, @RITLP_CoinTransportAmountPerc, 0.12)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 563, @RITLP_CoinTransportAmountPerc, 0.16)
INSERT INTO ResearchItemProperties VALUES (@RIT, 132, @RITLP_CoinTransportAmountPerc, 0.14)
INSERT INTO ResearchItemProperties VALUES (@RIT, 133, @RITLP_CoinTransportAmountPerc, 0.20)
INSERT INTO ResearchItemProperties VALUES (@RIT, 134, @RITLP_CoinTransportAmountPerc, 0.28)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 135, @RITLP_CoinTransportAmountPerc, 0.20)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 564, @RITLP_CoinTransportAmountPerc, 0.24)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 565, @RITLP_CoinTransportAmountPerc, 0.30)

INSERT INTO ResearchItemProperties VALUES (@RIT, 13, @RITLP_TreasuryCapacityPerc, 0.04)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 570, @RITLP_TreasuryCapacityPerc, 0.05)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 571, @RITLP_TreasuryCapacityPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 20, @RITLP_TreasuryCapacityPerc, 0.04)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 566, @RITLP_TreasuryCapacityPerc, 0.05)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 567, @RITLP_TreasuryCapacityPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 21, @RITLP_TreasuryCapacityPerc, 0.14)
INSERT INTO ResearchItemProperties VALUES (@RIT, 22, @RITLP_TreasuryCapacityPerc, 0.10)
INSERT INTO ResearchItemProperties VALUES (@RIT, 31, @RITLP_TreasuryCapacityPerc, 0.16)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 576, @RITLP_TreasuryCapacityPerc, 0.14)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 577, @RITLP_TreasuryCapacityPerc, 0.20)
INSERT INTO ResearchItemProperties VALUES (@RIT, 68, @RITLP_TreasuryCapacityPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 568, @RITLP_TreasuryCapacityPerc, 0.04)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 569, @RITLP_TreasuryCapacityPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 136, @RITLP_TreasuryCapacityPerc, 0.10)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 574, @RITLP_TreasuryCapacityPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 575, @RITLP_TreasuryCapacityPerc, 0.12)
INSERT INTO ResearchItemProperties VALUES (@RIT, 137, @RITLP_TreasuryCapacityPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 572, @RITLP_TreasuryCapacityPerc, 0.07)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 573, @RITLP_TreasuryCapacityPerc, 0.08)

INSERT INTO ResearchItemProperties VALUES (@RIT, 23, @RITLP_BarracksRecruitTimeFactorPerc, 0.05)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 580, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 581, @RITLP_BarracksRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 32, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 578, @RITLP_BarracksRecruitTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 579, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 54, @RITLP_BarracksRecruitTimeFactorPerc, 0.05)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 588, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 589, @RITLP_BarracksRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 59, @RITLP_BarracksRecruitTimeFactorPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 65, @RITLP_BarracksRecruitTimeFactorPerc, 0.01)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 592, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 593, @RITLP_BarracksRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 66, @RITLP_BarracksRecruitTimeFactorPerc, 0.05)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 594, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 595, @RITLP_BarracksRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 94, @RITLP_BarracksRecruitTimeFactorPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 582, @RITLP_BarracksRecruitTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 583, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 95, @RITLP_BarracksRecruitTimeFactorPerc, 0.10)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 590, @RITLP_BarracksRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 591, @RITLP_BarracksRecruitTimeFactorPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 96, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 586, @RITLP_BarracksRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 587, @RITLP_BarracksRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 97, @RITLP_BarracksRecruitTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 584, @RITLP_BarracksRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 585, @RITLP_BarracksRecruitTimeFactorPerc, 0.04)
INSERT INTO ResearchItemProperties VALUES (@RIT, 103, @RITLP_BarracksRecruitTimeFactorPerc, 0.08)
INSERT INTO ResearchItemProperties VALUES (@RIT, 104, @RITLP_BarracksRecruitTimeFactorPerc, 0.12)
INSERT INTO ResearchItemProperties VALUES (@RIT, 108, @RITLP_BarracksRecruitTimeFactorPerc, 0.01)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 598, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 599, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 109, @RITLP_BarracksRecruitTimeFactorPerc, 0.06)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 600, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 601, @RITLP_BarracksRecruitTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 144, @RITLP_BarracksRecruitTimeFactorPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 602, @RITLP_BarracksRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 603, @RITLP_BarracksRecruitTimeFactorPerc, 0.04)
INSERT INTO ResearchItemProperties VALUES (@RIT, 146, @RITLP_BarracksRecruitTimeFactorPerc, 0.07)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 596, @RITLP_BarracksRecruitTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 597, @RITLP_BarracksRecruitTimeFactorPerc, 0.08)

INSERT INTO ResearchItemProperties VALUES (@RIT, 44, @RITLP_TavernRecruitTimeFactorPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 604, @RITLP_TavernRecruitTimeFactorPerc, 0.04)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 605, @RITLP_TavernRecruitTimeFactorPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 45, @RITLP_TavernRecruitTimeFactorPerc, 0.10)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 606, @RITLP_TavernRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 607, @RITLP_TavernRecruitTimeFactorPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 67, @RITLP_TavernRecruitTimeFactorPerc, 0.12)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 608, @RITLP_TavernRecruitTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 609, @RITLP_TavernRecruitTimeFactorPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 72, @RITLP_TavernRecruitTimeFactorPerc, 0.09)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 610, @RITLP_TavernRecruitTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 611, @RITLP_TavernRecruitTimeFactorPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 78, @RITLP_TavernRecruitTimeFactorPerc, 0.04)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 612, @RITLP_TavernRecruitTimeFactorPerc, 0.04)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 613, @RITLP_TavernRecruitTimeFactorPerc, 0.07)
INSERT INTO ResearchItemProperties VALUES (@RIT, 130, @RITLP_TavernRecruitTimeFactorPerc, 0.02)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 616, @RITLP_TavernRecruitTimeFactorPerc, 0.03)
	INSERT INTO ResearchItemProperties VALUES (@RIT, 617, @RITLP_TavernRecruitTimeFactorPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 131, @RITLP_TavernRecruitTimeFactorPerc, 0.20)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 618, @RITLP_TavernRecruitTimeFactorPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 619, @RITLP_TavernRecruitTimeFactorPerc, 0.14)
INSERT INTO ResearchItemProperties VALUES (@RIT, 162, @RITLP_TavernRecruitTimeFactorPerc, 0.11)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 614, @RITLP_TavernRecruitTimeFactorPerc, 0.09)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 615, @RITLP_TavernRecruitTimeFactorPerc, 0.15)


INSERT INTO ResearchItemProperties VALUES (@RIT, 48, @RITLP_DefenseFactorPerc, 0.03)		-- wall bonus
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 620, @RITLP_DefenseFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 621, @RITLP_DefenseFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 49, @RITLP_DefenseFactorPerc, 0.06)		-- wall bonus
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 622, @RITLP_DefenseFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 623, @RITLP_DefenseFactorPerc, 0.04)
INSERT INTO ResearchItemProperties VALUES (@RIT, 50, @RITLP_DefenseFactorPerc, 0.04)		-- tower bonus
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 624, @RITLP_DefenseFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 625, @RITLP_DefenseFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 51, @RITLP_DefenseFactorPerc, 0.07)		--wall bonus
INSERT INTO ResearchItemProperties VALUES (@RIT, 69, @RITLP_DefenseFactorPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 83, @RITLP_DefenseFactorPerc, 0.04)		-- wall bonus
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 626, @RITLP_DefenseFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 627, @RITLP_DefenseFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 84, @RITLP_DefenseFactorPerc, 0.05)		-- wall bonus
INSERT INTO ResearchItemProperties VALUES (@RIT, 85, @RITLP_DefenseFactorPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 88, @RITLP_DefenseFactorPerc, 0.05)	
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 628, @RITLP_DefenseFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 629, @RITLP_DefenseFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 91, @RITLP_DefenseFactorPerc, 0.07)		-- tower bonus
INSERT INTO ResearchItemProperties VALUES (@RIT, 92, @RITLP_DefenseFactorPerc, 0.05)		-- tower bonus
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 636, @RITLP_DefenseFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 637, @RITLP_DefenseFactorPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 93, @RITLP_DefenseFactorPerc, 0.15)		-- tower bonus
INSERT INTO ResearchItemProperties VALUES (@RIT, 163, @RITLP_DefenseFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 632, @RITLP_DefenseFactorPerc, 0.01)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 633, @RITLP_DefenseFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 164, @RITLP_DefenseFactorPerc, 0.10)
INSERT INTO ResearchItemProperties VALUES (@RIT, 165, @RITLP_DefenseFactorPerc, 0.05) 
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 630, @RITLP_DefenseFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 631, @RITLP_DefenseFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 168, @RITLP_DefenseFactorPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 634, @RITLP_DefenseFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 635, @RITLP_DefenseFactorPerc, 0.03)


INSERT INTO ResearchItemProperties VALUES (@RIT, 63, @RITLP_StableRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 638, @RITLP_StableRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 639, @RITLP_StableRecruitTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 64, @RITLP_StableRecruitTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 640, @RITLP_StableRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 641, @RITLP_StableRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 70, @RITLP_StableRecruitTimeFactorPerc, 0.12)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 660, @RITLP_StableRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 661, @RITLP_StableRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 98, @RITLP_StableRecruitTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 650, @RITLP_StableRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 651, @RITLP_StableRecruitTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 99, @RITLP_StableRecruitTimeFactorPerc, 0.05)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 652, @RITLP_StableRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 653, @RITLP_StableRecruitTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 100, @RITLP_StableRecruitTimeFactorPerc, 0.10)
INSERT INTO ResearchItemProperties VALUES (@RIT, 102, @RITLP_StableRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 648, @RITLP_StableRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 649, @RITLP_StableRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 105, @RITLP_StableRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 646, @RITLP_StableRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 647, @RITLP_StableRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 107, @RITLP_StableRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 644, @RITLP_StableRecruitTimeFactorPerc, 0.02)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 645, @RITLP_StableRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 112, @RITLP_StableRecruitTimeFactorPerc, 0.07)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 654, @RITLP_StableRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 655, @RITLP_StableRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 113, @RITLP_StableRecruitTimeFactorPerc, 0.14)
INSERT INTO ResearchItemProperties VALUES (@RIT, 116, @RITLP_StableRecruitTimeFactorPerc, 0.08)
INSERT INTO ResearchItemProperties VALUES (@RIT, 117, @RITLP_StableRecruitTimeFactorPerc, 0.07)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 656, @RITLP_StableRecruitTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 657, @RITLP_StableRecruitTimeFactorPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 159, @RITLP_StableRecruitTimeFactorPerc, 0.06)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 642, @RITLP_StableRecruitTimeFactorPerc, 0.03)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 643, @RITLP_StableRecruitTimeFactorPerc, 0.03)
INSERT INTO ResearchItemProperties VALUES (@RIT, 160, @RITLP_StableRecruitTimeFactorPerc, 0.05)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 658, @RITLP_StableRecruitTimeFactorPerc, 0.01)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 659, @RITLP_StableRecruitTimeFactorPerc, 0.02)
INSERT INTO ResearchItemProperties VALUES (@RIT, 161, @RITLP_StableRecruitTimeFactorPerc, 0.07)


INSERT INTO ResearchItemProperties VALUES (@RIT, 71, @RITLP_WorkshopRecruitTimeFactorPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 662, @RITLP_WorkshopRecruitTimeFactorPerc, 0.04)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 663, @RITLP_WorkshopRecruitTimeFactorPerc, 0.04)
INSERT INTO ResearchItemProperties VALUES (@RIT, 73, @RITLP_WorkshopRecruitTimeFactorPerc, 0.12)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 666, @RITLP_WorkshopRecruitTimeFactorPerc, 0.05)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 667, @RITLP_WorkshopRecruitTimeFactorPerc, 0.12)
INSERT INTO ResearchItemProperties VALUES (@RIT, 74, @RITLP_WorkshopRecruitTimeFactorPerc, 0.10)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 664, @RITLP_WorkshopRecruitTimeFactorPerc, 0.05)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 665, @RITLP_WorkshopRecruitTimeFactorPerc, 0.06)
INSERT INTO ResearchItemProperties VALUES (@RIT, 101, @RITLP_WorkshopRecruitTimeFactorPerc, 0.12)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 668, @RITLP_WorkshopRecruitTimeFactorPerc, 0.05)	
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 669, @RITLP_WorkshopRecruitTimeFactorPerc, 0.07)
INSERT INTO ResearchItemProperties VALUES (@RIT, 106, @RITLP_WorkshopRecruitTimeFactorPerc, 0.16)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 670, @RITLP_WorkshopRecruitTimeFactorPerc, 0.05)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 671, @RITLP_WorkshopRecruitTimeFactorPerc, 0.08)
INSERT INTO ResearchItemProperties VALUES (@RIT, 114, @RITLP_WorkshopRecruitTimeFactorPerc, 0.20)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 672, @RITLP_WorkshopRecruitTimeFactorPerc, 0.08)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 673, @RITLP_WorkshopRecruitTimeFactorPerc, 0.12)
INSERT INTO ResearchItemProperties VALUES (@RIT, 157, @RITLP_WorkshopRecruitTimeFactorPerc, 0.10)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 674, @RITLP_WorkshopRecruitTimeFactorPerc, 0.05)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 675, @RITLP_WorkshopRecruitTimeFactorPerc, 0.05)
INSERT INTO ResearchItemProperties VALUES (@RIT, 158, @RITLP_WorkshopRecruitTimeFactorPerc, 0.12)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 676, @RITLP_WorkshopRecruitTimeFactorPerc, 0.06)
	--INSERT INTO ResearchItemProperties VALUES (@RIT, 677, @RITLP_WorkshopRecruitTimeFactorPerc, 0.10)



--INSERT INTO ResearchItemProperties VALUES (@RIT, 82, @RITLP_DefenseFactorPerc, 0.05)		-- wall bonus		-- wall bonus
--INSERT INTO ResearchItemProperties VALUES (@RIT, 86, @RITLP_DefenseFactorPerc, 0.05)		-- wall bonus
--INSERT INTO ResearchItemProperties VALUES (@RIT, 87, @RITLP_DefenseFactorPerc, 0.05)		-- wall bonus	-- wall bonus
--INSERT INTO ResearchItemProperties VALUES (@RIT, 89, @RITLP_DefenseFactorPerc, 0.05)		-- wall bonus
--INSERT INTO ResearchItemProperties VALUES (@RIT, 90, @RITLP_DefenseFactorPerc, 0.05)		-- wall bonus
--INSERT INTO ResearchItemProperties VALUES (@RIT, 166, @RITLP_DefenseFactorPerc, 0.0)
--INSERT INTO ResearchItemProperties VALUES (@RIT, 167, @RITLP_DefenseFactorPerc, 0.0)


--REQUIREMENTS--
--HQ--
INSERT INTO ResearchItemRequirements VALUES (@RIT, 2, @RIT, 1)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 504, @RIT, 2)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 500, @RIT, 2)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 9, @RIT, 7)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 502, @RIT, 9)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 506, @RIT, 9)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 508, @RIT, 129)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 153, @RIT, 504)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 153, @RIT, 500)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 110, @RIT, 153)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 152, @RIT, 110)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 115, @RIT, 110)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 111, @RIT, 115)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 111, @RIT, 152)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 42, @RIT, 506)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 42, @RIT, 502)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 77, @RIT, 42)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 12, @RIT, 77)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 75, @RIT, 77)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 76, @RIT, 12)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 76, @RIT, 75)

--Silver Mine--
INSERT INTO ResearchItemRequirements VALUES (@RIT, 518, @RIT, 3)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 518, @RIT, 4)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 516, @RIT, 518)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 26, @RIT, 516)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 27, @RIT, 26)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 30, @RIT, 27)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 156, @RIT, 30)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 522, @RIT, 518)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 522, @RIT, 18)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 10, @RIT, 522)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 14, @RIT, 10)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 16, @RIT, 14)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 127, @RIT, 16)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 24, @RIT, 16)
--INSERT INTO ResearchItemRequirements VALUES (@RIT, 23, @RIT, 127)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 29, @RIT, 127)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 29, @RIT, 24)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 18, @RIT, 15)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 520, @RIT, 15)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 19, @RIT, 15)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 524, @RIT, 19)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 126, @RIT, 524)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 40, @RIT, 126)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 154, @RIT, 40)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 155, @RIT, 154)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 121, @RIT, 155)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 25, @RIT, 121)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 28, @RIT, 127)


--Farmland--
INSERT INTO ResearchItemRequirements VALUES (@RIT, 34, @RIT, 33)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 36, @RIT, 35)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 538, @RIT, 39)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 536, @RIT, 34)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 534, @RIT, 34)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 148, @RIT, 536)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 148, @RIT, 534)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 41, @RIT, 148)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 149, @RIT, 41)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 150, @RIT, 149)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 8, @RIT, 150)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 540, @RIT, 36)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 544, @RIT, 36)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 38, @RIT, 540)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 38, @RIT, 544)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 147, @RIT, 38)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 147, @RIT, 538)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 119, @RIT, 147)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 118, @RIT, 119)


--Trading Post--
INSERT INTO ResearchItemRequirements VALUES (@RIT, 554, @RIT, 43)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 555, @RIT, 554)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 46, @RIT, 555)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 556, @RIT, 47)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 557, @RIT, 556)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 558, @RIT, 11)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 559, @RIT, 558)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 132, @RIT, 559)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 132, @RIT, 557)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 133, @RIT, 132)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 134, @RIT, 133)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 79, @RIT, 133)

--Treasury--
INSERT INTO ResearchItemRequirements VALUES (@RIT, 566, @RIT, 20)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 567, @RIT, 566)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 137, @RIT, 567)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 137, @RIT, 571)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 22, @RIT, 137)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 21, @RIT, 22)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 31, @RIT, 22)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 568, @RIT, 68)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 569, @RIT, 568)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 136, @RIT, 569)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 570, @RIT, 13)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 571, @RIT, 570)

--Barracks--
INSERT INTO ResearchItemRequirements VALUES (@RIT, 94, @RIT, 32)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 96, @RIT, 32)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 578, @RIT, 94)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 578, @RIT, 96)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 582, @RIT, 94)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 586, @RIT, 96)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 23, @RIT, 578)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 97, @RIT, 586)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 59, @RIT, 23)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 54, @RIT, 97)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 95, @RIT, 54)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 592, @RIT, 65)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 66, @RIT, 592)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 598, @RIT, 108)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 66, @RIT, 592)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 66, @RIT, 598)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 109, @RIT, 66)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 146, @RIT, 109)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 144, @RIT, 146)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 103, @RIT, 146)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 104, @RIT, 103)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 104, @RIT, 144)

--Tavern--
INSERT INTO ResearchItemRequirements VALUES (@RIT, 604, @RIT, 44)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 605, @RIT, 604)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 45, @RIT, 605)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 67, @RIT, 45)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 612, @RIT, 78)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 613, @RIT, 612)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 72, @RIT, 613)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 72, @RIT, 617)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 616, @RIT, 130)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 617, @RIT, 616)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 162, @RIT, 72)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 131, @RIT, 162)


--Walls--
INSERT INTO ResearchItemRequirements VALUES (@RIT, 163, @RIT, 48)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 165, @RIT, 163)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 49, @RIT, 165)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 168, @RIT, 49)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 51, @RIT, 49)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 92, @RIT, 168)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 93, @RIT, 92)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 84, @RIT, 165)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 164, @RIT, 168)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 50, @RIT, 48)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 88, @RIT, 50)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 83, @RIT, 50)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 85, @RIT, 88)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 69, @RIT, 83)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 91, @RIT, 69)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 91, @RIT, 69)

--Stables--
INSERT INTO ResearchItemRequirements VALUES (@RIT, 63, @RIT, 105)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 64, @RIT, 63)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 159, @RIT, 64)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 161, @RIT, 159)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 116, @RIT, 161)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 70, @RIT, 116)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 70, @RIT, 100)

INSERT INTO ResearchItemRequirements VALUES (@RIT, 102, @RIT, 105)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 160, @RIT, 102)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 107, @RIT, 102)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 99, @RIT, 160)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 98, @RIT, 160)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 112, @RIT, 99)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 112, @RIT, 98)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 100, @RIT, 112)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 117, @RIT, 112)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 113, @RIT, 100)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 113, @RIT, 117)

--Siege Workshop--
INSERT INTO ResearchItemRequirements VALUES (@RIT, 74, @RIT, 71)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 157, @RIT, 74)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 158, @RIT, 157)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 101, @RIT, 157)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 73, @RIT, 158)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 73, @RIT, 101)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 106, @RIT, 101)
INSERT INTO ResearchItemRequirements VALUES (@RIT, 114, @RIT, 106)


----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------Research-----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------- -- AGE 1 -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------Government Type Research Items---------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

	
INSERT INTO ResearchItems values (@RIT, 341, 1000000000, dbo.Translate('Supreme Authority'), 36288000000000, '', dbo.Translate('research341'), dbo.Translate('research341L'),null)
INSERT INTO ResearchItems values (@RIT, 342, 1000000000, dbo.Translate('Impressment'), 36288000000000, '', dbo.Translate('research342'), dbo.Translate('research342L'),null)
INSERT INTO ResearchItems values (@RIT, 343, 1000000000, dbo.Translate('Strength of Arms'), 36288000000000, '', dbo.Translate('research343'), dbo.Translate('research343L'),null)
INSERT INTO ResearchItems values (@RIT, 344, 1000000000, dbo.Translate('Long Live the King!'), 36288000000000, '', dbo.Translate('research344'), dbo.Translate('research344L'),null)
INSERT INTO ResearchItems values (@RIT, 345, 1000000000, dbo.Translate('Free Trade'), 36288000000000, '', dbo.Translate('research345'), dbo.Translate('research345L'),null)
INSERT INTO ResearchItems values (@RIT, 346, 1000000000, dbo.Translate('Land Ownership'), 51840000000000, '', dbo.Translate('research346'), dbo.Translate('research346L'),null)
INSERT INTO ResearchItems values (@RIT, 347, 1000000000, dbo.Translate('Order of Shadows'), 36288000000000, '', dbo.Translate('research347'), dbo.Translate('research347L'),null)
INSERT INTO ResearchItems values (@RIT, 348, 1000000000, dbo.Translate('For the Horde!'), 51840000000000, '', dbo.Translate('research348'), dbo.Translate('research348L'),null)
INSERT INTO ResearchItems values (@RIT, 349, 1000000000, dbo.Translate('Hasty Siegeworks'), 36288000000000, '', dbo.Translate('research349'), dbo.Translate('research349L'),null)
INSERT INTO ResearchItems values (@RIT, 350, 1000000000, dbo.Translate('Hand of Midas'), 51840000000000, '', dbo.Translate('research350'), dbo.Translate('research350L'),null)
INSERT INTO ResearchItems values (@RIT, 351, 1000000000, dbo.Translate('National Bank'), 36288000000000, '', dbo.Translate('research351'), dbo.Translate('research351L'),null)
INSERT INTO ResearchItems values (@RIT, 352, 1000000000, dbo.Translate('Dilligence'), 36288000000000, '', dbo.Translate('research352'), dbo.Translate('research352L'),null)
INSERT INTO ResearchItems values (@RIT, 353, 1000000000, dbo.Translate('Holy Warriors'), 51840000000000, '', dbo.Translate('research353'), dbo.Translate('research353L'),null)
INSERT INTO ResearchItems values (@RIT, 354, 1000000000, dbo.Translate('Martyrdom'), 51840000000000, '', dbo.Translate('research354'), dbo.Translate('research354L'),null)
INSERT INTO ResearchItems values (@RIT, 355, 1000000000, dbo.Translate('Silk Road'), 18144000000000, '', dbo.Translate('research355'), dbo.Translate('research355L'),null)
	
INSERT INTO ResearchItemProperties VALUES (@RIT, 341, @RITLP_HQTimeFactorPerc, 0.30)
INSERT INTO ResearchItemProperties VALUES (@RIT, 342, @RITLP_BarracksRecruitTimeFactorPerc, 0.10)
INSERT INTO ResearchItemProperties VALUES (@RIT, 343, @RITLP_StableRecruitTimeFactorPerc, 0.10)
INSERT INTO ResearchItemProperties VALUES (@RIT, 344, @RITLP_AttackFactorPerc, 0.10)
INSERT INTO ResearchItemProperties VALUES (@RIT, 345, @RITLP_CoinMineProductionPerc, 0.10)
INSERT INTO ResearchItemProperties VALUES (@RIT, 346, @RITLP_PopulationCapacityPerc, 0.20)
INSERT INTO ResearchItemProperties VALUES (@RIT, 347, @RITLP_TavernRecruitTimeFactorPerc, 0.50)
INSERT INTO ResearchItemProperties VALUES (@RIT, 348, @RITLP_StableRecruitTimeFactorPerc, 0.40)
INSERT INTO ResearchItemProperties VALUES (@RIT, 349, @RITLP_WorkshopRecruitTimeFactorPerc, 0.50)
INSERT INTO ResearchItemProperties VALUES (@RIT, 350, @RITLP_CoinMineProductionPerc, 0.30)
INSERT INTO ResearchItemProperties VALUES (@RIT, 351, @RITLP_TreasuryCapacityPerc, 0.50)
INSERT INTO ResearchItemProperties VALUES (@RIT, 352, @RITLP_HQTimeFactorPerc, 0.10)
INSERT INTO ResearchItemProperties VALUES (@RIT, 353, @RITLP_BarracksRecruitTimeFactorPerc, 0.40)
INSERT INTO ResearchItemProperties VALUES (@RIT, 354, @RITLP_VillageDefenseFactorPerc, 0.20)
INSERT INTO ResearchItemProperties VALUES (@RIT, 355, @RITLP_CoinTransportAmountPerc, 1.00)




--
-- HACK - ADJUST THE COST
-- 
update ResearchItems set PriceInCoins = 0 
update ResearchItems set PriceInCoins = 1000000000 where researchitemid between 341 and 355


--
-- research item's sprite sheet locations
--

INSERT INTO ResearchItemSpriteLocation values (1,1, 2,2)
	INSERT INTO ResearchItemSpriteLocation values (1,500, 2,2)
	--INSERT INTO ResearchItemSpriteLocation values (1,501, 2,2)
INSERT INTO ResearchItemSpriteLocation values (1,2, 104,2)
	INSERT INTO ResearchItemSpriteLocation values (1,504, 104,2)
	--INSERT INTO ResearchItemSpriteLocation values (1,505, 104,2)
INSERT INTO ResearchItemSpriteLocation values (1,3, 206,2)
	INSERT INTO ResearchItemSpriteLocation values (1,516, 206,2)
	--INSERT INTO ResearchItemSpriteLocation values (1,517, 206,2)
INSERT INTO ResearchItemSpriteLocation values (1,4, 308,2)
	INSERT INTO ResearchItemSpriteLocation values (1,518, 308,2)
	--INSERT INTO ResearchItemSpriteLocation values (1,519, 308,2)
--INSERT INTO ResearchItemSpriteLocation values (1,5, 410,2)
--INSERT INTO ResearchItemSpriteLocation values (1,6, 512,2)
INSERT INTO ResearchItemSpriteLocation values (1,7, 614,2)
	INSERT INTO ResearchItemSpriteLocation values (1,502, 614,2)
	--INSERT INTO ResearchItemSpriteLocation values (1,503, 614,2)
INSERT INTO ResearchItemSpriteLocation values (1,8, 716,2)
	--INSERT INTO ResearchItemSpriteLocation values (1,546, 716,2)
	--INSERT INTO ResearchItemSpriteLocation values (1,547, 716,2)
INSERT INTO ResearchItemSpriteLocation values (1,9, 818,2)
	INSERT INTO ResearchItemSpriteLocation values (1,506, 818,2)
	--INSERT INTO ResearchItemSpriteLocation values (1,507, 818,2)
INSERT INTO ResearchItemSpriteLocation values (1,10, 920,2)
INSERT INTO ResearchItemSpriteLocation values (1,11, 2,104)
	INSERT INTO ResearchItemSpriteLocation values (1,558, 2,104)
	INSERT INTO ResearchItemSpriteLocation values (1,559, 2,104)
INSERT INTO ResearchItemSpriteLocation values (1,12, 104,104)
INSERT INTO ResearchItemSpriteLocation values (1,13, 206,104)
	INSERT INTO ResearchItemSpriteLocation values (1,570, 206,104)
	INSERT INTO ResearchItemSpriteLocation values (1,571, 206,104)
INSERT INTO ResearchItemSpriteLocation values (1,14, 308,104)
INSERT INTO ResearchItemSpriteLocation values (1,15, 410,104)
	INSERT INTO ResearchItemSpriteLocation values (1,520, 410,104)
	--INSERT INTO ResearchItemSpriteLocation values (1,521, 410,104)
INSERT INTO ResearchItemSpriteLocation values (1,16, 512,104)
--INSERT INTO ResearchItemSpriteLocation values (1,17, 614,104)
INSERT INTO ResearchItemSpriteLocation values (1,18, 716,104)
	INSERT INTO ResearchItemSpriteLocation values (1,522, 716,104)
	--INSERT INTO ResearchItemSpriteLocation values (1,523, 716,104)
INSERT INTO ResearchItemSpriteLocation values (1,19, 818,104)
	INSERT INTO ResearchItemSpriteLocation values (1,524, 818,104)
	--INSERT INTO ResearchItemSpriteLocation values (1,525, 818,104)
INSERT INTO ResearchItemSpriteLocation values (1,20, 920,104)
	INSERT INTO ResearchItemSpriteLocation values (1,566, 920,104)
	INSERT INTO ResearchItemSpriteLocation values (1,567, 920,104)
INSERT INTO ResearchItemSpriteLocation values (1,21, 2,206)
INSERT INTO ResearchItemSpriteLocation values (1,22, 104,206)
INSERT INTO ResearchItemSpriteLocation values (1,23, 206,206)
	--INSERT INTO ResearchItemSpriteLocation values (1,580, 206,206)
	--INSERT INTO ResearchItemSpriteLocation values (1,581, 206,206)
INSERT INTO ResearchItemSpriteLocation values (1,24, 308,206)
INSERT INTO ResearchItemSpriteLocation values (1,25, 410,206)
	--INSERT INTO ResearchItemSpriteLocation values (1,530, 410,206)
	--INSERT INTO ResearchItemSpriteLocation values (1,531, 410,206)
INSERT INTO ResearchItemSpriteLocation values (1,26, 512,206)
INSERT INTO ResearchItemSpriteLocation values (1,27, 614,206)
INSERT INTO ResearchItemSpriteLocation values (1,28, 716,206)
INSERT INTO ResearchItemSpriteLocation values (1,29, 818,206)
	--INSERT INTO ResearchItemSpriteLocation values (1,528, 818,206)
	--INSERT INTO ResearchItemSpriteLocation values (1,529, 818,206)
INSERT INTO ResearchItemSpriteLocation values (1,30, 920,206)
INSERT INTO ResearchItemSpriteLocation values (1,31, 2,308)
	--INSERT INTO ResearchItemSpriteLocation values (1,576, 2,308)
	--INSERT INTO ResearchItemSpriteLocation values (1,577, 2,308)
INSERT INTO ResearchItemSpriteLocation values (1,32, 104,308)
	INSERT INTO ResearchItemSpriteLocation values (1,578, 104,308)
	--INSERT INTO ResearchItemSpriteLocation values (1,579, 104,308)
INSERT INTO ResearchItemSpriteLocation values (1,33, 206,308)
	INSERT INTO ResearchItemSpriteLocation values (1,534, 206,308)
	--INSERT INTO ResearchItemSpriteLocation values (1,535, 206,308)
INSERT INTO ResearchItemSpriteLocation values (1,34, 308,308)
	INSERT INTO ResearchItemSpriteLocation values (1,536, 308,308)
	--INSERT INTO ResearchItemSpriteLocation values (1,537, 308,308)
INSERT INTO ResearchItemSpriteLocation values (1,35, 410,308)
	INSERT INTO ResearchItemSpriteLocation values (1,540, 410,308)
	--INSERT INTO ResearchItemSpriteLocation values (1,541, 410,308)
INSERT INTO ResearchItemSpriteLocation values (1,36, 512,308)
	INSERT INTO ResearchItemSpriteLocation values (1,544, 512,308)
	--INSERT INTO ResearchItemSpriteLocation values (1,545, 512,308)
--INSERT INTO ResearchItemSpriteLocation values (1,37, 614,308)
INSERT INTO ResearchItemSpriteLocation values (1,38, 716,308)
INSERT INTO ResearchItemSpriteLocation values (1,39, 818,308)
	INSERT INTO ResearchItemSpriteLocation values (1,538, 818,308)
	--INSERT INTO ResearchItemSpriteLocation values (1,539, 818,308)
INSERT INTO ResearchItemSpriteLocation values (1,40, 920,308)
INSERT INTO ResearchItemSpriteLocation values (1,41, 2,410)
INSERT INTO ResearchItemSpriteLocation values (1,42, 104,410)
INSERT INTO ResearchItemSpriteLocation values (1,43, 206,410)
	INSERT INTO ResearchItemSpriteLocation values (1,554, 206,410)
	INSERT INTO ResearchItemSpriteLocation values (1,555, 206,410)
INSERT INTO ResearchItemSpriteLocation values (1,44, 308,410)
	INSERT INTO ResearchItemSpriteLocation values (1,604, 308,410)
	INSERT INTO ResearchItemSpriteLocation values (1,605, 308,410)
INSERT INTO ResearchItemSpriteLocation values (1,45, 410,410)
	--INSERT INTO ResearchItemSpriteLocation values (1,606, 410,410)
	--INSERT INTO ResearchItemSpriteLocation values (1,607, 410,410)
INSERT INTO ResearchItemSpriteLocation values (1,46, 512,410)
	--INSERT INTO ResearchItemSpriteLocation values (1,560, 512,410)
	--INSERT INTO ResearchItemSpriteLocation values (1,561, 512,410)
INSERT INTO ResearchItemSpriteLocation values (1,47, 614,410)
	INSERT INTO ResearchItemSpriteLocation values (1,556, 614,410)
	INSERT INTO ResearchItemSpriteLocation values (1,557, 614,410)
INSERT INTO ResearchItemSpriteLocation values (1,48, 716,410)
	--INSERT INTO ResearchItemSpriteLocation values (1,620, 716,410)
	--INSERT INTO ResearchItemSpriteLocation values (1,621, 716,410)
INSERT INTO ResearchItemSpriteLocation values (1,49, 818,410)
	--INSERT INTO ResearchItemSpriteLocation values (1,622, 818,410)
	--INSERT INTO ResearchItemSpriteLocation values (1,623, 818,410)
INSERT INTO ResearchItemSpriteLocation values (1,50, 920,410)
	--INSERT INTO ResearchItemSpriteLocation values (1,624, 920,410)
	--INSERT INTO ResearchItemSpriteLocation values (1,625, 920,410)
INSERT INTO ResearchItemSpriteLocation values (1,51, 2,512)
INSERT INTO ResearchItemSpriteLocation values (1,52, 104,512)
INSERT INTO ResearchItemSpriteLocation values (1,53, 206,512)
INSERT INTO ResearchItemSpriteLocation values (1,54, 308,512)
	--INSERT INTO ResearchItemSpriteLocation values (1,588, 308,512)
	--INSERT INTO ResearchItemSpriteLocation values (1,589, 308,512)
INSERT INTO ResearchItemSpriteLocation values (1,55, 410,512)
INSERT INTO ResearchItemSpriteLocation values (1,56, 512,512)
INSERT INTO ResearchItemSpriteLocation values (1,57, 614,512)
INSERT INTO ResearchItemSpriteLocation values (1,58, 716,512)
INSERT INTO ResearchItemSpriteLocation values (1,59, 818,512)
INSERT INTO ResearchItemSpriteLocation values (1,60, 920,512)
INSERT INTO ResearchItemSpriteLocation values (1,61, 2,614)
INSERT INTO ResearchItemSpriteLocation values (1,62, 104,614)
INSERT INTO ResearchItemSpriteLocation values (1,63, 206,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,638, 638,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,639, 639,614)
INSERT INTO ResearchItemSpriteLocation values (1,64, 308,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,640, 308,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,641, 308,614)
INSERT INTO ResearchItemSpriteLocation values (1,65, 410,614)
	INSERT INTO ResearchItemSpriteLocation values (1,592, 410,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,593, 410,614)
INSERT INTO ResearchItemSpriteLocation values (1,66, 512,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,594, 512,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,595, 512,614)
INSERT INTO ResearchItemSpriteLocation values (1,67, 614,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,608, 614,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,609, 614,614)
INSERT INTO ResearchItemSpriteLocation values (1,68, 716,614)
	INSERT INTO ResearchItemSpriteLocation values (1,568, 716,614)
	INSERT INTO ResearchItemSpriteLocation values (1,569, 716,614)
INSERT INTO ResearchItemSpriteLocation values (1,69, 818,614)
INSERT INTO ResearchItemSpriteLocation values (1,70, 920,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,660, 920,614)
	--INSERT INTO ResearchItemSpriteLocation values (1,661, 920,614)
INSERT INTO ResearchItemSpriteLocation values (1,71, 2,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,662, 2,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,663, 2,716)
INSERT INTO ResearchItemSpriteLocation values (1,72, 104,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,610, 104,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,611, 104,716)
INSERT INTO ResearchItemSpriteLocation values (1,73, 206,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,666, 206,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,667, 206,716)
INSERT INTO ResearchItemSpriteLocation values (1,74, 308,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,664, 308,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,665, 308,716)
INSERT INTO ResearchItemSpriteLocation values (1,75, 410,716)
INSERT INTO ResearchItemSpriteLocation values (1,76, 512,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,510, 512,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,511, 512,716)
INSERT INTO ResearchItemSpriteLocation values (1,77, 614,716)
INSERT INTO ResearchItemSpriteLocation values (1,78, 716,716)
	INSERT INTO ResearchItemSpriteLocation values (1,612, 716,716)
	INSERT INTO ResearchItemSpriteLocation values (1,613, 716,716)
INSERT INTO ResearchItemSpriteLocation values (1,79, 818,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,562, 818,716)
	--INSERT INTO ResearchItemSpriteLocation values (1,563, 818,716)
INSERT INTO ResearchItemSpriteLocation values (1,80, 920,716)
INSERT INTO ResearchItemSpriteLocation values (1,81, 2,818)
--INSERT INTO ResearchItemSpriteLocation values (1,82, 104,818)
INSERT INTO ResearchItemSpriteLocation values (1,83, 206,818)
	--INSERT INTO ResearchItemSpriteLocation values (1,626, 206,818)
	--INSERT INTO ResearchItemSpriteLocation values (1,627, 206,818)
INSERT INTO ResearchItemSpriteLocation values (1,84, 308,818)
INSERT INTO ResearchItemSpriteLocation values (1,85, 410,818)
--INSERT INTO ResearchItemSpriteLocation values (1,86, 512,818)
--INSERT INTO ResearchItemSpriteLocation values (1,87, 614,818)
INSERT INTO ResearchItemSpriteLocation values (1,88, 716,818)
	--INSERT INTO ResearchItemSpriteLocation values (1,628, 716,818)
	--INSERT INTO ResearchItemSpriteLocation values (1,629, 716,818)
--INSERT INTO ResearchItemSpriteLocation values (1,89, 818,818)
--INSERT INTO ResearchItemSpriteLocation values (1,90, 920,818)
INSERT INTO ResearchItemSpriteLocation values (1,91, 2,920)
INSERT INTO ResearchItemSpriteLocation values (1,92, 104,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,636, 104,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,637, 104,920)
INSERT INTO ResearchItemSpriteLocation values (1,93, 206,920)
INSERT INTO ResearchItemSpriteLocation values (1,94, 308,920)
	INSERT INTO ResearchItemSpriteLocation values (1,582, 308,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,583, 308,920)
INSERT INTO ResearchItemSpriteLocation values (1,95, 410,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,590, 410,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,591, 410,920)
INSERT INTO ResearchItemSpriteLocation values (1,96, 512,920)
	INSERT INTO ResearchItemSpriteLocation values (1,586, 512,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,587, 512,920)
INSERT INTO ResearchItemSpriteLocation values (1,97, 614,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,584, 614,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,585, 614,920)
INSERT INTO ResearchItemSpriteLocation values (1,98, 716,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,650, 716,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,651, 716,920)
INSERT INTO ResearchItemSpriteLocation values (1,99, 818,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,652, 818,920)
	--INSERT INTO ResearchItemSpriteLocation values (1,653, 818,920)
INSERT INTO ResearchItemSpriteLocation values (1,100, 920,920)
INSERT INTO ResearchItemSpriteLocation values (1,101, 2,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,668, 2,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,669, 2,1022)
INSERT INTO ResearchItemSpriteLocation values (1,102, 104,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,648, 104,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,649, 104,1022)
INSERT INTO ResearchItemSpriteLocation values (1,103, 206,1022)
INSERT INTO ResearchItemSpriteLocation values (1,104, 308,1022)
INSERT INTO ResearchItemSpriteLocation values (1,105, 410,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,646, 410,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,647, 410,1022)
INSERT INTO ResearchItemSpriteLocation values (1,106, 512,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,670, 512,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,671, 512,1022)
INSERT INTO ResearchItemSpriteLocation values (1,107, 614,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,644, 614,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,645, 614,1022)
INSERT INTO ResearchItemSpriteLocation values (1,108, 716,1022)
	INSERT INTO ResearchItemSpriteLocation values (1,598, 716,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,599, 716,1022)
INSERT INTO ResearchItemSpriteLocation values (1,109, 818,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,600, 818,1022)
	--INSERT INTO ResearchItemSpriteLocation values (1,601, 818,1022)
INSERT INTO ResearchItemSpriteLocation values (1,110, 920,1022)
INSERT INTO ResearchItemSpriteLocation values (1,111, 2,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,512, 2,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,513, 2,1124)
INSERT INTO ResearchItemSpriteLocation values (1,112, 104,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,654, 104,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,655, 104,1124)
INSERT INTO ResearchItemSpriteLocation values (1,113, 206,1124)
INSERT INTO ResearchItemSpriteLocation values (1,114, 308,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,672, 308,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,673, 308,1124)
INSERT INTO ResearchItemSpriteLocation values (1,115, 410,1124)
INSERT INTO ResearchItemSpriteLocation values (1,116, 512,1124)
INSERT INTO ResearchItemSpriteLocation values (1,117, 614,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,656, 614,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,657, 614,1124)
INSERT INTO ResearchItemSpriteLocation values (1,118, 716,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,548, 716,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,549, 716,1124)
INSERT INTO ResearchItemSpriteLocation values (1,119, 818,1124)
--INSERT INTO ResearchItemSpriteLocation values (1,120, 920,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,550, 920,1124)
	--INSERT INTO ResearchItemSpriteLocation values (1,551, 920,1124)
INSERT INTO ResearchItemSpriteLocation values (1,121, 2,1226)
	--INSERT INTO ResearchItemSpriteLocation values (1,532, 2,1226)
	--INSERT INTO ResearchItemSpriteLocation values (1,533, 2,1226)
--INSERT INTO ResearchItemSpriteLocation values (1,122, 104,1226)
--INSERT INTO ResearchItemSpriteLocation values (1,123, 206,1226)
--INSERT INTO ResearchItemSpriteLocation values (1,124, 308,1226)
--INSERT INTO ResearchItemSpriteLocation values (1,125, 410,1226)
INSERT INTO ResearchItemSpriteLocation values (1,126, 512,1226)
INSERT INTO ResearchItemSpriteLocation values (1,127, 614,1226)
--INSERT INTO ResearchItemSpriteLocation values (1,128, 716,1226)
	--INSERT INTO ResearchItemSpriteLocation values (1,526, 716,1226)
	--INSERT INTO ResearchItemSpriteLocation values (1,527, 716,1226)
INSERT INTO ResearchItemSpriteLocation values (1,129, 818,1226)
	INSERT INTO ResearchItemSpriteLocation values (1,508, 818,1226)
	--INSERT INTO ResearchItemSpriteLocation values (1,509, 818,1226)
INSERT INTO ResearchItemSpriteLocation values (1,130, 920,1226)
	INSERT INTO ResearchItemSpriteLocation values (1,616, 920,1226)
	INSERT INTO ResearchItemSpriteLocation values (1,617, 920,1226)
INSERT INTO ResearchItemSpriteLocation values (1,131, 2,1328)
	--INSERT INTO ResearchItemSpriteLocation values (1,618, 2,1328)
	--INSERT INTO ResearchItemSpriteLocation values (1,619, 2,1328)
INSERT INTO ResearchItemSpriteLocation values (1,132, 104,1328)
INSERT INTO ResearchItemSpriteLocation values (1,133, 206,1328)
INSERT INTO ResearchItemSpriteLocation values (1,134, 308,1328)
--INSERT INTO ResearchItemSpriteLocation values (1,135, 410,1328)
	--INSERT INTO ResearchItemSpriteLocation values (1,564, 410,1328)
	--INSERT INTO ResearchItemSpriteLocation values (1,565, 410,1328)
INSERT INTO ResearchItemSpriteLocation values (1,136, 512,1328)
	--INSERT INTO ResearchItemSpriteLocation values (1,574, 512,1328)
	--INSERT INTO ResearchItemSpriteLocation values (1,575, 512,1328)
INSERT INTO ResearchItemSpriteLocation values (1,137, 614,1328)
	--INSERT INTO ResearchItemSpriteLocation values (1,572, 614,1328)
	--INSERT INTO ResearchItemSpriteLocation values (1,573, 614,1328)
INSERT INTO ResearchItemSpriteLocation values (1,138, 716,1328)
INSERT INTO ResearchItemSpriteLocation values (1,139, 818,1328)
INSERT INTO ResearchItemSpriteLocation values (1,140, 920,1328)
INSERT INTO ResearchItemSpriteLocation values (1,141, 2,1430)
INSERT INTO ResearchItemSpriteLocation values (1,142, 104,1430)
--INSERT INTO ResearchItemSpriteLocation values (1,143, 206,1430)
INSERT INTO ResearchItemSpriteLocation values (1,144, 308,1430)
	--INSERT INTO ResearchItemSpriteLocation values (1,602, 308,1430)
	--INSERT INTO ResearchItemSpriteLocation values (1,603, 308,1430)
--INSERT INTO ResearchItemSpriteLocation values (1,145, 410,1430)
INSERT INTO ResearchItemSpriteLocation values (1,146, 512,1430)
	--INSERT INTO ResearchItemSpriteLocation values (1,596, 512,1430)
	--INSERT INTO ResearchItemSpriteLocation values (1,597, 512,1430)
INSERT INTO ResearchItemSpriteLocation values (1,147, 614,1430)
INSERT INTO ResearchItemSpriteLocation values (1,148, 716,1430)
INSERT INTO ResearchItemSpriteLocation values (1,149, 818,1430)
INSERT INTO ResearchItemSpriteLocation values (1,150, 920,1430)
	--INSERT INTO ResearchItemSpriteLocation values (1,552, 920,1430)
	--INSERT INTO ResearchItemSpriteLocation values (1,553, 920,1430)
--INSERT INTO ResearchItemSpriteLocation values (1,151, 2,1532)
	--INSERT INTO ResearchItemSpriteLocation values (1,514, 2,1532)
	--INSERT INTO ResearchItemSpriteLocation values (1,515, 2,1532)
INSERT INTO ResearchItemSpriteLocation values (1,152, 104,1532)
INSERT INTO ResearchItemSpriteLocation values (1,153, 206,1532)
INSERT INTO ResearchItemSpriteLocation values (1,154, 308,1532)
INSERT INTO ResearchItemSpriteLocation values (1,155, 410,1532)
INSERT INTO ResearchItemSpriteLocation values (1,156, 512,1532)
INSERT INTO ResearchItemSpriteLocation values (1,157, 614,1532)
	--INSERT INTO ResearchItemSpriteLocation values (1,674, 614,1532)
	--INSERT INTO ResearchItemSpriteLocation values (1,675, 614,1532)
INSERT INTO ResearchItemSpriteLocation values (1,158, 716,1532)
	--INSERT INTO ResearchItemSpriteLocation values (1,676, 716,1532)
	--INSERT INTO ResearchItemSpriteLocation values (1,677, 716,1532)
INSERT INTO ResearchItemSpriteLocation values (1,159, 818,1532)
	--INSERT INTO ResearchItemSpriteLocation values (1,642, 818,1532)
	--INSERT INTO ResearchItemSpriteLocation values (1,643, 818,1532)
INSERT INTO ResearchItemSpriteLocation values (1,160, 920,1532)
	--INSERT INTO ResearchItemSpriteLocation values (1,658, 920,1532)
	--INSERT INTO ResearchItemSpriteLocation values (1,659, 920,1532)
INSERT INTO ResearchItemSpriteLocation values (1,161, 2,1634)
INSERT INTO ResearchItemSpriteLocation values (1,162, 104,1634)
	--INSERT INTO ResearchItemSpriteLocation values (1,614, 104,1634)
	--INSERT INTO ResearchItemSpriteLocation values (1,615, 104,1634)
INSERT INTO ResearchItemSpriteLocation values (1,163, 206,1634)
	--INSERT INTO ResearchItemSpriteLocation values (1,632, 206,1634)
	--INSERT INTO ResearchItemSpriteLocation values (1,633, 206,1634)
INSERT INTO ResearchItemSpriteLocation values (1,164, 308,1634)
INSERT INTO ResearchItemSpriteLocation values (1,165, 410,1634)
	--INSERT INTO ResearchItemSpriteLocation values (1,630, 410,1634)
	--INSERT INTO ResearchItemSpriteLocation values (1,631, 410,1634)
--INSERT INTO ResearchItemSpriteLocation values (1,166, 512,1634)
--INSERT INTO ResearchItemSpriteLocation values (1,167, 614,1634)
INSERT INTO ResearchItemSpriteLocation values (1,168, 716,1634)
	--INSERT INTO ResearchItemSpriteLocation values (1,634, 716,1634)
	--INSERT INTO ResearchItemSpriteLocation values (1,635, 716,1634)
INSERT INTO ResearchItemSpriteLocation values (1,169, 818,1634)
INSERT INTO ResearchItemSpriteLocation values (1,170, 920,1634)

