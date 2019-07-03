--[[
	太阳神三国杀武将扩展包·魔法少女小圆
	适用版本：V2 - 终结版（版本号：20150926）
	武将总数：12
	武将一览：
		1、鹿目圆（花弓、善心、因果）+（许愿）
		2、晓美焰（军火、时停、轮回）+（布局、羁绊、诅咒）
		3、美树沙耶香（剑术、治愈、黑化）+（人鱼、陪伴、牵挂、救赎、神使）
		4、巴麻美（火枪、缎带、红茶、终曲）+（宝贝）
		5、佐仓杏子（尖枪、吃货、殉情）+（幻梦）
		6、丘比（窥探、缔约、替身、无情）
		7、志筑仁美（名门、思慕、坦白）+（倾心）
		8、上条恭介（才华、残体、痊愈）+（演出、惊觉）
		9、百江渚（贪酪、气泡、变脸）+（鼓舞、解答）
		10、魔女之夜（飓风、肆虐、舞台、回转）
		11、神·鹿目圆（箭雨、指引、神格、光辉）+（朋友、计遣）
		12、魔·晓美焰（银庭、干涉、魔道、独舞）+（执念）
	所需标记：
		1、@MdkYinGuoMark（“因”标记，来自技能“因果”）
		2、@MdkLunHuiMark（“轮回”标记，来自技能“轮回”）
		3、@MdkZuZhouMark（“诅咒”标记，来自技能“诅咒”）
		4、@MdkHeiHuaMark（“灵石”标记，来自技能“黑化”）
		5、@MdkShenShiMark（“令”标记，来自技能“神使”）
		6、@MdkXunQingMark（“灵石”标记，来自技能“殉情”）
		7、@MdkKuiTanMark（“目标”标记，来自技能“窥探”）
		8、@MdkDiYueFailMark（“缔约失败”标记，来自技能“缔约”）
		9、@MdkSiMuMark（“思慕”标记，来自技能“思慕”）
		10、@MdkTanBaiMark（“坦白”标记，来自技能“坦白”）
		11、@MdkQuanYuMark（“回复”标记，来自技能“痊愈”）
		12、@MdkYanChuMark（“听众”标记，来自技能“演出”）
		13、@MdkTanLaoMark（“乳酪”标记，来自技能“贪酪”）
		14、@MdkQiPaoMark（“泡泡”标记，来自技能“气泡”）
		15、@MdkJieDaMark（“令”标记，来自技能“解答”）
		16、@MdkHuiZhuanMark（“回转”标记，来自技能“回转”）
		17、@MdkGuangHuiMark（“光辉”标记，来自技能“光辉”）
		18、@MdkDuWuMark（“独舞”标记，来自技能“独舞”）
]]--
module("extensions.MadokaMagica", package.seeall)
extension = sgs.Package("MadokaMagica", sgs.Package_GeneralPack)
--开关设置
LinkSkillSwitch = false --联动技开关：开启后允许使用联动技
--技能暗将
SkillAnJiang = sgs.General(extension, "MdkSkillAnJiang", "god", 5, true, true, true)
--翻译信息
sgs.LoadTranslationTable{
	["MadokaMagica"] = "魔法少女小圆",
	["MdkSkillAnJiang"] = "技能暗将",
}
--辅助函数：用于变更武将时保持联动技效果
function getLinkSkills(room, player, old_general, new_general)
	local all_link_skills = {
		["MdkXuYuan"] = "KanameMadoka", 
		["MdkJiBan"] = "AkemiHomura", 
		["MdkZuZhou"] = "AkemiHomura", 
		["MdkPeiBan"] = "MikiSayaka", 
		["MdkQianGua"] = "MikiSayaka", 
		["MdkJiuShu"] = "MikiSayaka", 
		["MdkShenShi"] = "MikiSayaka", 
		["MdkBaoBei"] = "TomoeMami", 
		["MdkHuanMeng"] = "SakuraKyouko", 
		["MdkQingXin"] = "ShizukiHitomi", 
		["MdkJingJue"] = "KamijouKyousuke", 
		["MdkGuWu"] = "MomoeNagisa", 
		["MdkJieDa"] = "MomoeNagisa", 
		["MdkPengYou"] = "GodMadoka", 
		["MdkJiQian"] = "GodMadoka", 
		["MdkZhiNian"] = "DevilHomura"
	}
	local to_keep = {}
	local to_remove = {}
	local name = player:getGeneralName()
	local name2 = player:getGeneral2Name()
	local keep_general = ""
	if name == old_general and name2 ~= old_general then
		keep_general = name2
	elseif name ~= old_general and name2 == old_general then
		keep_general = name
	end
	if old_general == keep_general then
		old_general = ""
	end
	if new_general == keep_general then
		new_general = ""
	end
	for skill, general in pairs(all_link_skills) do
		if player:hasSkill(skill) then
			if general == old_general then
				table.insert(to_remove, skill)
			elseif general == new_general then
			else
				table.insert(to_keep, skill)
			end
		end
	end
	return to_keep, to_remove
end
function addLinkSkills(room, player, to_keep, to_remove)
	if #to_remove > 0 then
		for _,skill in ipairs(to_remove) do
			if player:hasSkill(skill) then
				room:detachSkillFromPlayer(player, skill)
			end
		end
	end
	if #to_keep > 0 then
		for _,skill in ipairs(to_keep) do
			if not player:hasSkill(skill) then
				room:attachSkillToPlayer(player, skill)
			end
		end
	end
end
--[[****************************************************************
	编号：MDK - 01
	武将：鹿目圆（Kaname Madoka）
	称号：保健委员
	性别：女
	势力：蜀
	体力上限：3勾玉
]]--****************************************************************
Madoka = sgs.General(extension, "KanameMadoka", "shu", 3, false)
--翻译信息
sgs.LoadTranslationTable{
	["KanameMadoka"] = "鹿目圆",
	["&KanameMadoka"] = "鹿目圆",
	["#KanameMadoka"] = "保健委员",
	["designer:KanameMadoka"] = "DGAH",
	["cv:KanameMadoka"] = "悠木碧",
	["illustrator:KanameMadoka"] = "百度百科",
	["~KanameMadoka"] = "再见，小焰……保重身体",
}
--[[
	技能：花弓（锁定技）
	描述：出牌阶段，若你没有装备武器，你视为装备有【麒麟弓】。
]]--
HuaGong = sgs.CreateTriggerSkill{
	name = "MdkHuaGong",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused, sgs.ChoiceMade},
	on_trigger = function(self, event, player, data)
		if player:getWeapon() then
		elseif player:getPhase() == sgs.Player_Play then
			local room = player:getRoom()
			if event == sgs.DamageCaused then
				local skill = sgs.Sanguosha:getTriggerSkill("kylin_bow")
				if skill then
					skill:trigger(event, room, player, data)
				else
					------------------------------------------------
					--下面这段是模拟麒麟弓的效果
					--其实正常情况下是不应该运行到这里的
					--只是为了兼容没有麒麟弓的MOD环境而已
					------------------------------------------------
					local damage = data:toDamage()
					local slash = damage.card
					if damage.chain or damage.transfer then
					elseif damage.by_user and slash and slash:isKindOf("Slash") then
						local target = damage.to
						if target:getMark("Equips_of_Others_Nullified_to_You") == 0 then
							local source = damage.from
							if source and source:isAlive() then
								local horses = {}
								local dhorse = target:getDefensiveHorse()
								local ohorse = target:getOffensiveHorse()
								if dhorse and source:canDiscard(target, dhorse:getEffectiveId()) then
									table.insert(horses, "dhorse")
								end
								if ohorse and source:canDiscard(target, ohorse:getEffectiveId()) then
									table.insert(horses, "ohorse")
								end
								if #horses == 0 then
									return false
								end
								if player and player:askForSkillInvoke("kylin_bow", data) then
									room:setEmotion(player, "weapon/kylin_bow")
									horses = table.concat(horses, "+")
									local horse = room:askForChoice(player, "kylin_bow", horses)
									if horse == "dhorse" then
										room:throwCard(dhorse, target, source)
									elseif horse == "ohorse" then
										room:throwCard(ohorse, target, source)
									end
								end
							end
						end
					end
					------------------------------------------------
				end
			elseif event == sgs.ChoiceMade then
				if data:toString() == "skillInvoke:kylin_bow:yes" then
					local index = 1
					local alives = room:getAlivePlayers()
					for _,p in sgs.qlist(alives) do
						if p:getGeneralName() == "AkemiHomura" or p:getGeneral2Name() == "AkemiHomura" then
							if p:objectName() == player:objectName() or p:inMyAttackRange(player) then
								index = math.random(1, 100) < 70 and 2 or 1
								break
							end
						end
					end
					room:broadcastSkillInvoke("MdkHuaGong", index) --播放配音
					room:notifySkillInvoked(player, "MdkHuaGong") --显示技能发动
				end
			end
		end
		return false
	end,
}
HuaGongRange = sgs.CreateAttackRangeSkill{
	name = "#MdkHuaGongRange",
	extra_func = function(self, player)
		if player:getWeapon() then
		elseif player:hasSkill("MdkHuaGong") then
			if player:getPhase() == sgs.Player_Play then
				return 5
			end
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkHuaGong", "#MdkHuaGongRange")
--添加技能
Madoka:addSkill(HuaGong)
Madoka:addSkill(HuaGongRange)
--翻译信息
sgs.LoadTranslationTable{
	["MdkHuaGong"] = "花弓",
	[":MdkHuaGong"] = "锁定技。出牌阶段，若你没有装备武器，你视为装备有【麒麟弓】。",
	["$MdkHuaGong1"] = "一下子秘密就暴露了呢~",
	["$MdkHuaGong2"] = "对班上的同学们要保密哦!",
}
--[[
	技能：善心
	描述：你攻击范围内的一名其他角色即将受到不少于其体力的伤害时，若伤害来源不为你，你可以弃一张牌并失去1点体力，防止此伤害。
]]--
ShanXin = sgs.CreateTriggerSkill{
	name = "MdkShanXin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local n = damage.damage
		if n < player:getHp() then
			return false
		end
		local from = damage.from
		local room = player:getRoom()
		local others = room:getOtherPlayers(player)
		for _,source in sgs.qlist(others) do
			if from and from:objectName() == source:objectName() then
			elseif source:hasSkill("MdkShanXin") and source:inMyAttackRange(player) then
				if source:canDiscard(source, "he") then
					local prompt = string.format("@MdkShanXin:%s::%d:", player:objectName(), n)
					if room:askForCard(source, "..", prompt, data, "MdkShanXin") then
						------------------------------------------------
						--耦合技能“因果”的效果
						------------------------------------------------
						if source:hasSkill("MdkYinGuo") then
							source:gainMark("@MdkYinGuoMark", 1)
						end
						------------------------------------------------
						room:broadcastSkillInvoke("MdkShanXin") --播放配音
						room:notifySkillInvoked(source, "MdkShanXin") --显示技能发动
						room:loseHp(source, 1)
						local msg = sgs.LogMessage()
						msg.type = "#MdkShanXin"
						msg.from = source
						msg.to:append(player)
						msg.arg = "MdkShanXin"
						msg.arg2 = n
						room:sendLog(msg) --发送提示信息
						return true
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
Madoka:addSkill(ShanXin)
--翻译信息
sgs.LoadTranslationTable{
	["MdkShanXin"] = "善心",
	[":MdkShanXin"] = "你攻击范围内的一名其他角色即将受到不少于其体力的伤害时，若伤害来源不为你，你可以弃一张牌并失去1点体力，防止此伤害。",
	["$MdkShanXin"] = "虽然不知道，但一定要救这孩子",
	["@MdkShanXin"] = "%src 即将受到 %arg 点伤害，您可以发动“善心”弃置一张牌并失去1点体力，防止此伤害",
	["~MdkShanXin"] = "选择一张牌（包括装备）->点击“确定”",
	["#MdkShanXin"] = "%from 发动了“%arg”，防止了 %to 本次将遭受的 %arg2 点伤害",
}
--[[
	技能：因果
	描述：你每脱离一次濒死状态或发动一次“善心”，你获得一枚“因”标记；出牌阶段限X次，你可以将一张黑色手牌当作【无中生有】使用。（X为你拥有的“因”标记的数量）
]]--
YinGuoVS = sgs.CreateViewAsSkill{
	name = "MdkYinGuo",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then
		elseif to_select:isBlack() then
			return true
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local trick = sgs.Sanguosha:cloneCard("ex_nihilo", suit, point)
			trick:addSubcard(card)
			trick:setSkillName("MdkYinGuoEffect")
			return trick
		end
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:getMark("MdkYinGuoRecord") < player:getMark("@MdkYinGuoMark") then
			return true
		end
		return false
	end,
}
YinGuo = sgs.CreateTriggerSkill{
	name = "MdkYinGuo",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.QuitDying, sgs.CardUsed, sgs.EventPhaseStart},
	view_as_skill = YinGuoVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.QuitDying then
			room:broadcastSkillInvoke("MdkYinGuo", 1) --播放配音
			room:notifySkillInvoked(player, "MdkYinGuo") --显示技能发动
			player:gainMark("@MdkYinGuoMark", 1)
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			local trick = use.card
			if trick:isKindOf("ExNihilo") and trick:getSkillName() == "MdkYinGuoEffect" then
				room:broadcastSkillInvoke("MdkYinGuo", 2) --播放配音
				room:notifySkillInvoked(player, "MdkYinGuo") --显示技能发动
				room:addPlayerMark(player, "MdkYinGuoRecord", 1)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Play then
				room:setPlayerMark(player, "MdkYinGuoRecord", 0)
			end
		end
		return false
	end,
}
--添加技能
Madoka:addSkill(YinGuo)
--翻译信息
sgs.LoadTranslationTable{
	["MdkYinGuo"] = "因果",
	[":MdkYinGuo"] = "你每脱离一次濒死状态或发动一次“善心”，你获得一枚“因”标记；出牌阶段限X次，你可以将一张黑色手牌当作【无中生有】使用。（X为你拥有的“因”标记的数量）",
	["$MdkYinGuo1"] = "是梦啊……",
	["$MdkYinGuo2"] = "无论什么时候都一定会这样撑下去",
	["@MdkYinGuoMark"] = "因",
	["MdkYinGuoEffect"] = "因果",
}
if LinkSkillSwitch then
--[[
	技能：许愿（联动技->晓美焰）
	描述：晓美焰濒死时，若其不满足“轮回”的发动条件，你可以变身为神·鹿目圆，令其执行“轮回”的效果，然后立即结束当前回合。
]]--
XuYuan = sgs.CreateTriggerSkill{
	name = "MdkXuYuan&",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EnterDying},
	on_trigger = function(self, event, player, data)
		local dying = data:toDying()
		local victim = dying.who
		if victim and victim:objectName() == player:objectName() then
			if player:isChained() then
			elseif player:hasSkill("MdkLunHui") then
				if player:isKongcheng() and player:getPile("MdkJunHuoPile"):isEmpty() then
				elseif player:canDiscard(player, "he") then
					if player:getMark("@MdkLunHuiMark") <= player:getCardCount() then
						return false
					end
				end
			end
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:hasSkill("MdkXuYuan") then
					if source:askForSkillInvoke("MdkXuYuan", data) then
						room:broadcastSkillInvoke("MdkXuYuan") --播放配音
						room:notifySkillInvoked(source, "MdkXuYuan") --显示技能发动
						room:doSuperLightbox("KanameMadoka", "MdkXuYuan") --播放全屏特效
						local isSecondaryHero = false
						if source:getGeneralName() ~= "KanameMadoka" and source:getGeneral2Name() == "KanameMadoka" then
							isSecondaryHero = true
						end
						local to_keep, to_remove = getLinkSkills(room, source, "KanameMadoka", "GodMadoka")
						room:changeHero(source, "GodMadoka", true, true, isSecondaryHero, true)
						addLinkSkills(room, source, to_keep, to_remove)
						doLunHui(room, source, player)
						room:throwEvent(sgs.TurnBroken)
						return true
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() then
			if target:getGeneralName() == "AkemiHomura" then
				return true
			elseif target:getGeneral2Name() == "AkemiHomura" then
				return true
			end
		end
		return false
	end,
}
--添加技能
Madoka:addSkill(XuYuan)
--翻译信息
sgs.LoadTranslationTable{
	["MdkXuYuan"] = "许愿",
	[":MdkXuYuan"] = "<font color=\"cyan\"><b>联动技。</b></font>晓美焰濒死时，若其不满足“轮回”的发动条件，你可以变身为神·鹿目圆，令其执行“轮回”的效果，然后立即结束当前回合。",
	["$MdkXuYuan"] = "终于找到了答案，相信我吧，绝不会让小焰到今天为止的努力白费",
}
end
--[[****************************************************************
	编号：MDK - 02
	武将：晓美焰（Akemi Homura）
	称号：神秘的转校生
	性别：女
	势力：魏
	体力上限：3勾玉
]]--****************************************************************
Homura = sgs.General(extension, "AkemiHomura", "wei", 3, false)
--翻译信息
sgs.LoadTranslationTable{
	["AkemiHomura"] = "晓美焰",
	["&AkemiHomura"] = "晓美焰",
	["#AkemiHomura"] = "神秘的转校生",
	["designer:AkemiHomura"] = "DGAH",
	["cv:AkemiHomura"] = "斋藤千和",
	["illustrator:AkemiHomura"] = "百度百科",
	["~AkemiHomura"] = "这……就是我的……绝望……",
}
--[[
	技能：军火
	描述：分发起始手牌时，额外发你四张牌，然后你选择四张牌置于你的武将牌上，称为“军火”。
	说明：你失去此技能时，将“军火”中的所有牌收回为手牌。
]]--
JunHuo = sgs.CreateTriggerSkill{
	name = "MdkJunHuo",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawInitialCards, sgs.AfterDrawInitialCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawInitialCards then
			room:broadcastSkillInvoke("MdkJunHuo") --播放配音
			room:notifySkillInvoked(player, "MdkJunHuo") --显示技能发动
			room:sendCompulsoryTriggerLog(player, "MdkJunHuo") --发送锁定技触发信息
			local n = data:toInt() + 4
			data:setValue(n)
		elseif event == sgs.AfterDrawInitialCards then
			local prompt = "@MdkJunHuo:::4:"
			local to_put = room:askForExchange(player, "MdkJunHuo", 4, 4, false, prompt)
			player:addToPile("MdkJunHuoPile", to_put, false)
			to_put:deleteLater()
		end
		return false
	end,
}
function doJunHuoGotback(room, player)
	local pile = player:getPile("MdkJunHuoPile")
	if pile:isEmpty() then
		return false
	end
	local move = sgs.CardsMoveStruct()
	move.from = player
	move.from_place = sgs.Player_PlaceSpecial
	move.to = player
	move.to_place = sgs.Player_PlaceHand
	move.card_ids = pile
	move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, player:objectName(), "MdkJunHuo", "")
	room:moveCardsAtomic(move, true)
end
JunHuoClear = sgs.CreateTriggerSkill{
	name = "#MdkJunHuoClear",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		if data:toString() == "MdkJunHuo" then
			local room = player:getRoom()
			doJunHuoGotback(room, player)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
extension:insertRelatedSkills("MdkJunHuo", "#MdkJunHuoClear")
--添加技能
Homura:addSkill(JunHuo)
Homura:addSkill(JunHuoClear)
--翻译信息
sgs.LoadTranslationTable{
	["MdkJunHuo"] = "军火",
	[":MdkJunHuo"] = "分发起始手牌时，额外发你四张牌，然后你选择四张牌置于你的武将牌上，称为“军火”。",
	["$MdkJunHuo"] = "让我想一想",
	["MdkJunHuoPile"] = "军火",
	["@MdkJunHuo"] = "请选择将 %arg 张牌作为“军火”置于武将牌上",
}
--[[
	技能：时停（阶段技）
	描述：若你的武将牌没有被横置，你可以交换你的手牌区和“军火”，然后本阶段内你获得技能“布局”。
]]--
function doShiTingExchange(room, player, reason)
	local handcard_ids = player:handCards()
	local pile = player:getPile("MdkJunHuoPile")
	if not pile:isEmpty() then
		local move = sgs.CardsMoveStruct()
		move.from_place = sgs.Player_PlaceSpecial
		move.to = player
		move.to_place = sgs.Player_PlaceHand
		move.card_ids = pile
		move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, player:objectName(), reason, "")
		room:moveCardsAtomic(move, false)
	end
	if not handcard_ids:isEmpty() then
		player:addToPile("MdkJunHuoPile", handcard_ids, false)
	end
end
ShiTingCard = sgs.CreateSkillCard{
	name = "MdkShiTingCard",
	--skill_name = "MdkShiTing",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("MdkShiTing", 1) --播放配音
		room:notifySkillInvoked(source, "MdkShiTing") --显示技能发动
		doShiTingExchange(room, source, "MdkShiTing")
		room:handleAcquireDetachSkills(source, "MdkBuJu")
	end,
}
ShiTingVS = sgs.CreateViewAsSkill{
	name = "MdkShiTing",
	n = 0,
	view_as = function(self, cards)
		return ShiTingCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:isChained() then
			return false
		elseif player:hasUsed("#MdkShiTingCard") then
			return false
		elseif player:isKongcheng() and player:getPile("MdkJunHuoPile"):isEmpty() then
			return false
		end
		return true
	end,
}
ShiTing = sgs.CreateTriggerSkill{
	name = "MdkShiTing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	view_as_skill = ShiTingVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			if player:hasSkill("MdkBuJu") then
				local room = player:getRoom()
				room:broadcastSkillInvoke("MdkShiTing", 2) --播放配音
				room:handleAcquireDetachSkills(player, "-MdkBuJu", true)
			end
		end
		return false
	end,
}
--添加技能
Homura:addSkill(ShiTing)
--翻译信息
sgs.LoadTranslationTable{
	["MdkShiTing"] = "时停",
	[":MdkShiTing"] = "阶段技。若你的武将牌没有被横置，你可以交换你的手牌区和“军火”，然后本阶段内你获得技能“布局”。",
	["$MdkShiTing1"] = "（时停发动声）",
	["$MdkShiTing2"] = "（时停解除声）",
	["mdkshiting"] = "时停",
}
--[[
	技能：布局
	描述：出牌阶段，你可以将至少一张手牌置于一名角色的武将牌上，称为“局”；你失去本技能时，弃置场上所有的“局”，视为你对目标角色依次使用了这些牌。若无法使用，改为由其获得之。
]]--
BuJuCard = sgs.CreateSkillCard{
	name = "MdkBuJuCard",
	--skill_name = "MdkBuJu",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_use = function(self, room, source, targets)
		local index = 1
		if self:subcardsLength() == 1 then
			local id = self:getSubcards():first()
			local card = sgs.Sanguosha:getCard(id)
			if card then
				if card:isKindOf("Peach") or card:isKindOf("Jink") or card:isKindOf("Nullification") then
					index = 2
				elseif card:isKindOf("ExNihilo") or card:isKindOf("GlobalEffect") then
					index = 2
				end
			end
		end
		room:broadcastSkillInvoke("MdkBuJu", index) --播放配音
		room:notifySkillInvoked(source, "MdkBuJu") --显示技能发动
		local target = targets[1]
		target:addToPile("MdkBuJuPile", self, false)
	end,
}
BuJuVS = sgs.CreateViewAsSkill{
	name = "MdkBuJu",
	n = 999,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local card = BuJuCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
}
function doBuJuEffect(room, source, target, id)
	local card = sgs.Sanguosha:getCard(id)
	local can_use = true
	if card:isKindOf("Jink") or card:isKindOf("Nullification") or card:isKindOf("Collateral") then
		can_use = false
	elseif card:isKindOf("EquipCard") then
		if target:isCardLimited(card, sgs.Card_MethodUse) then
			can_use = false
		else
			local use = sgs.CardUseStruct()
			use.from = source
			use.to:append(target)
			use.card = card
			room:useCard(use, false)
			return 
		end
	elseif source:isProhibited(target, card) then
		can_use = false
	elseif source:isCardLimited(card, sgs.Card_MethodUse) then
		can_use = false
	elseif card:isKindOf("Peach") and target:getLostHp() == 0 then
		can_use = false
	elseif card:isKindOf("FireAttack") and target:isKongcheng() then
		can_use = false
	elseif card:isKindOf("Dismantlement") and not source:canDiscard(target, "hej") then
		can_use = false
	end
	if can_use then
		local flag = string.format("MdkBuJuTarget_%s", target:objectName())
		room:setCardFlag(card, "MdkBuJuEffect")
		room:setCardFlag(card, flag)
		local use = sgs.CardUseStruct()
		use.from = source
		use.to:append(target)
		use.card = card
		room:useCard(use, false)
		return 
	end
	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, source:objectName(), target:objectName(), "MdkBuJu", "")
	room:obtainCard(target, card, reason, true)
