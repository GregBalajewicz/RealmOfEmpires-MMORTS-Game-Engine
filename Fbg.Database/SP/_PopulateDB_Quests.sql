IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = '_PopulateDB_Quests')
	BEGIN
		DROP  Procedure  _PopulateDB_Quests
	END

GO


CREATE Procedure dbo._PopulateDB_Quests

	AS
set nocount on


/*
	set this to true for mix (desktop + mob) realms in order to get simpler how-to instructions that work for both desktop and mobile
*/
declare @IS_SimplifiedDecForMixRealms int
SET @IS_SimplifiedDecForMixRealms = 1

declare @UI_M int 
declare @UI_D2 int 
 
set @UI_M = 0 
set @UI_D2 = 1 

delete Translations where [key] like 'Q -%'




delete QuestTemplates_Descriptions
delete QuestTemplates_Reward_Items_Troops
delete QuestTemplates_Reward_Items_PFWithDuration
delete QuestProgression
delete QuestTemplates

declare @IsP2Prealm bit
set @IsP2Prealm  = 0
select @IsP2Prealm =  attribvalue from RealmAttributes where attribid =20

declare @AreGiftsActive bit
set @AreGiftsActive  = 0
select @AreGiftsActive =  attribvalue from RealmAttributes where attribid =19

declare @RealmType varchar(100)
declare @RealmSubType varchar(100) -- Holiday14d etc
SELECT @RealmType = attribvalue FROM RealmAttributes WHERE attribID = 2000 
select @RealmSubType =  attribvalue from RealmAttributes where attribid =2001

IF @RealmType = 'X' OR @RealmType = 'CLASSIC' BEGIN 
	RETURN 1
END 

INSERT INTO Translations values (0, 0, 'Q - Res - Mining - title', 'Improve Mining Tech')
INSERT INTO Translations values (0, 0, 'Q - Res - Mining - desc 1', 'This tech will teach your people who is in charge, and what will happen if they disobey. Mining production improves as a result.')
INSERT INTO Translations values (0, 0, 'Q - Res - Mining - desc 2', 'This tech will allow your people to begin to understand chemicals, and attempt to unlock the secrets of transmutation. Mining production improves further.')
INSERT INTO Translations values (0, 0, 'Q - Res - Mining - desc 3', 'This tech teaches your people how to use copper in a wide variety of tools. Mining production improves further.')
INSERT INTO Translations values (0, 0, 'Q - Res - Mining - desc 4', 'This tech teaches your people how to gather and manipulate iron, and begin constructing better tools and weapons. Mining production improves further.')
INSERT INTO Translations values (0, 0, 'Q - Res - Mining - desc 5', 'Sometimes there just isnt enough ore near the surface and more invasive measures are needed. Mining production improves further.')
INSERT INTO Translations values (0, 0, 'Q - Res - Mining - desc 6', 'Sometimes better tools are just as important as better weapons. Mining production improves further.')
INSERT INTO Translations values (0, 0, 'Q - Res - Mining - desc 7', 'Pulleys multiply how much each of your loyal subjects can lift. Mining production improves further.')

INSERT INTO Translations values (0, 0, 'Q - Res - Building - title', 'Improve Building Tech')
INSERT INTO Translations values (0, 0, 'Q - Res - Building - desc 1', 'This tech will teach your people numbers and calculations. Construction and upgrade times are reduced.')
INSERT INTO Translations values (0, 0, 'Q - Res - Building - desc 2', 'This tech will help your people with complex buildings and war machine designs. Construction and upgrade times are reduced further.')
INSERT INTO Translations values (0, 0, 'Q - Res - Building - desc 3', 'Contruction is key in any civilization, this tech will teach your people advanced building techniques. Construction and upgrade times are reduced further.')

INSERT INTO Translations values (0, 0, 'Q - Res - Death - title', 'Death From Above')
INSERT INTO Translations values (0, 0, 'Q - Res - Death - desc 1', 'Having hot oil dropped on your enemies heads will make them think twice about assaulting your walls. Defense is increased') 

INSERT INTO Translations values (0, 0, 'Q - Res - Defense - title', 'Improve Defense Tech')
INSERT INTO Translations values (0, 0, 'Q - Res - Defense - desc 1', 'This tech will allow your people to dig moats around your castles that will hinder assaulting troops. Defense is increased further') 
INSERT INTO Translations values (0, 0, 'Q - Res - Defense - desc 2', 'Your enemies will have trouble getting into your citadels! Defense is increased')

INSERT INTO Translations values (0, 0, 'Q - Res - Trading - title', 'Improve Trading Tech')
INSERT INTO Translations values (0, 0, 'Q - Res - Trading - desc 1', 'What could be more useful than wheels?. This tech will improve the speed of transports.')
INSERT INTO Translations values (0, 0, 'Q - Res - Trading - desc 2', 'This tech will move your people past the barter system, and into the use of currency. The speed of transports increases further')
INSERT INTO Translations values (0, 0, 'Q - Res - Trading - desc 3', 'Two horses is better then one! This tech will improve the speed of transports further') 
INSERT INTO Translations values (0, 0, 'Q - Res - Trading - desc 4', 'Defending supply lines is key for winning wars. This tech will improve the speed of transports further') 

INSERT INTO Translations values (0, 0, 'Q - Res - Spying - title', 'Improve Spying Tech')
INSERT INTO Translations values (0, 0, 'Q - Res - Spying - desc 1', 'This tech will teach your people how to brew beer, making the tavern more appealing and making it easier to recruit spies. Spy recruit time is decreased')
INSERT INTO Translations values (0, 0, 'Q - Res - Spying - desc 2', 'Sometimes one person can do what an army cannot. Spy recruit time is decreased further')

INSERT INTO Translations values (0, 0, 'Q - Res - Workshop - title', 'Improve Workshop Tech')
INSERT INTO Translations values (0, 0, 'Q - Res - Workshop - desc 1', 'This tech teaches your people about the science that deals with matter, energy, motion, and force. Siege workshop production is increased')

INSERT INTO Translations values (0, 0, 'Q - Res - Stable - title', 'Improve Stable Tech')
INSERT INTO Translations values (0, 0, 'Q - Res - Stable - desc 1', 'Sometimes troops loyal only to money are necessary to win wars. Stable production is increased')
INSERT INTO Translations values (0, 0, 'Q - Res - Stable - desc 2', 'This tech will put the fear of god into your people, keeping them under control. Stable production increases further')
INSERT INTO Translations values (0, 0, 'Q - Res - Stable - desc 3', 'A war hammer with a spike on one end, that can penetrate plate mail. Stable production increases further')
INSERT INTO Translations values (0, 0, 'Q - Res - Stable - desc 4', 'This tech will provide our troops with heavy armor and all the benefits that come with it, Stable production increases further')
INSERT INTO Translations values (0, 0, 'Q - Res - Stable - desc 5', 'This tech will teach your knights to live by honour and for glory, Stable production increases further')

INSERT INTO Translations values (0, 0, 'Q - Res - Barracks - title', 'Improve Barracks Tech')
INSERT INTO Translations values (0, 0, 'Q - Res - Barracks - desc 1', 'This tech will influence your people to see things your way. Barracks production is increased')
INSERT INTO Translations values (0, 0, 'Q - Res - Barracks - desc 2', 'This tech will allow Lords, vassals and fiefs to become a part of your society. Barracks production is increased further')
INSERT INTO Translations values (0, 0, 'Q - Res - Barracks - desc 3', 'Blacksmiths will allow the creation of better weapons and armor, and bring you one step closer to unlocking the Infantry unit. Barracks production is increased further')
INSERT INTO Translations values (0, 0, 'Q - Res - Barracks - desc 4', 'Spears are your only real defense against cavalry, use them well. Barracks production is increased further')

INSERT INTO Translations values (0, 0, 'Q - Res - Farm - title', 'Improve Farm Tech')
INSERT INTO Translations values (0, 0, 'Q - Res - Farm - desc 1', 'This tech will teach your people advanced farming techniques, Farm production is increased')

INSERT INTO Translations values (0, 0, 'Q - Res - Treasury - title', 'Improve Treasury Tech')
INSERT INTO Translations values (0, 0, 'Q - Res - Treasury - desc 1', 'Keep your coins safe from dirty thieves! Treasury capacity increased')
INSERT INTO Translations values (0, 0, 'Q - Res - Treasury - desc 2', 'This tech teaches your people the art of making coins. Treasury capacity increases further')
INSERT INTO Translations values (0, 0, 'Q - Res - Treasury - desc 3', 'This tech teaches your people how to make unique coins, to prevent forgery, Treasury capacity increases further')

INSERT INTO Translations values (0, 0, 'Q - Res - Infantry - title', 'Unlock Infantry')
INSERT INTO Translations values (0, 0, 'Q - Res - Infantry - desc 1', 'This tech will allow your troops to use axes, and bring you one step closer to unlocking the Infantry unit')

INSERT INTO Translations values (0, 0, 'Q - Res - Cavalry - title', 'Unlock Light Cavalry')
INSERT INTO Translations values (0, 0, 'Q - Res - Cavalry - desc 1', 'Taming and riding horses will be vital to defeating your enemies, Unlocks Light Cavalry')