end
BuJu = sgs.CreateTriggerSkill{
	name = "MdkBuJu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventLoseSkill},
	view_as_skill = BuJuVS,
	on_trigger = function(self, event, player, data)
		if data:toString() == "MdkBuJu" then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,target in sgs.qlist(alives) do
				local pile = target:getPile("MdkBuJuPile")
				if not pile:isEmpty() then
					--room:broadcastSkillInvoke("MdkBuJu") --播放配音
					room:notifySkillInvoked(player, "MdkBuJu") --显示技能发动
					for _,id in sgs.qlist(pile) do
						doBuJuEffect(room, player, target, id)
						room:getThread():delay()
						if target:isDead() then
							break
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
BuJuAvoid = sgs.CreateProhibitSkill{
	name = "#MdkBuJuAvoid",
	is_prohibited = function(self, from, to, card)
		if card:hasFlag("MdkBuJuEffect") then
			local flag = string.format("MdkBuJuTarget_%s", to:objectName())
			return not card:hasFlag(flag)
		end
		return false
	end,
}
BuJuForAOE = sgs.CreateTriggerSkill{
	name = "#MdkBuJuForAOE",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreCardUsed},
	global = true,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local aoe = use.card
		if aoe and aoe:isKindOf("AOE") and aoe:hasFlag("MdkBuJuEffect") then
			local flag = string.format("MdkBuJuTarget_%s", player:objectName())
			if aoe:hasFlag(flag) and use.to:isEmpty() then
				use.to:append(player)
				data:setValue(use)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
extension:insertRelatedSkills("MdkBuJu", "#MdkBuJuAvoid")
extension:insertRelatedSkills("MdkBuJu", "#MdkBuJuForAOE")
--添加技能
SkillAnJiang:addSkill(BuJu)
SkillAnJiang:addSkill(BuJuAvoid)
SkillAnJiang:addSkill(BuJuForAOE)
Homura:addRelateSkill("MdkBuJu")
--翻译信息
sgs.LoadTranslationTable{
	["MdkBuJu"] = "布局",
	[":MdkBuJu"] = "出牌阶段，你可以将至少一张手牌置于一名角色的武将牌上，称为“局”；你失去本技能时，弃置场上所有的“局”，视为你对目标角色依次使用了这些牌。若无法使用，改为由其获得之。",
	["$MdkBuJu1"] = "（手枪音效）",
	["$MdkBuJu2"] = "（瞄准音效）",
	["MdkBuJuPile"] = "局",
	["mdkbuju"] = "布局",
}
--[[
	技能：轮回
	描述：你或你攻击范围内的一名角色即将进入濒死时，若你的武将牌没有被横置，你可以弃X张牌，交换你的手牌区和“军火”，令其将武将牌和体力牌重置为游戏开始时的状态，然后其弃置区域中的所有牌并摸四张牌。（X为你已发动过“轮回”的次数）
]]--
function doLunHui(room, source, target)
	local maxhp = target:getGeneralMaxHp()
	if maxhp ~= target:getMaxHp() then
		room:setPlayerProperty(target, "maxhp", sgs.QVariant(maxhp))
		room:broadcastProperty(target, "maxhp")
	end
	local hp = target:getHp()
	if hp < maxhp and target:isAlive() then
		local recover = sgs.RecoverStruct()
		recover.who = source
		recover.recover = maxhp - hp
		room:recover(target, recover)
	end
	if target:isChained() and target:isAlive() then
		room:setPlayerProperty(target, "chained", sgs.QVariant(false))
		room:broadcastProperty(target, "chained")
	end
	if target:isAlive() and not target:faceUp() then
		target:turnOver()
	end
	target:throwAllHandCardsAndEquips()
	local tricks = target:getJudgingArea()
	if not tricks:isEmpty() then
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, source:objectName(), target:objectName(), "MdkLunHui", "")
		for _,trick in sgs.qlist(tricks) do
			room:throwCard(trick, reason, nil)
		end
	end
	if target:isAlive() then
		room:drawCards(target, 4, "MdkLunHui")
	end