INSERT INTO Translations values (0, 0, 'Q - Res - Knights - title', 'Unlock Knights')
INSERT INTO Translations values (0, 0, 'Q - Res - Knights - desc 1', 'Armor for your horses will keep your riders mounted longer! This tech will bring you one step closer to unlocking the Knight')

INSERT INTO Translations values (0, 0, 'Q - Res - Trebuchets - title', 'Unlock Trebuchets')
INSERT INTO Translations values (0, 0, 'Q - Res - Trebuchets - desc 1', 'This tech will bring you one step closer to unlocking the powerful trebuchet siege weapon')

INSERT INTO Translations values (0, 0, 'Q - Res - Sorcery - title', 'Master Sorcery')
INSERT INTO Translations values (0, 0, 'Q - Res - Sorcery - goal 2', 'Cast the Time Chop Spell')
INSERT INTO Translations values (0, 0, 'Q - Res - Sorcery - goal 3', 'Cast the Elven Efficiency Spell')
INSERT INTO Translations values (0, 0, 'Q - Res - Sorcery - desc 2', 'Upgrade a building, the upgrade must take over 15 minute. While it is upgrading, you will notice a <B>Speed Up!</B> link. From the drop down, choose "Cast Time Chop Spell - cut 15 min - 5 servant" to cut 15 minute from the upgrade time.')
IF @IS_SimplifiedDecForMixRealms = 1 BEGIN
INSERT INTO Translations values (0, 0, 'Q - Res - Sorcery - desc 3', 'Cast the Elven Efficiency Spell (via servants, not via rewards), to enable Bonus Silver production for at least 1 day. Enjoy the silver boost as well the reward!')
END ELSE BEGIN 
INSERT INTO Translations values (0, 0, 'Q - Res - Sorcery - desc 3', 'Close this window, then look for this icon <img src= "https://static.realmofempires.com/images/pf_silvermore1.png" /> right below your avatar, name and points display on the top right of the screen. Click it to go to the page that allows you to enable this premium feature. Enable the Elven Efficiency Spell for at least 1 day. Enjoy the silver boost as well the reward!')
END


INSERT INTO Translations values (0, 0, 'Q - Res - Gift - title 1', 'Gift For You')
INSERT INTO Translations values (0, 0, 'Q - Res - Gift - title 2', 'Give And You Will Get')
INSERT INTO Translations values (0, 0, 'Q - Res - Gift - goal 1', 'Buy a Sack-Of-Silver gift')
INSERT INTO Translations values (0, 0, 'Q - Res - Gift - goal 2', 'Send a Gift')

INSERT INTO Translations values (0, 0, 'Q - Res - Gift - desc 1', 'Who wouldn''t want more silver? Not you! Well, getting more silver is easy. Just use the bazaar icon <img src= "https://static.realmofempires.com/images/icons/giftsS.png" /> at the bottom right of your Village overview to open the Bazaar and Inventory window.  From there select "A Sack of Silver" and buy as many items as you want.<BR><BR>Congratulations, you''re on your way to becoming a Silver Magnate!')

IF @IS_SimplifiedDecForMixRealms = 1 BEGIN
INSERT INTO Translations values (0, 0, 'Q - Res - Gift - desc 2', 'Give and you shall receive! Send any gift to your friends. Dont be afraid to ask for the favour in return, it is very easy for them to do! <BR><BR>Close this window, then click a "Gifts: Send" link just to the right of the quest link.')
END ELSE BEGIN 
INSERT INTO Translations values (0, 0, 'Q - Res - Gift - desc 2', 'Give and you shall receive! Send any gift to your friends. Dont be afraid to ask for the favour in return, it is very easy for them to do! <BR><BR>Close this window, then click a "Gifts: Send" link just to the right of the quest link.')
END

INSERT INTO Translations values (0,0,'Q - Res - Tutorial - title','Become a Master Leader')
INSERT INTO Translations values (0, 0, 'Q - Res - Tutorial - goal', 'Complete the Tutorial')
INSERT INTO Translations values (0, 0, 'Q - Res - Tutorial - desc 1', '<img src="https://static.realmofempires.com/images/gifts/Gift_sack_of_silver.png" style="float: left;padding: 2px; height: 105px;" /><BR />Complete the tutorial and claim your reward!<br /><br /><br /><img border=0 id=pointer align=middle  src=https://static.realmofempires.com/images/misc/Arrow_pointer_East.gif /> <a class="quests-startTutorial"  target=_parent href=startTutorial.aspx>LAUNCH TUTORIAL</a></span><br /><br />(go through the tutorial to the very end, then claim your reward below)<br />')

INSERT INTO Translations values (0,0,'Q - Res - Avatar - title','Choose Your Likeness')
INSERT INTO Translations values (0, 0, 'Q - Res - Avatar - goal', 'Change your Player Avatar')
INSERT INTO Translations values (0, 0, 'Q - Res - Avatar - desc 1M', 'There are many regal avatars that you can choose to represent you in-game.  <BR><BR>Tap on the your player name in the top left corner of the game window to open the Player Profile page.  Use the arrows on that page to cycle through all the available choices.  Find one you like and just like that you''ve got a whole new look. If only real life were this easy.')
INSERT INTO Translations values (0, 0, 'Q - Res - Avatar - desc 1D2', 'There are many regal avatars that you can choose to represent you in-game. <BR><BR> Click on the current avatar in the top left corner of the game window to open the Player Profile page.  Use the arrows on that page to cycle through all the available choices.  Find one you like and just like that you''ve got a whole new look. If only real life were this easy.')

INSERT INTO Translations values (0,0,'Q - Res - VillName - title','Name Your Village')
INSERT INTO Translations values (0, 0, 'Q - Res - VillName - goal', 'Change the Name of Your Village')
INSERT INTO Translations values (0, 0, 'Q - Res - VillName - desc 1M', 'You need a more exciting Village name. It''s easy to change it and if you do you''ll get a nice little reward!<BR><BR>Tap on the Resources button in the very top right of your screen. Once the Resources window opens, tap on the icon to the right of your Village name. Change the name to something new.')
INSERT INTO Translations values (0, 0, 'Q - Res - VillName - desc 1D2', 'You need a more exciting Village name. It''s easy to change it and if you do you''ll get a nice little reward!<BR><BR>Click on the village name, type in a new name and click ''save''')


INSERT INTO Translations values (0,0,'Q - Res - Spy - title','Spy on Someone')
INSERT INTO Translations values (0, 0, 'Q - Res - Spy - goal', 'Successfully Spy a Village')
INSERT INTO Translations values (0, 0, 'Q - Res - Spy - desc 1', 'Collect spies from your Rewards inventory, then spy on a Rebel village. <BR><BR>Send spies in any attack (or by themselves) to generate a spy report. <BR><BR>Read the report to see if you succeeded at gathering intel on the target''s building levels, defending forces, and silver supply. If successful, come back here to claim your reward! If not, you can always try again.')



INSERT INTO Translations values (2, 0, 'Q - Res - Mining - title', N'채광술 증진')
INSERT INTO Translations values (2, 0, 'Q - Res - Mining - desc 1', N'광산에서 일하는 일꾼에게 광석 캐는 기술과, 명령에 불복했을 때 어떻게 되는지 가르쳐 줍니다. 그 결과 광업 제품의 질이 올라갑니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Mining - desc 2', N'사람들에게 화학에 대한 지식을 알려주고, 변성의 비밀을 열 수 있게 해줍니다. 그리고 광업 제품의 질이 올라갑니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Mining - desc 3', N'사람들에게 철을 모으고 다루는 법을 알려주어 개량 도구와 무기를 만들게 해줍니다. 광업 제품의 질이 올라갑니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Mining - desc 4', N'고온의 열은 광석을 더 빨리 녹일 수 있습니다. 광업 제품의 질이 올라갑니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Mining - desc 5', N'지표에 광물이 부족하면 지표 아래를 탐색해야 합니다. 광업 제품의 질이 올라갑니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Mining - desc 6', N'좋은 도구가 좋은 무기만큼이나 중요할 때도 있습니다. 광업 제품의 질이 올라갑니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Mining - desc 7', N'일꾼들의 집중력을 불어넣어 줍니다. 한 명이라도 처신을 잘못하면 그 결과에 대해 연대책임을 져야 합니다. 광업 제품의 질이 올라갑니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Building - title', N'건설 기술 증진')
INSERT INTO Translations values (2, 0, 'Q - Res - Building - desc 1', N'사람들에게 숫자의 개념과 계산법을 가르쳐 줍니다. 건설과 업그레이드에 소요되는 시간이 줄어듭니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Building - desc 2', N'복잡한 형태의 건물을 지을 수 있고, 군수 기계 장치 디자인을 할 수 있게 도와줍니다. 건설과 업그레이드에 소요되는 시간이 줄어듭니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Building - desc 3', N'건축은 모든 문명에서 아주 중요한 요소입니다. 이 기술은 사람들에게 개량형 건물을 지을 수 있는 기술을 가르쳐 줍니다. 건설과 업그레이드에 소요되는 시간이 줄어듭니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Death - title', N'끓는 기름의 천벌')
INSERT INTO Translations values (2, 0, 'Q - Res - Death - desc 1', N'성벽을 기어 올라오는 적들의 머리 위로 끓는 기름을 붓는다면, 그들이 성벽을 쉽게 급습하지 못할 것입니다. 방어력이 증가합니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Defense - title', N'방어 기술 증진')
INSERT INTO Translations values (2, 0, 'Q - Res - Defense - desc 1', N'성곽 주변에 호를 파서 성을 공격하려는 적군을 묻어버릴 수 있습니다. 방어력이 더 증가합니다.') 
INSERT INTO Translations values (2, 0, 'Q - Res - Defense - desc 2', N'아무리 놈들이라도 요새에 함부로 덤벼들 생각을 못 할 거예요! 방어력이 증가합니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Trading - title', N'무역 기술 증진')
INSERT INTO Translations values (2, 0, 'Q - Res - Trading - desc 1', N'바퀴만큼 유용한 게 또 있을까요? 운송 수단의 이동 속도가 빨라집니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Trading - desc 2', N'주민들의 상거래 수준을 물물교환보다 나은 수준으로 끌어올려 화폐를 사용하게 해줍니다. 운송 수단의 이동 속도가 빨라집니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Trading - desc 3', N'기왕이면 두 마리! 운송 수단의 이동 속도가 빨라집니다.') 
INSERT INTO Translations values (2, 0, 'Q - Res - Trading - desc 4', N'전쟁에서 이기려면 물자 공급선 방어가 항상 제일 중요하죠. 운송 수단의 이동 속도가 빨라집니다.') 