end
LunHuiCard = sgs.CreateSkillCard{
	name = "MdkLunHuiCard",
	--skill_name = "MdkLunHui",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		if source:hasSkill("MdkZuZhou") and source:getMark("@MdkZuZhouMark") > 0 then
		else
			room:broadcastSkillInvoke("MdkLunHui") --播放配音
		end
		room:notifySkillInvoked(source, "MdkLunHui") --显示技能发动
		source:gainMark("@MdkLunHuiMark", 1)
		local target = room:getCurrentDyingPlayer()
		doShiTingExchange(room, source, "MdkLunHui")
		if target and target:isAlive() then
			doLunHui(room, source, target)
		end
	end,
}
LunHuiVS = sgs.CreateViewAsSkill{
	name = "MdkLunHui",
	n = 999,
	view_filter = function(self, selected, to_select)
		return #selected < sgs.Self:getMark("@MdkLunHuiMark")
	end,
	view_as = function(self, cards)
		if #cards == sgs.Self:getMark("@MdkLunHuiMark") then
			local card = LunHuiCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@MdkLunHui"
	end,
}
LunHui = sgs.CreateTriggerSkill{
	name = "MdkLunHui",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EnterDying},
	view_as_skill = LunHuiVS,
	on_trigger = function(self, event, player, data)
		local dying = data:toDying()
		local victim = dying.who
		if victim and victim:objectName() == player:objectName() then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:isChained() then
				elseif source:hasSkill("MdkLunHui") then
					local prompt = ""
					local times = source:getMark("@MdkLunHuiMark")
					if source:isKongcheng() and source:getPile("MdkJunHuoPile"):isEmpty() then
					elseif source:objectName() == player:objectName() then
						prompt = string.format("@MdkLunHui-myself:::%d:", times)
					elseif source:inMyAttackRange(player) then
						prompt = string.format("@MdkLunHui:%s::%d:", player:objectName(), times)
					end
					if prompt ~= "" then
						if room:askForUseCard(source, "@@MdkLunHui", prompt) then
							return true
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
Homura:addSkill(LunHui)
--翻译信息
sgs.LoadTranslationTable{
	["MdkLunHui"] = "轮回",
	[":MdkLunHui"] = "你或你攻击范围内的一名角色即将进入濒死时，若你的武将牌没有被横置，你可以弃X张牌，交换你的手牌区和“军火”，令其将武将牌和体力牌重置为游戏开始时的状态，然后其弃置区域中的所有牌并摸四张牌。（X为你已发动过“轮回”的次数）",
	["$MdkLunHui1"] = "我的战场不是这里",
	["$MdkLunHui2"] = "重复……我将重复无数次",
	["@MdkLunHui"] = "你可以弃 %arg 张牌发动“轮回”，令 %src 重置武将牌为游戏开始时的状态",
	["@MdkLunHui-myself"] = "你可以弃 %arg 张牌发动“轮回”，将武将牌重置为游戏开始时的状态",
	["~MdkLunHui"] = "选择一些要弃的牌（包括装备）->点击“确定”",
	["@MdkLunHuiMark"] = "轮回",
	["mdklunhui"] = "轮回",
}
if LinkSkillSwitch then
--[[
	技能：羁绊（联动技->鹿目圆、锁定技）
	描述：其他角色计算的与鹿目圆的距离+1。
]]--
JiBan = sgs.CreateDistanceSkill{
	name = "MdkJiBan&",
	correct_func = function(self, from, to)
		local extra = 0
		if to:getGeneralName() == "KanameMadoka" or to:getGeneral2Name() == "KanameMadoka" then
			local others = from:getAliveSiblings()
			for _,source in sgs.qlist(others) do
				if source:hasSkill("MdkJiBan") then
					extra = extra + 1
				end
			end
		end
		return extra
	end,
}
--添加技能
Homura:addSkill(JiBan)
--翻译信息
sgs.LoadTranslationTable{
	["MdkJiBan"] = "羁绊",
	[":MdkJiBan"] = "<font color=\"cyan\"><b>联动技。</b></font>锁定技。其他角色计算的与鹿目圆的距离+1。",
	["$MdkJiBan1"] = "“要救你”，这是我最初的心意",
	["$MdkJiBan2"] = "这已经是留到最后的唯一的路标",
}
--[[
	技能：诅咒（联动技->神·鹿目圆）
	描述：神·鹿目圆被指定为黑色锦囊牌的目标时，若使用者不为你，你可以取消之，然后你受到1点伤害。若如此做，你在下次发动“轮回”后获得所有“军火”并变身为魔·晓美焰。
	说明：“诅咒”发动后，只要再发动“轮回”，不论目标是谁，晓美焰都将变身为魔·晓美焰。
]]--
ZuZhou = sgs.CreateTriggerSkill{
	name = "MdkZuZhou&",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetSpecifying},
	on_trigger = function(self, events, player, data)
		local use = data:toCardUse()
		local trick = use.card
		if trick:isBlack() and trick:isNDTrick() then
			local targets = {}
			local victims = use.to
			for _,victim in sgs.qlist(victims) do
				if victim:getGeneralName() == "GodMadoka" or victim:getGeneral2Name() == "GodMadoka" then
					table.insert(targets, victim)
				end
			end
			if #targets == 0 then
				return false
			end
			local user = use.from
			local user_name = user and user:objectName() or ""
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			local to_cancel = {}
			local to_damage = {}
			to_cancel["isEmpty"] = true
			for _,target in ipairs(targets) do
				for _,source in sgs.qlist(alives) do
					if source:objectName() == user_name then
					elseif source:hasSkill("MdkZuZhou") and source:isAlive() then
						local prompt = string.format("invoke:%s::%s:", target:objectName(), trick:objectName())
						local ai_data = sgs.QVariant()
						ai_data:setValue(trick)
						room:setTag("MdkZuZhouTrick", ai_data) --For AI
						ai_data:setValue(user)
						room:setTag("MdkZuZhouUser", ai_data) --For AI
						local invoke = source:askForSkillInvoke("MdkZuZhou", sgs.QVariant(prompt))
						room:removeTag("MdkZuZhouUser") --For AI
						room:removeTag("MdkZuZhouTrick") --For AI
						if invoke then
							room:broadcastSkillInvoke("MdkZuZhou", 1) --播放配音
							room:notifySkillInvoked(source, "MdkZuZhou") --显示技能发动
							local msg = sgs.LogMessage()
							msg.type = "#MdkZuZhouCancel"
							msg.from = source
							msg.to:append(target)
							msg.arg = "MdkZuZhou"
							msg.card_str = trick:toString()
							room:sendLog(msg) --发送提示信息
							to_cancel[target:objectName()] = true
							to_cancel["isEmpty"] = false
							table.insert(to_damage, source)
							room:addPlayerMark(source, "MdkZuZhouDamage", 1)
							if source:getMark("@MdkZuZhouMark") == 0 then
								source:gainMark("@MdkZuZhouMark", 1)
							end
							break
						end
					end
				end
			end
			if to_cancel["isEmpty"] then
				return false
			end
			local new_targets = sgs.SPlayerList()
			for _,victim in sgs.qlist(victims) do
				if not to_cancel[victim:objectName()] then
					new_targets:append(victim)
				end
			end
			use.to = new_targets
			data:setValue(use)
			for _,source in ipairs(to_damage) do
				local damage = sgs.DamageStruct()
				damage.from = nil
				damage.to = source
				damage.damage = source:getMark("MdkZuZhouDamage")
				damage.reason = "MdkZuZhou"
				room:setPlayerMark(source, "MdkZuZhouDamage", 0)
				room:damage(damage)
			end
			return use.to:isEmpty()
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
ZuZhouAvoid = sgs.CreateTriggerSkill{
	name = "#MdkZuZhouAvoid",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		if move.to_place == sgs.Player_PlaceDelayedTrick then
			local target = move.to
			if target and target:objectName() == player:objectName() then
				local tricks = {}
				for _,id in sgs.qlist(move.card_ids) do
					local trick = sgs.Sanguosha:getCard(id)
					if trick:isBlack() and trick:isKindOf("DelayedTrick") then
						table.insert(tricks, trick)
					end
				end
				if #tricks == 0 then
					return false
				end
				local user = move.from
				local name = user and user:objectName() or ""
				local room = player:getRoom()
				local alives = room:getAlivePlayers()
				local to_cancel = sgs.IntList()
				local canceled = {}
				local to_damage = {}
				for _,source in sgs.qlist(alives) do
					if source:objectName() == name then
					elseif source:hasSkill("MdkZuZhou") and source:isAlive() then
						for _,trick in ipairs(tricks) do
							local id = trick:getEffectiveId()
							if not canceled[id] then
								local prompt = string.format("invoke:%s::%s:", player:objectName(), trick:objectName())
								local ai_data = sgs.QVariant()
								ai_data:setValue(trick)
								room:setTag("MdkZuZhouTrick", ai_data) --For AI
								ai_data:setValue(user)
								room:setTag("MdkZuZhouUser", ai_data) --For AI
								local invoke = source:askForSkillInvoke("MdkZuZhou", sgs.QVariant(prompt))
								room:removeTag("MdkZuZhouUser") --For AI
								room:removeTag("MdkZuZhouTrick") --For AI
								if invoke then
									local index = name == "Incubator" and 2 or 1
									room:broadcastSkillInvoke("MdkZuZhou", index) --播放配音
									room:notifySkillInvoked(source, "MdkZuZhou") --显示技能发动
									local msg = sgs.LogMessage()
									msg.type = "#MdkZuZhouCancel"
									msg.from = source
									msg.to:append(player)
									msg.arg = "MdkZuZhou"
									msg.card_str = trick:toString()
									room:sendLog(msg) --发送提示信息
									local throw = sgs.CardsMoveStruct()
									throw.to = nil
									throw.to_place = sgs.Player_DiscardPile
									throw.card_ids:append(id)
									throw.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, source:objectName(), "MdkZuZhou", "")
									room:moveCardsAtomic(throw, true)
									to_cancel:append(id)
									canceled[id] = true
									table.insert(to_damage, source)
									room:addPlayerMark(source, "MdkZuZhouDamage", 1)
									if source:getMark("@MdkZuZhouMark") == 0 then
										source:gainMark("@MdkZuZhouMark", 1)
									end
								end
							end
						end
					end
				end
				if to_cancel:isEmpty() then
					return false
				end
				move:removeCardIds(to_cancel)
				data:setValue(move)
				for _,source in ipairs(to_damage) do
					local damage = sgs.DamageStruct()
					damage.from = nil
					damage.to = source
					damage.damage = source:getMark("MdkZuZhouDamage")
					damage.reason = "MdkZuZhou"
					room:setPlayerMark(source, "MdkZuZhouDamage", 0)
					room:damage(damage)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() then
			if target:getGeneralName() == "GodMadoka" then
				return true
			elseif target:getGeneral2Name() == "GodMadoka" then
				return true
			end
		end
		return false
	end,
}
ZuZhouEffect = sgs.CreateTriggerSkill{
	name = "#MdkZuZhouEffect",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local card = use.card
		if card and card:isKindOf("SkillCard") and card:objectName() == "MdkLunHuiCard" then
			local room = player:getRoom()
			room:broadcastSkillInvoke("MdkZuZhou", 3) --播放配音
			room:notifySkillInvoked(player, "MdkZuZhou") --显示技能发动
			room:doSuperLightbox("DevilHomura", "MdkZuZhou") --播放全屏特效
			room:getThread():delay()
			player:loseAllMarks("@MdkZuZhouMark")
			doJunHuoGotback(room, player)
			local isSecondaryHero = false
			if player:getGeneralName() ~= "AkemiHomura" and player:getGeneral2Name() == "AkemiHomura" then
				isSecondaryHero = true
			end
			local to_keep, to_remove = getLinkSkills(room, player, "AkemiHomura", "DevilHomura")
			room:changeHero(player, "DevilHomura", true, true, isSecondaryHero, true)
			addLinkSkills(room, player, to_keep, to_remove)
		end
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:getMark("@MdkZuZhouMark") > 0
	end,
}
extension:insertRelatedSkills("MdkZuZhou", "#MdkZuZhouAvoid")
extension:insertRelatedSkills("MdkZuZhou", "#MdkZuZhouEffect")
--添加技能
Homura:addSkill(ZuZhou)
Homura:addSkill(ZuZhouAvoid)
Homura:addSkill(ZuZhouEffect)
--翻译信息
sgs.LoadTranslationTable{
	["MdkZuZhou"] = "诅咒",
	[":MdkZuZhou"] = "<font color=\"cyan\"><b>联动技。</b></font>神·鹿目圆被指定为黑色锦囊牌的目标时，若使用者不为你，你可以取消之，然后你受到1点伤害。若如此做，你在下次发动“轮回”后获得所有“军火”并变身为魔·晓美焰。",
	["$MdkZuZhou1"] = "我……要拯救小圆",
	["$MdkZuZhou2"] = "我绝不会再让孵化者碰她",
	["$MdkZuZhou3"] = "这才是人类感情的极致：比希望炙热，比绝望深邃……那是爱",
	["MdkZuZhou:invoke"] = "您想发动“诅咒”取消 %src 成为此【%arg】的目标吗？",
	["#MdkZuZhouCancel"] = "%from 发动了“%arg”，取消了 %to 作为此 %card 的目标",
	["@MdkZuZhouMark"] = "诅咒",
}
end
--[[****************************************************************
	编号：MDK - 03
	武将：美树沙耶香（Miki Sayaka）
	称号：守护的心意
	性别：女
	势力：魏
	体力上限：3勾玉
]]--****************************************************************
Sayaka = sgs.General(extension, "MikiSayaka", "wei", 3, false)
--翻译信息
sgs.LoadTranslationTable{
	["MikiSayaka"] = "美树沙耶香",
	["&MikiSayaka"] = "美树沙耶香",
	["#MikiSayaka"] = "守护的心意",
	["designer:MikiSayaka"] = "DGAH",
	["cv:MikiSayaka"] = "喜多村英梨",
	["illustrator:MikiSayaka"] = "百度百科",
	["~MikiSayaka"] = "我……真是个笨蛋……",
}
--[[
	技能：剑术（锁定技）
	描述：出牌阶段，你对距离为1的角色使用【杀】造成的伤害+1；且若你装备有剑类武器，你可以额外使用一张【杀】。
	说明：剑类武器，包括“雌雄双股剑”、“青釭剑”、“寒冰剑”、“倚天剑”、“杨修剑”共五种。
]]--
JianShu = sgs.CreateTriggerSkill{
	name = "MdkJianShu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			local damage = data:toDamage()
			local slash = damage.card
			if slash and slash:isKindOf("Slash") then
				local target = damage.to
				if target and player:distanceTo(target) == 1 then
					local room = player:getRoom()
					local msg = sgs.LogMessage()
					msg.type = "#MdkJianShuInvoke"
					msg.from = player
					msg.to:append(target)
					msg.arg = "MdkJianShu"
					room:sendLog(msg) --发送提示信息
					local n = damage.damage
					msg.type = "#MdkJianShuEffect"
					msg.arg = n
					n = n + 1
					msg.arg2 = n
					local play_sound = true
					if player:hasSkill("MdkJianQiang") and slash:isRed() then
						if player:getGeneralName() == "SakuraKyouko" then
							play_sound = false
						elseif player:getGeneral2Name() == "SakuraKyouko" and player:getGeneralName() ~= "MikiSayaka" then
							play_sound = false
						end
					end
					if play_sound then
						local index = ( n < target:getHp() and 1 or 2 )
						room:broadcastSkillInvoke("MdkJianShu", index) --播放配音
					end
					room:notifySkillInvoked(player, "MdkJianShu") --显示技能发动
					room:sendLog(msg) --发送提示信息
					damage.damage = n
					data:setValue(damage)
				end
			end
		end
		return false
	end,
}
JianShuMod = sgs.CreateTargetModSkill{
	name = "#MdkJianShuMod",
	residue_func = function(self, player, card)
		if card:isKindOf("Slash") and player:hasSkill("MdkJianShu") then
			if player:getPhase() == sgs.Player_Play then
				local weapon = player:getWeapon()
				local name = weapon and weapon:objectName() or ""
				if string.find(name, "sword") then
					return 1
				end
			end
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkJianShu", "#MdkJianShuMod")
--添加技能
Sayaka:addSkill(JianShu)
Sayaka:addSkill(JianShuMod)
--翻译信息
sgs.LoadTranslationTable{
	["MdkJianShu"] = "剑术",
	[":MdkJianShu"] = "锁定技。出牌阶段，你对距离为1的角色使用【杀】造成的伤害+1；且若你装备有剑类武器，你可以额外使用一张【杀】。",
	["$MdkJianShu1"] = "（舞剑声）",
	["$MdkJianShu2"] = "这是最后一击！",
	["#MdkJianShuInvoke"] = "%from 的技能“%arg”被触发，对 %to 造成的伤害+1",
	["#MdkJianShuEffect"] = "本次伤害由 %arg 点上升至 %arg2 点",
}
--[[
	技能：治愈
	描述：一名角色的回合结束时，若其已受伤，你可以交给其一张红心牌，令其回复1点体力。
	说明：若使用红心手牌对自己发动，则只需展示此红心牌即可。
]]--
ZhiYu = sgs.CreateTriggerSkill{
	name = "MdkZhiYu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			if player:isWounded() then
				local room = player:getRoom()
				local alives = room:getAlivePlayers()
				for _,source in sgs.qlist(alives) do
					if source:hasSkill("MdkZhiYu") and source:canDiscard(source, "h") then
						local pattern = ".|heart|.|."
						local prompt = "@MdkZhiYu-myself"
						if source:objectName() ~= player:objectName() then
							prompt = string.format("@MdkZhiYu:%s:", player:objectName())
						end
						local heart = room:askForCard(source, pattern, prompt, data, sgs.Card_MethodNone, nil, false, "MdkZhiYu", false)
						if heart then
							room:broadcastSkillInvoke("MdkZhiYu") --播放配音
							room:notifySkillInvoked(source, "MdkZhiYu") --显示技能发动
							if prompt == "@MdkZhiYu-myself" then
								local id = heart:getEffectiveId()
								room:showCard(source, id)
							end
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), player:objectName(), "MdkZhiYu", "")
							room:obtainCard(player, heart, reason, true)
							local recover = sgs.RecoverStruct()
							recover.who = source
							recover.recover = 1
							recover.card = heart
							room:recover(player, recover)
							if not player:isWounded() then
								return false
							end
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
--添加技能
Sayaka:addSkill(ZhiYu)
--翻译信息
sgs.LoadTranslationTable{
	["MdkZhiYu"] = "治愈",
	[":MdkZhiYu"] = "一名角色的回合结束时，若其已受伤，你可以交给其一张红心牌，令其回复1点体力。",
	["$MdkZhiYu"] = "奇迹和魔法都是存在的！",
	["@MdkZhiYu"] = "您可以发动“治愈”交给 %src 一张 红心 牌，令其回复 1 点体力",
	["~MdkZhiYu"] = "选择一张红心花色的牌（包括装备）->点击“确定”",
	["@MdkZhiYu-myself"] = "您可以发动“治愈”选择一张 红心 牌，回复 1 点体力",
}
--[[
	技能：黑化（限定技）
	描述：当你濒死时，你可以放弃求桃，失去技能“剑术”、“治愈”和“黑化”，回复体力至1点，然后变更为一个对立的身份并获得技能“人鱼”。
	说明：变更身份时，若有多个对立的身份，随机变为其中之一；身份局中，若原身份为主公，则变更身份后游戏立即结束，主忠方失败。
]]--
function doHeiHua(room, player)
	local is_hegemony = sgs.GetConfig("EnableHegemony", false)
	local game_mode = room:getMode()
	local is_1v3 = string.find(game_mode, "04_")
	local is_3v3 = string.find(game_mode, "06_")
	local camps = {}
	local lords = {}
	if is_hegemony then
		camps = {{"lord"}, {"loyalist"}, {"renegade"}, {"rebel"}}
	elseif is_1v3 then
		camps = {{"lord", "loyalist"}, {"rebel"}}
		lords = {"lord"}
	elseif is_3v3 then
		camps = {{"lord", "loyalist"}, {"renegade", "rebel"}}
		lords = {"lord", "renegade"}
	elseif game_mode == "08_defense" then
		camps = {{"loyalist"}, {"rebel"}}
	else
		camps = {{"lord", "loyalist"}, {"renegade"}, {"rebel"}}
		lords = {"lord"}
	end
	local my_role = player:getRole()
	local rest_role_list = {}
	for _,camp in ipairs(camps) do
		local meet = false
		for _,role in ipairs(camp) do
			if role == my_role then
				meet = true
			end
		end
		if not meet then
			for _,role in ipairs(camp) do
				local can_add = true
				for _,lord in ipairs(lords) do
					if lord == role then
						can_add = false
						break
					end
				end
				if can_add then
					table.insert(rest_role_list, role)
				end
			end
		end
	end
	local new_role = rest_role_list[math.random(1, #rest_role_list)]
	local new_camp = {}
	for _,camp in ipairs(camps) do
		for _,role in ipairs(camp) do
			if role == new_role then
				new_camp = camp
				break
			end
		end
	end
	local game_over = false
	for _,lord in ipairs(lords) do
		if lord == my_role then
			game_over = true
			break
		end
	end
	if not game_over then
		local other_roles = room:aliveRoles(player)
		local has_other_camp = false
		for _,other_role in ipairs(other_roles) do
			local is_same_camp = false
			for _,role in ipairs(new_camp) do
				if role == other_role then
					is_same_camp = true
					break
				end
			end
			if not is_same_camp then
				has_other_camp = true
				break
			end
		end
		if not has_other_camp then
			game_over = true
		end
	end
	room:setPlayerProperty(player, "role", sgs.QVariant(new_role))
	room:broadcastProperty(player, "role")
	room:updateStateItem()
	----------------------------------------------------------------
	--For AI
	----------------------------------------------------------------
	room:resetAI(player)
	local thread = room:getThread()
	local info = string.format("MdkHeiHua:Result:%s", new_role)
	thread:trigger(sgs.ChoiceMade, room, player, sgs.QVariant(info))
	----------------------------------------------------------------
	if game_over then
		local winner = table.concat(new_camp, "+")
		room:gameOver(winner)
	end
end
HeiHua = sgs.CreateTriggerSkill{
	name = "MdkHeiHua",
	frequency = sgs.Skill_Limited,
	events = {sgs.Dying},
	limit_mark = "@MdkHeiHuaMark",
	on_trigger = function(self, event, player, data)
		if player:getMark("@MdkHeiHuaMark") == 0 then
			return false
		end
		local dying = data:toDying()
		local who = dying.who
		if who and who:objectName() == player:objectName() then
			if player:askForSkillInvoke("MdkHeiHua", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("MdkHeiHua") --播放配音
				room:doSuperLightbox("MikiSayaka", "MdkHeiHua") --播放全屏特效
				player:loseMark("@MdkHeiHuaMark", 1)
				room:setPlayerMark(player, "MdkHeiHuaInvoked", 1)
				room:handleAcquireDetachSkills(player, "-MdkJianShu|-MdkZhiYu|-MdkHeiHua")
				local hp = player:getHp()
				if hp < 1 then
					local recover = sgs.RecoverStruct()
					recover.who = player
					recover.recover = 1 - hp
					room:recover(player, recover)
				end
				doHeiHua(room, player)
				room:handleAcquireDetachSkills(player, "MdkRenYu")
			end
		end
		return false
	end,
}
--添加技能
Sayaka:addSkill(HeiHua)
--翻译信息
sgs.LoadTranslationTable{
	["MdkHeiHua"] = "黑化",
	[":MdkHeiHua"] = "限定技。当你濒死时，你可以放弃求桃，失去技能“剑术”、“治愈”和“黑化”，回复体力至1点，然后变更为一个对立的身份并获得技能“人鱼”。",
	["$MdkHeiHua"] = "只要我愿意，痛苦什么的……完全能消除的啊！",
	["@MdkHeiHuaMark"] = "灵石",
}
--[[
	技能：人鱼（锁定技）
	描述：你跳过摸牌和弃牌阶段；你攻击范围外的其他角色不能成为你使用的牌的目标；其他角色即将对你造成伤害时，你获得其两张牌并对其造成X点伤害（X为你已损失的体力）。
]]--
RenYu = sgs.CreateTriggerSkill{
	name = "MdkRenYu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageForseen, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageForseen then
			local damage = data:toDamage()
			local source = damage.from
			if source and source:objectName() ~= player:objectName() then
				local x = player:getLostHp()
				if x > 0 then
					room:broadcastSkillInvoke("MdkRenYu") --播放配音
					room:notifySkillInvoked(player, "MdkRenYu") --显示技能发动
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName(), source:objectName(), "MdkRenYu", "")
					for i=1, 2, 1 do
						if source:isNude() then
							break
						end
						local id = room:askForCardChosen(player, source, "he", "MdkRenYu")
						if id < 0 then
							break
						end
						local place = room:getCardPlace(id)
						local unhide = ( place ~= sgs.Player_PlaceHand )
						local card = sgs.Sanguosha:getCard(id)
						room:obtainCard(player, card, reason, unhide)
					end
					local rejection = sgs.DamageStruct()
					rejection.from = player
					rejection.to = source
					rejection.damage = x
					room:damage(rejection)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			local phase = change.to
			if phase == sgs.Player_Draw or phase == sgs.Player_Discard then
				if player:isSkipped(phase) then
					return false
				end
				player:skip(phase)
			end
		end
		return false
	end,
}
RenYuLimit = sgs.CreateProhibitSkill{
	name = "#MdkRenYuLimit",
	is_prohibited = function(self, from, to, card)
		if card:isKindOf("SkillCard") then
			return false
		elseif from:objectName() == to:objectName() then
			return false
		elseif from:hasSkill("MdkRenYu") then
			return not from:inMyAttackRange(to)
		end
		return false
	end,
}
extension:insertRelatedSkills("MdkRenYu", "#MdkRenYuLimit")
--添加技能
SkillAnJiang:addSkill(RenYu)
SkillAnJiang:addSkill(RenYuLimit)
Sayaka:addRelateSkill("MdkRenYu")
--翻译信息
sgs.LoadTranslationTable{
	["MdkRenYu"] = "人鱼",
	[":MdkRenYu"] = "锁定技。你跳过摸牌和弃牌阶段；你攻击范围外的其他角色不能成为你使用的牌的目标；其他角色即将对你造成伤害时，你获得其两张牌并对其造成X点伤害（X为你已损失的体力）。",
	["$MdkRenYu"] = "（人鱼魔女出场背景音乐）",
}
if LinkSkillSwitch then
--[[
	技能：陪伴（联动技->上条恭介、锁定技）
	描述：上条恭介的手牌上限+X（X为其已损失的体力）。
]]--
PeiBan = sgs.CreateMaxCardsSkill{
	name = "MdkPeiBan&",
	extra_func = function(self, player)
		if player:getGeneralName() == "KamijouKyousuke" or player:getGeneral2Name() == "KamijouKyousuke" then
			local x = player:getLostHp()
			if x > 0 then
				if player:hasSkill("MdkPeiBan") then
					return x
				end
				local others = player:getAliveSiblings()
				for _,source in sgs.qlist(others) do
					if source:hasSkill("MdkPeiBan") then
						return x
					end
				end
			end
		end
		return 0
	end,
}
--添加技能
Sayaka:addSkill(PeiBan)
--翻译信息
sgs.LoadTranslationTable{
	["MdkPeiBan"] = "陪伴",
	[":MdkPeiBan"] = "<font color=\"cyan\"><b>联动技。</b></font>锁定技。上条恭介的手牌上限+X（X为其已损失的体力）。",
	["$MdkPeiBan"] = "一直以来真是谢谢你了[by上条恭介]",
}
--[[
	技能：牵挂（联动技->佐仓杏子、锁定技）
	描述：佐仓杏子的攻击范围+1，同时你计算的与其他角色的距离-1。
]]--
QianGua = sgs.CreateAttackRangeSkill{
	name = "MdkQianGua&",
	extra_func = function(self, player)
		if player:getGeneralName() == "SakuraKyouko" or player:getGeneral2Name() == "SakuraKyouko" then
			if player:hasSkill("MdkQianGua") then
				return 1
			end
			local others = player:getSiblings()
			for _,source in sgs.qlist(others) do
				if source:hasSkill("MdkQianGua") then
					return 1
				end
			end
		end
		return 0
	end,
}
QianGuaDist = sgs.CreateDistanceSkill{
	name = "#MdkQianGuaDist",
	correct_func = function(self, from, to)
		if from:getGeneralName() == "MikiSayaka" or from:getGeneral2Name() == "MikiSayaka" then
			local alives = from:getAliveSiblings()
			alives:append(from)
			for _,source in sgs.qlist(alives) do
				if source:getGeneralName() == "SakuraKyouko" or source:getGeneral2Name() == "SakuraKyouko" then
					return -1
				end
			end
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkQianGua", "#MdkQianGuaDist")
--添加技能
Sayaka:addSkill(QianGua)
Sayaka:addSkill(QianGuaDist)
--翻译信息
sgs.LoadTranslationTable{
	["MdkQianGua"] = "牵挂",
	[":MdkQianGua"] = "<font color=\"cyan\"><b>联动技。</b></font>锁定技。佐仓杏子的攻击范围+1，同时你计算的与其他角色的距离-1。",
	["$MdkQianGua"] = "果然我……还是牵挂着……",
	["#MdkQianGuaDist"] = "牵挂",
}
--[[
	技能：救赎（联动技->神·鹿目圆、锁定技）
	描述：神·鹿目圆的出牌阶段开始时，你失去已有的技能“黑化”和“人鱼”，然后重新获得已失去的技能“剑术”和“治愈”。
]]--
JiuShu = sgs.CreateTriggerSkill{
	name = "MdkJiuShu&",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local alives = room:getAlivePlayers()
		for _,target in sgs.qlist(alives) do
			if target:hasSkill("MdkJiuShu") then
				local names = {}
				if target:hasSkill("MdkHeiHua") then
					table.insert(names, "-MdkHeiHua")
				end
				if target:hasSkill("MdkRenYu") then
					table.insert(names, "-MdkRenYu")
				end
				if not target:hasSkill("MdkJianShu") then
					table.insert(names, "MdkJianShu")
				end
				if not target:hasSkill("MdkZhiYu") then
					table.insert(names, "MdkZhiYu")
				end
				if #names > 0 then
					room:doSuperLightbox("MikiSayaka", "MdkJiuShu") --播放全屏特效
					room:broadcastSkillInvoke("MdkJiuShu") --播放配音
					room:notifySkillInvoked(target, "MdkJiuShu") --显示技能发动
					local skillnames = table.concat(names, "|")
					room:handleAcquireDetachSkills(target, skillnames)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() and target:getPhase() == sgs.Player_Play then
			if target:getGeneralName() == "GodMadoka" then
				return true
			elseif target:getGeneral2Name() == "GodMadoka" then
				return true
			end
		end
		return false
	end,
}
--添加技能
Sayaka:addSkill(JiuShu)
--翻译信息
sgs.LoadTranslationTable{
	["MdkJiuShu"] = "救赎",
	[":MdkJiuShu"] = "<font color=\"cyan\"><b>联动技。</b></font>神·鹿目圆的出牌阶段开始时，你失去已有的技能“黑化”和“人鱼”，然后重新获得已失去的技能“剑术”和“治愈”。",
	["$MdkJiuShu"] = "已经没有任何后悔了",
}
--[[
	技能：神使（联动技->神·鹿目圆）
	描述：你从神·鹿目圆处获得牌时，你获得一枚“令”标记。你的手牌上限+X（X为你的“令”标记的数量）。神·鹿目圆或你攻击范围内的一名其他角色的回合开始时，你可以弃一枚“令”标记，令该角色摸两张牌。
]]--
ShenShiCard = sgs.CreateSkillCard{
	name = "MdkShenShiCard",
	skill_name = "MdkShenShi",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:notifySkillInvoked(source, "MdkShenShi") --显示技能发动
		source:loseMark("@MdkShenShiMark", 1)
		local target = room:getCurrent()
		room:drawCards(target, 2, "MdkShenShi")
	end,
}
ShenShiVS = sgs.CreateViewAsSkill{
	name = "MdkShenShi",
	n = 0,
	view_as = function(self, cards)
		return ShenShiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@MdkShenShi"
	end,
}
ShenShi = sgs.CreateTriggerSkill{
	name = "MdkShenShi&",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = ShenShiVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			local amTarget = false
			if player:getGeneralName() == "GodMadoka" or player:getGeneral2Name() == "GodMadoka" then
				amTarget = true
			end
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:getMark("@MdkShenShiMark") > 0 and source:hasSkill("MdkShenShi") then
					if amTarget or source:inMyAttackRange(player) then
						local prompt = string.format("@MdkShenShi:%s:", player:objectName())
						room:askForUseCard(source, "@@MdkShenShi", prompt)
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
ShenShiRecord = sgs.CreateTriggerSkill{
	name = "#MdkShenShiRecord",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local dest = move.to
		if dest and dest:objectName() == player:objectName() then
			local place = move.to_place
			if place == sgs.Player_PlaceHand or place == sgs.Player_PlaceEquip then
				local source = move.from
				if source then
					if source:getGeneralName() == "GodMadoka" or source:getGeneral2Name() == "GodMadoka" then
						for _,from in sgs.qlist(move.from_places) do
							if from == sgs.Player_PlaceHand or from == sgs.Player_PlaceEquip then
								local can_invoke = true
								if source:objectName() == player:objectName() then
									if from == place then
										can_invoke = false
									else
										local reason = bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
										if reason == sgs.CardMoveReason_S_REASON_GOTCARD then
										elseif reason == sgs.CardMoveReason_S_REASON_TRANSFER then
										elseif reason == sgs.CardMoveReason_S_REASON_PUT then
										else
											can_invoke = false
										end
									end
								end
								if can_invoke then
									local room = player:getRoom()
									room:notifySkillInvoked(player, "MdkShenShi") --显示技能发动
									player:gainMark("@MdkShenShiMark", 1)
									return false
								end
							end
						end
					end
				end
			end
		end
	end,
}
ShenShiKeep = sgs.CreateMaxCardsSkill{
	name = "#MdkShenShiKeep",
	extra_func = function(self, player)
		if player:hasSkill("MdkShenShi") then
			return player:getMark("@MdkShenShiMark")
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkShenShi", "#MdkShenShiRecord")
extension:insertRelatedSkills("MdkShenShi", "#MdkShenShiKeep")
--添加技能
Sayaka:addSkill(ShenShi)
Sayaka:addSkill(ShenShiRecord)
Sayaka:addSkill(ShenShiKeep)
--翻译信息
sgs.LoadTranslationTable{
	["MdkShenShi"] = "神使",
	[":MdkShenShi"] = "<font color=\"cyan\"><b>联动技。</b></font>你从神·鹿目圆处获得牌时，你获得一枚“令”标记。你的手牌上限+X（X为你的“令”标记的数量）。神·鹿目圆或你攻击范围内的一名其他角色的回合开始时，你可以弃一枚“令”标记，令该角色摸两张牌。",
	["$MdkShenShi1"] = "因为那就是我的职责啊",
	["$MdkShenShi2"] = "总之，我们就像是扛包的搬运工",
	["@MdkShenShiMark"] = "令",
	["@MdkShenShi"] = "您可以发动“神使”弃一枚“令”标记，令 %src 摸两张牌",
	["~MdkShenShi"] = "点击“确定”即可",
}
end
--[[****************************************************************
	编号：MDK - 04
	武将：巴麻美（Tomoe Mami）
	称号：优雅的学姐
	性别：女
	势力：吴
	体力上限：3勾玉
]]--****************************************************************
Mami = sgs.General(extension, "TomoeMami", "wu", 3, false)
--翻译信息
sgs.LoadTranslationTable{
	["TomoeMami"] = "巴麻美",
	["&TomoeMami"] = "巴麻美",
	["#TomoeMami"] = "优雅的学姐",
	["designer:TomoeMami"] = "DGAH",
	["cv:TomoeMami"] = "水桥香织",
	["illustrator:TomoeMami"] = "百度百科",
	["~TomoeMami"] = "成为魔法少女就是这个下场[by晓美焰]",
}
--[[
	技能：火枪
	描述：出牌阶段，若你装备有武器牌，你可以视为对一名角色使用了一张【杀】（不计入次数限制），然后你弃置此武器牌。
]]--
HuoQiangCard = sgs.CreateSkillCard{
	name = "MdkHuoQiangCard",
	skill_name = "MdkHuoQiang",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:canSlash(to_select)
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("_MdkHuoQiang")
		local use = sgs.CardUseStruct()
		use.from = source
		use.to:append(target)
		use.card = slash
		room:useCard(use, false)
		local weapon = source:getWeapon()
		if weapon then
			room:throwCard(weapon, source, source)
		end
	end,
}
HuoQiang = sgs.CreateViewAsSkill{
	name = "MdkHuoQiang",
	n = 0,
	view_as = function(self, cards)
		return HuoQiangCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getWeapon()
	end,
}
--添加技能
Mami:addSkill(HuoQiang)
--翻译信息
sgs.LoadTranslationTable{
	["MdkHuoQiang"] = "火枪",
	[":MdkHuoQiang"] = "出牌阶段，若你装备有武器牌，你可以视为对一名角色使用了一张【杀】（不计入次数限制），然后你弃置此武器牌。",
	["$MdkHuoQiang"] = "（燧发枪声）",
}
--[[
	技能：缎带
	描述：出牌阶段，你可以将一张红色锦囊牌当作【铁索连环】对至少一名角色使用；你计算的与武将牌横置的其他角色的距离-1。
]]--
DuanDaiCard = sgs.CreateSkillCard{
	name = "MdkDuanDaiCard",
	skill_name = "MdkDuanDai",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		local id = self:getSubcards():first()
		local card = sgs.Sanguosha:getCard(id)
		local suit = card:getSuit()
		local point = card:getNumber()
		local chain = sgs.Sanguosha:cloneCard("iron_chain", suit, point)
		chain:deleteLater()
		local selected = sgs.PlayerList()
		for _,p in ipairs(targets) do
			selected:append(p)
		end
		return chain:targetFilter(selected, to_select, sgs.Self)
	end,
	feasible = function(self, targets)
		if #targets > 0 then
			local id = self:getSubcards():first()
			local card = sgs.Sanguosha:getCard(id)
			local suit = card:getSuit()
			local point = card:getNumber()
			local chain = sgs.Sanguosha:cloneCard("iron_chain", suit, point)
			chain:deleteLater()
			local selected = sgs.PlayerList()
			for _,p in ipairs(targets) do
				selected:append(p)
			end
			return chain:targetsFeasible(selected, sgs.Self)
		end
		return false
	end,
	on_validate = function(self, use)
		local id = self:getSubcards():first()
		local card = sgs.Sanguosha:getCard(id)
		local suit = card:getSuit()
		local point = card:getNumber()
		local chain = sgs.Sanguosha:cloneCard("iron_chain", suit, point)
		chain:setSkillName("_MdkDuanDai")
		chain:addSubcard(id)
		return chain
	end,
}
DuanDai = sgs.CreateViewAsSkill{
	name = "MdkDuanDai",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isRed() and to_select:isKindOf("TrickCard")
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = DuanDaiCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
}
DuanDaiDist = sgs.CreateDistanceSkill{
	name = "#MdkDuanDaiDist",
	correct_func = function(self, from, to)
		if from:hasSkill("MdkDuanDai") and to:isChained() then
			return -1
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkDuanDai", "#MdkDuanDaiDist")
--添加技能
Mami:addSkill(DuanDai)
Mami:addSkill(DuanDaiDist)
--翻译信息
sgs.LoadTranslationTable{
	["MdkDuanDai"] = "缎带",
	[":MdkDuanDai"] = "出牌阶段，你可以将一张红色锦囊牌当作【铁索连环】对至少一名角色使用；你计算的与武将牌横置的其他角色的距离-1。",
	["$MdkDuanDai1"] = "真可惜啊",
	["$MdkDuanDai2"] = "在未来的后辈面前我可不能太丢脸呢",
	["#MdkDuanDaiDist"] = "缎带",
}
--[[
	技能：红茶
	描述：出牌阶段结束时，你可以摸一张牌；你的手牌上限+1。
]]--
HongCha = sgs.CreateTriggerSkill{
	name = "MdkHongCha",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			if player:askForSkillInvoke("MdkHongCha", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("MdkHongCha") --播放配音
				room:notifySkillInvoked(player, "MdkHongCha") --显示技能发动
				room:drawCards(player, 1, "MdkHongCha")
			end
		end
		return false
	end,
}
HongChaKeep = sgs.CreateMaxCardsSkill{
	name = "#MdkHongChaKeep",
	extra_func = function(self, player)
		if player:hasSkill("MdkHongCha") then
			return 1
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkHongCha", "#MdkHongChaKeep")
--添加技能
Mami:addSkill(HongCha)
Mami:addSkill(HongChaKeep)
--翻译信息
sgs.LoadTranslationTable{
	["MdkHongCha"] = "红茶",
	[":MdkHongCha"] = "出牌阶段结束时，你可以摸一张牌；你的手牌上限+1。",
	["$MdkHongCha"] = "嗯哼~",
}
--[[
	技能：终曲（阶段技）
	描述：你可以弃置三张相同花色的牌，对一名攻击范围内的角色造成两点火焰伤害。
]]--
ZhongQuCard = sgs.CreateSkillCard{
	name = "MdkZhongQuCard",
	skill_name = "MdkZhongQu",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:inMyAttackRange(to_select)
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local damage = sgs.DamageStruct()
		damage.from = source
		damage.to = target
		damage.damage = 2
		damage.nature = sgs.DamageStruct_Fire
		local room = source:getRoom()
		room:damage(damage)
		----------------------------------------------------------------
		--有时候此火焰伤害不会触发铁索连环的传导效果，
		--可能是主程序自身的逻辑有待完善，故在此补全模拟
		----------------------------------------------------------------
		if target:isChained() then
			room:setPlayerProperty(target, "chained", sgs.QVariant(false))
			room:broadcastProperty(target, "chained")
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				if p:isChained() then
					room:getThread():delay()
					local msg = sgs.LogMessage()
					msg.type = "#IronChainDamage"
					msg.from = p
					room:sendLog(msg) --发送提示信息
					damage.to = p
					damage.chain = true
					damage.transfer = false
					damage.transfer_reason = ""
					room:damage(damage)
					if p:isAlive() and p:isChained() then
						room:setPlayerProperty(p, "chained", sgs.QVariant(false))
						room:broadcastProperty(p, "chained")
					end
				end
			end
		end
		----------------------------------------------------------------
	end,
}
ZhongQu = sgs.CreateViewAsSkill{
	name = "MdkZhongQu",
	n = 3,
	view_filter = function(self, selected, to_select)
		if #selected > 0 then
			return to_select:getSuit() == selected[1]:getSuit()
		end
		return true
	end,
	view_as = function(self, cards)
		if #cards == 3 then
			local card = ZhongQuCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if player:getCardCount() < 3 or player:hasUsed("#MdkZhongQuCard") then
			return false
		end
		return true
	end,
}
--添加技能
Mami:addSkill(ZhongQu)
--翻译信息
sgs.LoadTranslationTable{
	["MdkZhongQu"] = "终曲",
	[":MdkZhongQu"] = "阶段技。你可以弃置三张相同花色的牌，对一名攻击范围内的角色造成两点火焰伤害。",
	["$MdkZhongQu"] = "Tiro Finale!",
}
if LinkSkillSwitch then
--[[
	技能：宝贝（联动技->百江渚）
	描述：一名其他角色对百江渚使用【杀】时，你可以令该角色将武将牌横置。
]]--
BaoBei = sgs.CreateTriggerSkill{
	name = "MdkBaoBei&",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local slash = use.card
		if slash and slash:isKindOf("Slash") then
			local can_invoke = false
			for _,target in sgs.qlist(use.to) do
				if target:getGeneralName() == "MomoeNagisa" or target:getGeneral2Name() == "MomoeNagisa" then
					can_invoke = true
					break
				end
			end
			if can_invoke then
				local room = player:getRoom()
				local others = room:getOtherPlayers(player)
				for _,source in sgs.qlist(others) do
					if source:hasSkill("MdkBaoBei") then
						if source:askForSkillInvoke("MdkBaoBei", data) then
							room:broadcastSkillInvoke("MdkBaoBei") --播放配音
							room:notifySkillInvoked(source, "MdkBaoBei") --显示技能发动
							room:setPlayerProperty(player, "chained", sgs.QVariant(true))
							room:broadcastProperty(player, "chained")
							room:setEmotion(player, "chain") --播放动画
							return false
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and not target:isChained()
	end,
}
--添加技能
Mami:addSkill(BaoBei)
--翻译信息
sgs.LoadTranslationTable{
	["MdkBaoBei"] = "宝贝",
	[":MdkBaoBei"] = "<font color=\"cyan\"><b>联动技。</b></font>一名其他角色对百江渚使用【杀】时，你可以令该角色将武将牌横置。",
	["$MdkBaoBei"] = "你要继续欺负贝贝的话，我可不能坐视不管",
}
end
--[[****************************************************************
	编号：MDK - 05
	武将：佐仓杏子（Sakura Kyouko）
	称号：风见野的来客
	性别：女
	势力：蜀
	体力上限：3勾玉
]]--****************************************************************
Kyouko = sgs.General(extension, "SakuraKyouko", "shu", 3, false)
--翻译信息
sgs.LoadTranslationTable{
	["SakuraKyouko"] = "佐仓杏子",
	["&SakuraKyouko"] = "佐仓杏子",
	["#SakuraKyouko"] = "风见野的来客",
	["designer:SakuraKyouko"] = "DGAH",
	["cv:SakuraKyouko"] = "野中蓝",
	["illustrator:SakuraKyouko"] = "百度百科",
	["~SakuraKyouko"] = "至少让我做一次幸福的梦吧……",
}
--[[
	技能：尖枪（锁定技）
	描述：出牌阶段，你使用的红色【杀】不可被闪避；你使用黑色【杀】时可以额外指定一名目标。
]]--
JianQiang = sgs.CreateTriggerSkill{
	name = "MdkJianQiang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			local use = data:toCardUse()
			local slash = use.card
			if slash and slash:isKindOf("Slash") and slash:isRed() then
				local room = player:getRoom()
				local play_sound = true
				if player:hasSkill("MdkJianShu") then
					if player:getGeneralName() == "MikiSayaka" then
						play_sound = false
					elseif player:getGeneral2Name() == "MikiSayaka" and player:getGeneralName() ~= "SakuraKyouko" then
						play_sound = false
					end
					if not play_sound then
						local has_near_target = false
						for _,target in sgs.qlist(use.to) do
							if player:distanceTo(target) == 1 then
								has_near_target = true
								break
							end
						end
						if not has_near_target then
							play_sound = true
						end
					end
				end
				if play_sound then
					room:broadcastSkillInvoke("MdkJianQiang", 1) --播放配音
				end
				room:notifySkillInvoked(player, "MdkJianQiang") --显示技能发动
				local key = string.format("Jink_%s", slash:toString())
				local newJinkList = sgs.IntList()
				for _,target in sgs.qlist(use.to) do
					local msg = sgs.LogMessage()
					msg.type = "#NoJink"
					msg.from = target
					room:sendLog(msg) --发送提示信息
					newJinkList:append(0)
				end
				local tag = sgs.QVariant()
				tag:setValue(newJinkList)
				player:setTag(key, tag)
			end
		end
		return false
	end,
}
JianQiangMod = sgs.CreateTargetModSkill{
	name = "#MdkJianQiangMod",
	extra_target_func = function(self, player, card)
		if card:isKindOf("Slash") and card:isBlack() then
			if player:hasSkill("MdkJianQiang") and player:getPhase() == sgs.Player_Play then
				return 1
			end
		end
		return 0
	end,
}
JianQiangAudioEffect = sgs.CreateTriggerSkill{
	name = "#MdkJianQiangAudioEffect",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local slash = use.card
		if slash and slash:isKindOf("Slash") and slash:isBlack() then
			if use.to:length() > 1 and player:getPhase() == sgs.Player_Play then
				if player:hasSkill("MdkJianQiang") then
					local room = player:getRoom()
					room:broadcastSkillInvoke("MdkJianQiang", 2) --播放配音
				end
			end
		end
		return false
	end,
}
extension:insertRelatedSkills("MdkJianQiang", "#MdkJianQiangMod")
extension:insertRelatedSkills("MdkJianQiang", "#MdkJianQiangAudioEffect")
--添加技能
Kyouko:addSkill(JianQiang)
Kyouko:addSkill(JianQiangMod)
Kyouko:addSkill(JianQiangAudioEffect)
--翻译信息
sgs.LoadTranslationTable{
	["MdkJianQiang"] = "尖枪",
	[":MdkJianQiang"] = "锁定技。出牌阶段，你使用的红色【杀】不可被闪避；你使用黑色【杀】时可以额外指定一名目标。",
	["$MdkJianQiang1"] = "结束了！",
	["$MdkJianQiang2"] = "编织结界！",
}
--[[
	技能：吃货
	描述：摸牌阶段，你可以放弃摸牌，改为亮出牌堆顶的三张牌，你选择一名角色获得其中所有的【桃】，然后你获得其余的牌。
]]--
ChiHuo = sgs.CreateTriggerSkill{
	name = "MdkChiHuo",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke("MdkChiHuo", data) then
			local room = player:getRoom()
			room:broadcastSkillInvoke("MdkChiHuo", 1) --播放配音
			room:notifySkillInvoked(player, "MdkChiHuo") --显示技能发动
			local ids = room:getNCards(3, true)
			local show = sgs.CardsMoveStruct()
			show.to = nil
			show.to_place = sgs.Player_PlaceTable
			show.card_ids = ids
			show.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "MdkChiHuo", "")
			room:moveCardsAtomic(show, true)
			room:getThread():delay()
			local peaches, others = sgs.IntList(), sgs.IntList()
			for _,id in sgs.qlist(ids) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isKindOf("Peach") then
					peaches:append(id)
				else
					others:append(id)
				end
			end
			if not peaches:isEmpty() then
				local alives = room:getAlivePlayers()
				local prompt = string.format("@MdkChiHuo:::%d:", peaches:length())
				local ai_data = sgs.QVariant()
				ai_data:setValue(peaches)
				room:setTag("MdkChiHuoData", ai_data) -- For AI
				local target = room:askForPlayerChosen(player, alives, "MdkChiHuo", prompt, true, false)
				room:removeTag("MdkChiHuoData")
				target = target or player
				if target:objectName() == player:objectName() then
					room:broadcastSkillInvoke("MdkChiHuo", 2) --播放配音
				else
					room:broadcastSkillInvoke("MdkChiHuo", 3) --播放配音
				end
				local give = sgs.CardsMoveStruct()
				give.to = target
				give.to_place = sgs.Player_PlaceHand
				give.card_ids = peaches
				give.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTBACK, player:objectName(), target:objectName(), "MdkChiHuo", "")
				room:moveCardsAtomic(give, true)
			end
			if not others:isEmpty() then
				local get = sgs.CardsMoveStruct()
				get.to = player
				get.to_place = sgs.Player_PlaceHand
				get.card_ids = others
				get.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTBACK, player:objectName(), "MdkChiHuo", "")
				room:moveCardsAtomic(get, true)
			end
			data:setValue(0)
			return true
		end
		return false
	end,
}
--添加技能
Kyouko:addSkill(ChiHuo)
--翻译信息
sgs.LoadTranslationTable{
	["MdkChiHuo"] = "吃货",
	[":MdkChiHuo"] = "摸牌阶段，你可以放弃摸牌，改为亮出牌堆顶的三张牌，你选择一名角色获得其中所有的【桃】，然后你获得余下的牌。",
	["$MdkChiHuo1"] = "（纸袋取苹果音效）",
	["$MdkChiHuo2"] = "（啃食苹果声）",
	["$MdkChiHuo3"] = "吃吗？",
	["@MdkChiHuo"] = "您可以将这 %arg 张【桃】交给一名场上的角色（包括自己）",
}
--[[
	技能：殉情（限定技）
	描述：你攻击范围内的一名其他角色濒死时，若本局游戏中你与该角色相互造成过伤害（由系统记录），你可以弃置所有手牌与装备，令你与该角色各失去等量的体力上限。
]]--
XunQingCard = sgs.CreateSkillCard{
	name = "MdkXunQingCard",
	skill_name = "MdkXunQing",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local target = room:getCurrentDyingPlayer()
		local index = 1
		if target then
			if target:getGeneralName() == "MikiSayaka" or target:getGeneral2Name() == "MikiSayaka" then
				index = 2
			end
		end
		room:broadcastSkillInvoke("MdkXunQing", index) --播放配音
		room:doSuperLightbox("SakuraKyouko", "MdkXunQing") --播放全屏特效
		room:notifySkillInvoked(source, "MdkXunQing") --显示技能发动
		source:loseMark("@MdkXunQingMark", 1)
		local n = source:getCardCount()
		source:throwAllHandCardsAndEquips()
		room:loseMaxHp(source, n)
	end,
}
XunQingVS = sgs.CreateViewAsSkill{
	name = "MdkXunQing",
	n = 0,
	view_as = function(self, cards)
		return XunQingCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@MdkXunQing"
	end,
}
XunQing = sgs.CreateTriggerSkill{
	name = "MdkXunQing",
	frequency = sgs.Skill_Limited,
	events = {sgs.Dying},
	view_as_skill = XunQingVS,
	limit_mark = "@MdkXunQingMark",
	on_trigger = function(self, event, player, data)
		if player:getMark("@MdkXunQingMark") == 0 then
			return false
		end
		local dying = data:toDying()
		local target = dying.who
		if target and target:objectName() ~= player:objectName() then
			if player:inMyAttackRange(target) and player:canDiscard(player, "he") then
				local room = player:getRoom()
				local damage_tag = string.format("MdkXunQingRecord_%s_%s", player:objectName(), target:objectName())
				local damaged_tag = string.format("MdkXunQingRecord_%s_%s", target:objectName(), player:objectName())
				if room:getTag(damage_tag):toBool() and room:getTag(damaged_tag):toBool() then
					local n = player:getCardCount()
					if n > 0 then
						local prompt = string.format("@MdkXunQing:%s::%d", target:objectName(), n)
						local invoke = room:askForUseCard(player, "@@MdkXunQing", prompt)
						if invoke then
							room:loseMaxHp(target, n)
						end
					end
				end
			end
		end
		return false
	end,
}
XunQingRecord = sgs.CreateTriggerSkill{
	name = "#MdkXunQingRecord",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage},
	global = true,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local source = damage.from
		if source and source:objectName() == player:objectName() then
			local target = damage.to
			if target and target:objectName() ~= player:objectName() then
				local key = string.format("MdkXunQingRecord_%s_%s", source:objectName(), target:objectName())
				local room = player:getRoom()
				room:setTag(key, sgs.QVariant(true))
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
extension:insertRelatedSkills("MdkXunQing", "#MdkXunQingRecord")
--添加技能
Kyouko:addSkill(XunQing)
Kyouko:addSkill(XunQingRecord)
--翻译信息
sgs.LoadTranslationTable{
	["MdkXunQing"] = "殉情",
	[":MdkXunQing"] = "限定技。你攻击范围内的一名其他角色濒死时，若本局游戏中你与该角色相互造成过伤害（由系统记录），你可以弃置所有手牌与装备，令你与该角色各失去等量的体力上限。",
	["$MdkXunQing1"] = "这家伙交给我吧",
	["$MdkXunQing2"] = "好了，我和你在一起……沙耶香",
	["@MdkXunQing"] = "您可以发动“殉情”弃置所有牌，令你与 %src 各失去 %arg 点体力上限",
	["~MdkXunQing"] = "点击“确定”即可",
	["@MdkXunQingMark"] = "灵石",
}
if LinkSkillSwitch then
--[[
	技能：幻梦（联动技->美树沙耶香）
	描述：美树沙耶香使用的【杀】结算完毕后，你可以获得之。每回合限一次。
]]--
HuanMeng = sgs.CreateTriggerSkill{
	name = "MdkHuanMeng&",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local slash = use.card
		if slash and slash:isKindOf("Slash") then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:hasSkill("MdkHuanMeng") and source:getMark("MdkHuanMengInvoked") == 0 then
					if source:askForSkillInvoke("MdkHuanMeng", data) then
						room:broadcastSkillInvoke("MdkHuanMeng") --播放配音
						room:notifySkillInvoked(source, "MdkHuanMeng") --显示技能发动
						room:setPlayerMark(source, "MdkHuanMengInvoked", 1)
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTBACK, source:objectName(), "MdkHuanMeng", "")
						room:obtainCard(source, slash, reason, true)
						return false
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target then
			if target:getGeneralName() == "MikiSayaka" then
				return true
			elseif target:getGeneral2Name() == "MikiSayaka" then
				return true
			end
		end
		return false
	end,
}
HuanMengClear = sgs.CreateTriggerSkill{
	name = "#MdkHuanMengClear",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:getMark("MdkHuanMengInvoked") > 0 then
					room:setPlayerMark(source, "MdkHuanMengInvoked", 0)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
extension:insertRelatedSkills("MdkHuanMeng", "#MdkHuanMengClear")
--添加技能
Kyouko:addSkill(HuanMeng)
Kyouko:addSkill(HuanMengClear)
--翻译信息
sgs.LoadTranslationTable{
	["MdkHuanMeng"] = "幻梦",
	[":MdkHuanMeng"] = "<font color=\"cyan\"><b>联动技。</b></font>美树沙耶香使用的【杀】结算完毕后，你可以获得之。每回合限一次。",
	["$MdkHuanMeng"] = "是这样的吗？沙耶香……",
}
end
--[[****************************************************************
	编号：MDK - 06
	武将：丘比（Incubator）
	称号：孵化者
	性别：男
	势力：群
	体力上限：2勾玉
]]--****************************************************************
QB = sgs.General(extension, "Incubator", "qun", 2, true)
--翻译信息
sgs.LoadTranslationTable{
	["Incubator"] = "丘比",
	["&Incubator"] = "丘比",
	["#Incubator"] = "孵化者",
	["designer:Incubator"] = "DGAH",
	["cv:Incubator"] = "加藤英美里",
	["illustrator:Incubator"] = "百度百科",
	["~Incubator"] = "利用你们人类的感情太危险了",
}
--[[
	技能：窥探
	描述：回合结束时，你可以选择一名攻击范围内的其他角色，然后直到其回合开始，该角色每使用或打出一张牌，你摸一张牌。
	说明：你同一时间只能选择一名角色作为“窥探”目标。若你发动“窥探”选择目标后获得了新的回合，且在新的回合结束时再次发动“窥探”选择了不同的目标，则原有的“窥探”目标将不再受此技能影响。
]]--
KuiTan = sgs.CreateTriggerSkill{
	name = "MdkKuiTan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local room = player:getRoom()
			local others = room:getOtherPlayers(player)
			local targets = sgs.SPlayerList()
			local last_victim = nil
			local name = player:property("MdkKuiTanTarget"):toString()
			for _,p in sgs.qlist(others) do
				if player:inMyAttackRange(p) then
					targets:append(p)
				end
				if p:objectName() == name then
					last_victim = p
				end
			end
			local target = room:askForPlayerChosen(player, targets, "MdkKuiTan", "@MdkKuiTan", true, true)
			if target then
				room:broadcastSkillInvoke("MdkKuiTan", 1) --播放配音
				room:notifySkillInvoked(player, "MdkKuiTan") --显示技能发动
				if last_victim and last_victim:getMark("@MdkKuiTanMark") > 0 then
					last_victim:loseMark("@MdkKuiTanMark", 1)
				end
				target:gainMark("@MdkKuiTanMark", 1)
				room:setPlayerProperty(player, "MdkKuiTanTarget", sgs.QVariant(target:objectName()))
			end
		end
		return false
	end,
}
KuiTanEffect = sgs.CreateTriggerSkill{
	name = "#MdkKuiTanEffect",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local card = nil
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			card = use.card
		elseif event == sgs.CardResponded then
			local response = data:toCardResponse()
			card = response.m_card
		end
		if card and not card:isKindOf("SkillCard") then
			local room = player:getRoom()
			local others = room:getOtherPlayers(player)
			for _,source in sgs.qlist(others) do
				if source:hasSkill("MdkKuiTan") then
					local name = source:property("MdkKuiTanTarget"):toString()
					if name == player:objectName() then
						room:broadcastSkillInvoke("MdkKuiTan", 2) --播放配音
						room:notifySkillInvoked(source, "MdkKuiTan") --显示技能发动
						room:drawCards(source, 1, "MdkKuiTan")
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:getMark("@MdkKuiTanMark") > 0
	end,
}
function clearKuiTanMark(room, source)
	local name = source:property("MdkKuiTanTarget"):toString()
	if name ~= "" then
		room:setPlayerProperty(source, "MdkKuiTanTarget", sgs.QVariant(""))
		local alives = room:getAlivePlayers()
		for _,target in sgs.qlist(alives) do
			if target:objectName() == name then
				if target:getMark("@MdkKuiTanMark") > 0 then
					target:loseMark("@MdkKuiTanMark", 1)
				end
				break
			end
		end
	end
end
KuiTanClear = sgs.CreateTriggerSkill{
	name = "#MdkKuiTanClear",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.Death, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				if player:getMark("@MdkKuiTanMark") > 0 then
					player:loseAllMarks("@MdkKuiTanMark")
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			local victim = death.who
			if victim and victim:objectName() == player:objectName() then
				if player:hasSkill("MdkKuiTan") then
					clearKuiTanMark(room, player)
				end
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "MdkKuiTan" then
				clearKuiTanMark(room, player)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	priority = 1,
}
extension:insertRelatedSkills("MdkKuiTan", "#MdkKuiTanEffect")
extension:insertRelatedSkills("MdkKuiTan", "#MdkKuiTanClear")
--添加技能
QB:addSkill(KuiTan)
QB:addSkill(KuiTanEffect)
QB:addSkill(KuiTanClear)
--翻译信息
sgs.LoadTranslationTable{
	["MdkKuiTan"] = "窥探",
	[":MdkKuiTan"] = "回合结束时，你可以选择一名攻击范围内的其他角色，然后直到其回合开始，该角色每使用或打出一张牌，你摸一张牌。",
	["$MdkKuiTan1"] = "能观测，就能干涉",
	["$MdkKuiTan2"] = "能干涉，就能驾驭",
	["@MdkKuiTanMark"] = "目标",
	["@MdkKuiTan"] = "您可以选择一名其他角色发动技能“窥探”",
}
--[[
	技能：缔约
	描述：你选择“窥探”的角色的回合开始时，你可以令其选择一项：1、交给你所有手牌，然后你交给其任意数量的牌；若你给出的牌少于你获得的牌，其摸两张牌或回复1点体力。2、本回合内其与你计算的距离+1。
]]--
function doDiYue(room, source, target)
	local handcard_ids = target:handCards()
	local n_obtain = handcard_ids:length()
	if n_obtain > 0 then
		local obtain = sgs.CardsMoveStruct()
		obtain.from = target
		obtain.from_place = sgs.Player_PlaceHand
		obtain.to = source
		obtain.to_place = sgs.Player_PlaceHand
		obtain.card_ids = handcard_ids
		obtain.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, target:objectName(), source:objectName(), "MdkDiYue", "")
		room:moveCardsAtomic(obtain, false)
	end
	local prompt = string.format("@MdkDiYue:%s::%d:", target:objectName(), n_obtain)
	local ai_data = sgs.QVariant()
	ai_data:setValue(target)
	room:setTag("MdkDiYueTarget", ai_data) --For AI
	room:setPlayerMark(source, "MdkDiYueObtainCount", n_obtain) --For AI
	local to_give = room:askForExchange(source, "MdkDiYue", 999, 0, true, prompt, true)
	room:setPlayerMark(source, "MdkDiYueObtainCount", 0) --For AI
	room:removeTag("MdkDiYueTarget") --For AI
	local n_give = 0
	if to_give then
		n_give = to_give:subcardsLength()
		if n_give > 0 then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), target:objectName(), "MdkDiYue", "")
			room:obtainCard(target, to_give, reason, false)
		end
	end
	if n_give < n_obtain then
		local choices = target:getLostHp() > 0 and "draw+recover" or "draw"
		local choice = room:askForChoice(target, "MdkDiYueDesire", choices)
		if choice == "draw" then
			room:drawCards(target, 2, "MdkDiYue")
		elseif choice == "recover" then
			local recover = sgs.RecoverStruct()
			recover.who = source
			recover.recover = 1
			room:recover(target, recover)
		end
	end
end
DiYue = sgs.CreateTriggerSkill{
	name = "MdkDiYue",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			local room = player:getRoom()
			local others = room:getOtherPlayers(player)
			for _,source in sgs.qlist(others) do
				if source:hasSkill("MdkDiYue") then
					if source:property("MdkKuiTanTarget"):toString() == player:objectName() then
						local ai_data = sgs.QVariant()
						ai_data:setValue(player)
						if source:askForSkillInvoke("MdkDiYue", ai_data) then
							room:broadcastSkillInvoke("MdkDiYue") --播放配音
							room:notifySkillInvoked(source, "MdkDiYue") --显示技能发动
							ai_data:setValue(source)
							local choice = room:askForChoice(player, "MdkDiYue", "accept+reject", ai_data)
							if choice == "accept" then
								doDiYue(room, source, player)
							elseif choice == "reject" then
								source:gainMark("@MdkDiYueFailMark", 1)
							end
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:getMark("@MdkKuiTanMark") > 0
	end,
	priority = 2,
}
DiYueDist = sgs.CreateDistanceSkill{
	name = "#MdkDiYueDist",
	correct_func = function(self, from, to)
		if to:hasSkill("MdkDiYue") then
			return to:getMark("@MdkDiYueFailMark")
		end
		return 0
	end,
}
DiYueClear = sgs.CreateTriggerSkill{
	name = "#MdkDiYueClear",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				if p:getMark("@MdkDiYueFailMark") > 0 then
					p:loseAllMarks("@MdkDiYueFailMark")
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
extension:insertRelatedSkills("MdkDiYue", "#MdkDiYueDist")
extension:insertRelatedSkills("MdkDiYue", "#MdkDiYueClear")
--添加技能
QB:addSkill(DiYue)
QB:addSkill(DiYueDist)
QB:addSkill(DiYueClear)
--翻译信息
sgs.LoadTranslationTable{
	["MdkDiYue"] = "缔约",
	[":MdkDiYue"] = "你选择“窥探”的角色的回合开始时，你可以令其选择一项：1、交给你所有手牌，然后你交给其任意数量的牌；若你给出的牌少于你获得的牌，其摸两张牌或回复1点体力。2、本回合内其与你计算的距离+1。",
	["$MdkDiYue1"] = "我可以实现你们的任何一个愿望",
	["$MdkDiYue2"] = "希望你们和我签下契约，成为魔法少女",
	["$MdkDiYue3"] = "跟我签下契约，成为魔法少女吧！",
	["MdkDiYue:accept"] = "签订契约成为马猴烧酒",
	["MdkDiYue:reject"] = "不签，滚",
	["@MdkDiYue"] = "您可以交还给 %src 任意数量的手牌；若不足 %arg 张，%src 将摸两张牌或回复1点体力",
	["MdkDiYueDesire"] = "缔约",
	["MdkDiYueDesire:draw"] = "摸两张牌",
	["MdkDiYueDesire:recover"] = "回复1点体力",
	["@MdkDiYueFailMark"] = "缔约失败",
	["#MdkDiYueDist"] = "缔约失败",
}
--[[
	技能：替身（锁定技）
	描述：游戏开始时或一名角色的回合结束后，若你没有获得过“替身”牌，你将牌堆顶的一张牌置于你的武将牌上，称为“替身”；你即将受到伤害时，若你有“替身”牌，你防止此伤害并选择一张“替身”牌获得之。（至多X/2张，结果向下取整，X为场上人数）。
]]--
function getNewTiShenCard(room, player, x)
	local total = room:alivePlayerCount()
	total = math.floor(total / 2)
	local n = player:getPile("MdkTiShenPile"):length()
	x = math.min(x, total - n)
	if x > 0 then
		--room:broadcastSkillInvoke("MdkTiShen") --播放配音
		room:notifySkillInvoked(player, "MdkTiShen") --显示技能发动
		room:sendCompulsoryTriggerLog(player, "MdkTiShen", true) --发送锁定技触发信息
		local ids = room:getNCards(x, true)
		local open_list = sgs.SPlayerList()
		open_list:append(player)
		player:addToPile("MdkTiShenPile", ids, false, open_list)
	end
end
TiShen = sgs.CreateTriggerSkill{
	name = "MdkTiShen",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.DamageForseen},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			getNewTiShenCard(room, player, 1)
		elseif event == sgs.DamageForseen then
			local pile = player:getPile("MdkTiShenPile")
			if pile:isEmpty() then
				return false
			end
			room:fillAG(pile, player)
			local id = room:askForAG(player, pile, false, "MdkTiShen")
			room:clearAG(player)
			room:broadcastSkillInvoke("MdkTiShen") --播放配音
			room:notifySkillInvoked(player, "MdkShiTing") --显示技能发动
			if id < 0 then
				local index = math.random(0, pile:length() - 1)
				id = pile:at(index)
			end
			local card = sgs.Sanguosha:getCard(id)
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, player:objectName(), "MdkTiShen", "")
			room:obtainCard(player, card, reason, true)
			room:setPlayerMark(player, "MdkTiShenInvoked", 1)
			local msg = sgs.LogMessage()
			msg.type = "#MdkTiShenAvoid"
			msg.from = player
			msg.arg = "MdkTiShen"
			room:sendLog(msg) --发送提示信息
			return true
		end
		return false
	end,
}
TiShenEffect = sgs.CreateTriggerSkill{
	name = "#MdkTiShenEffect",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:getMark("MdkTiShenInvoked") == 0 then
					if source:hasSkill("MdkTiShen") then
						getNewTiShenCard(room, source, 1)
					end
				else
					room:setPlayerMark(source, "MdkTiShenInvoked", 0)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
extension:insertRelatedSkills("MdkTiShen", "#MdkTiShenEffect")
--添加技能
QB:addSkill(TiShen)
QB:addSkill(TiShenEffect)
--翻译信息
sgs.LoadTranslationTable{
	["MdkTiShen"] = "替身",
	[":MdkTiShen"] = "锁定技。游戏开始时或一名角色的回合结束后，若你没有获得过“替身”牌，你将牌堆顶的一张牌置于你的武将牌上，称为“替身”；你即将受到伤害时，若你有“替身”牌，你防止此伤害并选择一张“替身”牌获得之。（至多X/2张，结果向下取整，X为场上人数）。",
	["$MdkTiShen1"] = "太浪费了",
	["$MdkTiShen2"] = "明明也知道这是没用的……你也真是不长记性啊",
	["MdkTiShenPile"] = "替身",
	["#MdkTiShenAvoid"] = "%from 发动了“%arg”，防止了将受到的本次伤害",
}
--[[
	技能：无情（锁定技）
	描述：你造成的伤害视为无伤害来源。
]]--
WuQing = sgs.CreateTriggerSkill{
	name = "MdkWuQing",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Predamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke("MdkWuQing") --播放配音
		room:notifySkillInvoked(player, "MdkWuQing") --显示技能发动
		local damage = data:toDamage()
		local msg = sgs.LogMessage()
		msg.type = "#MdkWuQingEffect"
		msg.from = player
		msg.to:append(damage.to)
		msg.arg = "MdkWuQing"
		room:sendLog(msg) --发送提示信息
		damage.from = nil
		damage.by_user = false --防止使用“寒冰剑”时导致游戏崩溃
		data:setValue(damage)
		return false
	end,
}
--添加技能
QB:addSkill(WuQing)
--翻译信息
sgs.LoadTranslationTable{
	["MdkWuQing"] = "无情",
	[":MdkWuQing"] = "锁定技。你造成的伤害视为无伤害来源。",
	["$MdkWuQing"] = "感情这种现象，只是极罕见的精神疾患",
	["#MdkWuQingEffect"] = "%from 的技能“%arg”被触发，对 %to 造成的本次伤害视为无伤害来源",
}
--[[****************************************************************
	编号：MDK - 07
	武将：志筑仁美（Shizuki Hitomi）
	称号：大家闺秀
	性别：女
	势力：吴
	体力上限：3勾玉
]]--****************************************************************
Hitomi = sgs.General(extension, "ShizukiHitomi", "wu", 3, false)
--翻译信息
sgs.LoadTranslationTable{
	["ShizukiHitomi"] = "志筑仁美",
	["&ShizukiHitomi"] = "志筑仁美",
	["#ShizukiHitomi"] = "大家闺秀",
	["designer:ShizukiHitomi"] = "DGAH",
	["cv:ShizukiHitomi"] = "新谷良子",
	["illustrator:ShizukiHitomi"] = "百度百科",
	["~ShizukiHitomi"] = "你不知道这是多么美妙的事情吗？",
}
--[[
	技能：名门（锁定技）
	描述：你于回合外失去牌时，你摸一张牌。
]]--
MingMen = sgs.CreateTriggerSkill{
	name = "MdkMingMen",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local move = data:toMoveOneTime()
			local source = move.from
			if source and source:objectName() == player:objectName() then
				local target = move.to
				if target and target:objectName() == player:objectName() then
					local dest = move.to_place
					if dest == sgs.Player_PlaceHand or dest == sgs.Player_PlaceEquip then
						return false
					end
				end
				local can_invoke = false
				for _,place in sgs.qlist(move.from_places) do
					if place == sgs.Player_PlaceHand or place == sgs.Player_PlaceEquip then
						can_invoke = true
						break
					end
				end
				if can_invoke then
					local room = player:getRoom()
					if move.reason.m_skillName ~= "mdksimu" then --防止与“思慕”配音冲突
						room:broadcastSkillInvoke("MdkMingMen")
					end
					room:notifySkillInvoked(player, "MdkMingMen")
					room:drawCards(player, 1, "MdkMingMen")
				end
			end
		end
		return false
	end,
}
--添加技能
Hitomi:addSkill(MingMen)
--翻译信息
sgs.LoadTranslationTable{
	["MdkMingMen"] = "名门",
	[":MdkMingMen"] = "锁定技。你于回合外失去牌时，你摸一张牌。",
	["$MdkMingMen1"] = "抱歉，我要先走了~",
	["$MdkMingMen2"] = "是茶道的练习~",
}
--[[
	技能：思慕
	描述：一名其他角色的回合开始时，你可以弃两张牌，令此回合内该角色的红心牌均视为草花花色。每轮限一次。
]]--
SiMuCard = sgs.CreateSkillCard{
	name = "MdkSiMuCard",
	--skill_name = "MdkSiMu",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local current = room:getCurrent()
		local index = 1
		if current then
			if current:getGeneralName() == "KamijouKyousuke" then
				index = 2
			elseif current:getGeneral2Name() == "KamijouKyousuke" then
				index = 2
			end
		end
		room:broadcastSkillInvoke("MdkSiMu", index) --播放配音
		room:notifySkillInvoked(source, "MdkSiMu") --显示技能发动
		local msg = sgs.LogMessage()
		msg.type = "#MdkSiMu"
		msg.from = source
		msg.to:append(current)
		msg.arg = "MdkSiMu"
		room:sendLog(msg) --发送提示信息
		if current and current:isAlive() then
			if current:getMark("@MdkSiMuMark") == 0 then
				current:gainMark("@MdkSiMuMark", 1)
				room:handleAcquireDetachSkills(current, "#MdkSiMuEffect")
			end
		end
	end,
}
SiMuVS = sgs.CreateViewAsSkill{
	name = "MdkSiMu",
	n = 2,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local card = SiMuCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@MdkSiMu"
	end,
}
SiMu = sgs.CreateTriggerSkill{
	name = "MdkSiMu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = SiMuVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase == sgs.Player_Start then
			local others = room:getOtherPlayers(player)
			local prompt = string.format("@MdkSiMu:%s:", player:objectName())
			for _,source in sgs.qlist(others) do
				if source:hasSkill("MdkSiMu") and source:canDiscard(source, "he") then
					if source:getMark("MdkSiMuInvoked") == 0 then
						if source:getCardCount() >= 2 then
							if room:askForUseCard(source, "@@MdkSiMu", prompt) then
								room:setPlayerMark(source, "MdkSiMuInvoked", 1)
							end
						end
					end
				end
			end
		elseif phase == sgs.Player_NotActive then
			if player:getMark("MdkSiMuInvoked") > 0 then
				room:setPlayerMark(player, "MdkSiMuInvoked", 0)
			end
			if player:getMark("@MdkSiMuMark") > 0 then
				player:loseAllMarks("@MdkSiMuMark")
			end
			if player:hasSkill("#MdkSiMuEffect") then
				room:handleAcquireDetachSkills(player, "-#MdkSiMuEffect")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
	priority = 2,
}
SiMuEffect = sgs.CreateFilterSkill{
	name = "#MdkSiMuEffect",
	view_filter = function(self, to_select)
		return to_select:getSuit() == sgs.Card_Heart
	end,
	view_as = function(self, card)
		local id = card:getId()
		local wrapped = sgs.Sanguosha:getWrappedCard(id)
		wrapped:setSkillName("MdkSiMuEffect")
		wrapped:setSuit(sgs.Card_Club)
		wrapped:setModified(true)
		return wrapped
	end,
}
--添加技能
Hitomi:addSkill(SiMu)
SkillAnJiang:addSkill(SiMuEffect)
--翻译信息
sgs.LoadTranslationTable{
	["MdkSiMu"] = "思慕",
	[":MdkSiMu"] = "一名其他角色的回合开始时，你可以弃两张牌，令此回合内该角色的红心牌均视为草花花色。每轮限一次。",
	["$MdkSiMu1"] = "想跟你聊关于恋爱的事",
	["$MdkSiMu2"] = "从很久以前开始，我……就仰慕着上条恭介同学了！",
	["@MdkSiMu"] = "您可以发动“思慕”弃置两张牌，令 %src 本回合内的红心牌均视为草花花色",
	["~MdkSiMu"] = "选择两张牌（包括装备）->点击“确定”",
	["#MdkSiMu"] = "%from 发动了“%arg”，%to 本回合内的<font color=\"red\">红心</font>牌均被视为<font color=\"black\">草花</font>花色",
	["@MdkSiMuMark"] = "思慕",
	["MdkSiMuEffect"] = "思慕",
	["mdksimu"] = "思慕",
}
--[[
	技能：坦白（限定技）
	描述：出牌阶段，你可以与一名体力小于你的角色进行拼点。若你胜，你可以指定至多一名已受伤的其他角色（拼点目标除外），你与该角色各回复1点体力，然后拼点目标受到1点伤害。否则你失去1点体力。
	说明：拼点成功后，也可以不指定其他角色，只令自己回复1点体力。
]]--
TanBaiCard = sgs.CreateSkillCard{
	name = "MdkTanBaiCard",
	--skill_name = "MdkTanBai",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets > 0 then
			return false
		elseif to_select:objectName() == sgs.Self:objectName() then
			return false
		elseif to_select:isKongcheng() then
			return false
		end
		return to_select:getHp() < sgs.Self:getHp()
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local index = 1
		if target:getGeneralName() == "MikiSayaka" or target:getGeneral2Name() == "MikiSayaka" then
			index = 2
		end
		room:broadcastSkillInvoke("MdkTanBai", index) --播放配音
		room:notifySkillInvoked(source, "MdkTanBai") --显示技能发动
		room:doSuperLightbox("ShizukiHitomi", "MdkTanBai") --播放全屏特效
		source:loseMark("@MdkTanBaiMark", 1)
		local card = self:subcardsLength() > 0 and self or nil
		local success = source:pindian(target, "MdkTanBai", card)
		if success then
			local to_recover = {source}
			local others = room:getOtherPlayers(source)
			local can_recover = sgs.SPlayerList()
			for _,p in sgs.qlist(others) do
				if p:objectName() == target:objectName() then
				elseif p:isWounded() then
					can_recover:append(p)
				end
			end
			if not can_recover:isEmpty() then
				local prompt = string.format("@MdkTanBai:%s:", target:objectName())
				local beneficiary = room:askForPlayerChosen(source, can_recover, "MdkTanBai", prompt, true)
				if beneficiary then
					to_recover = {beneficiary, source}
				end
			end
			for _,p in ipairs(to_recover) do
				if p:getLostHp() > 0 then
					local recover = sgs.RecoverStruct()
					recover.who = source
					recover.recover = 1
					room:recover(p, recover, true)
				end
			end
			room:getThread():delay()
			local damage = sgs.DamageStruct()
			damage.from = nil
			damage.to = target
			damage.damage = 1
			room:damage(damage)
		else
			room:loseHp(source, 1)
		end
	end,
}
TanBaiVS = sgs.CreateViewAsSkill{
	name = "MdkTanBai",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local card = TanBaiCard:clone()
		if #cards == 1 then
			card:addSubcard(cards[1])
		end
		return card
	end,
	enabled_at_play = function(self, player)
		if player:getMark("@MdkTanBaiMark") == 0 then
			return false
		elseif player:isKongcheng() then
			return false
		end
		return true
	end,
}
TanBai = sgs.CreateTriggerSkill{
	name = "MdkTanBai",
	frequency = sgs.Skill_Limited,
	events = {},
	view_as_skill = TanBaiVS,
	limit_mark = "@MdkTanBaiMark",
	on_trigger = function(self, event, player, data)
		return false
	end,
}
--添加技能
Hitomi:addSkill(TanBai)
--翻译信息
sgs.LoadTranslationTable{
	["MdkTanBai"] = "坦白",
	[":MdkTanBai"] = "限定技。出牌阶段，你可以与一名体力小于你的角色进行拼点。若你胜，你可以指定至多一名已受伤的其他角色（拼点目标除外），你与该角色各回复1点体力，然后拼点目标受到1点伤害。否则你失去1点体力。",
	["$MdkTanBai1"] = "我已经决定了，不再对自己撒谎",
	["$MdkTanBai2"] = "沙耶香，你能正面对待自己真正的感情吗？",
	["@MdkTanBaiMark"] = "坦白",
	["@MdkTanBai"] = "您可以选择一名已受伤的其他角色（%src 除外），你与该角色各回复 1 点体力",
	["~MdkTanBai"] = "选择一名其他角色->点击“确定”",
	["mdktanbai"] = "坦白",
}
if LinkSkillSwitch then
--[[
	技能：倾心（联动技->上条恭介）
	描述：上条恭介的草花判定牌生效时，你可以摸一张牌。
]]--
QingXin = sgs.CreateTriggerSkill{
	name = "MdkQingXin&",
	frequency = sgs.Skill_Frequent,
	events = {sgs.FinishRetrial},
	on_trigger = function(self, event, player, data)
		local judge = data:toJudge()
		if judge.card:getSuit() == sgs.Card_Club then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:hasSkill("MdkQingXin") then
					if source:askForSkillInvoke("MdkQingXin", data) then
						room:broadcastSkillInvoke("MdkQingXin") --播放配音
						room:notifySkillInvoked(source, "MdkQingXin") --显示技能发动
						room:drawCards(source, 1, "MdkQingXin")
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() then
			if target:getGeneralName() == "KamijouKyousuke" then
				return true
			elseif target:getGeneral2Name() == "KamijouKyousuke" then
				return true
			end
		end
		return false
	end,
}
--添加技能
Hitomi:addSkill(QingXin)
--翻译信息
sgs.LoadTranslationTable{
	["MdkQingXin"] = "倾心",
	[":MdkQingXin"] = "<font color=\"cyan\"><b>联动技。</b></font>上条恭介的草花判定牌生效时，你可以摸一张牌。",
	["$MdkQingXin"] = "我呀，可喜欢努力的上条同学了！",
}
end
--[[****************************************************************
	编号：MDK - 08
	武将：上条恭介（Kamijou Kyousuke）
	称号：不幸的音乐家
	性别：男
	势力：魏
	体力上限：4勾玉
]]--****************************************************************
Kyousuke = sgs.General(extension, "KamijouKyousuke", "wei", 4, true)
--翻译信息
sgs.LoadTranslationTable{
	["KamijouKyousuke"] = "上条恭介",
	["&KamijouKyousuke"] = "上条恭介",
	["#KamijouKyousuke"] = "不幸的音乐家",
	["designer:KamijouKyousuke"] = "DGAH",
	["cv:KamijouKyousuke"] = "吉田圣子",
	["illustrator:KamijouKyousuke"] = "动画第12话",
	["~KamijouKyousuke"] = "我的手已经不会再动了……",
}
--[[
	技能：才华（锁定技）
	描述：你使用草花牌无距离限制和次数限制。
]]--
CaiHua = sgs.CreateTargetModSkill{
	name = "MdkCaiHua",
	pattern = "Card",
	residue_func = function(self, player, card)
		if player:hasSkill("MdkCaiHua") then
			if card:isKindOf("SkillCard") then
			elseif card:getSuit() == sgs.Card_Club then
				return 1000
			end
		end
		return 0
	end,
	distance_limit_func = function(self, player, card)
		if player:hasSkill("MdkCaiHua") then
			if card:isKindOf("SkillCard") then
			elseif card:getSuit() == sgs.Card_Club then
				return 1000
			end
		end
		return 0
	end,
}
--添加技能
Kyousuke:addSkill(CaiHua)
--翻译信息
sgs.LoadTranslationTable{
	["MdkCaiHua"] = "才华",
	[":MdkCaiHua"] = "锁定技。你使用草花牌无距离限制和次数限制。",
	["$MdkCaiHua"] = "啊哈哈……",
}
--[[
	技能：残体（锁定技）
	描述：出牌阶段开始时，若你没有受伤，你选择一项：弃置一张装备牌，或者失去1点体力。
]]--
CanTi = sgs.CreateTriggerSkill{
	name = "MdkCanTi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			if player:isWounded() then
				return false
			end
			local room = player:getRoom()
			room:broadcastSkillInvoke("MdkCanTi") --播放配音
			room:notifySkillInvoked(player, "MdkCanTi") --显示技能发动
			room:sendCompulsoryTriggerLog(player, "MdkCanTi") --发送锁定技触发信息
			if room:askForCard(player, "EquipCard", "@MdkCanTi", data, "MdkCanTi") then
				return false
			end
			room:loseHp(player, 1)
		end
		return false
	end,
}
--添加技能
Kyousuke:addSkill(CanTi)
--翻译信息
sgs.LoadTranslationTable{
	["MdkCanTi"] = "残体",
	[":MdkCanTi"] = "锁定技。出牌阶段开始时，若你没有受伤，你选择一项：弃置一张装备牌，或者失去1点体力。",
	["$MdkCanTi1"] = "动不了了……",
	["$MdkCanTi2"] = "已经连痛感都没有了……",
	["@MdkCanTi"] = "残体：请弃置一张装备牌，否则你将失去1点体力",
	["~MdkCanTi"] = "选择一张装备牌->点击“确定”",
}
--[[
	技能：痊愈（觉醒技）
	描述：回合结束后，若你累计在你的三个回合内回复过体力，你失去技能“残体”并获得技能“演出”。
]]--
QuanYu = sgs.CreateTriggerSkill{
	name = "MdkQuanYu",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart, sgs.HpRecover},
	on_trigger = function(self, event, player, data)
		if player:getMark("MdkQuanYuWaked") > 0 then
			return false
		end
		local room = player:getRoom()
		local phase = player:getPhase()
		if event == sgs.EventPhaseStart then
			if phase == sgs.Player_NotActive then
				if player:getMark("MdkQuanYuRecover") == 0 then
					return false
				end
				room:setPlayerMark(player, "MdkQuanYuRecover", 0)
				local turns = player:getMark("@MdkQuanYuMark")
				if turns >= 3 then
					room:broadcastSkillInvoke("MdkQuanYu") --播放配音
					room:notifySkillInvoked(player, "MdkQuanYu") --显示技能发动
					room:doSuperLightbox("KamijouKyousuke", "MdkQuanYu") --播放全屏特效
					local msg = sgs.LogMessage()
					msg.type = "#MdkQuanYuWake"
					msg.from = player
					msg.arg = turns
					msg.arg2 = "MdkQuanYu"
					room:sendLog(msg) --发送提示信息
					player:loseAllMarks("@MdkQuanYuMark")
					room:handleAcquireDetachSkills(player, "-MdkCanTi|MdkYanChu")
					player:gainMark("@waked", 1)
					room:setPlayerMark(player, "MdkQuanYuWaked", 1)
				end
			end
		elseif event == sgs.HpRecover then
			if phase == sgs.Player_NotActive then
				return false
			elseif player:getMark("MdkQuanYuRecover") == 0 then
				room:setPlayerMark(player, "MdkQuanYuRecover", 1)
				player:gainMark("@MdkQuanYuMark", 1)
			end
		end
		return false
	end,
}
--添加技能
Kyousuke:addSkill(QuanYu)
--翻译信息
sgs.LoadTranslationTable{
	["MdkQuanYu"] = "痊愈",
	[":MdkQuanYu"] = "觉醒技。回合结束后，若你累计在你的三个回合内回复过体力，你失去技能“残体”并获得技能“演出”。",
	["$MdkQuanYu"] = "就像沙耶香说的那样，这是奇迹呢",
	["#MdkQuanYuWake"] = "%from 已累计在 %arg 个回合内回复过体力，触发“%arg2”觉醒",
	["@MdkQuanYuMark"] = "回复",
}
--[[
	技能：演出（阶段技）
	描述：你可以进行一次判定。若结果为黑色：本阶段内你使用草花牌可以额外指定一名角色为目标，然后你重复此流程；你获得因此产生的所有黑色判定牌。
]]--
YanChuCard = sgs.CreateSkillCard{
	name = "MdkYanChuCard",
	skill_name = "MdkYanChu",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local to_get = sgs.IntList()
		while true do
			local judge = sgs.JudgeStruct()
			judge.who = source
			judge.reason = "MdkYanChu"
			judge.pattern = ".|black"
			judge.good = true
			judge.time_consuming = true
			room:judge(judge)
			if judge:isGood() then
				local id = judge.card:getEffectiveId()
				to_get:append(id)
				source:gainMark("@MdkYanChuMark", 1)
			else
				break
			end
		end
		local get = sgs.CardsMoveStruct()
		get.to = source
		get.to_place = sgs.Player_PlaceHand
		get.card_ids = to_get
		get.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTBACK, source:objectName(), "MdkYanChu", "")
		room:moveCardsAtomic(get, true)
	end,
}
YanChuVS = sgs.CreateViewAsSkill{
	name = "MdkYanChu",
	n = 0,
	view_as = function(self, cards)
		return YanChuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#MdkYanChuCard")
	end,
}
YanChu = sgs.CreateTriggerSkill{
	name = "MdkYanChu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	view_as_skill = YanChuVS,
	on_trigger = function(self, event, player, data)
		if player:getMark("@MdkYanChuMark") == 0 then
		elseif player:getPhase() == sgs.Player_Play then
			player:loseAllMarks("@MdkYanChuMark")
		end
		return false
	end,
}
YanChuMod = sgs.CreateTargetModSkill{
	name = "#MdkYanChuMod",
	extra_target_func = function(self, player, card)
		if player:hasSkill("MdkYanChu") then
			if card:isKindOf("SkillCard") then
			elseif card:getSuit() == sgs.Card_Club then
				return player:getMark("@MdkYanChuMark")
			end
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkYanChu", "#MdkYanChuMod")
--添加技能
SkillAnJiang:addSkill(YanChu)
SkillAnJiang:addSkill(YanChuMod)
Kyousuke:addRelateSkill("MdkYanChu")
--翻译信息
sgs.LoadTranslationTable{
	["MdkYanChu"] = "演出",
	[":MdkYanChu"] = "阶段技。你可以进行一次判定。若结果为黑色：本阶段内你使用草花牌可以额外指定一名角色为目标，然后你重复此流程；你获得因此产生的所有黑色判定牌。",
	["$MdkYanChu1"] = "我是25号，上条恭介",
	["$MdkYanChu2"] = "课题曲是：《万福玛利亚》",
	["$MdkYanChu3"] = "（小提琴声）",
	["@MdkYanChuMark"] = "听众",
}
if LinkSkillSwitch then
--[[
	技能：惊觉（联动技->美树沙耶香）
	描述：出牌阶段结束时，若你本阶段发动“演出”获得了至少三张黑色牌，你可以弃一张牌，令美树沙耶香摸两张牌。
]]--
JingJueCard = sgs.CreateSkillCard{
	name = "MdkJingJueCard",
	skill_name = "MdkJingJue",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:getGeneralName() == "MikiSayaka" then
				return true
			elseif to_select:getGeneral2Name() == "MikiSayaka" then
				return true
			end
		end
		return false
	end,
	on_effect = function(self, effect)
		local target = effect.to
		local room = target:getRoom()
		room:drawCards(target, 2, "MdkJingJue")
	end,
}
JingJueVS = sgs.CreateViewAsSkill{
	name = "MdkJingJue",
	n = 1,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = JingJueCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@MdkJingJue"
	end,
}
JingJue = sgs.CreateTriggerSkill{
	name = "MdkJingJue&",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseEnd},
	view_as_skill = JingJueVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.reason.m_skillName == "MdkYanChu" and move.reason.m_reason == sgs.CardMoveReason_S_REASON_GOTBACK then
				if move.to_place == sgs.Player_PlaceHand then
					local dest = move.to
					if dest and dest:objectName() == player:objectName() then
						room:addPlayerMark(player, "MdkJingJueCount", move.card_ids:length())
					end
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play then
				local n = player:getMark("MdkJingJueCount")
				if n > 0 then
					room:setPlayerMark(player, "MdkJingJueCount", 0)
				end
				if n >= 3 and player:canDiscard(player, "he") then
					local alives = room:getAlivePlayers()
					local can_invoke = false
					for _,p in sgs.qlist(alives) do
						if p:getGeneralName() == "MikiSayaka" or p:getGeneral2Name() == "MikiSayaka" then
							can_invoke = true
							break
						end
					end
					if can_invoke then
						if room:askForUseCard(player, "@@MdkJingJue", "@MdkJingJue") then
							room:broadcastSkillInvoke("MdkJingJue") --播放配音
							room:notifySkillInvoked(player, "MdkJingJue") --显示技能发动
						end
					end
				end
			end
		end
		return false
	end,
}
--添加技能
Kyousuke:addSkill(JingJue)
--翻译信息
sgs.LoadTranslationTable{
	["MdkJingJue"] = "惊觉",
	[":MdkJingJue"] = "<font color=\"cyan\"><b>联动技。</b></font>出牌阶段结束时，若你本阶段发动“演出”获得了至少三张黑色牌，你可以弃一张牌，令美树沙耶香摸两张牌。",
	["$MdkJingJue"] = "沙耶香？",
	["@MdkJingJue"] = "您可以发动“惊觉”弃一张牌，令 美树沙耶香 摸两张牌",
	["~MdkJingJue"] = "选择一张要弃置的牌（包括装备）->选择一名目标角色->点击“确定”",
}
end
--[[****************************************************************
	编号：MDK - 09
	武将：百江渚（Momoe Nagisa）
	称号：可爱的后辈
	性别：女
	势力：群
	体力上限：3勾玉
]]--****************************************************************
Nagisa = sgs.General(extension, "MomoeNagisa", "qun", 3, false)
--翻译信息
sgs.LoadTranslationTable{
	["MomoeNagisa"] = "百江渚",
	["&MomoeNagisa"] = "百江渚",
	["#MomoeNagisa"] = "可爱的后辈",
	["designer:MomoeNagisa"] = "DGAH",
	["cv:MomoeNagisa"] = "阿澄佳奈",
	["illustrator:MomoeNagisa"] = "百度百科",
	["~MomoeNagisa"] = "要变起司了……",
}
--[[
	技能：贪酪
	描述：摸牌阶段开始时，你可以选择一名角色。若如此做，你额外摸一张牌，且本回合内，若其存活，除该角色外的角色不能成为你所使用牌的目标。
]]--
TanLao = sgs.CreateTriggerSkill{
	name = "MdkTanLao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			local phase = player:getPhase()
			if phase == sgs.Player_Draw then
				local alives = room:getAlivePlayers()
				local target = room:askForPlayerChosen(player, alives, "MdkTanLao", "@MdkTanLao", true)
				if target then
					room:broadcastSkillInvoke("MdkTanLao") --播放配音
					room:notifySkillInvoked(player, "MdkTanLao") --显示技能发动
					target:gainMark("@MdkTanLaoMark", 1)
					room:setPlayerMark(player, "MdkTanLaoInvoked", 1)
				end
			elseif phase == sgs.Player_NotActive then
				if player:getMark("MdkTanLaoInvoked") > 0 then
					room:setPlayerMark(player, "MdkTanLaoInvoked", 0)
					local alives = room:getAlivePlayers()
					for _,p in sgs.qlist(alives) do
						if p:getMark("@MdkTanLaoMark") > 0 then
							p:loseAllMarks("@MdkTanLaoMark")
						end
					end
				end
			end
		elseif event == sgs.DrawNCards then
			if player:getMark("MdkTanLaoInvoked") > 0 then
				local n = data:toInt()
				data:setValue(n + 1)
			end
		end
		return false
	end,
}
TanLaoAvoid = sgs.CreateProhibitSkill{
	name = "#MdkTanLaoAvoid",
	is_prohibited = function(self, from, to, card)
		if card:isKindOf("SkillCard") then
		elseif from:getMark("MdkTanLaoInvoked") > 0 then
			local others = to:getSiblings()
			for _,p in sgs.qlist(others) do
				if p:getMark("@MdkTanLaoMark") > 0 then
					return true
				end
			end
		end
		return false
	end,
}
extension:insertRelatedSkills("MdkTanLao", "#MdkTanLaoAvoid")
--添加技能
Nagisa:addSkill(TanLao)
Nagisa:addSkill(TanLaoAvoid)
--翻译信息
sgs.LoadTranslationTable{
	["MdkTanLao"] = "贪酪",
	[":MdkTanLao"] = "摸牌阶段开始时，你可以选择一名角色。若如此做，你额外摸一张牌，且本回合内，若其存活，除该角色外的其他角色不能成为你所使用牌的目标。",
	["$MdkTanLao"] = "渚只是还想再吃一次起司而已",
	["@MdkTanLao"] = "您可以发动“贪酪”选择一名角色。若如此做，您将额外摸一张牌，但本回合内只能对该角色使用卡牌",
	["@MdkTanLaoMark"] = "乳酪",
}
--[[
	技能：气泡
	描述：出牌阶段，你使用【杀】造成伤害时，你可以令目标防止此伤害并失去等量体力，然后其获得一枚“泡泡”标记直到其回合结束。该角色的攻击范围-X（X为其拥有的“泡泡”标记数）
]]--
QiPao = sgs.CreateTriggerSkill{
	name = "MdkQiPao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			local damage = data:toDamage()
			local slash = damage.card
			if slash and slash:isKindOf("Slash") then
				local target = damage.to
				local x = damage.damage
				local prompt = string.format("invoke:%s::%d", target:objectName(), x)
				local room = player:getRoom()
				room:setTag("MdkQiPaoData", data) --For AI
				local invoke = player:askForSkillInvoke("MdkQiPao", sgs.QVariant(prompt))
				room:removeTag("MdkQiPaoData") --For AI
				if invoke then
					room:broadcastSkillInvoke("MdkQiPao") --播放配音
					room:notifySkillInvoked(player, "MdkQiPao") --显示技能发动
					local msg = sgs.LogMessage()
					msg.type = "#MdkQiPaoAvoid"
					msg.from = player
					msg.to:append(target)
					msg.arg = "MdkQiPao"
					msg.arg2 = x
					room:sendLog(msg) --发送提示信息
					room:loseHp(target, x)
					if target:isAlive() then
						target:gainMark("@MdkQiPaoMark", 1)
					end
					damage.damage = 0
					data:setValue(damage)
					return true
				end
			end
		end
		return false
	end,
}
QiPaoRange = sgs.CreateAttackRangeSkill{
	name = "#MdkQiPaoRange",
	extra_func = function(self, player)
		return - player:getMark("@MdkQiPaoMark")
	end,
}
QiPaoClear = sgs.CreateTriggerSkill{
	name = "#MdkQiPaoClear",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	global = true,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			player:loseAllMarks("@MdkQiPaoMark")
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:getMark("@MdkQiPaoMark") > 0
	end,
}
extension:insertRelatedSkills("MdkQiPao", "#MdkQiPaoRange")
extension:insertRelatedSkills("MdkQiPao", "#MdkQiPaoClear")
--添加技能
Nagisa:addSkill(QiPao)
Nagisa:addSkill(QiPaoRange)
Nagisa:addSkill(QiPaoClear)
--翻译信息
sgs.LoadTranslationTable{
	["MdkQiPao"] = "气泡",
	[":MdkQiPao"] = "出牌阶段，你使用【杀】造成伤害时，你可以令目标防止此伤害并失去等量体力，然后其获得一枚“泡泡”标记直到其回合结束。该角色的攻击范围-X（X为其拥有的“泡泡”标记数）",
	["$MdkQiPao"] = "（气泡声）",
	["#MdkQiPaoAvoid"] = "%from 发动了“%arg”，令本次将对 %to 造成的 %arg2 点伤害视为失去体力",
	["MdkQiPao:invoke"] = "您可以发动“气泡”防止此伤害，改令 %src 失去 %arg 点体力并使其获得 1 枚“泡泡”标记",
	["@MdkQiPaoMark"] = "泡泡",
	["#MdkQiPaoRange"] = "气泡",
}
--[[
	技能：变脸（阶段技）
	描述：你可以将武将牌翻面。你的武将牌状态改变时，你可以弃一张非基本牌，令你的武将牌恢复至原先的状态，然后你可以视为使用了一张【杀】。
	说明：你因“变脸”将武将牌翻面、重置、横置时，不可重复触发此技能。
]]--
BianLianCard = sgs.CreateSkillCard{
	name = "MdkBianLianCard",
	skill_name = "MdkBianLian",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:setPlayerFlag(source, "MdkBianLianCardEffect")
		source:turnOver()
		room:setPlayerFlag(source, "-MdkBianLianCardEffect")
	end,
}
BianLianSlashCard = sgs.CreateSkillCard{
	name = "BianLianSlashCard",
	skill_name = "MdkBianLian",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		local selected = sgs.PlayerList()
		for _,p in ipairs(targets) do
			selected:append(p)
		end
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:deleteLater()
		return slash:targetFilter(selected, to_select, sgs.Self)
	end,
	feasible = function(self, targets)
		local selected = sgs.PlayerList()
		for _,p in ipairs(targets) do
			selected:append(p)
		end
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:deleteLater()
		return slash:targetsFeasible(selected, sgs.Self)
	end,
	on_validate = function(self, use)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("MdkBianLian_NoAudioEffect")
		return slash
	end,
}
BianLianVS = sgs.CreateViewAsSkill{
	name = "MdkBianLian",
	n = 0,
	ask = "",
	view_as = function(self, cards)
		if ask == "" then
			return BianLianCard:clone()
		elseif ask == "@@MdkBianLian" then
			return BianLianSlashCard:clone()
		end
	end,
	enabled_at_play = function(self, player)
		ask = ""
		return not player:hasUsed("#MdkBianLianCard")
	end,
	enabled_at_response = function(self, player, pattern)
		ask = pattern
		return pattern == "@@MdkBianLian"
	end,
}
BianLian = sgs.CreateTriggerSkill{
	name = "MdkBianLian",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TurnedOver, sgs.ChainStateChanged},
	view_as_skill = BianLianVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TurnedOver then
			if player:hasFlag("MdkBianLianTurnOverEffect") then
				room:setPlayerFlag(player, "-MdkBianLianTurnOverEffect")
				return false
			end
			local up = player:faceUp()
			local prompt = up and "@MdkBianLianTurnDown" or "@MdkBianLianTurnUp"
			if room:askForCard(player, "^BasicCard|.|.|.", prompt, data, "MdkBianLian") then
				if not player:hasFlag("MdkBianLianCardEffect") then
					room:broadcastSkillInvoke("MdkBianLian") --播放配音
					room:notifySkillInvoked(player, "MdkBianLian") --显示技能发动
				end
				room:setPlayerFlag(player, "MdkBianLianTurnOverEffect")
				player:turnOver()
			else
				return false
			end
		elseif event == sgs.ChainStateChanged then
			if player:hasFlag("MdkBianLianChainEffect") then
				room:setPlayerFlag(player, "-MdkBianLianChainEffect")
				return false
			end
			local chain = player:isChained()
			local prompt = chain and "@MdkBianLianChainBack" or "@MdkBianLianChain"
			if room:askForCard(player, "^BasicCard|.|.|.", prompt, data, "MdkBianLian") then
				room:broadcastSkillInvoke("MdkBianLian") --播放配音
				room:notifySkillInvoked(player, "MdkBianLian") --显示技能发动
				room:setPlayerFlag(player, "MdkBianLianChainEffect")
				room:setPlayerProperty(player, "chained", sgs.QVariant(not chain))
				room:broadcastProperty(player, "chained")
			else
				return false
			end
		end
		room:askForUseCard(player, "@@MdkBianLian", "@MdkBianLianSlash")
		return false
	end,
}
--添加技能
Nagisa:addSkill(BianLian)
--翻译信息
sgs.LoadTranslationTable{
	["MdkBianLian"] = "变脸",
	[":MdkBianLian"] = "阶段技。你可以将武将牌翻面。你的武将牌状态改变时，你可以弃一张非基本牌，令你的武将牌恢复至原先的状态，然后你可以视为使用了一张【杀】。",
	["$MdkBianLian"] = "一直瞒着你，对不起",
	["@MdkBianLianTurnUp"] = "变脸：您可以弃一张 非基本牌 将武将牌翻回至 正面 向上",
	["@MdkBianLianTurnDown"] = "变脸：您可以弃一张 非基本牌 将武将牌翻回至 背面 向上",
	["@MdkBianLianChain"] = "变脸：您可以弃一张 非基本牌 令武将牌恢复为 连环 状态",
	["@MdkBianLianChainBack"] = "变脸：您可以弃一张 非基本牌 令武将牌恢复为 非连环 状态",
	["@MdkBianLianSlash"] = "变脸：您可以视为使用了一张【杀】",
	["~MdkBianLian"] = "选择一名目标角色->点击“确定”",
	["MdkBianLian_NoAudioEffect"] = "变脸",
}
if LinkSkillSwitch then
--[[
	技能：鼓舞（联动技->巴麻美、锁定技）
	描述：巴麻美每次回复的体力+1。当巴麻美失去最后的手牌时，你令其摸一张牌。
]]--
GuWu = sgs.CreateTriggerSkill{
	name = "MdkGuWu&",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreHpRecover, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreHpRecover then
			room:broadcastSkillInvoke("MdkGuWu", 2) --播放配音
			room:notifySkillInvoked(player, "MdkGuWu") --显示技能发动
			local msg = sgs.LogMessage()
			msg.type = "#MdkGuWuEffect"
			msg.from = player
			msg.arg = "MdkGuWu"
			msg.arg2 = 1
			room:sendLog(msg) --发送提示信息
			local recover = data:toRecover()
			recover.recover = recover.recover + 1
			data:setValue(recover)
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.is_last_handcard then
				local source = move.from
				if source and source:objectName() == player:objectName() then
					room:broadcastSkillInvoke("MdkGuWu", 1) --播放配音
					room:notifySkillInvoked(player, "MdkGuWu") --显示技能发动
					room:drawCards(player, 1, "MdkGuWu")
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() then
			if target:getGeneralName() == "TomoeMami" then
				return true
			elseif target:getGeneral2Name() == "TomoeMami" then
				return true
			end
		end
		return false
	end,
}
--添加技能
Nagisa:addSkill(GuWu)
--翻译信息
sgs.LoadTranslationTable{
	["MdkGuWu"] = "鼓舞",
	[":MdkGuWu"] = "<font color=\"cyan\"><b>联动技。</b></font>锁定技。巴麻美每次回复的体力+1。当巴麻美失去最后的手牌时，你令其摸一张牌。",
	["$MdkGuWu1"] = "只有贝贝支撑和鼓励着孤单一人的我[by巴麻美]",
	["$MdkGuWu2"] = "如果没有这孩子在的话，我肯定早就崩溃了[by巴麻美]",
	["#MdkGuWuEffect"] = "受技能“%arg”影响，%from 将额外回复 %arg2 点体力",
}
--[[
	技能：解答（联动技->神·鹿目圆）
	描述：你从神·鹿目圆处获得牌时，你获得一枚“令”标记。你的手牌上限+X（X为你的“令”标记的数量）。神·鹿目圆或你攻击范围内的一名其他角色的回合结束时，你可以弃一枚“令”标记，交给其两张牌，然后你摸两张牌。
]]--
JieDaCard = sgs.CreateSkillCard{
	name = "MdkJieDaCard",
	skill_name = "MdkJieDa",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		room:notifySkillInvoked(source, "MdkJieDa") --显示技能发动
		source:loseMark("@MdkJieDaMark", 1)
		local target = room:getCurrent()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), target:objectName(), "MdkJieDa", "")
		room:obtainCard(target, self, reason, false)
		if source:isAlive() then
			room:drawCards(source, 2, "MdkJieDa")
		end
	end,
}
JieDaVS = sgs.CreateViewAsSkill{
	name = "MdkJieDa",
	n = 2,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local card = JieDaCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@MdkJieDa"
	end,
}
JieDa = sgs.CreateTriggerSkill{
	name = "MdkJieDa&",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = JieDaVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local isTarget = false
			if player:getGeneralName() == "GodMadoka" or player:getGeneral2Name() == "GodMadoka" then
				isTarget = true
			end
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:getMark("@MdkJieDaMark") > 0 and source:hasSkill("MdkJieDa") then
					if isTarget or source:inMyAttackRange(player) then
						if source:getCardCount() >= 2 then
							local prompt = string.format("@MdkJieDa:%s:", player:objectName())
							room:askForUseCard(source, "@@MdkJieDa", prompt)
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
JieDaRecord = sgs.CreateTriggerSkill{
	name = "#MdkJieDaRecord",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local dest = move.to
		if dest and dest:objectName() == player:objectName() then
			local place = move.to_place
			if place == sgs.Player_PlaceHand or place == sgs.Player_PlaceEquip then
				local source = move.from
				if source then
					if source:getGeneralName() == "GodMadoka" or source:getGeneral2Name() == "GodMadoka" then
						for _,from in sgs.qlist(move.from_places) do
							if from == sgs.Player_PlaceHand or from == sgs.Player_PlaceEquip then
								local can_invoke = true
								if source:objectName() == player:objectName() then
									if from == place then
										can_invoke = false
									else
										local reason = bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
										if reason == sgs.CardMoveReason_S_REASON_GOTCARD then
										elseif reason == sgs.CardMoveReason_S_REASON_TRANSFER then
										elseif reason == sgs.CardMoveReason_S_REASON_PUT then
										else
											can_invoke = false
										end
									end
								end
								if can_invoke then
									local room = player:getRoom()
									room:notifySkillInvoked(player, "MdkJieDa") --显示技能发动
									player:gainMark("@MdkJieDaMark", 1)
									return false
								end
							end
						end
					end
				end
			end
		end
	end,
}
JieDaKeep = sgs.CreateMaxCardsSkill{
	name = "#MdkJieDaKeep",
	extra_func = function(self, player)
		if player:hasSkill("MdkJieDa") then
			return player:getMark("@MdkJieDaMark")
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkJieDa", "#MdkJieDaRecord")
extension:insertRelatedSkills("MdkJieDa", "#MdkJieDaKeep")
--添加技能
Nagisa:addSkill(JieDa)
Nagisa:addSkill(JieDaRecord)
Nagisa:addSkill(JieDaKeep)
--翻译信息
sgs.LoadTranslationTable{
	["MdkJieDa"] = "解答",
	[":MdkJieDa"] = "<font color=\"cyan\"><b>联动技。</b></font>你从神·鹿目圆处获得牌时，你获得一枚“令”标记。你的手牌上限+X（X为你的“令”标记的数量）。神·鹿目圆或你攻击范围内的一名其他角色的回合结束时，你可以弃一枚“令”标记，交给其两张牌，然后你摸两张牌。",
	["$MdkJieDa"] = "那由我亲自解释",
	["@MdkJieDaMark"] = "令",
	["@MdkJieDa"] = "您可以发动“解答”交给 %src 两张牌，然后你摸两张牌",
	["~MdkJieDa"] = "依次选择两张牌（包括装备）->点击“确定”",
}
end
--[[****************************************************************
	编号：MDK - 10
	武将：魔女之夜（Walpurgis Night）[隐藏武将]
	称号：最终的狂欢
	性别：女
	势力：神
	体力上限：6勾玉
]]--****************************************************************
WalNight = sgs.General(extension, "WalpurgisNight", "god", 6, false, true)
--翻译信息
sgs.LoadTranslationTable{
	["WalpurgisNight"] = "魔女之夜",
	["&WalpurgisNight"] = "魔女之夜",
	["#WalpurgisNight"] = "最终的狂欢",
	["designer:WalpurgisNight"] = "DGAH",
	["cv:WalpurgisNight"] = "水桥香织",
	["illustrator:WalpurgisNight"] = "萌娘百科",
	["~WalpurgisNight"] = "（魔女之夜崩灭之音）",
}
--[[
	技能：飓风（锁定技）
	描述：游戏开始后或你脱离濒死状态后的第一个出牌阶段开始时，你视为发动了一次“乱武”。
]]--
function doLuanWu(room, player)
	room:broadcastSkillInvoke("MdkJuFeng") --播放配音
	room:notifySkillInvoked(player, "MdkJuFeng") --显示技能发动
	room:doSuperLightbox("WalpurgisNight", "MdkJuFeng") --播放全屏特效
	local others = room:getOtherPlayers(player)
	local thread = room:getThread()
	for _,p in sgs.qlist(others) do
		local siblings = room:getOtherPlayers(p)
		local min_dist = 9999
		local targets = sgs.SPlayerList()
		for _,target in sgs.qlist(siblings) do
			if p:canSlash(target, nil, false) then
				local dist = p:distanceTo(target)
				if dist < min_dist then
					targets = sgs.SPlayerList()
					targets:append(target)
					min_dist = dist
				elseif dist == min_dist then
					targets:append(target)
				end
			end
		end
		local losehp = true
		if targets:isEmpty() then
		elseif room:askForUseSlashTo(p, targets, "@luanwu-slash") then
			losehp = false
		end
		if losehp then
			room:loseHp(p, 1)
		end
		thread:delay()
	end
end
JuFeng = sgs.CreateTriggerSkill{
	name = "MdkJuFeng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.QuitDying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Play then
				if player:getMark("MdkJuFengInvoked") == 0 then
					room:setPlayerMark(player, "MdkJuFengInvoked", 1)
					doLuanWu(room, player)
				end
			end
		elseif event == sgs.QuitDying then
			local dying = data:toDying()
			local victim = dying.who
			if victim and victim:objectName() == player:objectName() then
				room:setPlayerMark(player, "MdkJuFengInvoked", 0)
			end
		end
		return false
	end,
}
--添加技能
WalNight:addSkill(JuFeng)
--翻译信息
sgs.LoadTranslationTable{
	["MdkJuFeng"] = "飓风",
	[":MdkJuFeng"] = "锁定技。游戏开始后或你脱离濒死状态后的第一个出牌阶段开始时，你视为发动了一次“乱武”。",
	["$MdkJuFeng"] = "（魔女之夜降临背景音乐）",
}
--[[
	技能：肆虐（锁定技）
	描述：出牌阶段，若你未造成过伤害，你使用【杀】无次数限制；你对其他角色造成伤害时，你弃置目标一张装备牌。
]]--
SiNve = sgs.CreateTriggerSkill{
	name = "MdkSiNve",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then
			if player:getPhase() == sgs.Player_Play then
				room:setPlayerMark(player, "MdkSiNveDamage", 1)
			end
			local damage = data:toDamage()
			local victim = damage.to
			if victim and victim:objectName() ~= player:objectName() then
				if victim:hasEquip() and player:canDiscard(victim, "e") then
					room:sendCompulsoryTriggerLog(player, "MdkSiNve") --发送锁定技触发信息
					local id = room:askForCardChosen(player, victim, "e", "MdkSiNve", false, sgs.Card_MethodDiscard)
					if id >= 0 then
						room:broadcastSkillInvoke("MdkSiNve") --播放配音
						room:notifySkillInvoked(player, "MdkSiNve") --显示技能发动
						room:throwCard(id, victim, player)
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Play then
				room:setPlayerMark(player, "MdkSiNveDamage", 0)
			end
		end
		return false
	end,
}
SiNveMod = sgs.CreateTargetModSkill{
	name = "#MdkSiNveMod",
	residue_func = function(self, player, card)
		if card:isKindOf("Slash") and player:hasSkill("MdkSiNve") then
			if player:getPhase() == sgs.Player_Play and player:getMark("MdkSiNveDamage") == 0 then
				return 1000
			end
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkSiNve", "#MdkSiNveMod")
--添加技能
WalNight:addSkill(SiNve)
WalNight:addSkill(SiNveMod)
--翻译信息
sgs.LoadTranslationTable{
	["MdkSiNve"] = "肆虐",
	[":MdkSiNve"] = "锁定技。出牌阶段，若你未造成过伤害，你使用【杀】无次数限制；你对其他角色造成伤害时，你弃置目标一张装备牌。",
	["$MdkSiNve1"] = "（魔女之夜的使魔）",
	["$MdkSiNve2"] = "（房屋震动声）",
}
--[[
	技能：舞台（锁定技）
	描述：其他角色计算的与你的距离+1；你受到的无属性伤害-1。
]]--
WuTai = sgs.CreateTriggerSkill{
	name = "MdkWuTai",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Normal then
			local room = player:getRoom()
			room:broadcastSkillInvoke("MdkWuTai") --播放配音
			room:notifySkillInvoked(player, "MdkWuTai") --显示技能发动
			local count = damage.damage - 1
			local msg = sgs.LogMessage()
			msg.from = player
			if count > 0 then
				msg.type = "#MdkWuTaiEffect"
				msg.arg = count + 1
				msg.arg2 = count
			else
				msg.type = "#MdkWuTaiAvoid"
				msg.arg = "MdkWuTai"
				msg.arg2 = count + 1
			end
			room:sendLog(msg) --发送提示信息
			damage.damage = count
			data:setValue(damage)
			return count == 0
		end
		return false
	end,
}
WuTaiDist = sgs.CreateDistanceSkill{
	name = "#MdkWuTaiDist",
	correct_func = function(self, from, to)
		if to:hasSkill("MdkWuTai") then
			return 1
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkWuTai", "#MdkWuTaiDist")
--添加技能
WalNight:addSkill(WuTai)
WalNight:addSkill(WuTaiDist)
--翻译信息
sgs.LoadTranslationTable{
	["MdkWuTai"] = "舞台",
	[":MdkWuTai"] = "锁定技。其他角色计算的与你的距离+1；你受到的无属性伤害-1。",
	["$MdkWuTai"] = "（魔女之夜音效）",
	["#MdkWuTaiEffect"] = "%from 的技能“舞台”被触发，本次受到的伤害-1，由 %arg 点减少至 %arg2 点",
	["#MdkWuTaiAvoid"] = "%from 的技能“%arg”被触发，防止了本次受到的 %arg2 点伤害",
	["#MdkWuTaiDist"] = "舞台",
}
--[[
	技能：回转（锁定技）
	描述：回合结束时，你将武将牌翻面并获得一枚“回转”标记。回合开始时，若你的“回转”标记不少于场上人数，你弃掉所有“回转”标记，令所有距离你最近的角色依次失去1点体力上限。
		你的攻击范围+X（X为你的“回转”标记数量）。
]]--
HuiZhuan = sgs.CreateTriggerSkill{
	name = "MdkHuiZhuan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase == sgs.Player_Finish then
			room:sendCompulsoryTriggerLog(player, "MdkHuiZhuan") --发送锁定技触发信息
			player:turnOver()
			player:gainMark("@MdkHuiZhuanMark", 1)
		elseif phase == sgs.Player_Start then
			local n_mark = player:getMark("@MdkHuiZhuanMark")
			local n_player = room:alivePlayerCount()
			if n_mark >= n_player then
				room:broadcastSkillInvoke("MdkHuiZhuan") --播放配音
				room:notifySkillInvoked(player, "MdkHuiZhuan") --显示技能发动
				room:doSuperLightbox("WalpurgisNight", "MdkHuiZhuan") --播放全屏特效
				local msg = sgs.LogMessage()
				msg.type = "#MdkHuiZhuanInvoke"
				msg.from = player
				msg.arg = n_mark
				msg.arg2 = n_player
				room:sendLog(msg) --发送提示信息
				player:loseAllMarks("@MdkHuiZhuanMark")
				local others = room:getOtherPlayers(player)
				local victims = {}
				local min_dist = 9999
				for _,p in sgs.qlist(others) do
					local dist = player:distanceTo(p)
					if dist < min_dist then
						min_dist = dist
						victims = {p}
					elseif dist == min_dist then
						table.insert(victims, p)
					end
				end
				for _,victim in ipairs(victims) do
					room:loseMaxHp(victim, 1)
				end
			end
		end
		return false
	end,
}
HuiZhuanRange = sgs.CreateAttackRangeSkill{
	name = "#MdkHuiZhuanRange",
	extra_func = function(self, player)
		if player:hasSkill("MdkHuiZhuan") then
			return player:getMark("@MdkHuiZhuanMark")
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkHuiZhuan", "#MdkHuiZhuanRange")
--添加技能
WalNight:addSkill(HuiZhuan)
WalNight:addSkill(HuiZhuanRange)
--翻译信息
sgs.LoadTranslationTable{
	["MdkHuiZhuan"] = "回转",
	[":MdkHuiZhuan"] = "锁定技。回合结束时，你将武将牌翻面并获得一枚“回转”标记。回合开始时，若你的“回转”标记不少于场上人数，你弃掉所有“回转”标记，令所有距离你最近的角色依次失去1点体力上限。你的攻击范围+X（X为你的“回转”标记数量）",
	["$MdkHuiZhuan"] = "（魔女之夜主题音乐）",
	["#MdkHuiZhuanInvoke"] = "%from 的回合开始，因拥有的“回转”标记数(%arg)不少于场上人数(%arg2)，触发技能“<font color=\"yellow\">回转</font>”",
	["@MdkHuiZhuanMark"] = "回转",
}
--[[****************************************************************
	编号：MDK - 11
	武将：神·鹿目圆[隐藏武将]
	称号：希望之神
	性别：女
	势力：神
	体力上限：3勾玉
]]--****************************************************************
MadokaEX = sgs.General(extension, "GodMadoka", "god", 3, false, true)
--翻译信息
sgs.LoadTranslationTable{
	["GodMadoka"] = "神·鹿目圆",
	["&GodMadoka"] = "鹿目圆",
	["#GodMadoka"] = "希望之神",
	["designer:GodMadoka"] = "DGAH",
	["cv:GodMadoka"] = "悠木碧",
	["illustrator:GodMadoka"] = "萌娘百科",
	["~GodMadoka"] = "不可以……我要裂开了！",
}
--[[
	技能：箭雨
	描述：你可以将一张武器牌或红色的【杀】当作【万箭齐发】使用。
]]--
JianYu = sgs.CreateViewAsSkill{
	name = "MdkJianYu",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:isKindOf("Weapon") then
			return true
		elseif to_select:isKindOf("Slash") and to_select:isRed() then
			return true
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local trick = sgs.Sanguosha:cloneCard("archery_attack", suit, point)
			trick:setSkillName("MdkJianYu")
			trick:addSubcard(card)
			return trick
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isNude()
	end,
}
--添加技能
MadokaEX:addSkill(JianYu)
--翻译信息
sgs.LoadTranslationTable{
	["MdkJianYu"] = "箭雨",
	[":MdkJianYu"] = "你可以将一张武器牌或红色的【杀】当作【万箭齐发】使用。",
	["$MdkJianYu"] = "（魔法箭雨声）",
}
--[[
	技能：指引
	描述：一名角色进入濒死状态时，你可以弃一张红色牌。若如此做，你展示该角色所有手牌并弃置其区域中的所有黑色牌，然后该角色回复1点体力。
		出牌阶段限一次，你可以弃至少一张黑色牌，然后摸等量的牌。
]]--
ZhiYinCard = sgs.CreateSkillCard{
	name = "MdkZhiYinCard",
	--skill_name = "MdkZhiYin",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("MdkZhiYin", 4) --播放配音
		local n = self:subcardsLength()
		room:drawCards(source, n, "MdkZhiYin")
	end,
}
ZhiYinVS = sgs.CreateViewAsSkill{
	name = "MdkZhiYin",
	n = 999,
	view_filter = function(self, selected, to_select)
		return to_select:isBlack()
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local card = ZhiYinCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if player:hasUsed("#MdkZhiYinCard") then
			return false
		elseif player:isNude() then
			return false
		end
		return true
	end,
}
ZhiYin = sgs.CreateTriggerSkill{
	name = "MdkZhiYin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EnterDying},
	view_as_skill = ZhiYinVS,
	on_trigger = function(self, event, player, data)
		local dying = data:toDying()
		local victim = dying.who
		if victim and victim:objectName() == player:objectName() then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:hasSkill("MdkZhiYin") and source:canDiscard(source, "he") then
					local prompt = string.format("@MdkZhiYin:%s:", player:objectName())
					if room:askForCard(source, ".|red", prompt, data, "MdkZhiYin") then
						local index = 3
						if source:objectName() ~= player:objectName() then
							index = math.random(1, 100) > 50 and 1 or 2
						end
						room:broadcastSkillInvoke("MdkZhiYin", index) --播放配音
						room:notifySkillInvoked(source, "MdkZhiYin") --显示技能发动
						if not player:isKongcheng() then
							room:showAllCards(player)
						end
						local cards = player:getCards("hej")
						local to_clear = sgs.IntList()
						for _,c in sgs.qlist(cards) do
							if c:isBlack() then
								local id = c:getEffectiveId()
								if source:canDiscard(player, id) then
									to_clear:append(id)
								end
							end
						end
						local x = to_clear:length()
						if x > 0 then
							local move = sgs.CardsMoveStruct()
							move.to = nil
							move.to_place = sgs.Player_DiscardPile
							move.card_ids = to_clear
							move.reason = sgs.CardMoveReason(
								sgs.CardMoveReason_S_REASON_DISMANTLE, 
								source:objectName(), 
								player:objectName(), 
								"MdkZhiYin", 
								""
							)
							room:moveCardsAtomic(move, true)
						end
						if player:isAlive() and player:getLostHp() > 0 then
							local recover = sgs.RecoverStruct()
							recover.who = source
							recover.recover = 1
							room:recover(player, recover)
						end
						return false
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
	priority = 3,
}
--添加技能
MadokaEX:addSkill(ZhiYin)
--翻译信息
sgs.LoadTranslationTable{
	["MdkZhiYin"] = "指引",
	[":MdkZhiYin"] = "一名角色进入濒死状态时，你可以弃一张红色牌。若如此做，你展示该角色所有手牌并弃置其区域中的所有黑色牌，然后该角色回复1点体力。阶段技。你可以弃至少一张黑色牌，然后摸等量的牌。",
	["$MdkZhiYin1"] = "对不起，让你久等了",
	["$MdkZhiYin2"] = "来，走吧",
	["$MdkZhiYin3"] = "因果，全都由我来接收",
	["$MdkZhiYin4"] = "你们的祈祷，我绝不会让它以绝望的形式结束",
	["@MdkZhiYin"] = "您可以发动“指引”弃一张红色牌，令 %src 弃置其区域中所有黑色牌并回复 1 点体力",
	["~MdkZhiYin"] = "选择一张红色牌（包括装备）->点击“确定”",
	["mdkzhiyin"] = "指引",
}
--[[
	技能：神格（锁定技）
	描述：其他角色计算的与你的距离+X（X为该角色的体力）；你不能被指定为其他角色使用的延时性锦囊牌的目标。
]]--
ShenGe = sgs.CreateProhibitSkill{
	name = "MdkShenGe",
	is_prohibited = function(self, from, to, card)
		if to:hasSkill("MdkShenGe") then
			if card:isKindOf("DelayedTrick") then
				if to:objectName() ~= from:objectName() then
					return true
				end
			end
		end
		return false
	end,
}
ShenGeDist = sgs.CreateDistanceSkill{
	name = "#MdkShenGeDist",
	correct_func = function(self, from, to)
		if to:hasSkill("MdkShenGe") then
			return from:getHp()
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkShenGe", "#MdkShenGeDist")
--添加技能
MadokaEX:addSkill(ShenGe)
MadokaEX:addSkill(ShenGeDist)
--翻译信息
sgs.LoadTranslationTable{
	["MdkShenGe"] = "神格",
	[":MdkShenGe"] = "锁定技。其他角色计算的与你的距离+X（X为该角色的体力）；你不能被指定为其他角色使用的延时性锦囊牌的目标。",
	["$MdkShenGe1"] = "现在的我，能看到过去和未来的一切",
	["$MdkShenGe2"] = "因为我变成了现在的我，才能够知道真正的你",
	["#MdkShenGeDist"] = "神格",
}
--[[
	技能：光辉（限定技）
	描述：出牌阶段，除你以外，若一名角色满足：1、体力最多；2、攻击范围内包含所有其他角色，你可以摸三张牌，视为对其使用了一张【决斗】（不可被【无懈可击】抵消）。此【决斗】对其造成伤害时，该角色立即死亡，且所有其他角色重置武将牌并回复所有体力。
]]--
GuangHuiCard = sgs.CreateSkillCard{
	name = "MdkGuangHuiCard",
	skill_name = "MdkGuangHui",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:objectName() == sgs.Self:objectName() then
				return false
			end
			local others = to_select:getAliveSiblings()
			local hp = to_select:getHp()
			for _,p in sgs.qlist(others) do
				if sgs.Self:objectName() == p:objectName() then
				elseif p:getHp() >= hp then
					return false
				elseif to_select:inMyAttackRange(p) then
				else
					return false
				end
			end
			local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
			duel:deleteLater()
			local selected = sgs.PlayerList()
			return duel:targetFilter(selected, to_select, sgs.Self)
		end
		return false
	end,
	on_validate = function(self, use)
		local source = use.from
		local room = source:getRoom()
		room:broadcastSkillInvoke("MdkGuangHui") --播放配音
		room:notifySkillInvoked(source, "MdkGuangHui") --显示技能发动
		room:doSuperLightbox("GodMadoka", "MdkGuangHui") --播放全屏特效
		source:loseMark("@MdkGuangHuiMark", 1)
		room:drawCards(source, 3, "MdkGuangHui")
		for _,target in sgs.qlist(use.to) do
			room:setPlayerFlag(target, "MdkGuangHuiTarget")
		end
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:setSkillName("MdkGuangHui_Effect") --防止播放额外配音
		duel:toTrick():setCancelable(false)
		return duel
	end,
}
GuangHuiVS = sgs.CreateViewAsSkill{
	name = "MdkGuangHui",
	n = 0,
	view_as = function(self, cards)
		return GuangHuiCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:getMark("@MdkGuangHuiMark") > 0 then
			local others = player:getAliveSiblings()
			local max_hp = 0
			local target = nil
			for _,p in sgs.qlist(others) do
				local hp = p:getHp()
				if hp > max_hp then
					max_hp = hp
					target = p
					for _,p2 in sgs.qlist(others) do
						if p2:objectName() == p:objectName() then
						elseif p:inMyAttackRange(p2) then
						else
							target = nil
							break
						end
					end
				elseif hp == max_hp then
					target = nil
				end
			end
			return target ~= nil
		end
		return false
	end,
}
GuangHui = sgs.CreateTriggerSkill{
	name = "MdkGuangHui",
	frequency = sgs.Skill_Limited,
	events = {sgs.Damage},
	view_as_skill = GuangHuiVS,
	limit_mark = "@MdkGuangHuiMark",
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local duel = damage.card
		if duel and duel:isKindOf("Duel") and duel:getSkillName() == "MdkGuangHui_Effect" then
			local target = damage.to
			if target:hasFlag("MdkGuangHuiTarget") then
				local room = player:getRoom()
				room:setPlayerFlag(target, "-MdkGuangHuiTarget")
				room:killPlayer(target, damage)
				local others = room:getOtherPlayers(player)
				for _,p in sgs.qlist(others) do
					if p:isChained() then
						room:setPlayerProperty(p, "chained", sgs.QVariant(false))
						room:broadcastProperty(p, "chained")
					end
					if p:isAlive() and not p:faceUp() then
						p:turnOver()
					end
					if p:isAlive() then
						local x = p:getLostHp()
						local recover = sgs.RecoverStruct()
						recover.who = player
						recover.recover = x
						room:recover(p, recover)
					end
				end
			end
		end
		return false
	end,
}
--添加技能
MadokaEX:addSkill(GuangHui)
--翻译信息
sgs.LoadTranslationTable{
	["MdkGuangHui"] = "光辉",
	[":MdkGuangHui"] = "限定技。出牌阶段，除你以外，若一名角色满足：1、体力最多；2、攻击范围内包含所有其他角色，你可以摸三张牌，视为对其使用了一张【决斗】（不可被【无懈可击】抵消）。此【决斗】对其造成伤害时，该角色立即死亡，且所有其他角色重置武将牌并回复所有体力。",
	["$MdkGuangHui"] = "我再也没有绝望的必要了！",
	["@MdkGuangHuiMark"] = "光辉",
	["MdkGuangHui_Effect"] = "光辉",
}
if LinkSkillSwitch then
--[[
	技能：朋友（联动技->晓美焰）
	描述：你对晓美焰造成伤害后，你可以令晓美焰回复1点体力。
]]--
PengYou = sgs.CreateTriggerSkill{
	name = "MdkPengYou&",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local target = damage.to
		if target and target:isAlive() then
			if target:getGeneralName() == "AkemiHomura" or target:getGeneral2Name() == "AkemiHomura" then
				local ai_data = sgs.QVariant()
				ai_data:setValue(target)
				if player:askForSkillInvoke("MdkPengYou", ai_data) then
					local room = player:getRoom()
					room:broadcastSkillInvoke("MdkPengYou") --播放配音
					room:notifySkillInvoked(player, "MdkPengYou") --显示技能发动
					local recover = sgs.RecoverStruct()
					recover.who = player
					recover.recover = 1
					room:recover(target, recover)
				end
			end
		end
		return false
	end,
}
--添加技能
MadokaEX:addSkill(PengYou)
--翻译信息
sgs.LoadTranslationTable{
	["MdkPengYou"] = "朋友",
	[":MdkPengYou"] = "<font color=\"cyan\"><b>联动技。</b></font>你对晓美焰造成伤害后，你可以令晓美焰回复1点体力。",
	["$MdkPengYou1"] = "一直没能意识到……对不起……",
	["$MdkPengYou2"] = "你是我最好的朋友",
}
--[[
	技能：计遣（联动技->美树沙耶香、百江渚）
	描述：出牌阶段结束时，你可以将一张非基本牌交给美树沙耶香或百江渚。若如此做，此回合结束后，该角色获得一个额外的回合。
	说明：在因“计遣”获得的额外回合中，不能再次发动“计遣”
]]--
JiQianCard = sgs.CreateSkillCard{
	name = "MdkJiQianCard",
	--skill_name = "MdkJiQian",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			local name = to_select:getGeneralName()
			if name == "MikiSayaka" or name == "MomoeNagisa" then
				return true
			end
			name = to_select:getGeneral2Name()
			if name == "MikiSayaka" or name == "MomoeNagisa" then
				return true
			end
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local name = target:getGeneralName()
		local name2 = target:getGeneral2Name()
		local index = -1
		if name == "MikiSayaka" then
			index = 1
		elseif name == "MomoeNagisa" then
			index = 2
		elseif name2 == "MikiSayaka" then
			index = 1
		elseif name2 == "MomoeNagisa" then
			index = 2
		end
		room:broadcastSkillInvoke("MdkJiQian", index) --播放配音
		room:notifySkillInvoked(source, "MdkJiQian") --显示技能发动
		room:addPlayerMark(target, "MdkJiQianTarget", 1)
		if source:objectName() == target:objectName() then
			local id = self:getSubcards():first()
			room:showCard(source, id)
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), target:objectName(), "MdkJiQian", "")
		room:obtainCard(target, self, reason, true)
	end,
}
JiQianVS = sgs.CreateViewAsSkill{
	name = "MdkJiQian",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isKindOf("BasicCard")
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = JiQianCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@MdkJiQian"
	end,
}
JiQian = sgs.CreateTriggerSkill{
	name = "MdkJiQian&",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	view_as_skill = JiQianVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			if player:getMark("MdkJiQianExtraTurn") > 0 then
				return false
			elseif player:isNude() then
				return false
			end
			local can_invoke = false
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				local name = p:getGeneralName()
				if name == "MikiSayaka" or name == "MomoeNagisa" then
					can_invoke = true
					break
				end
				name = p:getGeneral2Name()
				if name == "MikiSayaka" or name == "MomoeNagisa" then
					can_invoke = true
					break
				end
			end
			if can_invoke then
				room:askForUseCard(player, "@@MdkJiQian", "@MdkJiQian")
			end
		end
		return false
	end,
}
JiQianEffect = sgs.CreateTriggerSkill{
	name = "#MdkJiQianEffect",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			local target = nil
			for _,p in sgs.qlist(alives) do
				if p:getMark("MdkJiQianTarget") > 0 then
					room:removePlayerMark(p, "MdkJiQianTarget", 1)
					target = p
					break
				end
			end
			if target then
				room:setPlayerMark(target, "MdkJiQianExtraTurn", 1)
				target:gainAnExtraTurn()
				room:setPlayerMark(target, "MdkJiQianExtraTurn", 0)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end,
	priority = 1,
}
extension:insertRelatedSkills("MdkJiQian", "#MdkJiQianEffect")
--添加技能
MadokaEX:addSkill(JiQian)
MadokaEX:addSkill(JiQianEffect)
--翻译信息
sgs.LoadTranslationTable{
	["MdkJiQian"] = "计遣",
	[":MdkJiQian"] = "<font color=\"cyan\"><b>联动技。</b></font>出牌阶段结束时，你可以将一张非基本牌交给美树沙耶香或百江渚。若如此做，此回合结束后，该角色获得一个额外的回合。",
	["$MdkJiQian1"] = "稍微走了点弯路[by美树沙耶香]",
	["$MdkJiQian2"] = "真是的呢[by百江渚]",
	["@MdkJiQian"] = "您可以发动“计遣”交给 美树沙耶香 或 百江渚 一张 非基本牌，令其回合结束后获得一个额外的回合",
	["~MdkJiQian"] = "选择一张非基本牌->选择一名目标角色->点击“确定”",
	["mdkjiqian"] = "计遣",
}
end
--[[****************************************************************
	编号：MDK - 12
	武将：魔·晓美焰[隐藏武将]
	称号：炽爱之魔
	性别：女
	势力：神
	体力上限：4勾玉
]]--****************************************************************
HomuraEX = sgs.General(extension, "DevilHomura", "god", 4, false, true)
--翻译信息
sgs.LoadTranslationTable{
	["DevilHomura"] = "魔·晓美焰",
	["&DevilHomura"] = "晓美焰",
	["#DevilHomura"] = "炽爱之魔",
	["designer:DevilHomura"] = "DGAH",
	["cv:DevilHomura"] = "斋藤千和",
	["illustrator:DevilHomura"] = "萌娘百科",
	["~DevilHomura"] = "到了那个时候，我就再次成为你们的敌人吧",
}
--[[
	技能：银庭
	描述：摸牌阶段，你额外摸一张牌，然后你可以将一张手牌置于武将牌上，称为“欲”；一名角色的判定牌生效前，你可以打出一张“欲”牌替换之。
]]--
YinTingCard = sgs.CreateSkillCard{
	name = "MdkYinTingCard",
	--skill_name = "MdkYinTing",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("MdkYinTing", 1) --播放配音
		source:addToPile("MdkYinTingPile", self, false)
	end,
}
YinTingVS = sgs.CreateViewAsSkill{
	name = "MdkYinTing",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = YinTingCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@MdkYinTing"
	end,
}
YinTing = sgs.CreateTriggerSkill{
	name = "MdkYinTing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards, sgs.AfterDrawNCards, sgs.AskForRetrial},
	view_as_skill = YinTingVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawNCards then
			room:sendCompulsoryTriggerLog(player, "MdkYinTing") --发送锁定技触发信息
			local n = data:toInt()
			data:setValue(n + 1)
		elseif event == sgs.AfterDrawNCards then
			room:askForUseCard(player, "@@MdkYinTing", "@MdkYinTing")
		elseif event == sgs.AskForRetrial then
			local pile = player:getPile("MdkYinTingPile")
			if pile:isEmpty() then
				return false
			end
			local judge = data:toJudge()
			local target = judge.who
			local prompt = string.format("invoke:%s::%s:", target:objectName(), judge.reason)
			local ai_data = sgs.QVariant(prompt)
			room:setTag("MdkYinTingData", data) --For AI
			local invoke = room:askForSkillInvoke(player, "MdkYinTing", ai_data)
			room:removeTag("MdkYinTingData") --For AI
			if invoke then
				room:fillAG(pile, player)
				room:setTag("MdkYinTingData", data) --For AI
				local id = room:askForAG(player, pile, false, "MdkYinTing")
				room:removeTag("MdkYinTingData") --For AI
				room:clearAG(player)
				if id >= 0 then
					room:broadcastSkillInvoke("MdkYinTing", 2) --播放配音
					room:notifySkillInvoked(player, "MdkYinTing") --显示技能发动
					local card = sgs.Sanguosha:getCard(id)
					room:retrial(card, player, judge, "MdkYinTing", true)
				end
			end
		end
		return false
	end,
}
--添加技能
HomuraEX:addSkill(YinTing)
--翻译信息
sgs.LoadTranslationTable{
	["MdkYinTing"] = "银庭",
	[":MdkYinTing"] = "摸牌阶段，你额外摸一张牌，然后你可以将一张手牌置于武将牌上，称为“欲”；一名角色的判定牌生效前，你可以打出一张“欲”牌替换之。",
	["$MdkYinTing1"] = "我所期望的是能让你幸福的世界",
	["$MdkYinTing2"] = "或许那样也不错",
	["@MdkYinTing"] = "银庭：您可以将一张手牌作为“欲”置于武将牌上",
	["~MdkYinTing"] = "选择一张手牌->点击“确定”",
	["MdkYinTingPile"] = "欲",
	["MdkYinTing:invoke"] = "您想发动“银庭”打出一张“欲”牌来修改 %src 的 %arg 判定吗？",
	["mdkyinting"] = "银庭",
}
--[[
	技能：干涉（阶段技）
	描述：你可以弃四张花色各不相同的“欲”，令一名角色失去一项技能；你受到其他角色造成的伤害时，你也可以对该角色发动此技能。
]]--
GanSheCard = sgs.CreateSkillCard{
	name = "MdkGanSheCard",
	--skill_name = "MdkGanShe",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			local target_name = sgs.Self:property("MdkGanSheTarget"):toString()
			if target_name ~= "" then
				return to_select:objectName() == target_name
			end
			return true
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		room:setPlayerProperty(source, "MdkGanSheTarget", sgs.QVariant())
		local target = targets[1]
		room:notifySkillInvoked(source, "MdkGanShe") --显示技能发动
		local skills = target:getVisibleSkillList()
		local names = {}
		for _,skill in sgs.qlist(skills) do
			if skill:inherits("SPConvertSkill") then
			elseif skill:isAttachedLordSkill() then
			elseif skill:isLordSkill() and not target:hasLordSkill(skill:objectName()) then
			else
				table.insert(names, skill:objectName())
			end
		end
		if #names == 0 then
			return 
		end
		local choices = table.concat(names, "+")
		local ai_data = sgs.QVariant()
		ai_data:setValue(target)
		room:setTag("MdkGanSheVictim", ai_data) --For AI
		local choice = room:askForChoice(source, "MdkGanShe", choices, ai_data)
		room:removeTag("MdkGanSheVictim") --For AI
		local index = 1
		local name = target:getGeneralName()
		local name2 = target:getGeneral2Name()
		if name == "GodMadoka" or name2 == "GodMadoka" then
			index = 3
		elseif name == "MikiSayaka" or name2 == "MikiSayaka" then
			index = 2
		elseif name == "KanameMadoka" or name2 == "KanameMadoka" then
			index = 3
		end
		room:broadcastSkillInvoke("MdkGanShe", index) --播放配音
		room:handleAcquireDetachSkills(target, "-"..choice, false)
	end,
}
GanSheVS = sgs.CreateViewAsSkill{
	name = "MdkGanShe",
	n = 4,
	expand_pile = "MdkYinTingPile",
	view_filter = function(self, selected, to_select)
		local suit = to_select:getSuit()
		for _,c in ipairs(selected) do
			if c:getSuit() == suit then
				return false
			end
		end
		return sgs.Sanguosha:matchExpPattern(".|.|.|MdkYinTingPile", sgs.Self, to_select)
	end,
	view_as = function(self, cards)
		if #cards == 4 then
			local card = GanSheCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if player:hasUsed("#MdkGanSheCard") then
			return false
		end
		local pile = player:getPile("MdkYinTingPile")
		if pile:length() < 4 then
			return false
		end
		local suits = {}
		for _,id in sgs.qlist(pile) do
			local card = sgs.Sanguosha:getCard(id)
			local suit = card:getSuit()
			suits[suit] = 1
		end
		local total = 0
		for suit, count in pairs(suits) do
			total = total + count
		end
		return total >= 4
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@MdkGanShe"
	end,
}
GanShe = sgs.CreateTriggerSkill{
	name = "MdkGanShe",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	view_as_skill = GanSheVS,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local source = damage.from
		if source and source:isAlive() and source:objectName() ~= player:objectName() then
			local can_invoke = false
			local skills = source:getVisibleSkillList()
			for _,skill in sgs.qlist(skills) do
				if skill:inherits("SPConvertSkill") then
				elseif skill:isAttachedLordSkill() then
				elseif skill:isLordSkill() and not source:hasLordSkill(skill:objectName()) then
				else
					can_invoke = true
					break
				end
			end
			if can_invoke then
				local pile = player:getPile("MdkYinTingPile")
				if pile:length() < 4 then
					return false
				end
				local suits = {}
				for _,id in sgs.qlist(pile) do
					local card = sgs.Sanguosha:getCard(id)
					local suit = card:getSuit()
					suits[suit] = 1
				end
				local total = 0
				for suit, count in pairs(suits) do
					total = total + count
				end
				if total < 4 then
					return false
				end
			end
			if can_invoke then
				local room = player:getRoom()
				local target_name = source:objectName()
				room:setPlayerProperty(player, "MdkGanSheTarget", sgs.QVariant(target_name))
				local prompt = string.format("@MdkGanShe:%s:", target_name)
				room:askForUseCard(player, "@@MdkGanShe", prompt)
				room:setPlayerProperty(player, "MdkGanSheTarget", sgs.QVariant())
			end
		end
		return false
	end,
}
--添加技能
HomuraEX:addSkill(GanShe)
--翻译信息
sgs.LoadTranslationTable{
	["MdkGanShe"] = "干涉",
	[":MdkGanShe"] = "阶段技。你可以弃四张花色各不相同的“欲”，令一名角色失去一项技能；你受到其他角色造成的伤害时，你可以对该角色发动此技能。",
	["$MdkGanShe1"] = "我夺走的不过是个小碎片",
	["$MdkGanShe2"] = "美树沙耶香，你可以与我抗衡吗？",
	["$MdkGanShe3"] = "没事的，你毫无疑问是原本的你",
	["@MdkGanShe"] = "您可以发动“干涉”弃四张花色各不相同的“欲”牌，令 %src 失去一项技能",
	["~MdkGanShe"] = "依次选择四张要弃置的“欲”牌->点击“确定”",
	["mdkganshe"] = "干涉",
}
--[[
	技能：魔道（锁定技）
	描述：你的回合内，你的攻击范围无限；其他角色对你使用延时性锦囊牌时，你获得此牌。
]]--
MoDao = sgs.CreateTriggerSkill{
	name = "MdkMoDao",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		if move.to_place == sgs.Player_PlaceDelayedTrick then
			local dest = move.to
			if dest and dest:objectName() == player:objectName() then
				local source = move.from
				if source and source:objectName() == player:objectName() then
					return false
				end
				local room = player:getRoom()
				room:broadcastSkillInvoke("MdkMoDao") --播放配音
				room:notifySkillInvoked(player, "MdkMoDao") --显示技能发动
				room:sendCompulsoryTriggerLog(player, "MdkMoDao") --发送锁定技触发信息
				local get = sgs.CardsMoveStruct()
				get.to = player
				get.to_place = sgs.Player_PlaceHand
				get.card_ids = move.card_ids
				get.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTCARD, player:objectName(), "MdkMoDao", "")
				room:moveCardsAtomic(get, true)
			end
		end
		return false
	end,
}
MoDaoRange = sgs.CreateAttackRangeSkill{
	name = "#MdkMoDaoRange",
	extra_func = function(self, player)
		if player:getPhase() ~= sgs.Player_NotActive then
			if player:hasSkill("MdkMoDao") then
				return 1000
			end
		end
		return 0
	end,
}
extension:insertRelatedSkills("MdkMoDao", "#MdkMoDaoRange")
--添加技能
HomuraEX:addSkill(MoDao)
HomuraEX:addSkill(MoDaoRange)
--翻译信息
sgs.LoadTranslationTable{
	["MdkMoDao"] = "魔道",
	[":MdkMoDao"] = "锁定技。你的回合内，你的攻击范围无限；其他角色对你使用延时性锦囊牌时，你获得此牌。",
	["$MdkMoDao1"] = "现在的我是“魔”",
	["$MdkMoDao2"] = "反抗天理是理所当然的",
}
--[[
	技能：独舞（限定技）
	描述：出牌阶段，你可以摸三张牌，与一名手牌数多于体力的其他角色拼点。若你赢，该角色失去所有技能并获得技能“崩坏”。
	说明：若没有手牌数多于体力的其他角色，不能发动此技能；即，不可以只摸牌不拼点。
]]--
DuWuCard = sgs.CreateSkillCard{
	name = "MdkDuWuCard",
	--skill_name = "MdkDuWu",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:objectName() == sgs.Self:objectName() then
				return false
			elseif to_select:isKongcheng() then
				return false
			elseif to_select:getHandcardNum() > to_select:getHp() then
				return true
			end
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local index = 1
		if target:getGeneralName() == "Incubator" or target:getGeneral2Name() == "Incubator" then
			index = 2
		end
		room:broadcastSkillInvoke("MdkDuWu", index) --播放配音
		room:notifySkillInvoked(source, "MdkDuWu") --显示技能发动
		room:doSuperLightbox("DevilHomura", "MdkDuWu") --播放全屏特效
		source:loseMark("@MdkDuWuMark", 1)
		room:drawCards(source, 3, "MdkDuWu")
		local card = self:subcardsLength() > 0 and self or nil
		local success = source:pindian(target, "MdkDuWu", card)
		if success then
			local skills = target:getVisibleSkillList()
			local names = {}
			for _,skill in sgs.qlist(skills) do
				if skill:inherits("SPConvertSkill") then
				elseif skill:isAttachedLordSkill() then
				else
					table.insert(names, "-"..skill:objectName())
				end
			end
			if #names > 0 then
				names = table.concat(names, "|")
				room:handleAcquireDetachSkills(target, names)
			end
			room:handleAcquireDetachSkills(target, "benghuai")
		end
	end,
}
DuWuVS = sgs.CreateViewAsSkill{
	name = "MdkDuWu",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local card = DuWuCard:clone()
		if #cards == 1 then
			card:addSubcard(cards[1])
		end
		return card
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:getMark("@MdkDuWuMark") == 0 then
			return false
		end
		local others = player:getAliveSiblings()
		for _,p in sgs.qlist(others) do
			if p:getHandcardNum() > math.max(0, p:getHp()) then
				return true
			end
		end
		return false
	end,
}
DuWu = sgs.CreateTriggerSkill{
	name = "MdkDuWu",
	frequency = sgs.Skill_Limited,
	events = {},
	view_as_skill = DuWuVS,
	limit_mark = "@MdkDuWuMark",
	on_trigger = function(self, event, player, data)
		return false
	end,
}
--添加技能
HomuraEX:addSkill(DuWu)
--翻译信息
sgs.LoadTranslationTable{
	["MdkDuWu"] = "独舞",
	[":MdkDuWu"] = "限定技。出牌阶段，你可以摸三张牌，与一名手牌数多于体力的其他角色拼点。若你赢，该角色失去所有技能并获得技能“崩坏”。",
	["$MdkDuWu1"] = "这份感情是只属于我的，只为了小圆的东西",
	["$MdkDuWu2"] = "你要好好协助哦，孵化者~",
	["@MdkDuWuMark"] = "独舞",
	["mdkduwu"] = "独舞",
}
if LinkSkillSwitch then
--[[
	技能：执念（联动技->神·鹿目圆）
	描述：神·鹿目圆令你回复体力时，你可以获得其一张牌，令其变身为鹿目圆并执行一次“轮回”的效果。然后本局游戏中你可以额外发动一次“独舞”。
]]--
ZhiNian = sgs.CreateTriggerSkill{
	name = "MdkZhiNian&",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.HpRecover},
	on_trigger = function(self, event, player, data)
		local recover = data:toRecover()
		local source = recover.who
		if source and source:isAlive() then
			if source:getGeneralName() == "GodMadoka" or source:getGeneral2Name() == "GodMadoka" then
				if source:isNude() then
					return false
				end
				local ai_data = sgs.QVariant()
				ai_data:setValue(source)
				if player:askForSkillInvoke("MdkZhiNian", ai_data) then
					local room = player:getRoom()
					room:broadcastSkillInvoke("MdkZhiNian") --播放配音
					room:notifySkillInvoked(player, "MdkZhiNian") --显示技能发动
					room:doSuperLightbox("DevilHomura", "MdkZhiNian") --播放全屏特效
					local id = room:askForCardChosen(player, source, "he", "MdkZhiNian")
					if id >= 0 then
						room:obtainCard(player, id, false)
					end
					local isSecondaryHero = false
					if source:getGeneralName() ~= "GodMadoka" and source:getGeneral2Name() == "GodMadoka" then
						isSecondaryHero = true
					end
					local to_keep, to_remove = getLinkSkills(room, source, "GodMadoka", "KanameMadoka")
					room:changeHero(source, "KanameMadoka", true, true, isSecondaryHero, true)
					addLinkSkills(room, source, to_keep, to_remove)
					doLunHui(room, player, source)
					if player:isAlive() then
						player:gainMark("@MdkDuWuMark", 1)
					end
				end
			end
		end
		return false
	end,
}
--添加技能
HomuraEX:addSkill(ZhiNian)
--翻译信息
sgs.LoadTranslationTable{
	["MdkZhiNian"] = "执念",
	[":MdkZhiNian"] = "<font color=\"cyan\"><b>联动技。</b></font>神·鹿目圆令你回复体力时，你可以获得其一张牌，令其变身为鹿目圆并执行一次“轮回”的效果。然后本局游戏中你可以额外发动一次“独舞”。",
	["$MdkZhiNian"] = "终于……捉到你了！",
}
end