INSERT INTO Translations values (2, 0, 'Q - Res - Spying - title', N'스파이 기술 증진')
INSERT INTO Translations values (2, 0, 'Q - Res - Spying - desc 1', N'맥주 앵조법을 가르쳐 사람들이 주점을 더 많이 찾게 만들어 줍니다. 그러면 자연스럽게 스파이들도 많이 모이겠죠. 스파이 고용에 걸리는 시간이 줄어듭니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Spying - desc 2', N'때로는 한 사람이 부대 전체가 할 수 없는 일을 해내기도 하죠. 스파이 고용에 걸리는 시간이 줄어듭니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Workshop - title', N'작업장 기술 증진')
INSERT INTO Translations values (2, 0, 'Q - Res - Workshop - desc 1', N'사람들에게 물질, 에너지, 동작, 포스에 관한 과학을 가르쳐 줍니다. 작업장 생산량이 증가합니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Stable - title', N'마구간 기술 증진')
INSERT INTO Translations values (2, 0, 'Q - Res - Stable - desc 1', N'가끔은 돈에 충실한 보병이 전쟁을 승리로 이끌어 주기도 하죠. 마구간 제조품이 증가합니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Stable - desc 2', N'사람들에게 신에 대한 두려움을 심어주어 쉽게 동요하지 않게 해줍니다. 마구간 제조품이 증가합니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Stable - desc 3', N'끝이 표족한 못이 박혀 있는 워해머로 플레이트 메일 갑옷을 뚫을 수 있습니다. 마구간 제조품이 증가합니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Stable - desc 4', N'아군 병사들에게 중장갑을 제공합니다. 마구간 제조품이 증가합니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Stable - desc 5', N'기사들에게 명예와 영광의 가치를 가르쳐 줍니다. 마구간 제조품이 증가합니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Barracks - title', N'막사 기술 증진')
INSERT INTO Translations values (2, 0, 'Q - Res - Barracks - desc 1', N'사람들에게 당신의 의도와 의사를 이해할 수 있게 해줍니다. 막사 생산량이 증가합니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Barracks - desc 2', N'군주, 가신, 영주들이 당신의 세력 하에 들어올 수 있게 해줍니다. 막사 생산량이 증가합니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Barracks - desc 3', N'대장간에서 더 좋은 무기와 방어구를 만들어 보병대  모집을 위한 레벨에 한 발 가까이 갈 수 있게 해줍니다. 막사 생산량이 증가합니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Barracks - desc 4', N'기병을 막을 수 있는 건 장창 밖에 없으니 전략적으로 활용하세요. 막사 생산량이 증가합니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Farm - title', N'농업 기술 증진')
INSERT INTO Translations values (2, 0, 'Q - Res - Farm - desc 1', N'사람들에게 개량 농업 기술을 가르쳐 줍니다. 농장 생산량이 증가합니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Treasury - title', N'저장고 기술 증진')
INSERT INTO Translations values (2, 0, 'Q - Res - Treasury - desc 1', N'애써 모은 돈을 도둑놈들에게 뺏길 순 없죠! 저장고의 저장량이 증가합니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Treasury - desc 2', N'동전을 제작할 수 있는 기술을 가르쳐 줍니다. 저장고의 저장량이 더 증가합니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Treasury - desc 3', N'적군이 훔칠 수 없는 특별한 동전을 제작할 수 있는 기술을 가르쳐 줍니다. 저장고의 저장량이 증가합니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Infantry - title', N'보병대 모집')
INSERT INTO Translations values (2, 0, 'Q - Res - Infantry - desc 1', N'병사들에게 도끼를 휘두르는 기술을 가르쳐 주어, 보병대 모집을 위한 레벨에 한 발 가까이 갈 수 있게 해줍니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Cavalry - title', N'경기병대 모집')
INSERT INTO Translations values (2, 0, 'Q - Res - Cavalry - desc 1', N'말을 다룬다는 것은 적을 섬멸하는 데 크나큰 도움이 됩니다. 경기병대를 모집할 수 있습니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Knights - title', N'기사단 모집')
INSERT INTO Translations values (2, 0, 'Q - Res - Knights - desc 1', N'말에 갑옷을 입히면 기수가 더 오래 싸울 수 있습니다! 기사단 모집을 위한 레벨에 한 발 가까이 갈 수 있게 해줍니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Trebuchets - title', N'투석기 제작')
INSERT INTO Translations values (2, 0, 'Q - Res - Trebuchets - desc 1', N'무시무시한 공성무기인 투석기를 제작할 수 있는 레벨레 한 발 가까이 갈 수 있게 해줍니다.')

INSERT INTO Translations values (2, 0, 'Q - Res - Sorcery - title', N'마스터 소서리')
INSERT INTO Translations values (2, 0, 'Q - Res - Sorcery - goal 1', N'시간 축소 주문 시전')
INSERT INTO Translations values (2, 0, 'Q - Res - Sorcery - goal 2', N'시간 점프 주문 시전')
INSERT INTO Translations values (2, 0, 'Q - Res - Sorcery - goal 3', N'엘프의 능률 주문 시전')
INSERT INTO Translations values (2, 0, 'Q - Res - Sorcery - desc 1', N'업그레이드 시간이 1분 이상 소요되는 건물 하나를 업그레이드하세요. 업그레이드가 진행되는 동안 <B>즉시 완료!</B> 링크가 뜹니다. 펼침 메뉴에서 "시간 축소 주문 시전 - 1분 축소 - 일꾼 1명"을 선택해 업그레이드 시간을 1분 줄여주세요.<BR><BR>남은 시간이 5초 이하일 경우, 주문이 취소됩니다. 그래도 일꾼을 잃진 않습니다.')
INSERT INTO Translations values (2, 0, 'Q - Res - Sorcery - desc 2', N'업그레이드 시간이 15분 이상 소요되는 건물 하나를 업그레이드하세요. 업그레이드가 진행되는 동안 <B>즉시 완료!</B> 링크가 뜹니다. 펼침 메뉴에서 "시간 점프 주문 시전 - 15분 축소 - 일꾼 5명"을 선택해 업그레이드 시간을 15분 줄여주세요.')
INSERT INTO Translations values (2, 0, 'Q - Res - Sorcery - desc 3', N'창을 닫고 아바타, 이름, 포인트가 쓰여 있는 창의 오른쪽 하단에 있는 <img src= "https://static.realmofempires.com/images/pf_silvermore1.png" /> 아이콘을 찾아 클릭하면, 연결되는 페이지에서 프리미엄 기능을 사용할 수 있습니다. 엘프의 능률 주문을 최소 하루 동안 사용해보세요. 보상으로 은화 부스터를 드립니다!')

INSERT INTO Translations values (2, 0, 'Q - Res - Gift - title 1', N'당신을 위한 선물')
INSERT INTO Translations values (2, 0, 'Q - Res - Gift - title 2', N'주는만큼 받으리라')
INSERT INTO Translations values (2, 0, 'Q - Res - Gift - goal 1', N'은화 자루 구입 기념 선물')
INSERT INTO Translations values (2, 0, 'Q - Res - Gift - goal 2', N'선물 보내기')
INSERT INTO Translations values (2, 0, 'Q - Res - Gift - desc 1', N'가끔은 스스로에게 선물을 주는 것도 나쁘지 않아요! 은화 자루 선물을 "구입 후 즉시 사용"하고 돌아오면 넉넉한 보상을 드려요.<BR><BR>창을 닫고, 퀘스트 링크 오른쪽에 있는 "선물:사용하기"를 클릭하세요.')
INSERT INTO Translations values (2, 0, 'Q - Res - Gift - desc 2', N'주는만큼 받으리라! 친구에게 선물을 보내보세요. 굳이 답례를 청하지 않아도 상관없어요, 묻지 않아도 될만큼 쉬운 일이니까요!<BR><BR>창을 닫고, 퀘스트 링크 오른쪽에 있는 "선물:보내기"를 클릭하세요.')

INSERT INTO Translations values (2,0,'Q - Res - Tutorial - title',N'마스터 리더 되기')
INSERT INTO Translations values (2, 0, 'Q - Res - Tutorial - goal', N'튜토리얼 완수하기')
INSERT INTO Translations values (2, 0, 'Q - Res - Tutorial - desc 1', N'<img src="https://static.realmofempires.com/images/gifts/Gift_sack_of_silver.png" style="float: left;padding: 2px; height: 105px;" /><BR />튜토리얼을 완수해 보상을 받아보세요!<br /><br /><br /><img border=0 id=pointer align=middle  src=https://static.realmofempires.com/images/misc/Arrow_pointer_East.gif /> <a class="quests-startTutorial"  target=_parent href=startTutorial.aspx>튜토리얼 시작하기</a></span><br /><br />(튜토리얼을 끝까지 완수한 후, 아래의 보상을 받아보세요.)<br />')

INSERT INTO Translations values (2,0,'Q - Res - Avatar - title',N'아바타를 선택하세요')
INSERT INTO Translations values (2, 0, 'Q - Res - Avatar - goal', N'아바타를 바꿔보세요')
INSERT INTO Translations values (2, 0, 'Q - Res - Avatar - desc 1', N'창을 닫고 아바타 그림을 클릭하면 아바타를 선택할 수 있는 창이 열립니다. 지금의 아바타가 마음에 들지 않으면 원하는 다른 아바타를 고르세요. 아바타를 선택하면 보상을 받을 수 있습니다!')

INSERT INTO Translations values (2,0,'Q - Res - VillName - title',N'마을에 이름을 지어주세요')
INSERT INTO Translations values (2, 0, 'Q - Res - VillName - goal', N'마을 이름을 바꿔보세요')
INSERT INTO Translations values (2, 0, 'Q - Res - VillName - desc 1', N'마을 이름을 바꾸는 방법을 가르쳐드릴게요. 영토가 확장되면 꼭 사용하게 될 중요한 정보입니다. 창을 닫고 마을 가운데에 있는 빨간 지붕을 가진 지휘본부 건물을 클릭하고 <U>마을 이름 바꾸기</U>를 선택하세요.<BR><BR>이름을 바꾸고 돌아오면 보상을 받을 수 있습니다!')

INSERT INTO Translations values (2,0,'Q - Res - Spy - title',N'스파이 보내기')
INSERT INTO Translations values (2, 0, 'Q - Res - Spy - goal', N'마을을 성공적으로 정찰했습니다')
INSERT INTO Translations values (2, 0, 'Q - Res - Spy - desc 1', N'스파이를 고용해 반란군의 마을에 정찰을 보내세요. 정찰 보고서를 열어 스파이가 주둔 병력의 정보를 성공적으로 알아냈는지 확인해보세요. 성공했다면 이곳으로 돌아와 보상을 받아가세요!')

--
--
-- Title quests
--
--
insert into QuestTemplates(TagName,DependantQuestTagName,reward_silver,reward_credits,CompleteCondition_TitleLevel) values
	('level_2', null, 1000,null,2)
	insert into QuestTemplates_Reward_Items_Troops(TagName, UnitTypeID,Amount ) values ('level_2', 11 ,10) --CM
	if @RealmSubType = 'Subscription' BEGIN 
		insert into QuestTemplates_Reward_Items_PFWithDuration(TagName, PFPackageID, DurationInMinutes) values ('level_2', 1000 ,60*24*14) -- subscription
	END 
insert into QuestTemplates(TagName,DependantQuestTagName,reward_silver,reward_credits,CompleteCondition_TitleLevel) values
	('level_3','level_2', null,null,3)
	insert into QuestTemplates_Reward_Items_Troops(TagName, UnitTypeID,Amount ) values ('level_3', 5 ,25)
insert into QuestTemplates(TagName,DependantQuestTagName,reward_silver,reward_credits,CompleteCondition_TitleLevel) values
	('level_4','level_3', 3000,null,4)
	insert into QuestTemplates_Reward_Items_Troops(TagName, UnitTypeID,Amount ) values ('level_4', 11 ,10) --CM
	insert into QuestTemplates_Reward_Items_PFWithDuration(TagName, PFPackageID, DurationInMinutes) values ('level_4', 32 ,120) -- rebel rush
	insert into QuestTemplates_Reward_Items_PFWithDuration(TagName, PFPackageID, DurationInMinutes) values ('level_4', 23 ,15) -- defense bonus

--
--
-- Building quests
--
--
insert into QuestTemplates(TagName,DependantQuestTagName,reward_silver,reward_credits,CompleteCondition_Building_ID,CompleteCondition_Building_Level ) values
	('B_SM_lvl3', null, 200,null,5,3)
insert into QuestTemplates(TagName,DependantQuestTagName,reward_silver,reward_credits,CompleteCondition_Building_ID,CompleteCondition_Building_Level ) values
	('B_SM_lvl4', 'B_SM_lvl3', 200,null,5,4)
insert into QuestTemplates(TagName,DependantQuestTagName,reward_silver,reward_credits,CompleteCondition_Building_ID,CompleteCondition_Building_Level ) values
	('B_SM_lvl5','B_SM_lvl4', 500,null,5,5)
	insert into QuestTemplates_Reward_Items_PFWithDuration(TagName, PFPackageID, DurationInMinutes) values ('B_SM_lvl5', 22 ,15)
																																
--
--
-- Number of village quests
--
--


--
--
-- Research quests
--
--
INSERT INTO Translations values (0, 0, 'Q - Res - Building - desc generic', 'Improve your leadership and speed up building construction across your empire.')
INSERT INTO QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values 
('Res_1', null, 400,null, 1,dbo.Translate('Q - Res - Building - title'),dbo.Translate('Q - Res - Building - desc generic')) --RID: 1 Forestry
INSERT INTO QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values 
('Res_2', null, 400,null, 2,dbo.Translate('Q - Res - Building - title'),dbo.Translate('Q - Res - Building - desc generic')) --RID: 2 Writing
INSERT INTO QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values 
('Res_7', null, 400,null, 7,dbo.Translate('Q - Res - Building - title'),dbo.Translate('Q - Res - Building - desc generic')) --RID: 7 Mathematics
INSERT INTO QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values 
('Res_9', null, 400,null, 9,dbo.Translate('Q - Res - Building - title'),dbo.Translate('Q - Res - Building - desc generic')) --RID: 9 Management
INSERT INTO QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values 
('Res_129', null, 400,null, 129,dbo.Translate('Q - Res - Building - title'),dbo.Translate('Q - Res - Building - desc generic')) --RID: 129 Religion
INSERT INTO QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values 
('Res_500', null, 800,null, 500,dbo.Translate('Q - Res - Building - title'),dbo.Translate('Q - Res - Building - desc generic')) --RID: 500 Forestry II
INSERT INTO QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values 
('Res_502', null, 800,null, 502,dbo.Translate('Q - Res - Building - title'),dbo.Translate('Q - Res - Building - desc generic')) --RID: 502 Mathematics II
INSERT INTO QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values 
('Res_504', null, 800,null, 504,dbo.Translate('Q - Res - Building - title'),dbo.Translate('Q - Res - Building - desc generic')) --RID: 504 Writing II
INSERT INTO QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values 
('Res_506', null, 800,null, 506,dbo.Translate('Q - Res - Building - title'),dbo.Translate('Q - Res - Building - desc generic')) --RID: 506 Management II
INSERT INTO QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values 
('Res_508', null, 800,null, 508,dbo.Translate('Q - Res - Building - title'),dbo.Translate('Q - Res - Building - desc generic')) --RID: 508 Religion II


--
-- UNLOCK UNIT QUESTS
--
-- NOTE - in order for these quest to work, this research item, must fully unlock the unit that this quest tells you to unlock.
--	Meaning, that this must be the final research a player will do to unlock it. 
--	if player is to do any other research items after this one, then this quest will not work right

-- item #55 depends on 52 and 53 so it will be done last to unlock infantry. Edit: ITEM 53 IS NOW THE LAST ONE.
insert into QuestTemplates(TagName,DependantQuestTagName, reward_silver, reward_credits, CompleteCondition_ResearchItemID, title, description) values
	('Res_52',null,500,null, 53,dbo.Translate('Q - Res - Infantry - title'),dbo.Translate('Q - Res - Infantry - desc 1'))



declare @i int
--
--
-- Progression
--
--
set @i=1
	
																		--SM	HQ	Tre	Far	Bar	Stb
insert into QuestProgression values (@i,'B_SM_lvl3',2)							--3		1	1	1	

set @i = @i + 1 
insert into QuestProgression values (@i,'B_SM_lvl5',2)   						--				2
insert into QuestProgression values (@i,'Res_1',0)   						
