--[[
	太阳神三国杀武将扩展包·魔法少女小圆（AI部分）
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
--[[****************************************************************
	编号：MDK - 01
	武将：鹿目圆（Kaname Madoka）
	称号：保健委员
	性别：女
	势力：蜀
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：花弓（锁定技）
	描述：出牌阶段，若你没有装备武器，你视为装备有【麒麟弓】。
]]--
--[[
	技能：善心
	描述：你攻击范围内的一名其他角色即将受到不少于其体力的伤害时，若伤害来源不为你，你可以弃一张牌并失去1点体力，防止此伤害。
]]--
--room:askForCard(source, "..", prompt, data, "MdkShanXin")
sgs.ai_skill_cardask["@MdkShanXin"] = function(self, data, pattern, target, target2, arg, arg2)
	local care_lord = false
	if self.role == "renegade" and target:isLord() then
		care_lord = ( self.room:alivePlayerCount() > 2 )
	end
	local is_friend = self:isFriend(target)
	if care_lord or is_friend then
		local n_damage = tonumber(arg)
		local hp = target:getHp()
		local n_peaches = self:getAllPeachNum()
		local is_safe = ( hp + n_peaches > n_damage )
		if care_lord and is_safe and not is_friend then
			return "."
		end
		if is_safe and n_damage <= 1 then
			return "."
		end
		local my_hp = self.player:getHp()
		local am_safe = ( my_hp + n_peaches > 1 )
		if is_safe and not am_safe then
			return "."
		end
		local to_discard = self:askForDiscard("dummy", 1, 1, false, true)
		if #to_discard == 1 then
			return to_discard[1]
		end
	end
	return "."
end
--相关信息
sgs.ai_choicemade_filter["cardResponded"]["@MdkShanXin"] = function(self, player, promptlist)
	--"cardResponded:..:@MdkShanXin:sgs2::5::_135_"
	--"cardResponded:..:@MdkShanXin:sgs2::3::_nil_"
	local target_name = promptlist[4]
	local target = findPlayerByObjectName(self.room, target_name, false, player)
	if target then
		local discard_str = promptlist[8]
		if discard_str ~= "_nil_" then
			sgs.updateIntention(player, target, -80)
		end
	end
end
--[[
	技能：因果
	描述：你每脱离一次濒死状态或发动一次“善心”，你获得一枚“因”标记；出牌阶段限X次，你可以将一张黑色手牌当作【无中生有】使用。（X为你拥有的“因”标记的数量）
]]--
--YinGuoVS:Play
local yinguo_skill = {
	name = "MdkYinGuo",
	getTurnUseCard = function(self, inclusive)
		if self.player:isKongcheng() then
			return nil
		elseif self.player:getMark("MdkYinGuoRecord") < self.player:getMark("@MdkYinGuoMark") then
			local handcards = self.player:getHandcards()
			local blacks = {}
			for _,c in sgs.qlist(handcards) do
				if c:isBlack() then
					table.insert(blacks, c)
				end
			end
			if #blacks == 0 then
				return nil
			end
			self:sortByKeepValue(blacks)
			local black = blacks[1]
			local card_str = string.format(
				"ex_nihilo:MdkYinGuoEffect[%s:%d]=%d", 
				black:getSuitString(), 
				black:getNumber(), 
				black:getEffectiveId()
			)
			return sgs.Card_Parse(card_str)
		end
	end,
}
table.insert(sgs.ai_skills, yinguo_skill)
--相关信息
sgs.ai_cardneed["MdkYinGuo"] = function(friend, hcard, self)
	if friend:getMark("@MdkYinGuoMark") > 0 then
		return hcard:isBlack()
	end
	return false
end
--[[
	技能：许愿（联动技->晓美焰）
	描述：晓美焰濒死时，若其不满足“轮回”的发动条件，你可以变身为神·鹿目圆，令其执行“轮回”的效果，然后立即结束当前回合。
]]--
--source:askForSkillInvoke("MdkXuYuan", data)
sgs.ai_skill_invoke["MdkXuYuan"] = function(self, data)
	local dying = data:toDying()
	local target = dying.who
	if target and self:isFriend(target) then
		if self:getAllPeachNum(target) + target:getHp() > 0 then
			return false
		end
		return true
	end
	return false
end
--[[****************************************************************
	编号：MDK - 02
	武将：晓美焰（Akemi Homura）
	称号：神秘的转校生
	性别：女
	势力：魏
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：军火
	描述：分发起始手牌时，额外发你四张牌，然后你选择四张牌置于你的武将牌上，称为“军火”。
]]--
--room:askForExchange(player, "MdkJunHuo", 4, 4, false, prompt)
sgs.ai_skill_discard["MdkJunHuo"] = sgs.ai_skill_discard["qixing"]
--[[
	技能：时停（阶段技）
	描述：若你的武将牌没有被横置，你可以交换你的手牌区和“军火”，然后本阶段内你获得技能“布局”。
]]--
--ShiTingCard:Play
local shiting_skill = {
	name = "MdkShiTing",
	getTurnUseCard = function(self, inclusive)
		if self.player:isChained() then
			return nil
		elseif self.player:hasUsed("#MdkShiTingCard") then
			return nil
		elseif self.player:isKongcheng() and self.player:getPile("MdkJunHuoPile"):isEmpty() then
			return nil
		end
		if inclusive then
			return sgs.Card_Parse("#MdkShiTingCard:.:")
		end
		local handcards = self.player:getHandcards()
		for _,c in sgs.qlist(handcards) do
			if c:isKindOf("Jink") or c:isKindOf("Nullification") then
			else
				local dummy_use = {
					isDummy = true,
				}
				self:useCardByClassName(c, dummy_use)
				if dummy_use.card then
					return nil
				end
			end
		end
		return sgs.Card_Parse("#MdkShiTingCard:.:")
	end,
}
table.insert(sgs.ai_skills, shiting_skill)
sgs.ai_skill_use_func["#MdkShiTingCard"] = function(card, use, self)
	local pile = self.player:getPile("MdkJunHuoPile")
	local n_pile = pile:length()
	local overflow = nil
	if n_pile == 0 then
		overflow = self:getOverflow()
		if overflow <= 0 then
			if self:needKongcheng() then
				use.card = card
			end
			return 
		end
	end
	overflow = overflow or self:getOverflow()
	if overflow > 0 then
		if self.player:getHandcardNum() > n_pile then
			use.card = card
			return 
		end
	end
	local all_cards = {}
	for _,id in sgs.qlist(pile) do
		local c = sgs.Sanguosha:getCard(id)
		table.insert(all_cards, c)
		if c:isKindOf("Jink") or c:isKindOf("Nullification") then
		else
			local dummy_use = {
				isDummy = true,
			}
			self:useCardByClassName(c, dummy_use)
			if dummy_use.card then
				use.card = card
				return 
			end
		end
	end
	if self.player:getLostHp() > 0 and self:isWeak() then
		for _,c in ipairs(all_cards) do
			if isCard("Peach", c, self.player) then
				use.card = card
				return 
			end
		end
	end
	if #self.friends_noself > 0 then
		local group_must_use = {}
		local group_good_use = {}
		local group_bad_use = {}
		local group_no_use = {}
		for _,c in ipairs(all_cards) do
			if self.player:isCardLimited(c, sgs.Card_MethodUse) then
				table.insert(group_no_use, c)
			elseif c:isKindOf("GlobalEffect") or c:isKindOf("AOE") or c:isKindOf("Analeptic") then
				table.insert(group_must_use, c)
			elseif c:isKindOf("EquipCard") then
				if c:isKindOf("GaleShell") then
					table.insert(group_bad_use, c)
				else
					table.insert(group_good_use, c)
				end
			elseif c:isKindOf("ExNihilo") or c:isKindOf("Peach") then
				table.insert(group_good_use, c)
			elseif c:isKindOf("Jink") or c:isKindOf("Nullification") or c:isKindOf("Collateral") then
				table.insert(group_no_use, c)
			else
				table.insert(group_bad_use, c)
			end
		end
		if #group_good_use > 0 then
			local c, p = self:getCardNeedPlayer(group_good_use, false)
			if c and p then
				use.card = card
				return 
			end
		end
		if #group_no_use > 0 then
			local c, p = self:getCardNeedPlayer(group_no_use, false)
			if c and p then
				use.card = card
				return 
			end
		end
		if #group_bad_use > 0 then
			local c, p = self:getCardNeedPlayer(group_bad_use, false)
			if c and p then
				local safe = true
				if self.player:isProhibited(p, c) then
				elseif self.player:isCardLimited(c, sgs.Card_MethodUse) then
				elseif c:isKindOf("FireAttack") and p:isKongcheng() then
				elseif c:isKindOf("Dismantlement") and not self.player:canDiscard(p, "hej") then
				else
					safe = false
				end
				if safe then
					use.card = card
					return
				end
			end
		end
	end
end
--相关信息
sgs.ai_use_value["MdkShiTingCard"] = 2.7
sgs.ai_use_priority["MdkShiTingCard"] = 0.4
--[[
	技能：布局
	描述：出牌阶段，你可以将至少一张手牌置于一名角色的武将牌上，称为“局”；你失去本技能时，弃置场上所有的“局”，视为你对该角色依次使用了这些牌。若无法使用，改为由目标角色获得之。
]]--
--BuJuCard:Play
local buju_skill = {
	name = "MdkBuJu",
	getTurnUseCard = function(self, inclusive)
		if self.player:isKongcheng() then
			return nil
		end
		return sgs.Card_Parse("#MdkBuJuCard:.:")
	end,
}
table.insert(sgs.ai_skills, buju_skill)
sgs.ai_skill_use_func["#MdkBuJuCard"] = function(card, use, self)
	local handcards = self.player:getHandcards()
	for _,c in sgs.qlist(handcards) do
		if c:isKindOf("Jink") or c:isKindOf("Nullification") then
		elseif self.player:isCardLimited(c, sgs.Card_MethodUse, true) then
		elseif c:isAvailable(self.player) then
			local dummy_use = {
				isDummy = true,
			}
			self:useCardByClassName(c, dummy_use)
			if dummy_use.card then
				return 
			end
		end
	end
	local group_must_use = {}
	local group_good_use = {}
	local group_bad_use = {}
	local group_no_use = {}
	for _,c in sgs.qlist(handcards) do
		if self.player:isCardLimited(c, sgs.Card_MethodUse) then
			table.insert(group_no_use, c)
		elseif c:isKindOf("Jink") or c:isKindOf("Nullification") or c:isKindOf("Collateral") then
			table.insert(group_no_use, c)
		elseif c:isKindOf("GlobalEffect") or c:isKindOf("AOE") or c:isKindOf("Analeptic") then
			table.insert(group_must_use, c)
		elseif c:isKindOf("ExNihilo") or c:isKindOf("Peach") then
			table.insert(group_good_use, c)
		elseif c:isKindOf("EquipCard") then
			if c:isKindOf("GaleShell") then
				table.insert(group_bad_use, c)
			else
				table.insert(group_good_use, c)
			end
		else
			table.insert(group_bad_use, c)
		end
	end
	if #group_no_use > 0 then
		local c, p = self:getCardNeedPlayer(group_no_use, true)
		if c and p then
			local card_str = string.format("#MdkBuJuCard:%d:->%s", c:getEffectiveId(), p:objectName())
			local acard = sgs.Card_Parse(card_str)
			assert(acard)
			use.card = acard
			if use.to then
				use.to:append(p)
			end
			return 
		end
	end
	if #group_good_use > 0 then
		local c, p = self:getCardNeedPlayer(group_good_use, true)
		if c and p then
			local card_str = string.format("#MdkBuJuCard:%d:->%s", c:getEffectiveId(), p:objectName())
			local acard = sgs.Card_Parse(card_str)
			assert(acard)
			use.card = acard
			if use.to then
				use.to:append(p)
			end
			return 
		end
	end
	if #group_bad_use > 0 then
		self:sortByUseValue(group_bad_use, true)
		local system_getDistanceLimit = SmartAI.getDistanceLimit
		local system_slashIsAvailable = SmartAI.slashIsAvailable
		SmartAI.getDistanceLimit = function(self, _card, _from)
			return 9999
		end
		SmartAI.slashIsAvailable = function(self, _player, _slash)
			return true
		end
		local target = nil
		local to_use = nil
		local gale_shell = nil
		for _,c in ipairs(group_bad_use) do
			local dummy_use = {
				isDummy = true,
				to = sgs.SPlayerList(),
			}
			self:useCardByClassName(c, dummy_use)
			if dummy_use.card and dummy_use.card:objectName() == c:objectName() then
				if not dummy_use.to:isEmpty() then
					target = dummy_use.to:first()
					to_use = c
					break
				end
			end
			if c:isKindOf("GaleShell") and not gale_shell then
				gale_shell = c
			end
		end
		SmartAI.getDistanceLimit = system_getDistanceLimit
		SmartAI.slashIsAvailable = system_slashIsAvailable
		if target and to_use then
			local card_str = string.format("#MdkBuJuCard:%d:->%s", to_use:getEffectiveId(), target:objectName())
			local acard = sgs.Card_Parse(card_str)
			assert(acard)
			use.card = acard
			if use.to then
				use.to:append(target)
			end
			return 
		end
		if gale_shell then
			local targets = {}
			for _,enemy in ipairs(self.enemies) do
				if self:hasSkills("bazhen|yizhong|bossmanjia", enemy) then
					table.insert(targets, enemy)
				elseif enemy:getArmor() then
					table.insert(targets, enemy)
				end
			end
			if #targets == 0 then
				return 
			end
			self:sort(targets, "defense")
			local target = nil
			local target2 = nil
			local target3 = nil
			for _,enemy in ipairs(targets) do
				if self:hasSkills(sgs.lose_equip_skill, enemy) then
					if not target3 then
						target3 = enemy
					end
				elseif enemy:hasArmorEffect("silver_lion") and enemy:getLostHp() > 0 then
					if not target2 then
						target2 = enemy
					end
				else
					target = enemy
					break
				end
			end
			if target then
			elseif self:getOverflow() > 0 then
				target = target2 or target3
			end
			if target then
				local card_str = string.format("#MdkBuJuCard:%d:->%s", gale_shell:getEffectiveId(), target:objectName())
				local acard = sgs.Card_Parse(card_str)
				assert(acard)
				use.card = acard
				if use.to then
					use.to:append(target)
				end
			end
		end
	end
	if #group_must_use > 0 then
		self:sortByUseValue(group_must_use)
		local friends_to_draw = nil
		local friends_to_recover, no_need_friends = nil, nil
		for _,c in ipairs(group_must_use) do
			if c:isKindOf("Analeptic") then
			elseif c:isKindOf("AOE") then
				local max_v, max_p = 0, nil
				if #self.enemies > 0 then
					for _,enemy in ipairs(self.enemies) do
						local v = - self:getAoeValueTo(c, enemy, self.player)
						if v > max_v then
							max_v = v
							max_p = enemy
						end
					end
				end
				if max_v == 0 and #self.friends > 0 then
					for _,friend in ipairs(self.friends) do
						local v = self:getAoeValueTo(c, friend, self.player)
						if v > max_v then
							max_v = v
							max_p = friend
						end
					end
				end
				if max_v > 0 and max_p then
					local card_str = string.format("#MdkBuJuCard:%d:->%s", c:getEffectiveId(), max_p:objectName())
					local acard = sgs.Card_Parse(card_str)
					assert(acard)
					use.card = acard
					if use.to then
						use.to:append(max_p)
					end
					return 
				end
			elseif c:isKindOf("GlobalEffect") then
				if c:isKindOf("GodSalvation") then
					friends_to_recover, no_need_friends = self:getWoundedFriend(false, true)
					if friends_to_recover and #friends_to_recover > 0 then
						for _,p in ipairs(friends_to_recover) do
							if self:hasTrickEffective(c, p, self.player) then
								local card_str = string.format("#MdkBuJuCard:%d:->%s", c:getEffectiveId(), p:objectName())
								local acard = sgs.Card_Parse(card_str)
								assert(acard)
								use.card = acard
								if use.to then
									use.to:append(p)
								end
								return 
							end
						end
					end
				elseif c:isKindOf("AmazingGrace") then
					friends_to_draw = friends_to_draw or self:findPlayerToDraw(true, 1, true)
					if friends_to_draw and #friends_to_draw > 0 then
						for _,p in ipairs(friends_to_draw) do
							if self.player:isProhibited(p, c) or self:hasTrickEffective(c, p, self.player) then
								local card_str = string.format("#MdkBuJuCard:%d:->%s", c:getEffectiveId(), p:objectName())
								local acard = sgs.Card_Parse(card_str)
								assert(acard)
								use.card = acard
								if use.to then
									use.to:append(p)
								end
								return 
							end
						end
					end
				end
			end
		end
	end
end
--相关信息
sgs.ai_use_value["MdkBuJuCard"] = 1.5
sgs.ai_use_priority["MdkBuJuCard"] = 1.2
--[[
	技能：轮回
	描述：你或你攻击范围内的一名角色即将进入濒死时，若你的武将牌没有被横置，你可以弃X张牌，交换你的手牌区和“军火”，令其将武将牌和体力牌重置为游戏开始时的状态，然后其弃置区域中的所有牌并摸四张牌。（X为你已发动过“轮回”的次数）
]]--
--room:askForUseCard(source, "@@MdkLunHui", prompt)
sgs.ai_skill_use["@@MdkLunHui"] = function(self, prompt, method)
	local parts = prompt:split(":")
	local x = tonumber(parts[4])
	if x > self.player:getCardCount() then
		return "."
	end
	local target = nil
	local may_save = false
	if parts[1] == "@MdkLunHui-myself" then
		target = self.player
		may_save = true
	else
		local alives = self.room:getAlivePlayers()
		for _,p in sgs.qlist(alives) do
			if p:objectName() == parts[2] then
				target = p
				break
			end
		end
		if target then
			if self:isFriend(target) then
				may_save = true
			elseif self.role == "renegade" and target:isLord() then
				if self.room:alivePlayerCount() > 2 then
					may_save = true
				end
			end
		end
	end
	if not may_save then
		return "."
	elseif self:getAllPeachNum() >= 1 - target:getHp() then
		return "."
	end
	if x == 0 then
		return "#MdkLunHuiCard:.:->."
	end
	local to_discard = self:askForDiscard("dummy", x, x, false, true)
	if #to_discard == x then
		local card_str = table.concat(to_discard, "+")
		local use_str = string.format("#MdkLunHuiCard:%s:->.", card_str)
		return use_str
	end
	return "."
end
--相关信息
sgs.ai_choicemade_filter["cardUsed"].MdkLunHui = function(self, player, use)
	local card = use.card
	if card and card:objectName() == "MdkLunHuiCard" then
		local target = self.room:getCurrentDyingPlayer()
		if target and target:objectName() ~= player:objectName() then
			sgs.updateIntention(player, target, -200)
		end
	end
end
--[[
	技能：羁绊（联动技->鹿目圆、锁定技）
	描述：其他角色计算的与鹿目圆的距离+1。
]]--
--[[
	技能：诅咒（联动技->神·鹿目圆）
	描述：神·鹿目圆被指定为黑色锦囊牌的目标时，若使用者不为你，你可以取消之，然后你受到1点伤害。若如此做，你在下次发动“轮回”后获得所有“军火”并变身为魔·晓美焰。
	说明：“诅咒”发动后，只要再发动“轮回”，不论目标是谁，晓美焰都将变身为魔·晓美焰。
]]--
--source:askForSkillInvoke("MdkZuZhou", sgs.QVariant(prompt))
--source:askForSkillInvoke("MdkZuZhou", sgs.QVariant(prompt))
sgs.ai_skill_invoke["MdkZuZhou"] = function(self, data)
	--invoke:target::trick:
	local prompt = data:toString()
	local parts = prompt:split(":")
	local target_name, trick_name = parts[2], parts[4]
	local target = nil
	local alives = self.room:getAlivePlayers()
	for _,p in sgs.qlist(alives) do
		if p:objectName() == target_name then
			target = p
			break
		end
	end
	if target and self:isFriend(target) then
		local trick = self.room:getTag("MdkZuZhouTrick"):toCard()
		if trick and trick:objectName() == trick_name then
			local user = self.room:getTag("MdkZuZhouUser"):toPlayer()
			if user and user:isAlive() then
				user = findPlayerByObjectName(self.room, user:objectName())
			else
				user = nil
			end
			if self:hasTrickEffective(trick, target, user) then
				if sgs.dynamic_value["benefit"][trick:getClassName()] then
					return false
				end
				if trick:isKindOf("DelayedTrick") then
					if target:containsTrick("YanxiaoCard") then
						return false
					end
				elseif trick:isKindOf("Snatch") then
					if target:isNude() then
						return false
					end
				elseif trick:isKindOf("Dismantlement") then
					if target:isNude() then
						return false
					elseif user and not user:canDiscard(target, "he") then
						return false
					end
				elseif trick:isKindOf("FireAttack") then
					if target:isKongcheng() then
						return false
					elseif user then
						if user:isKongcheng() then
							return false
						elseif not user:canDiscard(user, "h") then
							return false
						end
					end
				elseif trick:isKindOf("Collateral") then
					if not target:getWeapon() then
						return false
					end
				end
				local userIsFriend = false
				if user and self:isFriend(user, target) then
					userIsFriend = true
				end
				if userIsFriend and target:hasFlag("AIGlobal_NeedToWake") then
					return false
				end
				local effect = sgs.CardEffectStruct()
				effect.from = user
				effect.to = target
				effect.card = trick
				if trick:isCancelable(effect) then
					local friend_null_count = self:getCardsNum("Nullification")
					local enemy_null_count = 0
					for _,friend in ipairs(self.friends_noself) do
						friend_null_count = friend_null_count + getCardsNum("Nullification", friend, self.player)
					end
					for _,enemy in ipairs(self.enemies) do
						enemy_null_count = enemy_null_count + getCardsNum("Nullification", enemy, self.player)
					end
					if friend_null_count > enemy_null_count then
						return false
					end
				end
				local damage = 0
				local nature = sgs.DamageStruct_Normal
				if trick:isKindOf("FireAttack") then
					damage = 1
					nature = sgs.DamageStruct_Fire
				elseif trick:isKindOf("AOE") or trick:isKindOf("Duel") or trick:isKindOf("Drowning") then
					local can_avoid = false
					if trick:isKindOf("SavageAssault") then
						local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						slash:deleteLater()
						if target:isLocked(slash) then
						elseif self.player:objectName() == target:objectName() then
							if self:getCardsNum("Slash") > 0 then
								can_avoid = true
							end
						else
							if getCardsNum("Slash", target, self.player) > 0 then
								can_avoid = true
							end
						end
					elseif trick:isKindOf("ArcheryAttack") then
						local jink = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
						jink:deleteLater()
						if target:isLocked(jink) then
						elseif self.player:objectName() == target:objectName() then
							if self:getCardsNum("Jink") > 0 then
								can_avoid = true
							end
						else
							if getCardsNum("Jink", target, self.player) > 0 then
								can_avoid = true
							end
						end
					elseif trick:isKindOf("Duel") then
						if not userIsFriend then
							local slash_num = 0
							local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
							slash:deleteLater()
							if target:isLocked(slash) then
							elseif self.player:objectName() == target:objectName() then
								slash_num = self:getCardsNum("Slash")
							else
								slash_num = getCardsNum("Slash", target, self.player)
							end
							local user_slash_num = 0
							if user and not user:isLocked(slash) then
								user_slash_num = getCardsNum("Slash", user, self.player)
							end
							if slash_num > user_slash_num then
								can_avoid = true
							end
						end
					end
					if not can_avoid then
						damage = 1
					end
				elseif sgs.dynamic_value["damage_card"][trick:getClassName()] then
					damage = 1
				end
				local will_cause_death = false
				if damage > 0 then
					JinXuanDi = self.room:findPlayerBySkillName("wuling")
					if JinXuanDi then
						if nature == sgs.DamageStruct_Normal and JinXuanDi:getMark("@fire") > 0 then
							nature = sgs.DamageStruct_Fire
						elseif nature == sgs.DamageStruct_Fire and JinXuanDi:getMark("@wind") > 0 then
							damage = damage + 1
						end
					end
					if target:hasSkill("chouhai") and target:isKongcheng() then
						damage = damage + 1
					end
					if nature == sgs.DamageStruct_Fire then
						if target:hasArmorEffect("vine") or target:hasArmorEffect("gale_shell") then
							damage = damage + 1
						end
					elseif nature == sgs.DamageStruct_Normal and target:hasSkill("MdkWuTai") then
						damage = damage - 1
					end
					if damage > 1 then
						if target:hasArmorEffect("silver_lion") then
							damage = 1
						elseif JinXuanDi and JinXuanDi:getMark("@earth") > 0 and nature ~= sgs.DamageStruct_Normal then
							damage = 1
						elseif target:hasSkill("buqu") and target:getPile("buqu"):isEmpty() and target:getHp() == 1 then
							damage = 1
						end
					end
					if damage > 0 then
						if damage >= target:getHp() then
							if target:hasSkill("niepan") and target:getMark("@nirvana") > 0 then
							elseif target:hasSkill("fuli") and target:getMark("@laoji") > 0 then
							elseif target:hasSkill("buqu") and target:getPile("buqu"):isEmpty() then
							elseif self:needDeath(target) then
								return false
							elseif damage >= target:getHp() + self:getAllPeachNum(target) then
								will_cause_death = true
							end
						end
					end
				end
				if will_cause_death then
					return true
				elseif damage > 0 then
					if getBestHp(target) > target:getHp() then
						return false
					elseif self:getDamagedEffects(target, user, false) then
						return false
					end
				elseif userIsFriend then
					return false
				else
					if trick:isKindOf("Dismantlement") or trick:isKindOf("Snatch") then
						if self:getDangerousCard(target) then
							return true
						elseif self:getValuableCard(target) then
							return true
						end
					elseif trick:isKindOf("Collateral") then
						local weapon = target:getWeapon()
						if weapon and self:isValuableCard(weapon, target) then
							return true
						end
					end
				end
				if getBestHp(self.player) > self.player:getHp() then
					return true
				end
				local skills = self.player:getVisibleSkillList()
				for _,skill in sgs.qlist(skills) do
					local callback = sgs.ai_need_damaged[skill:objectName()]
					if type(callback) == "function" then
						if callback(self, nil, self.player) then
							return true
						end
					end
				end
				if self:isWeak() and self:getAllPeachNum() == 0 then
					return true
				end
			end
		end
	end
	return false
end
--[[****************************************************************
	编号：MDK - 03
	武将：美树沙耶香（Miki Sayaka）
	称号：守护的心意
	性别：女
	势力：魏
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：剑术（锁定技）
	描述：出牌阶段，你对距离为1的角色使用【杀】造成的伤害+1；且若你装备有剑类武器，你可以额外使用一张【杀】。
	说明：剑类武器，包括“雌雄双股剑”、“青釭剑”、“寒冰剑”、“倚天剑”、“杨修剑”共五种。
]]--
sgs.ai_cardneed["MdkJianShu"] = function(friend, hcard, self)
	if hcard:isKindOf("Slash") then
		return true
	elseif hcard:isKindOf("Weapon") and string.find(hcard:objectName(), "sword") then
		return true
	elseif hcard:isKindOf("OffensiveHorse") then
		return true
	end
	return false
end
local system_hasHeavySlashDamage = SmartAI.hasHeavySlashDamage
function SmartAI:hasHeavySlashDamage(from, slash, to, getValue)
	to = to or self.player
	local damage = system_hasHeavySlashDamage(self, from, slash, to, true)
	if from and from:hasSkill("MdkJianShu") and from:distanceTo(to) == 1 then
		local extra = true
		if damage <= 1 then
			if from:hasSkill("jueqing") then
				extra = false
			elseif to:hasArmorEffect("silver_lion") and not IgnoreArmor(from, to) then
				extra = false
			else
				local JinXuanDi = self.room:findPlayerBySkillName("wuling")
				if JinXuanDi and JinXuanDi:getMark("@earth") then
					if slash and slash:isKindOf("NatureSlash") then
						extra = false
					elseif not slash or slash:objectName() == "slash" then
						if from:hasWeapon("fan") then
							extra = false
						elseif from:hasSkill("lihuo") and not self:isWeak(from) then
							extra = false
						end
					end
				end
			end
		end
		if extra then
			damage = damage + 1
		end
	end
	if getValue then
		return damage
	end
	return damage > 1
end
--[[
	技能：治愈
	描述：一名角色的回合结束时，若其已受伤，你可以交给其一张红心牌，令其回复1点体力。
]]--
--room:askForCard(source, pattern, prompt, data, sgs.Card_MethodNone, nil, false, "MdkZhiYu", false)
sgs.ai_skill_cardask["@MdkZhiYu-myself"] = function(self, data, pattern, target, target2, arg, arg2)
	if getBestHp(self.player) <= self.player:getHp() and not self:isWeak() then
		return "."
	end
	local equip, dhorse, handcard = nil, nil, nil
	local equips = self.player:getEquips()
	for _,e in sgs.qlist(equips) do
		if e:isKindOf("DefensiveHorse") then
		elseif e:getSuit() == sgs.Card_Heart then
			equip = e
		end
	end
	dhorse = self.player:getDefensiveHorse()
	if dhorse and dhorse:getSuit() ~= sgs.Card_Heart then
		dhorse = nil
	end
	local to_show = equip or dhorse
	if to_show then
		if self:hasSkill(sgs.lose_equip_skill) then
			return "$"..to_show:getEffectiveId()
		end
	end
	local handcards = self.player:getHandcards()
	for _,c in sgs.qlist(handcards) do
		if c:getSuit() == sgs.Card_Heart then
			handcard = c
			break
		end
	end
	to_show = handcard or to_show
	if to_show then
		return "$"..to_show:getEffectiveId()
	end
	return "."
end
sgs.ai_skill_cardask["@MdkZhiYu"] = function(self, data, pattern, target, target2, arg, arg2)
	if target and self:isFriend(target) then
		if getBestHp(target) <= target:getHp() then
			return "."
		end
		local cards = self.player:getCards("he")
		local hearts = {}
		for _,c in sgs.qlist(cards) do
			if c:getSuit() == sgs.Card_Heart then
				table.insert(hearts, c)
			end
		end
		if #hearts == 0 then
			return "."
		end
		self:sortByKeepValue(hearts)
		local to_give = hearts[1]
		if self:isWeak() then
			to_give = nil
			for _,c in ipairs(hearts) do
				if not isCard("Peach", c, self.player) then
					to_give = c
					break
				end
			end
			if not to_give then
				for _,c in ipairs(hearts) do
					if isCard("Peach", c, target) then
						to_give = c
						break
					end
				end
			end
		end
		if to_give then
			return "$"..to_give:getEffectiveId()
		end
	end
	return "."
end
--相关信息
sgs.ai_cardneed["MdkZhiYu"] = function(friend, hcard, self)
	return hcard:getSuit() == sgs.Card_Heart
end
sgs.MdkZhiYu_suit_value = {
	heart = 4.2,
}
sgs.ai_choicemade_filter["cardResponded"]["@MdkZhiYu"] = function(self, player, promptlist)
	--"cardResponded:..:@MdkZhiYu:sgs2::_135_"
	local target_name = promptlist[4]
	local target = findPlayerByObjectName(self.room, target_name, false, player)
	if target then
		local discard_str = promptlist[#promptlist]
		if discard_str ~= "_nil_" then
			sgs.updateIntention(player, target, -80)
		end
	end
end
--[[
	技能：黑化（限定技）
	描述：当你濒死时，你可以放弃求桃，失去技能“剑术”、“治愈”和“黑化”，回复体力至1点，然后变更为一个对立的身份并获得技能“人鱼”。
	说明：变更身份时，若有多个对立的身份，随机变为其中之一；身份局中，若原身份为主公，则变更身份后游戏立即结束，主忠方失败。
]]--
--player:askForSkillInvoke("MdkHeiHua", data)
sgs.ai_skill_invoke["MdkHeiHua"] = function(self, data)
	local need_to_recover = 1 - self.player:getHp()
	local can_use_peach = true
	if self.player:hasFlag("Global_PreventPeach") then
		can_use_peach = false
	else
		local peach = sgs.Sanguosha:cloneCard("peach", sgs.Card_NoSuit, 0)
		peach:deleteLater()
		if self.player:isCardLimited(peach, sgs.Card_MethodUse) then
			can_use_peach = false
		end
	end
	local can_use_analeptic = true
	local analeptic = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
	analeptic:deleteLater()
	if self.player:isCardLimited(analeptic, sgs.Card_MethodUse) then
		can_use_analeptic = false
	end
	local n_peach = can_use_peach and self:getAllPeachNum() or 0
	local n_analeptic = can_use_analeptic and self:getCardsNum("Analeptic") or 0
	local distance = need_to_recover - n_peach - n_analeptic
	if distance <= 0 then
		return false
	end
	if self.player:hasSkill("niepan") and self.player:getMark("@nirvana") > 0 then
		return false
	elseif self.player:hasSkill("fuli") and self.player:getMark("@laoji") > 0 then
		return false
	end
	for _,friend in ipairs(self.friends) do
		if friend:hasSkill("MdkLunHui") and not friend:isChained() then
			if friend:canDiscard(friend, "he") and friend:getMark("@MdkLunHuiMark") <= friend:getCardCount() then
				if friend:objectName() == self.player:objectName() then
					return false
				elseif friend:inMyAttackRange(self.player) then
					return false
				end
			end
		end
	end
	local can_recover = 0
	if not self.player:isKongcheng() then
		for _,friend in ipairs(self.friends) do
			if friend:hasSkill("buyi") then
				local handcards = self.player:getHandcards()
				local no_basic = true
				for _,c in sgs.qlist(handcards) do
					if c:isKindOf("BasicCard") then
						no_basic = false
						break
					end
				end
				if no_basic then
					can_recover = can_recover + 1
					if can_recover >= distance then
						return false
					end
				end
				break
			end
		end
	end
	for _,friend in ipairs(self.friends) do
		if friend:hasSkill("MdkZhiYin") and friend:canDiscard(friend, "he") then
			if self:getSuitNum("red", true, friend) > 0 then
				can_recover = can_recover + 1
				if can_recover >= distance then
					return false
				end
			end
		end
	end
	if can_use_analeptic then
		for _,friend in ipairs(self.friends) do
			if friend:hasSkill("chunlao") and not friend:getPile("wine"):isEmpty() then
				can_recover = can_recover + 1
				if can_recover >= distance then
					return false
				end
				break
			end
		end
	end
	local current = self.room:getCurrent()
	if can_use_peach and current and self:isFriend(current) then
		for _,friend in ipairs(self.friends) do
			if friend:hasSkill("nosjiefan") and friend:canSlash(current, false) then
				if friend:objectName() == self.player:objectName() then
					can_recover = can_recover + self:getCardsNum("Slash", true, true)
				else
					can_recover = can_recover + getCardsNum("Slash", friend, self.player)
				end
				if can_recover >= distance then
					return false
				end
			end
		end
	end
	for _,friend in ipairs(self.friends_noself) do
		if friend:hasSkill("nosrenxin") and not friend:isKongcheng() then
			can_recover = can_recover + 1
			if can_recover >= distance then
				return false
			end
		end
	end
	if can_use_analeptic and self.player:hasLordSkill("weidai") then
		for _,friend in ipairs(self.friends_noself) do
			if friend:canDiscard(friend, "h") and self:getSuitNum("spade", false, friend) > 0 then
				can_recover = can_recover + 1
				if can_recover >= distance then
					return false
				end
			end
		end
	end
	if self.role == "renegade" then
		return true
	end
	local process = sgs.gameProcess(self.room)
	if self.role == "loyalist" then
		if process == "rebel" then
			return true
		end
	elseif self.role == "rebel" then
		if string.find("loyalist|loyalish", process) then
			return true
		end
	elseif self.role == "lord" then
		if process == "rebel" and sgs.current_mode_players["loyalist"] == 0 then
			return true
		end
	end
	return false
end
--相关信息
sgs.ai_choicemade_filter["skillInvoke"].MdkHeiHua = function(self, player, promptlist)
	if promptlist[#promptlist] == "yes" then
		--Nothing To Do.
	end
end
sgs.ai_choicemade_filter["MdkHeiHua"] = {
	["Result"] = function(self, player, promptlist)
		local role = promptlist[#promptlist]
		sgs.role_evaluation[player:objectName()] = {lord = 0, rebel = 0, loyalist = 0, renegade = 0}
		sgs.role_evaluation[player:objectName()][role] = 99999
		sgs.ai_role[player:objectName()] = player:getRole()
		self:updatePlayers(true, true)
		for _, p in sgs.qlist(self.room:getAlivePlayers()) do
			sgs.ais[p:objectName()]:updatePlayers(true, p:isLord())
		end
		sgs.outputRoleValues(player, 0)
	end,
}
--[[
	技能：人鱼（锁定技）
	描述：你跳过摸牌和弃牌阶段；你攻击范围外的其他角色不能成为你使用的牌的目标；其他角色即将对你造成伤害时，你获得其两张牌并对其造成X点伤害（X为你已损失的体力）。
]]--
--room:askForCardChosen(player, source, "he", "MdkRenYu")
--相关信息
sgs.ai_need_damaged["MdkRenYu"] = function(self, from, to)
	return from:objectName() ~= to:objectName()
end
local System_getOverflow = SmartAI.getOverflow
function SmartAI:getOverflow(player, getMaxCards)
	player = player or self.player
	if player:hasSkill("MdkRenYu") then
		return getMaxCards and player:getHandcardNum() or 0
	end
	return System_getOverflow(self, player, getMaxCards)
end
--[[
	技能：陪伴（联动技->上条恭介、锁定技）
	描述：上条恭介的手牌上限+X（X为其已损失的体力）。
]]--
--[[
	技能：牵挂（联动技->佐仓杏子、锁定技）
	描述：佐仓杏子的攻击范围+1，同时你计算的与其他角色的距离-1。
]]--
--[[
	技能：救赎（联动技->神·鹿目圆、锁定技）
	描述：神·鹿目圆的出牌阶段开始时，你失去已有的技能“黑化”和“人鱼”，然后重新获得已失去的技能“剑术”和“治愈”。
]]--
--[[
	技能：神使（联动技->神·鹿目圆）
	描述：你从神·鹿目圆处获得牌时，你获得一枚“令”标记。你的手牌上限+X（X为你的“令”标记的数量）。神·鹿目圆或你攻击范围内的一名其他角色的回合开始时，你可以弃一枚“令”标记，令该角色摸两张牌。
]]--
--room:askForUseCard(source, "@@MdkShenShi", prompt)
sgs.ai_skill_use["@@MdkShenShi"] = function(self, prompt, method)
	local target = self.room:getCurrent()
	if target and self:isFriend(target) then
		local overflow = self:getOverflow(target)
		local skip_play_phase = self:willSkipPlayPhase(target)
		if skip_play_phase and overflow > -2 then
			return "."
		end
		if overflow > 2 then
			return "."
		end
		if self:isWeak(target) then
			return "#MdkShenShiCard:.:->."
		end
		if #self.enemies > 0 then
			if self:hasSkills(sgs.Active_cardneed_skill, target) then
				if self:willSkipDrawPhase(target) then
					if target:getHandcardNum() < 4 then
						return "#MdkShenShiCard:.:->."
					end
				else
					if target:getHandcardNum() < 2 then
						return "#MdkShenShiCard:.:->."
					end
				end
			end
		end
		local my_overflow = overflow
		local baseline = -2
		if target:objectName() ~= self.player:objectName() then
			my_overflow = self:getOverflow()
			baseline = 0
		end
		if my_overflow > baseline then
			return "."
		end
		return "#MdkShenShiCard:.:->."
	end
	return "."
end
--相关信息
sgs.ai_choicemade_filter["cardUsed"]["@@MdkShenShi"] = function(self, player, promptlist)
	--cardUsed:@@MdkShenShi:@MdkShenShi:sgs2::nil
end
function MdkShenShiCard_intention(self, player, use)
	local skillcard = use.card
	if skillcard and skillcard:objectName() == "MdkShenShiCard" then
		local target = self.room:getCurrent()
		if target and target:objectName() ~= player:objectName() then
			sgs.updateIntention(player, target, -25)
		end
	end
end
table.insert(sgs.ai_choicemade_filter["cardUsed"], MdkShenShiCard_intention)
--[[****************************************************************
	编号：MDK - 04
	武将：巴麻美（Tomoe Mami）
	称号：优雅的学姐
	性别：女
	势力：吴
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：火枪
	描述：出牌阶段，若你装备有武器牌，你可以视为对一名角色使用了一张【杀】（不计入次数限制），然后你弃置此武器牌。
]]--
--HuoQiangCard:Play
local huoqiang_skill = {
	name = "MdkHuoQiang",
	getTurnUseCard = function(self, inclusive)
		if self.player:getWeapon() then
			return sgs.Card_Parse("#MdkHuoQiangCard:.:")
		end
	end,
}
table.insert(sgs.ai_skills, huoqiang_skill)
sgs.ai_skill_use_func["#MdkHuoQiangCard"] = function(card, use, self)
	--必须在应当使用【杀】时才考虑发动此技能
	local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	slash:deleteLater()
	local dummy_use = {
		isDummy = true,
		to = sgs.SPlayerList(),
	}
	self:useBasicCard(slash, dummy_use)
	local target = nil
	if dummy_use.card and not dummy_use.to:isEmpty() then
		target = dummy_use.to:first()
	else
		return 
	end
	--如果没有装备武器牌，那么果断发动此技能
	local weapon = self.player:getWeapon()
	if not weapon then
		use.card = card
		if use.to then
			use.to:append(target)
		end
		return 
	end
	--如果手上有别的武器，并且本来就准备使用其替换现有武器，那么果断发动此技能
	if not self.player:isKongcheng() then
		local handcards = self.player:getHandcards()
		local will_use_hand_weapon = false
		for _,c in sgs.qlist(handcards) do
			if c:isKindOf("Weapon") then
				dummy_use = {
					isDummy = true,
					to = nil,
				}
				self:useEquipCard(c, dummy_use)
				if dummy_use.card then
					will_use_hand_weapon = true
					break
				end
			end
		end
		if will_use_hand_weapon then
			use.card = card
			if use.to then
				use.to:append(target)
			end
			return 
		end
	end
	--如果可以致目标于死地，那么果断发动此技能
	local damage = self:hasHeavySlashDamage(self.player, slash, target, true)
	if damage > 1 and target:hasArmorEffect("silver_lion") then
		damage = 1
	end
	local make_death = false
	if damage > 0 then
		if target:hasSkill("sizhan") and not self.player:hasSkill("jueqing") then
		else
			if target:hasSkill("shibei") and target:getMark("shibei") > 0 and not self.player:hasSkill("jueqing") then
				damage = damage + 1
			end
			if target:hasSkill("niepan") and target:getMark("@nirvana") > 0 then
			elseif target:hasSkill("fuli") and target:getMark("@laoji") > 0 then
			elseif target:hasSkill("buqu") and target:getPile("buqu"):length() < 5 then
			elseif target:hasSkill("nosbuqu") and target:getPile("nosbuqu"):length() < 5 then
			else
				local hp = target:getHp()
				if damage >= hp and damage >= hp + self:getAllPeachNum(target) then
					make_death = true
				end
			end
		end
	end
	if make_death then
		use.card = card
		if use.to then
			use.to:append(target)
		end
		return 
	end
	--如果敌人手里有【借刀杀人】而自己没有【杀】，或者敌人手里有【顺手牵羊】、【过河拆桥】
	--那么为了避免浪费，应当发动此技能
	local weaponID = weapon:getEffectiveId()
	local my_slash_num = self:getCardsNum("Slash")
	if #self.enemies > 0 and not self.player:hasSkill("noswuyan") then
		for _,enemy in ipairs(self.enemies) do
			local has_dangerous_trick = false
			if my_slash_num == 0 and getKnownCard(enemy, self.player, "Collateral", true, "he") > 0 then
				has_dangerous_trick = true
			elseif enemy:distanceTo(self.player) == 1 and getKnownCard(enemy, self.player, "Snatch", true, "he") > 0 then
				has_dangerous_trick = true
			elseif enemy:canDiscard(self.player, weaponID) and getKnownCard(enemy, self.player, "Dismantlement", true, "he") > 0 then
				has_dangerous_trick = true
			end
			if has_dangerous_trick then
				use.card = card
				if use.to then
					use.to:append(target)
				end
				return 
			end
		end
	end
	--如果当前武器对保命很重要，那么不应发动此技能
	local amWeak = self:isWeak()
	if amWeak then
		if isCard("Peach", weapon, self.player) or isCard("Analeptic", weapon, self.player) then
			return 
		elseif #self.enemies > 0 and isCard("Jink", weapon, self.player) then
			for _,enemy in ipairs(self.enemies) do
				if enemy:inMyAttackRange(self.player) then
					return 
				end
			end
		end
	end
	--如果弃置当前武器牌会对后续输出造成影响，那么不应发动此技能
	--local range = weapon:toWeapon():getRange()
	local range = sgs.weapon_range[weapon:getClassName()] or 1
	if range <= 1 then
		use.card = card
		if use.to then
			use.to:append(target)
		end
		return 
	elseif #self.enemies > 0 then
		local has_targets = false
		local also_has_targets = false
		for _,enemy in ipairs(self.enemies) do
			if sgs.isGoodTarget(enemy, self.enemies, self) then
				if self.player:inMyAttackRange(enemy) then
					has_targets = true
					if self.player:inMyAttackRange(enemy, range) then
						also_has_targets = true
						break
					end
				end
			end
		end
		if has_targets and not also_has_targets then
			if my_slash_num > 0 then
				return 
			end
			local need_distance_skills = "liuli|qiangxi|xueji|zhaolie|MdkShanXin|MdkJianQiang"
			if self:hasSkills(need_distance_skills) then
				return 
			end
			--如果快挂了，就不管那么多了
			if amWeak and #self.enemies > 0 then
				local amInDanger = false
				for _,enemy in ipairs(self.enemies) do
					if enemy:inMyAttackRange(self.player) then
						amInDanger = true
						break
					end
				end
				if amInDanger and self:getAllPeachNum() == 0 then
					use.card = card
					if use.to then
						use.to:append(target)
					end
				end
			end
			return 
		end
	end
	--没有顾虑了就发动技能吧
	if target then
		use.card = card
		if use.to then
			use.to:append(target)
		end
	end
end
--相关信息
sgs.ai_cardneed["MdkHuoQiang"] = function(friend, hcard, self)
	return hcard:isKindOf("Weapon")
end
sgs.ai_use_value["MdkHuoQiangCard"] = sgs.ai_use_value["Slash"] or 4.5
sgs.ai_use_priority["MdkHuoQiangCard"] = ( sgs.ai_use_priority["Slash"] or 2.6 ) - 0.1
--[[
	技能：缎带
	描述：出牌阶段，你可以将一张红色锦囊牌当作【铁索连环】对至少一名角色使用；你计算的与武将牌横置的其他角色的距离-1。
]]--
--DuanDaiCard:Play
local duandai_skill = {
	name = "MdkDuanDai",
	getTurnUseCard = function(self, inclusive)
		if self.player:isKongcheng() then
			return nil
		end
		return sgs.Card_Parse("#MdkDuanDaiCard:.:")
	end,
}
table.insert(sgs.ai_skills, duandai_skill)
sgs.ai_skill_use_func["#MdkDuanDaiCard"] = function(card, use, self)
	local handcards = self.player:getHandcards()
	local can_use = {}
	for _,c in sgs.qlist(handcards) do
		if c:isRed() and c:isKindOf("TrickCard") then
			table.insert(can_use, c)
		end
	end
	if #can_use == 0 then
		return 
	end
	self:sortByUseValue(can_use, true)
	local trick = can_use[1]
	local dummy_use = {
		isDummy = true,
	}
	self:useTrickCard(trick, dummy_use)
	if dummy_use.card then
		return
	end
	local iron_chain = sgs.Sanguosha:cloneCard("iron_chain", trick:getSuit(), trick:getNumber())
	iron_chain:deleteLater()
	dummy_use = {
		isDummy = true,
		to = sgs.SPlayerList(),
	}
	self:useTrickCard(iron_chain, dummy_use)
	if dummy_use.card and not dummy_use.to:isEmpty() then
		local card_str = string.format("#MdkDuanDaiCard:%d:", trick:getEffectiveId())
		local acard = sgs.Card_Parse(card_str)
		use.card = acard
		if use.to then
			use.to = dummy_use.to
		end
		return 
	end
	if #self.enemies == 0 then
		return
	end
	self:sort(self.enemies, "defense")
	local targets = {}
	local need_ohorse_skills = "kuanggu|qianxi|nosqianxi|duanbing|MdkJianShu"
	local need_ohorse = self:hasSkills(need_ohorse_skills)
	if not need_ohorse then
		local n_snatch = 0
		local n_supply_shortage = 0
		if not self:hasSkills("qicai|nosqicai") then
			n_snatch = self:getCardsNum("Snatch", "he", true)
			n_supply_shortage = self:getCardsNum("SupplyShortage", "he", true)
		end
		if n_snatch > 0 or n_supply_shortage > 0 then
			need_ohorse = true
		end
	end
	if need_ohorse then
		for _,enemy in ipairs(self.enemies) do
			if self.player:distanceTo(enemy) == 2 then
				table.insert(targets, enemy)
			end
		end
	end
	local need_distance_skills = "liuli|qiangxi|xueji|zhaolie|MdkShanXin|MdkJianQiang"
	local need_distance = self:hasSkills(need_distance_skills)
	if not need_distance then
		local n_slash = self:getCardsNum("Slash", "he", true)
		if n_slash > 0 then
			need_distance = true
		end
	end
	if need_distance then
		for _,enemy in ipairs(self.enemies) do
			if not self.player:inMyAttackRange(enemy) then
				if self.player:inMyAttackRange(enemy, -1) then
					table.insert(targets, enemy)
				end
			end
		end
	end
	if #targets == 0 then
		return 
	end
	local card_str = string.format("#MdkDuanDaiCard:%d:", trick:getEffectiveId())
	local acard = sgs.Card_Parse(card_str)
	use.card = acard
	if use.to then
		use.to:append(targets[1])
		if #targets > 1 then
			use.to:append(targets[2])
		end
	end
end
--相关信息
sgs.ai_cardneed["MdkDuanDai"] = function(friend, hcard, self)
	return hcard:isRed() and hcard:isKindOf("TrickCard")
end
sgs.ai_use_value["MdkDuanDaiCard"] = sgs.ai_use_value["IronChain"] or 5.4
sgs.ai_use_priority["MdkDuanDaiCard"] = sgs.ai_use_priority["IronChain"] or 9.1
--[[
	技能：红茶
	描述：出牌阶段结束时，你可以摸一张牌；你的手牌上限+1。
]]--
--player:askForSkillInvoke("MdkHongCha", data)
sgs.ai_skill_invoke["MdkHongCha"] = true
--[[
	技能：终曲（阶段技）
	描述：你可以弃置三张相同花色的牌，对一名攻击范围内的角色造成两点火焰伤害。
]]--
--ZhongQuCard:Play
local zhongqu_skill = {
	name = "MdkZhongQu",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#MdkZhongQuCard") then
			return nil
		elseif #self.enemies == 0 then
			return nil
		elseif self.player:getCardCount() >= 3 then
			return sgs.Card_Parse("#MdkZhongQuCard:.:")
		end
	end,
}
table.insert(sgs.ai_skills, zhongqu_skill)
sgs.ai_skill_use_func["#MdkZhongQuCard"] = function(card, use, self)
	local cards = self.player:getCards("he")
	local groups = {}
	for _,c in sgs.qlist(cards) do
		local id = c:getEffectiveId()
		if self.player:canDiscard(self.player, id) then
			local suit = c:getSuit()
			if not groups[suit] then
				groups[suit] = {}
			end
			table.insert(groups[suit], c)
		end
	end
	local suits = {}
	for suit, group in pairs(groups) do
		if #group >= 3 then
			table.insert(suits, suit)
		end
	end
	if #suits == 0 then
		return 
	end
	local targets = {}
	for _,enemy in ipairs(self.enemies) do
		if self.player:inMyAttackRange(enemy) then
			if self:damageIsEffective(enemy, sgs.DamageStruct_Fire, self.player) then
				table.insert(targets, enemy)
			end
		end
	end
	if #targets == 0 then
		return 
	end
	local card_keep_value = {}
	local first, second, third = nil, nil, nil
	local min_value = 9999
	local min_suit = nil
	local may_use = {}
	for _,suit in ipairs(suits) do
		local cards = groups[suit] or {}
		for index, card in ipairs(cards) do
			local value = self:getKeepValue(card)
			card_keep_value[card] = value
			if index == 1 then
				first = card
			elseif index == 2 then
				second = card
			elseif index == 3 then
				third = card
			else
				if card_keep_value[first] > value then
					first = card
				elseif card_keep_value[second] > value then
					second = card
				elseif card_keep_value[third] > value then
					third = card
				end
			end
		end
		local total_value = card_keep_value[first] + card_keep_value[second] + card_keep_value[third]
		if total_value < min_value then
			min_value = total_value
			min_suit = suit
			may_use = {first, second, third}
		end
	end
	if min_value > 30 then
		return 
	end
	local care_lord = ( self.role == "renegade" and self.room:alivePlayerCount() > 2 )
	self:sort(targets, "defense")
	local targetA = nil -- Can Cause Death.
	local targetB = nil -- Chained Target.
	local targetC = nil -- Can Cause Super Damage.
	local targetD = nil -- Normal Target.
	local targetE = nil -- Can Cause Little Damage.
	local JinXuanDi = self.room:findPlayerBySkillName("wuling")
	local wind_mark = ( JinXuanDi and JinXuanDi:getMark("@wind") > 0 )
	local earth_mark = ( JinXuanDi and JinXuanDi:getMark("@earth") > 0 )
	for _,target in ipairs(targets) do
		local damage = 2
		if wind_mark then
			damage = damage + 1
		end
		if target:isKongcheng() and target:hasSkill("chouhai") then
			damage = damage + 1
		end
		local armor = target:getArmor()
		if armor then
			if target:hasArmorEffect("vine") or target:hasArmorEffect("gale_shell") then
				damage = damage + 1
			end
		elseif target:hasSkill("bossmanjia") then
			damage = damage + 1
		end
		local hp = target:getHp()
		if damage > 1 then
			if earth_mark then
				damage = 1
			elseif armor and target:hasArmorEffect("silver_lion") then
				damage = 1
			elseif target:hasSkill("buqu") and hp == 1 then
				damage = 1
			end
		end
		local cause_death = false
		if damage >= hp then
			if target:hasSkill("buqu") and target:getPile("buqu"):length() < 5 then
			elseif target:hasSkill("nosbuqu") and target:getPile("nosbuqu"):length() < 5 then
			elseif target:hasSkill("niepan") and target:getMark("@nirvana") > 0 then
			elseif target:hasSkill("fuli") and target:getMark("@laoji") > 0 then
			elseif target:hasSkill("MdkLunHui") and target:getCardCount() >= target:getMark("@MdkLunHuiMark") then
			elseif damage >= hp + self:getAllPeachNum(target) then
				cause_death = true
			end
		end
		if cause_death then
			if care_lord and target:isLord() then
				continue
			else
				targetA = target
				break
			end
		elseif self:cantbeHurt(target, self.player, damage) then
			continue
		end
		if target:isChained() and not targetB then
			if self:isGoodChainTarget(target, self.player, sgs.DamageStruct_Fire, damage, nil) then
				targetB = target
			end
		elseif damage > 2 and not targetC then
			targetC = target
		elseif damage < 2 and not targetE then
			targetE = target
		elseif not targetD then
			targetD = target
		elseif targetB and targetC and targetD and targetE then
			break
		end
	end
	if targetB then
		for _,friend in ipairs(self.friends) do
			if friend:isChained() and self:damageIsEffective(friend, sgs.DamageStruct_Fire, self.player) then
				local not_care = false
				local friend_hp = friend:getHp()
				if friend_hp > 1 then
					not_care = earth_mark or friend:hasArmorEffect("silver_lion")
				elseif friend_hp == 1 then
					not_care = friend:hasSkill("buqu")
				end
				if not_care and self:hasSkills(sgs.masochism_skill, friend) then
				else
					targetB = nil
					break
				end
			end
		end
	end
	if targetD or targetE then
		if self:isWeak() and self:getOverflow() <= 0 then
			targetD = nil
			targetE = nil
		end
	end
	local target = targetA or targetB or targetC or targetD or targetE
	if target and #may_use == 3 then
		local to_use = {}
		for _,card in ipairs(may_use) do
			table.insert(to_use, card:getEffectiveId())
		end
		to_use = table.concat(to_use, "+")
		local card_str = string.format("#MdkZhongQuCard:%s:->%s", to_use, target:objectName())
		local acard = sgs.Card_Parse(card_str)
		use.card = acard
		if use.to then
			use.to:append(target)
		end
	end
end
--相关信息
sgs.ai_use_value["MdkZhongQuCard"] = 6.5
sgs.ai_use_priority["MdkZhongQuCard"] = 8.9
--[[
	技能：宝贝（联动技->百江渚）
	描述：一名其他角色对百江渚使用【杀】时，你可以令该角色将武将牌横置。
]]--
--source:askForSkillInvoke("MdkBaoBei", data)
sgs.ai_skill_invoke["MdkBaoBei"] = function(self, data)
	local use = data:toCardUse()
	local target = use.from
	if target and target:isAlive() then
		if self:isFriend(target) then
			return false
		end
		return self:isGoodChainTarget(target)
	end
	return false
end
--[[****************************************************************
	编号：MDK - 05
	武将：佐仓杏子（Sakura Kyouko）
	称号：风见野的来客
	性别：女
	势力：蜀
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：尖枪（锁定技）
	描述：出牌阶段，你使用的红色【杀】不可被闪避；你使用黑色【杀】时可以额外指定一名目标。
]]--
--相关信息
sgs.ai_cardneed["MdkJianQiang"] = function(friend, hcard, self)
	return hcard:isKindOf("Slash")
end
--[[
	技能：吃货
	描述：摸牌阶段，你可以放弃摸牌，改为亮出牌堆顶的三张牌，你选择一名角色获得其中所有的【桃】，然后你获得其余的牌。
]]--
--player:askForSkillInvoke("MdkChiHuo", data)
sgs.ai_skill_invoke["MdkChiHuo"] = true
--room:askForPlayerChosen(player, alives, "MdkChiHuo", prompt, true, false)
sgs.ai_skill_playerchosen["MdkChiHuo"] = function(self, targets)
	local data = self.room:getTag("MdkChiHuoData")
	local ids = data:toIntList()
	local peaches = {}
	for _,id in sgs.qlist(ids) do
		peach = sgs.Sanguosha:getCard(id)
		table.insert(peaches, peach)
	end
	local card, target = self:getCardNeedPlayer(peaches, true)
	if target then
		for _,p in sgs.qlist(targets) do
			if p:objectName() == target:objectName() then
				return target
			end
		end
	end
	return nil
end
--相关信息
sgs.ai_playerchosen_intention["MdkChiHuo"] = -80
--[[
	技能：殉情（限定技）
	描述：你攻击范围内的一名其他角色濒死时，若本局游戏中你与该角色相互造成过伤害（由系统记录），你可以弃置任意数量的牌，令你与该角色分别失去等量的体力上限。
]]--
--room:askForUseCard(player, "@@MdkXunQing", prompt)
sgs.ai_skill_use["@@MdkXunQing"] = function(self, prompt, method)
	local parts = prompt:split(":")
	local name, n = parts[2], tonumber(parts[4])
	local target = nil
	local others = self.room:getOtherPlayers(self.player)
	for _,p in sgs.qlist(others) do
		if p:objectName() == name then
			target = p
			break
		end
	end
	if target and self:isEnemy(target) then
		if self:getAllPeachNum(target) == 0 then
			return "."
		end
		local maxhp = target:getMaxHp()
		local my_maxhp = self.player:getMaxHp()
		local kill_target = ( n >= maxhp )
		local kill_myself = ( n >= my_maxhp )
		if kill_myself then
			if #self.friends_noself == 0 then
				return "."
			elseif self.role == "lord" or self.role == "renegade" then
				return "."
			elseif self.role == "rebel" then
				local has_another_rebel = false
				for _,friend in ipairs(self.friends_noself) do
					if sgs.evaluatePlayerRole(friend) == "rebel" then
						has_another_rebel = true
						break
					end
				end
				if not has_another_rebel then
					return "."
				end
			end
		end
		if self.role == "rebel" and target:isLord() then
			local use_str = string.format("#MdkXunQingCard:.:->%s", target:objectName())
			return use_str
		end
		local care_lord = false
		if self.role == "renegade" and target:isLord() then
			care_lord = ( self.room:alivePlayerCount() > 2 )
		end
		if kill_target and care_lord then
			return "."
		end
		if kill_target and sgs.turncount > 1 and #self.enemies == 1 then
			return 
		end
		if kill_target and target:hasSkill("wuhun") then
			local alives = self.room:getAlivePlayers()
			local victims = {}
			for _,p in sgs.qlist(alives) do
				if p:objectName() == self.player:objectName() then
				elseif p:objectName() == target:objectName() then
				elseif p:getMark("@nightmare") > 0 then
					table.insert(victims, p)
				end
			end
			if #victims > 0 then
				local compare_func = function(a, b)
					local markA = a:getMark("@nightmare")
					local markB = b:getMark("@nightmare")
					if markA == markB then
						local possibleA = 0
						local lord_buff = -5
						if self:isFriend(target, a) then
							possibleA = -10
						elseif self:isEnemy(target, a) then
							possibleA = 10
							lord_buff = 5
						end
						if a:isLord() then
							possibleA = possibleA + lord_buff
						end
						lord_buff = -5
						local possibleB = 0
						if self:isFriend(target, b) then
							possibleA = -10
						elseif self:isEnemy(target, b) then
							possibleA = 10
							lord_buff = 5
						end
						if b:isLord() then
							possibleB = possibleB + lord_buff
						end
						return possibleA > possibleB
					end
					return markA > markB
				end
				table.sort(victims, compare_func)
				local victim = victims[1]
				if self:isFriend(victim) then
					return "."
				end
			end
		end
		if kill_myself and self:needDeath() then
			local use_str = string.format("#MdkXunQingCard:.:->%s", target:objectName())
			return use_str
		end
		local invoke = false
		local process_value = sgs.gameProcess(self.room, true, false)
		local skills = sgs.need_maxhp_skill or  "yingzi|zaiqi|yinghun|hunzi|juejing|ganlu|noszishou|miji|olmiji|chizhong|xueji|hunshang|xuehen|neojushou|tannang|fangzhu|nosshangshi|nosmiji"
		skills = skills.."|"..sgs.save_skill.."|"..sgs.exclusive_skill.."|"..sgs.recover_skill.."|"..sgs.masochism_skill
		local amInDanger = false
		if self:isWeak() then
			local can_attack = 0
			for _,enemy in ipairs(self.enemies) do
				if enemy:inMyAttackRange(self.player) then
					can_attack = can_attack + 1
				end
			end
			if can_attack > 0 then
				if self:getAllPeachNum() + self.player:getHp() <= can_attack then
					amInDanger = true
				end
			end
		end
		if kill_target then
			if self.role == "loyalist" then
				if process_value > ( kill_myself and 3 or 0 ) - ( amInDanger and 2 or 0 ) then --顺风局
					invoke = true
				elseif process_value < ( kill_myself and -10 or -2 ) + ( amInDanger and 3 or 0 ) then --逆风局
					invoke = true
				end
			elseif self.role == "rebel" then
				if process_value < ( kill_myself and -4 or -1 ) + ( amInDanger and 2.5 or 0 ) then --顺风局
					invoke = true
				elseif process_value > ( kill_myself and 7 or 1 ) - ( amInDanger and 3.5 or 0 ) then --逆风局
					invoke = true
				end
			end
		elseif self:hasSkills(skills, target) then
			if self.role == "loyalist" then
				if process_value > ( kill_myself and 4 or 1 ) - ( amInDanger and 1.5 or 0 ) then --顺风局
					invoke = true
				elseif process_value < ( kill_myself and -15 or -5 ) + ( amInDanger and 2 or 0 ) then --逆风局
					invoke = true
				end
			elseif self.role == "rebel" then
				if process_value < ( kill_myself and -4 or -2 ) + ( amInDanger and 2 or 0 ) then --顺风局
					invoke = true
				elseif process_value > ( kill_myself and 5 or 0 ) - ( amInDanger and 2.5 or 0 ) then --逆风局
					invoke = true
				end
			end
		elseif amInDanger and self.role == "rebel" then
			invoke = true
		elseif self:hasSkills(skills, self.player) then
			return "."
		end
		if invoke then
			local use_str = string.format("#MdkXunQingCard:.:->%s", target:objectName())
			return use_str
		end
	end
	return "."
end
--相关信息
sgs.ai_card_intention["MdkXunQingCard"] = 400
--[[
	技能：幻梦（联动技->美树沙耶香）
	描述：美树沙耶香使用的【杀】结算完毕后，你可以获得之。每回合限一次。
]]--
--source:askForSkillInvoke("MdkHuanMeng", data)
sgs.ai_skill_invoke["MdkHuanMeng"] = function(self, data)
	local use = data:toCardUse()
	local slash = use.card
	if slash then
		if slash:isKindOf("NatureSlash") then
			return true
		elseif slash:subcardsLength() > 1 then
			return true
		end
	else
		return false
	end
	local target = use.from
	if target and target:isAlive() then
		if target:isCardLimited(slash, sgs.Card_MethodUse) then
			return true
		end
		local enemies = self.enemies
		if target:objectName() ~= self.player:objectName() then
			enemies = self:getEnemies(target)
		end
		if #enemies == 0 then
			return true
		end
		local nature_slash = ""
		if target:objectName() == self.player:objectName() then
			if self:getCardsNum("FireSlash") > 0 then
				nature_slash = "fire_slash"
			elseif self:getCardsNum("ThunderSlash") > 0 then
				nature_slash = "thunder_slash"
			end
		else
			if getCardsNum("FireSlash", target, self.player) > 0 then
				nature_slash = "fire_slash"
			elseif getCardsNum("ThunderSlash", target, self.player) > 0 then
				nature_slash = "thunder_slash"
			end
		end
		if nature_slash == "" then
			return true
		end
		local can_slash_more_times = self:hasCrossbowEffect(target)
		while not can_slash_more_times do
			local slash_times = target:getSlashCount()
			if target:hasSkill("tianyi") and slash_times <= 1 and target:hasFlag("TianyiSuccess") then
				can_slash_more_times = true
				break
			elseif target:hasSkill("xianzhen") and target:hasFlag("XianzhenSuccess") then
				can_slash_more_times = true
				break
			elseif target:hasSkill("MdkJianShu") and slash_times <= 1 then
				local weapon = target:getWeapon()
				local name = weapon and weapon:objectName() or ""
				if string.find(name, "sword") then
					can_slash_more_times = true
					break
				end
			end
			break
		end
		if not can_slash_more_times then
			return true
		end
		local will_use_more_slash = false
		local ns = sgs.Sanguosha:cloneCard(nature_slash, sgs.Card_NoSuit, 0)
		ns:deleteLater()
		for _,enemy in ipairs(enemies) do
			if target:canSlash(enemy, ns) and not self:slashProhibit(ns, enemy, target) then
				will_use_more_slash = true
				break
			end
		end
		if will_use_more_slash then
			return false
		end
	end
	return true
end
--[[****************************************************************
	编号：MDK - 06
	武将：丘比（Incubator）
	称号：孵化者
	性别：男
	势力：群
	体力上限：2勾玉
]]--****************************************************************
--[[
	技能：窥探
	描述：回合结束时，你可以选择一名攻击范围内的其他角色，然后直到其回合开始，该角色每使用或打出一张牌，你摸一张牌。
	说明：你同一时间只能选择一名角色作为“窥探”目标。若你发动“窥探”选择目标后获得了新的回合，且在新的回合结束时再次发动“窥探”选择了不同的目标，则原有的“窥探”目标将不再受此技能影响。
]]--
--room:askForPlayerChosen(player, targets, "MdkKuiTan", "@MdkKuiTan", true, true)
sgs.ai_skill_playerchosen["MdkKuiTan"] = function(self, targets)
	local friends, enemies = {}, {}
	for _,p in sgs.qlist(targets) do
		if self:isFriend(p) then
			table.insert(friends, p)
		else
			table.insert(enemies, p)
		end
	end
	if #friends > 0 then
		self:sort(friends, "handcard")
		friends = sgs.reverse(friends)
		if self.player:hasSkill("MdkDiYue") then
			for _,friend in ipairs(friends) do
				if friend:hasSkill("manjuan") then
					return friend
				end
			end
			for _,friend in ipairs(friends) do
				if self:isWeak(friend) then
					return friend
				end
			end
		end
	end
	if #enemies > 0 then
		self:sort(enemies, "handcard")
		enemies = sgs.reverse(enemies)
		for _,enemy in ipairs(enemies) do
			if enemy:getHandcardNum() > 2 then
				if self:hasSkills(sgs.notActive_cardneed_skill, enemy) then
					return enemy
				end
			end
		end
	end
	if #friends > 0 then
		for _,friend in ipairs(friends) do
			if self:hasSkills(sgs.notActive_cardneed_skill, friend) then
				return friend
			end
		end
		return friends[1]
	end
	if #enemies > 0 then
		return enemies[1]
	end
end
--[[
	技能：缔约
	描述：你选择“窥探”的角色的回合开始时，你可以令其选择一项：1、交给你所有手牌，然后你交给其任意数量的牌；若你给出的牌少于你获得的牌，其摸两张牌或回复1点体力。2、本回合内其与你计算的距离+1。
]]--
--room:askForExchange(source, "MdkDiYue", 999, 0, true, prompt, true)
sgs.ai_skill_discard["MdkDiYue"] = function(self, discard_num, min_num, optional, include_equip)
	local target = self.room:getTag("MdkDiYueTarget"):toPlayer()
	if target then
		local n_obtain = self.player:getMark("MdkDiYueObtainCount")
		local can_recover, need_recover = false, false
		if n_obtain > 0 and target:getLostHp() > 0 then
			can_recover = true
			local target_hp = target:getHp()
			if target:hasSkill("hunzi") and target:getMark("hunzi") == 0 and target_hp > 0 then
			elseif target:isLord() then
				if self:needToLoseHp(target, nil, nil, true, true) then
				elseif not sgs.isLordHealthy() then
					need_recover = true
				end
			else
				if target_hp >= 2 and self:hasSkills("kuanggu|zaiqi", target) then
				elseif target_hp >= 2 and self:hasSkills("rende|nosrende|olrende", target) and #self:getFriendsNoself(target) > 0 then
				elseif self:needToLoseHp(target, nil, nil, nil, true) then
				else
					need_recover = true
				end
			end
		end
		local to_give = {}
		if self:isFriend(target) then
			local max_count = need_recover and math.max(0, n_obtain - 1) or 9999
			local cards = self.player:getCards("he")
			cards = sgs.QList2Table(cards)
			self:sortByUseValue(cards)
			max_count = math.min(max_count, #cards)
			--给虚弱的队友：桃、酒
			local hcard_num = target:getHandcardNum()
			if self:isWeak(target) then
				local rest_cards = {}
				local enough = false
				for index, c in ipairs(cards) do
					if enough then
						table.insert(rest_cards, c)
					elseif isCard("Peach", c, target) or isCard("Analeptic", c, target) then
						table.insert(to_give, c:getEffectiveId())
						if #to_give >= max_count then
							return to_give
						elseif hcard_num + #to_give > 3 then
							enough = true
						end
					end
				end
				cards = rest_cards
			end
			--给弱的队友：防具、防御马
			if #to_give < max_count and target:getHp() <= 2 then
				local rest_cards = {}
				local armor_given, dhorse_given = false, false
				for index, c in ipairs(cards) do
					local rest_flag = true
					if c:isKindOf("Armor") and not armor_given then
						if c:isKindOf("GaleShell") then
						elseif target:getArmor() or self:hasSkills("bazhen|yizhong|bossmanjia", target) then
						else
							rest_flag = false
							armor_given = true
							table.insert(to_give, c:getEffectiveId())
							if #to_give >= max_count then
								return to_give
							end
						end
					elseif c:isKindOf("DefensiveHorse") and not dhorse_given then
						rest_flag = false
						dhorse_given = true
						table.insert(to_give, c:getEffectiveId())
						if #to_give >= max_count then
							return to_give
						end
					end
					if rest_flag then
						table.insert(rest_cards, c)
					end
				end
				cards = rest_cards
			end
			--考虑诸葛连弩和杀
			if #to_give < max_count then
				if self:hasCrossbowEffect(target) or getKnownCard(target, self.player, "Crossbow") > 0 then
					local has_good_enemy_as_target = false
					if #self.enemies > 0 then
						for _,enemy in ipairs(self.enemies) do
							if target:distanceTo(enemy) == 1 and sgs.isGoodTarget(enemy, self.enemies, self) then
								has_good_enemy_as_target = true
								break
							end
						end
					end
					if has_good_enemy_as_target then
						local rest_cards = {}
						for index, c in ipairs(cards) do
							if isCard("Slash", c, target) then
								table.insert(to_give, c:getEffectiveId())
								if #to_give >= max_count then
									return to_give
								end
							else
								table.insert(rest_cards, c)
							end
						end
						cards = rest_cards
					end
				elseif self:hasSkills("longdan|longhun|wusheng|wushen|keji", target) and target:getHandcardNum() > 2 then
					for index, c in ipairs(cards) do
						if c:isKindOf("Crossbow") then
							table.insert(to_give, c:getEffectiveId())
							if #to_give >= max_count then
								return to_give
							end
							table.remove(cards, index)
							break
						end
					end
				end
			end
			--考虑队友的技能
			if #to_give < max_count then
				local skills = target:getVisibleSkillList(true)
				local skillnames = {}
				for _,skill in sgs.qlist(skills) do
					local callback = sgs.ai_cardneed[skill:objectName()]
					if type(callback) == "function" then
						table.insert(skillnames, skill:objectName())
					end
				end
				if #skillnames > 0 then
					local rest_cards = {}
					for _,c in ipairs(cards) do
						local rest_flag = true
						for _,name in ipairs(skillnames) do
							if sgs.ai_cardneed[name](target, c, self) then
								table.insert(to_give, c:getEffectiveId())
								if #to_give >= max_count then
									return to_give
								end
								rest_flag = false
								break
							end
						end
						if rest_flag then
							table.insert(rest_cards, c)
						end
					end
					cards = rest_cards
				end
			end
			if #to_give < max_count then
				local count = max_count - #to_give
				local overflow = self:getOverflow()
				count = math.max(0, math.min(#cards, math.min(count, overflow)))
				if count > 0 then
					for i=1, count, 1 do
						table.insert(to_give, cards[i]:getEffectiveId())
					end
				end
			end
		else
			local count = 0
			if n_obtain == 1 then
				count = 1
			elseif n_obtain == 2 then
				count = need_recover and 2 or 0
			end
			if count == 0 then
				return {}
			end
			local handcards = self.player:getHandcards()
			handcards = sgs.QList2Table(handcards)
			self:sortByUseValue(handcards, true)
			count = math.min(count, #handcards)
			local can_give = {}
			local cannot_give = {}
			for _,c in ipairs(handcards) do
				if isCard("Peach", c, target) or isCard("ExNihilo", c, target) or self:isValuableCard(c, target) then
					table.insert(cannot_give, c)
				else
					table.insert(can_give, c)
				end
			end
			if #cannot_give > 0 then
				for _,c in ipairs(cannot_give) do
					table.insert(can_give, c)
				end
			end
			handcards = can_give
			for i=1, count, 1 do
				table.insert(to_give, handcards[i]:getEffectiveId())
			end
		end
		return to_give
	end
	return {}
end
--room:askForChoice(target, "MdkDiYueDesire", choices)
sgs.ai_skill_choice["MdkDiYueDesire"] = function(self, choices, data)
	if string.find(choices, "recover") then
		if getBestHp(self.player) < self.player:getHp() then
			return "draw"
		elseif self.player:hasSkill("manjuan") then
			return "draw"
		elseif self:isWeak() then
			return "recover"
		elseif self:getOverflow() + 2 > 0 then
			return "recover"
		elseif self:willSkipPlayPhase() then
			return "recover"
		elseif self:getCardsNum("Peach") >= self.player:getLostHp() then
			return "draw"
		elseif self:hasSkills(sgs.Active_cardneed_skill) then
			return "draw"
		end
		return "recover"
	end
	return "draw"
end
--source:askForSkillInvoke("MdkDiYue", ai_data)
sgs.ai_skill_invoke["MdkDiYue"] = function(self, data)
	local target = data:toPlayer()
	if target:hasSkill("manjuan") then
		if self:isFriend(target) then
			return true
		else
			return false
		end
	end
	if self.player:hasSkill("manjuan") then
		if self:isFriend(target) and target:getHandcardNum() <= 1 then
			return true
		end
		return false
	end
	return true
end
--room:askForChoice(player, "MdkDiYue", "accept+reject", ai_data)
sgs.ai_skill_choice["MdkDiYue"] = function(self, choices, data)
	local source = data:toPlayer()
	local num = self.player:getHandcardNum()
	--没有手牌时，欣然接受
	if num == 0 then
		return "accept"
	--只有一张手牌时，若是好牌且对方不是友军，则拒绝，否则接受
	elseif num == 1 then
		local card = self.player:getHandcards():first()
		if self:isValuableCard(card) then
			if not self:isFriend(source) then
				return "reject"
			end
		end
		return "accept"
	--无条件接受友军请求，以求配合
	elseif self:isFriend(source) then
		return "accept"
	--对于敌人或不明身份的人：
	--若手牌为4张及以上，直接拒绝
	elseif num > 3 then
		return "reject"
	end
	--若手牌为2~3张：
	--如果自己有好牌，就拒绝
	local handcards = self.player:getHandcards()
	for _,c in sgs.qlist(handcards) do
		if self:isValuableCard(c) then
			return "reject"
		elseif self:isValuableCard(c, source) then
			return "reject"
		end
	end
	--如果对方有已知的烂牌，或者未知的牌，就拒绝
	local cards = source:getCards("he")
	local flag = string.format("visible_%s_%s", self.player:objectName(), source:objectName())
	for _,c in sgs.qlist(cards) do
		local id = c:getEffectiveId()
		local place = self.room:getCardPlace(id)
		local known = false
		if place == sgs.Player_PlaceEquip then
			known = true
		elseif place == sgs.Player_PlaceHand then
			if c:hasFlag("visible") or c:hasFlag(flag) then
				known = true
			end
		end
		if known then
			if not self:isValuableCard(c, source) then
				return "reject"
			end
		else
			return "reject"
		end
	end
	--对方全是好牌，自己全是烂牌：接受
	return "accept"
end
--[[
	技能：替身（锁定技）
	描述：游戏开始时或一名角色的回合结束后，若你没有获得过“替身”牌，你将牌堆顶的一张牌置于你的武将牌上，称为“替身”；你即将受到伤害时，若你有“替身”牌，你防止此伤害并选择一张“替身”牌获得之。（至多X/2张，结果向下取整，X为场上人数）。
]]--
--room:askForAG(player, pile, false, "MdkTiShen")
--[[
	技能：无情（锁定技）
	描述：你造成的伤害视为无伤害来源。
]]--
local System_cantbeHurt = SmartAI.cantbeHurt
function SmartAI:cantbeHurt(player, from, damageNum)
	from = from or self.player
	if from:hasSkill("MdkWuQing") then
		return false
	end
	return System_cantbeHurt(self, player, from, damageNum)
end
--[[****************************************************************
	编号：MDK - 07
	武将：志筑仁美（Shizuki Hitomi）
	称号：大家闺秀
	性别：女
	势力：吴
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：名门（锁定技）
	描述：你于回合外失去牌时，你摸一张牌。
]]--
--[[
	技能：思慕
	描述：一名其他角色的回合开始时，你可以弃两张牌，令此回合内该角色的红心牌均视为草花花色。每轮限一次。
]]--
--room:askForUseCard(source, "@@MdkSiMu", prompt)
sgs.ai_skill_use["@@MdkSiMu"] = function(self, prompt, method)
	local target = self.room:getCurrent()
	local is_enemy = self:isEnemy(target)
	local is_friend = self:isFriend(target)
	local need_change_suit = false
	--考虑影响乐不思蜀和兵粮寸断：发动技能对兵粮寸断有利，对乐不思蜀绝对不利
	if not target:containsTrick("YanxiaoCard") then
		local has_indulgence = target:containsTrick("indulgence")
		local has_supply_shortage = target:containsTrick("supply_shortage")
		---如果是朋友，而且只有乐不思蜀，那么不能发动变色，否则必中。
		if is_friend and has_indulgence and not has_supply_shortage then
			return "."
		--如果是敌人，而且只有兵粮寸断，那么不能发动变色，否则必不中。
		elseif is_enemy and has_supply_shortage and not has_indulgence then
			return "."
		end
		--如果乐不思蜀和兵粮寸断都有
		if has_indulgence and has_supply_shortage then
			local overflow = self:getOverflow(target)
			local num = target:getHandcardNum()
			if is_enemy then
				--如果是敌人，手牌很少，需要补充手牌，那么不发动，否则兵粮寸断容易不中
				if overflow < 0 or num < 2 then
					return "."
				--如果是敌人，拥有回合内首要技能，需要出牌，那么应当发动，令乐不思蜀必中
				elseif self:hasSkills(sgs.priority_skill, target) then
					need_change_suit = true
				--如果是敌人，手牌很多，需要出牌，那么应当发动，令乐不思蜀必中
				elseif overflow > 0 or num > 2 then
					need_change_suit = true
				end
			elseif is_friend then
				--如果是朋友，手牌很多，需要出牌，那么不发动，增加乐不思蜀不中的概率
				if overflow > 0 or num > 2 then
					return "."
				end
			end
		end
		--如果是朋友，而且只有兵粮寸断，那么必须发动，增加兵粮寸断不中的概率
		if is_friend and has_supply_shortage and not has_indulgence then
			need_change_suit = true
		--如果是敌人，而且只有乐不思蜀，那么必须发动，令乐不思蜀必中
		elseif is_enemy and has_indulgence and not has_supply_shortage then
			need_change_suit = true
		end
	end
	if need_change_suit then
		local to_discard = self:askForDiscard("dummy", 2, 2, false, true)
		if #to_discard == 2 then
			local use_str = string.format("#MdkSiMuCard:%s:->.", table.concat(to_discard, "+"))
			return use_str
		end
	end
	--如果是敌人，而且有技能“奇袭”、“银铃”，那么不发动
	if is_enemy and self:hasSkills("qixi|yinling", target) then
		if not self:willSkipPlayPhase(target) then
			return "."
		end
	end
	--联动上条恭介
	if is_friend and target:hasSkill("MdkCaiHua") and #self.enemies > 0 then
		if not self:willSkipPlayPhase(target) then
			local no_target = true
			for _,enemy in ipairs(self.enemies) do
				if target:inMyAttackRange(enemy) then
					no_target = false
					break
				end
			end
			if no_target then
				local need_invoke = false
				local num = target:getHandcardNum()
				if num > 3 then
					need_invoke = true
				elseif not self:willSkipDrawPhase(target) then
					local skills = target:getVisibleSkillList(true)
					num = num + self:ImitateResult_DrawNCards(target, skills)
					if num > 3 then
						need_invoke = true
					end
				end
				if need_invoke then
					local to_discard = self:askForDiscard("dummy", 2, 2, false, true)
					if #to_discard == 2 then
						local can_invoke = true
						for _,id in ipairs(to_discard) do
							local card = sgs.Sanguosha:getCard(id)
							if card then
								if card:isKindOf("Peach") or card:isKindOf("ExNihilo") then
									can_invoke = false
									break
								elseif self:isValuableCard(card) then
									can_invoke = false
									break
								end
							end
						end
						if can_invoke then
							local use_str = string.format("#MdkSiMuCard:%s:->.", table.concat(to_discard, "+"))
							return use_str
						end
					end
				end
			end
		end
	end
	--洗牌，提升手牌质量
	if is_enemy and self.player:hasSkill("MdkMingMen") then
		local need_wash = false
		if self:getAllPeachNum() == 0 then
			if self:isWeak() then
				need_wash = true
			elseif target and #self.friends_noself > 0 then
				for _,friend in ipairs(self.friends_noself) do
					if target:inMyAttackRange(friend) and self:isWeak(friend) then
						need_wash = true
						break
					end
				end
			end
		end
		if not need_wash then
			local armor = self.player:getArmor()
			if armor and self:needToThrowArmor() then
				need_wash = true
			end
		end
		if need_wash then
			local to_discard = self:askForDiscard("dummy", 2, 2, false, true)
			if #to_discard == 2 then
				local use_str = string.format("#MdkSiMuCard:%s:->.", table.concat(to_discard, "+"))
				return use_str
			end
		end
	end
	return "."
end
--[[
	技能：坦白（限定技）
	描述：出牌阶段，你可以与一名体力小于你的角色进行拼点。若你胜，你可以指定至多一名已受伤的其他角色（拼点目标除外），你与该角色各回复1点体力，然后拼点目标受到1点伤害。否则你失去1点体力。
]]--
--source:pindian(target, "MdkTanBai", card)
--room:askForPlayerChosen(source, can_recover, "MdkTanBai", prompt, true)
sgs.ai_skill_playerchosen["MdkTanBai"] = function(self, targets)
	local friends = {}
	for _,p in sgs.qlist(targets) do
		if self:isFriend(p) then
			table.insert(friends, p)
		end
	end
	if #friends == 0 then
		return nil
	end
	self:sort(friends, "defense")
	if self:isWeak(friends[1]) then
		return friends[1]
	end
	for _,friend in ipairs(friends) do
		if getBestHp(friend) < friend:getHp() then
			return friend
		end
	end
	return friends[1]
end
--TanBaiCard:Play
local tanbai_skill = {
	name = "MdkTanBai",
	getTurnUseCard = function(self, inclusive)
		if self.player:getMark("@MdkTanBaiMark") == 0 then
			return nil
		elseif self.player:isKongcheng() then
			return nil
		end
		return sgs.Card_Parse("#MdkTanBaiCard:.:")
	end,
}
table.insert(sgs.ai_skills, tanbai_skill)
sgs.ai_skill_use_func["#MdkTanBaiCard"] = function(card, use, self)
	local my_hp = self.player:getHp()
	local targets = {}
	local others = self.room:getOtherPlayers(self.player)
	for _,p in sgs.qlist(others) do
		if p:isKongcheng() then
		elseif p:getHp() < my_hp then
			table.insert(targets, p)
		end
	end
	if #targets == 0 then
		return
	end
	local my_max_point = 0
	local can_use = {}
	local handcards = self.player:getHandcards()
	for _,c in sgs.qlist(handcards) do
		local point = c:getNumber()
		if point > my_max_point then
			can_use = {c}
			my_max_point = point
		elseif point == my_max_point then
			table.insert(can_use, c)
		end
	end
	local target = nil
	local max_value = 0
	local max_target = nil
	local enemies_mayBeTarget, unknowns, friends = {}, {}, {}
	local JinXuanDi = self.room:findPlayerBySkillName("wuling")
	local fire_mark = JinXuanDi and JinXuanDi:getMark("@fire") > 0 or false
	local care_lord = ( self.role == "renegade" and self.room:alivePlayerCount() > 2 )
	local function getPindianValue(p, is_friend)
		local v = 10
		if p:hasSkill("tuntian") then
			v = v - 2
		end
		if p:getHandcardNum() == 1 and self:needKongcheng(p) then
			v = v - 2
		end
		if not self:hasLoseHandcardEffective(p) then
			v = v - 1
		end
		local damage = 0
		if p:hasSkill("sizhan") then
		elseif p:getMark("@late") > 0 or p:getMark("@fenyong") > 0 or p:getMark("@fog") > 0 then
		else
			damage = 1
			if p:hasSkill("chouhai") and p:isKongcheng() then
				damage = damage + 1
			end
			if fire_mark then
				if p:hasArmorEffect("vine") or p:hasArmorEffect("gale_shell") then
					damage = damage + 1
				end
			end
			if damage > 1 then
				if p:hasArmorEffect("silver_lion") then
					damage = 1
				elseif p:hasSkill("buqu") and p:getHp() == 1 then
					damage = 1
				end
			end
		end
		if damage > 0 then
			v = v + damage * 20
			local will_cause_death = false
			if damage >= p:getHp() then
				if p:hasSkill("niepan") and p:getMark("@nirvana") > 0 then
				elseif p:hasSkill("fuli") and p:getMark("@laoji") > 0 then
				elseif p:hasSkill("buqu") and p:getPile("buqu"):length() < 5 then
				elseif p:hasSkill("nosbuqu") and p:getPile("nosbuqu"):length() < 5 then
				elseif damage >= p:getHp() + self:getAllPeachNum(p) then
					will_cause_death = true
				end
			end
			if will_cause_death then
				v = v + 500
				if care_lord and p:isLord() then
					return v - 1000
				end
				if p:hasSkill("wuhun") then
					local victims = self:getWuhunRevengeTargets()
					for _,victim in ipairs(victims) do
						if self:isFriend(victim) then
							return v - 1000
						elseif care_lord and victim:isLord() then
							return v - 1000
						end
					end
				end
			else
				if self:needToLoseHp(p) then
					v = v - 4
				end
				if self:hasSkills("guixin|yiji|jieming|xuehen|fangzhu|quanji|renjie|tongxin|huashen|nosyiji", p) then
					v = v - 3
				end
			end
		end
		if is_friend then
			v = -v
		end
		return v
	end
	self:sort(targets, "defense")
	for index, p in ipairs(targets) do
		if self:isEnemy(p) then
			handcards = p:getHandcards()
			local flag = string.format("visible_%s_%s", self.player:objectName(), p:objectName())
			local will_lose = false
			local has_unknown_card = false
			for _,c in sgs.qlist(handcards) do
				if c:hasFlag("visible") or c:hasFlag(flag) then
					if c:getNumber() >= my_max_point then
						will_lose = true
						break
					end
				else
					has_unknown_card = true
				end
			end
			if will_lose then
			elseif has_unknown_card then
				table.insert(enemies_mayBeTarget, p)
			else
				--enemies_canBeTarget
				local value = getPindianValue(p)
				value = value - index
				if value > max_value then
					max_value = value
					max_target = p
				end
			end
		elseif self:isFriend(p) then
			table.insert(friends, p)
		else
			table.insert(unknowns, p)
		end
	end
	if max_value == 0 and #enemies_mayBeTarget > 0 then
		local can_invoke = false
		if my_max_point > 10 then
			can_invoke = true
		elseif my_max_point > 9 and self:isWeak() and self:getAllPeachNum() == 0 then
			can_invoke = true
		elseif my_max_point > 8 and self.player:getHp() >= getBestHp(self.player) then
			can_invoke = true
		end
		if can_invoke then
			for index, enemy in ipairs(enemies_mayBeTarget) do
				local value = getPindianValue(enemy)
				value = value * 0.6 - index
				if value > max_value then
					max_value = value
					max_target = enemy
				end
			end
		end
	end
	if max_value == 0 and #friends > 0 then
		friends = sgs.reverse(friends)
		for index, friend in ipairs(friends) do
			local handcards = friend:getHandcards()
			local flag = string.format("visible_%s_%s", self.player:objectName(), friend:objectName())
			local can_win = false
			local has_unknown_card = false
			for _,c in sgs.qlist(handcards) do
				if c:hasFlag("visible") or c:hasFlag(flag) then
					if c:getNumber() < my_max_point then
						can_win = true
						break
					end
				else
					has_unknown_card = true
				end
			end
			if has_unknown_card and my_max_point > 7 and handcards:length() > 3 then
				can_win = true
			end
			if can_win then
				local value = getPindianValue(friend, true)
				value = value * 0.4 - index
				if value > max_value then
					max_value = value
					max_target = friend
				end
			end
		end
	end
	if max_value == 0 and #unknowns > 0 then
		for index, p in ipairs(unknowns) do
			local handcards = p:getHandcards()
			local flag = string.format("visible_%s_%s", self.player:objectName(), p:objectName())
			local will_lose = false
			local has_unknown_card = false
			for _,c in sgs.qlist(handcards) do
				if c:hasFlag("visible") or c:hasFlag(flag) then
					if c:getNumber() >= my_max_point then
						will_lose = true
						break
					end
				else
					has_unknown_card = true
					break
				end
			end
			if will_lose or has_unknown_card then
			else
				local value = getPindianValue(p)
				value = value * 0.5 - index
				if value > max_value then
					max_value = value
					max_target = p
				end
			end
		end
	end
	if max_target and max_value > 0 then
		target = max_target
	end
	if target and #self.friends_noself > 0 then
		local can_recover = {}
		for _,friend in ipairs(self.friends_noself) do
			if target:objectName() == friend:objectName() then
			elseif friend:getLostHp() > 0 then
				table.insert(can_recover, friend)
			end
		end
		if #can_recover > 0 then
			local value = 20
			self:sort(can_recover, "defense")
			local to_recover = can_recover[1]
			if getBestHp(to_recover) >= to_recover:getHp() then
				value = value - 10
			end
			if self:isWeak(to_recover) then
				value = value + 15
			end
			if to_recover:hasSkill("shushen") then
				value = value + 10
			end
			max_value = max_value + value
		end
	end
	if target and self.player:getLostHp() > 0 then
		local value = 20
		if getBestHp(self.player) >= self.player:getHp() then
			value = value - 10
		end
		if self:isWeak() then
			value = value + 15
		end
		if self.player:hasSkill("shushen") and #self.friends_noself > 0 then
			value = value + 10
		end
		max_value = max_value + value
	end
	if target and self:getOverflow() > 0 then
		max_value = max_value + 1
	end
	if target and max_value > 20 and #can_use > 0 then
		self:sortByUseValue(can_use, true)
		local to_use = can_use[1]:getEffectiveId()
		local card_str = string.format("#MdkTanBaiCard:%d:->%s", to_use, target:objectName())
		local acard = sgs.Card_Parse(card_str)
		use.card = acard
		if use.to then
			use.to:append(target)
		end
	end
end
--相关信息
sgs.ai_use_value["MdkTanBaiCard"] = 8.1
sgs.ai_use_priority["MdkTanBaiCard"] = 9.5
sgs.ai_card_intention["MdkTanBaiCard"] = function(self, card, from, tos)
	for _,to in ipairs(tos) do
		local intention = 125
		if self:hasSkills(sgs.masochism_skill, to) then
			if to:getHp() > 1 then
				intention = 0
			elseif to:getHp() + self:getAllPeachNum(to) > 1 then
				intention = 0
			end
		end
		if intention ~= 0 then
			sgs.updateIntention(from, to, intention)
		end
	end
end
sgs.ai_playerchosen_intention["MdkTanBai"] = function(self, from, to)
	local intention = -80
	if getBestHp(to) >= to:getHp() then
		intention = 0
	end
	if intention ~= 0 then
		sgs.updateIntention(from, to, intention)
	end
end
sgs.ai_cardneed["MdkTanBai"] = function(friend, hcard, self)
	if friend:getMark("@MdkTanBaiMark") > 0 then
		if friend:getPhase() == sgs.Player_Play or not self:willSkipPlayPhase(friend) then
			return hcard:getNumber() > 11
		end
	end
end
--[[
	技能：倾心（联动技->上条恭介）
	描述：上条恭介的草花判定牌生效时，你可以摸一张牌。
]]--
--source:askForSkillInvoke("MdkQingXin", data)
sgs.ai_skill_invoke["MdkQingXin"] = true
--[[****************************************************************
	编号：MDK - 08
	武将：上条恭介（Kamijou Kyousuke）
	称号：不幸的音乐家
	性别：男
	势力：魏
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：才华（锁定技）
	描述：你使用草花牌无距离限制和次数限制。
]]--
sgs.ai_cardneed["MdkCaiHua"] = function(friend, hcard, self)
	return hcard:getSuit() == sgs.Card_Club
end
--[[
	技能：残体（锁定技）
	描述：出牌阶段开始时，若你没有受伤，你选择一项：弃置一张装备牌，或者失去1点体力。
]]--
--room:askForCard(player, "EquipCard", "@MdkCanTi", data, "MdkCanTi")
sgs.ai_skill_cardask["@MdkCanTi"] = function(self, data, pattern, target, target2, arg, arg2)
	local can_eat_peach = false
	local n_peach = self:getCardsNum("Peach")
	if n_peach > 0 then
		can_eat_peach = true
		local peach = sgs.Sanguosha:cloneCard("peach", sgs.Card_NoSuit, 0)
		peach:deleteLater()
		if self.player:isLocked(peach) then
			can_eat_peach = false
		else
			local has_weak_friend = false
			for _,friend in ipairs(self.friends_noself) do
				if self:isWeak(friend) then
					has_weak_friend = true
					break
				end
			end
			if has_weak_friend and n_peach < #self.enemies then
				can_eat_peach = false
			end
		end
	end
	if can_eat_peach then
		return "."
	end
	if self.player:hasSkill("MdkZhiYu") then
		if self:hasSuit("heart", true, self.player) then
			return "."
		end
	end
	if self.player:hasSkill("jieyin") and #self.friends_noself > 0 then
		if self.player:getHandcardNum() >= 2 and self.player:canDiscard(self.player, "h") then
			for _,friend in ipairs(self.friends_noself) do
				if friend:isMale() and friend:getLostHp() > 0 then
					return "."
				end
			end
		end
	end
	if getBestHp(self.player) > self.player:getHp() then
		return "."
	end
	if self:needToLoseHp() then
		return "."
	end
end
--[[
	技能：痊愈（觉醒技）
	描述：回合结束后，若你累计在你的三个回合内回复过体力，你失去技能“残体”并获得技能“演出”。
]]--
--[[
	技能：演出（阶段技）
	描述：你可以进行一次判定。若结果为黑色：本阶段内你使用草花牌可以额外指定一名角色为目标，然后你重复此流程；你获得因此产生的所有黑色判定牌。
]]--
--YanChuCard:Play
local yanchu_skill = {
	name = "MdkYanChu",
	getTurnUseCard = function(self, inclusive)
		if not self.player:hasUsed("#MdkYanChuCard") then
			return sgs.Card_Parse("#MdkYanChuCard:.:")
		end
	end,
}
table.insert(sgs.ai_skills, yanchu_skill)
sgs.ai_skill_use_func["#MdkYanChuCard"] = function(card, use, self)
	use.card = card
end
--相关信息
sgs.ai_use_priority["MdkYanChuCard"] = 10
sgs.ai_use_value["MdkYanChuCard"] = 9.9
--[[
	技能：惊觉（联动技->美树沙耶香）
	描述：出牌阶段结束时，若你本阶段发动“演出”获得了至少三张黑色牌，你可以弃一张牌，令美树沙耶香摸两张牌。
]]--
--room:askForUseCard(player, "@@MdkJingJue", "@MdkJingJue")
sgs.ai_skill_use["@@MdkJingJue"] = function(self, prompt, method)
	if self.player:isNude() then
		return "."
	end
	local targets = {}
	for _,p in ipairs(self.friends) do
		if p:getGeneralName() == "MikiSayaka" or p:getGeneral2Name() == "MikiSayaka" then
			table.insert(targets, p)
		end
	end
	if #targets == 0 then
		return "."
	end
	local target = nil
	local PangTong = nil
	if #targets == 1 then
		target = targets[1]
		if target:hasSkill("manjuan") then
			if target:getPhase() == sgs.Player_NotActive then
				PangTong = target
				target = nil
			end
		end
	elseif #targets > 1 then
		self:sort(targets, "defense")
		local weak_friends, cardneed_friends, good_friends, other_friends = {}, {}, {}, {}
		for _,friend in ipairs(targets) do
			if friend:hasSkill("manjuan") and friend:getPhase() == sgs.Player_NotActive then
				PangTong = friend
			elseif self:isWeak(friend) then
				table.insert(weak_friends, friend)
			elseif self:hasSkills(sgs.notActive_cardneed_skill, friend) then
				table.insert(cardneed_friends, friend)
			elseif self:hasSkills(sgs.Active_cardneed_skill.."|"..sgs.priority_skill, friend) then
				table.insert(good_friends, friend)
			else
				table.insert(other_friends, friend)
			end
		end
		target = weak_friends[1] or cardneed_friends[1] or good_friends[1] or other_friends[1]
	end
	if not target then
		if PangTong and self.player:getHandcardNum() == 1 and self:needKongcheng() then
			local card = self.player:getHandcards():first()
			if not isCard("Peach", card, self.player) then
				target = PangTong
			end
		end
	end
	if not target then
		return "."
	end
	local flag = false
	if self.player:isKongcheng() then
		flag = true
	elseif self:getOverflow() <= 0 then
		flag = true
	end
	local to_discard = self:askForDiscard("dummy", 1, 1, false, flag)
	if #to_discard == 0 then
		return "."
	end
	local use_str = string.format("#MdkJingJueCard:%d:->%s", to_discard[1], target:objectName())
	return use_str
end
--相关信息
sgs.ai_card_intention["MdkJingJueCard"] = function(self, card, from, tos)
	for _,to in ipairs(tos) do
		if from:objectName() == to:objectName() then
		elseif to:hasSkill("manjuan") then
		else
			sgs.updateIntention(from, to, -50)
		end
	end
end
--[[****************************************************************
	编号：MDK - 09
	武将：百江渚（Momoe Nagisa）
	称号：可爱的后辈
	性别：女
	势力：群
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：贪酪
	描述：摸牌阶段开始时，你可以选择一名角色。若如此做，你额外摸一张牌，且本回合内，若其存活，除该角色外的角色不能成为你所使用牌的目标。
]]--
--room:askForPlayerChosen(player, alives, "MdkTanLao", "@MdkTanLao", true)
sgs.ai_skill_playerchosen["MdkTanLao"] = function(self, targets)
	if self:hasSkills("MdkChiHuo|shelie") then
		return nil
	end
	local draw_skills = {"zaiqi", "luoyi", "nosfuhun"}
	for _,skill in ipairs(draw_skills) do
		if self.player:hasSkill(skill) then
			local callback = sgs.ai_skill_invoke[skill]
			local invoke = false
			if type(callback) == "function" then
				invoke = callback(self, sgs.QVariant())
			elseif type(callback) == "boolean" then
				invoke = callback
			end
			if invoke then
				return nil
			end
		end
	end
	if #self.enemies == 0 then
		return self.player
	end
	local handcards = self.player:getHandcards()
	local forMe, forOther, forAll = {}, {}, {}
	for _,c in sgs.qlist(handcards) do
		if c:isKindOf("GaleShell") or c:isKindOf("Snatch") or c:isKindOf("SupplyShortage") then
			table.insert(forOther, c)
		elseif c:isKindOf("EquipCard") or c:isKindOf("ExNihilo") or c:isKindOf("Lightning") then
			table.insert(forMe, c)
		elseif c:isKindOf("Peach") and self.player:getLostHp() > 0 then
			table.insert(forMe, c)
		elseif c:isKindOf("Slash") then
			table.insert(forOther, c)
		elseif c:isKindOf("Dismantlement") or c:isKindOf("Duel") or c:isKindOf("FireAttack") or c:isKindOf("Indulgence") then
			table.insert(forOther, c)
		elseif c:isKindOf("AOE") then
			table.insert(forOther, c)
		elseif c:isKindOf("GlobalEffect") then
			table.insert(forAll, c)
		end
	end
	if #forOther > 0 then
		local reallyForOther = {}
		self:sort(self.enemies, "defense")
		for _,c in ipairs(forOther) do
			for _,enemy in ipairs(self.enemies) do
				if c:targetFilter(sgs.PlayerList(), enemy, self.player) then
					table.insert(reallyForOther, c)
					break
				end
			end
		end
		forOther = reallyForOther
	end
	if #forMe > 0 then
		local reallyForMe = {}
		for _,c in ipairs(forMe) do
			local dummy_use = {
				isDummy = true,
			}
			self:useCardByClassName(c, dummy_use)
			if dummy_use.card then
				table.insert(reallyForMe, c)
			end
		end
		forMe = reallyForMe
	end
	if #forMe > 0 and #forOther == 0 then
		return self.player
	elseif #forMe == 0 and #forOther > 0 then
		local count = {}
		for _,c in ipairs(forOther) do
			if not c:isKindOf("AOE") then
				local dummy_use = {
					isDummy = true,
					to = sgs.SPlayerList(),
				}
				self:useCardByClassName(c, dummy_use)
				if dummy_use.card and not dummy_use.to:isEmpty() then
					for _,p in sgs.qlist(dummy_use.to) do
						count[p:objectName()] = ( count[p:objectName()] or 0 ) + 1
					end
				end
			end
		end
		local max_name = nil
		local max_num = 0
		for name, num in pairs(count) do
			if num > max_num then
				max_num = num
				max_name = name
			end
		end
		if max_name then
			local others = self.room:getOtherPlayers(self.player)
			for _,p in sgs.qlist(others) do
				if p:objectName() == max_name then
					return p
				end
			end
		end
	end
end
--相关信息
local system_useEquipCard = SmartAI.useEquipCard
function SmartAI:useEquipCard(card, use)
	if self.player:hasSkill("MdkTanLao") and self.player:getMark("MdkTanLaoInvoked") > 0 then
		if self.player:getMark("@MdkTanLaoMark") == 0 then
			local others = self.room:getOtherPlayers(self.player)
			for _,p in sgs.qlist(others) do
				if p:getMark("@MdkTanLaoMark") > 0 then
					return 
				end
			end
		end
	end
	system_useEquipCard(self, card, use)
end
local system_useCardByClassName = SmartAI.useCardByClassName
function SmartAI:useCardByClassName(card, use)
	if card and card:isKindOf("EquipCard") then
		if self.player:hasSkill("MdkTanLao") and self.player:getMark("MdkTanLaoInvoked") > 0 then
			if self.player:getMark("@MdkTanLaoMark") == 0 then
				local others = self.room:getOtherPlayers(self.player)
				for _,p in sgs.qlist(others) do
					if p:getMark("@MdkTanLaoMark") > 0 then
						return 
					end
				end
			end
		end
	end
	system_useCardByClassName(self, card, use)
end
--[[
	技能：气泡
	描述：出牌阶段，你使用【杀】造成伤害时，你可以令目标防止此伤害并失去等量体力，然后其获得一枚“泡泡”标记直到其回合结束。该角色的攻击范围-X（X为其拥有的“泡泡”标记数）
]]--
--player:askForSkillInvoke("MdkQiPao", sgs.QVariant(prompt))
sgs.ai_skill_invoke["MdkQiPao"] = function(self, data)
	--invoke:target::damage
	local prompt = data:toString():split(":")
	local name, x = prompt[2], tonumber(prompt[4])
	local target = nil
	local alives = self.room:getAlivePlayers()
	for _,p in sgs.qlist(alives) do
		if p:objectName() == name then
			target = p
			break
		end
	end
	if not target then
		return false
	end
	if self:cantbeHurt(target, self.player, x) then
		return true
	end
	local damage = self.room:getTag("MdkQiPaoData"):toDamage()
	local nature = damage and damage.nature or sgs.DamageStruct_Normal
	local n_damage = damage and damage.damage or x
	if nature ~= sgs.DamageStruct_Normal and target:isChained() then
		local care_lord = ( self.role == "renegade" and self.room:alivePlayerCount() > 2 )
		for _,p in sgs.qlist(alives) do
			if p:objectName() == target:objectName() or p:hasSkill("sizhan") then
			elseif p:isChained() and self:damageIsEffective(p, nature, self.player) then
				if self:cantbeHurt(p, self.player, n_damage) then
					return true
				end
				if self:isFriend(p) then
					if self:isWeak(p) then
						return true
					elseif not self:getDamagedEffects(p, self.player, false) then
						return true
					end
				else
					local may_cause_death = false
					if p:getHp() > n_damage then
					elseif p:hasSkill("niepan") and p:getMark("@nirvana") > 0 then
					elseif p:hasSkill("fuli") and p:getMark("@laoji") > 0 then
					elseif p:hasSkill("buqu") and p:getPile("buqu"):isEmpty() then
					elseif p:hasSkill("nosbuqu") and p:getPile("buqu"):isEmpty() then
					else
						may_cause_death = true
					end
					if may_cause_death then
						if p:getHp() + self:getAllPeachNum(p) > n_damage then
							may_cause_death = false
						end
					end
					if may_cause_death then
						if care_lord and p:isLord() then
							return true
						end
					elseif self:getDamagedEffects(p, self.player, false) then
						return true
					end
				end
			end
		end
		--考虑闪电：若有队友能改判，则发动此技能，以免破坏铁索连环
		if n_damage < 3 and #self.enemies > 1 then
			local lightning_target = nil
			for _,p in sgs.qlist(alives) do
				if p:containsTrick("lightning") and not p:containsTrick("YanxiaoCard") then
					lightning_target = p
					break
				end
			end
			if lightning_target then
				local case, wizard = self:getFinalRetrial(lightning_target, "lightning")
				if case == 1 then
					local chained_enemy = 0
					for _,enemy in ipairs(self.enemies) do
						if enemy:isChained() then
							chained_enemy = chained_enemy + 1
						end
					end
					if chained_enemy > 1 then
						return true
					end
				end
			end
		end
		return false
	end
	local will_cause_death = false
	if n_damage >= target:getHp() and not target:hasSkill("sizhan") then
		if target:hasSkill("niepan") and target:getMark("@nirvana") > 0 then
		elseif target:hasSkill("fuli") and target:getMark("@fuli") > 0 then
		elseif target:hasSkill("buqu") and target:getPile("buqu"):isEmpty() then
		elseif target:hasSkill("nosbuqu") and target:getPile("nosbuqu"):isEmpty() then
		elseif n_damage >= target:getHp() + self:getAllPeachNum(target) then
			will_cause_death = true
		end
	end
	local is_friend = self:isFriend(target)
	if will_cause_death and not target:hasSkill("yuwen") then
		--断肠
		if target:hasSkill("duanchang") then
			local has_good_skill = false
			local my_skills = self.player:getVisibleSkillList()
			local bad_skills = sgs.bad_skills or "benghuai|wumou|shiyong|yaowu|zaoyao|chanyuan|chouhai|ranshang"
			for _,skill in sgs.qlist(my_skills) do
				if skill:inherits("SPConvertSkill") then
				elseif skill:isAttachedLordSkill() then
				elseif skill:isLordSkill() and not self.player:hasLordSkill(skill:objectName()) then
				elseif string.find(bad_skills, skill:objectName()) then 
				else
					has_good_skill = true
					break
				end
			end
			if has_good_skill then
				return true
			end
		end
		--毒士
		if target:hasSkill("dushi") and not self.player:hasSkill("benghuai") then
			return true
		end
		--追忆
		if is_friend and target:hasSkill("zhuiyi") then
			return true
		end
		--挥泪
		if target:hasSkill("huilei") and not self.player:isNude() then
			if self.player:isKongcheng() then
			elseif self.player:getHandcardNum() == 1 and self:needKongcheng() then
			elseif not self:hasLoseHandcardEffective() then
			else
				return true
			end
			local n_equips = self.player:getEquips():length()
			if n_equips > 1 then
				return true
			elseif n_equips == 1 then
				if self.player:getArmor() and self:needToThrowArmor() then
				elseif self:hasSkills(sgs.lose_equip_skill) then
				else
					return true
				end
			end
		end
		--击杀奖惩
		local role = sgs.evaluatePlayerRole(target)
		if self.role == "lord" and role == "loyalist" then
			return true
		elseif role == "rebel" then
			return false
		end
		--连破
		if self.player:hasSkill("lianpo") then
			return false
		end
		--焚心
		if self.player:hasSkill("fenxin") and self.role == "renegade" then
			return false
		end
		--献图：防止队友失去体力
		if self.player:getMark("XiantuKill") == 0 then
			for _,friend in ipairs(self.friends_noself) do
				if friend:hasSkill("xiantu") and friend:hasFlag("XiantuInvoked") then
					return false
				end
			end
		end
	end
	--恃勇：扣减体力上限
	local slash = damage.card or sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	if slash:isRed() and target:hasSkill("shiyong") then
		return is_friend and true or false
	end
	--伤害点数情况
	if self:getDamagedEffects(target, self.player, true) then
		return is_friend and false or true
	elseif target:hasSkill("zhaxiang") and not hasManjuanEffect(player) then
		return is_friend and true or false
	elseif n_damage > 1 and target:hasArmorEffect("silver_lion") then
		return is_friend and false or true
	elseif target:hasSkill("chouhai") and target:isKongcheng() then
		return is_friend and true or false
	end
	--疠火：防止自己失去体力
	local skillname = slash:getSkillName()
	if skillname == "lihuo" then
		return true
	--父魂：自己获得技能
	elseif skillname == "fuhun" then
		return false
	end
	--狂暴：自己获得暴怒标记
	if self.player:hasSkill("kuangbao") and self:hasSkills("wumou|wuqian|shenfen")then
		return false
	end
	--武继：攒伤害加速自己觉醒
	if self.player:hasSkill("wuji") and self.player:getMark("wuji") == 0 then
		if self.player:getMark("damage_point_round") < 3 then
			return false
		end
	end
	if not is_friend then
		if self.player:distanceTo(target) == 1 then
			--潜袭：扣减体力上限
			if self.player:hasSkill("nosqianxi") then
				return false
			--狂骨：回复自己体力
			elseif self.player:hasSkill("kuanggu") and self.player:getLostHp() > 0 then
				return false
			end
		end
		--烈刃：发动拼点
		if self.player:hasSkill("lieren") then
			if self.player:isKongcheng() or target:isKongcheng() then
			else
				return false
			end
		end
	end
	--破军：翻面
	if self.player:hasSkill("pojun") then
		if self:toTurnOver(target, n_damage, "pojun") then
			if not is_friend then
				return false
			end
		else
			if is_friend then
				return false
			end
		end
	end
	--暴虐：令主公回复体力
	if self.player:getKingdom() == "qun" and not self.player:hasSkill("hongyan") then
		for _,friend in ipairs(self.friends_noself) do
			if friend:hasLordSkill("baonve") and friend:getLostHp() > 0 then
				return false
			end
		end
	end
	return is_friend and false or true
end
--[[
	技能：变脸（阶段技）
	描述：你可以将武将牌翻面。你的武将牌状态改变时，你可以弃一张非基本牌，令你的武将牌恢复至原先的状态，然后你可以视为使用了一张【杀】。
	说明：你因“变脸”将武将牌翻面、重置、横置时，不可重复触发此技能。
]]--
--room:askForCard(player, "^BasicCard|.|.|.", prompt, data, "MdkBianLian")
sgs.ai_skill_cardask["@MdkBianLianTurnDown"] = function(self, data, pattern, target, target2, arg, arg2)
	--询问是否从正面向上翻到背面向上
	local invoke = false
	if self.player:hasSkill("cangni") and self.player:getPhase() == sgs.Player_NotActive then
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:deleteLater()
		local dummy_use = {
			isDummy = true,
		}
		self:useBasicCard(slash, dummy_use)
		if dummy_use.card then
			invoke = true
		end
	end
	if invoke then
		local cards = self.player:getCards("he")
		local can_discard = {}
		for _,c in sgs.qlist(cards) do
			if c:isKindOf("BasicCard") then
			elseif self.player:canDiscard(self.player, c:getEffectiveId()) then
				table.insert(can_discard, c)
			end
		end
		if #can_discard > 0 then
			self:sortByKeepValue(can_discard)
			return "$"..can_discard[1]:getEffectiveId()
		end
	end
	return "."
end
sgs.ai_skill_cardask["@MdkBianLianTurnUp"] = function(self, data, pattern, target, target2, arg, arg2)
	--询问是否从背面向上翻到正面向上
	local cards = self.player:getCards("he")
	local can_discard = {}
	for _,c in sgs.qlist(cards) do
		if c:isKindOf("BasicCard") then
		elseif self.player:canDiscard(self.player, c:getEffectiveId()) then
			table.insert(can_discard, c)
		end
	end
	if #can_discard > 0 then
		if self.player:getPhase() == sgs.Player_Play then
			self:sortByUseValue(can_discard, true)
		else
			self:sortByKeepValue(can_discard)
		end
		return "$"..can_discard[1]:getEffectiveId()
	end
	return "."
end
--room:askForCard(player, "^BasicCard|.|.|.", prompt, data, "MdkBianLian")
sgs.ai_skill_cardask["@MdkBianLianChainBack"] = function(self, data, pattern, target, target2, arg, arg2)
	--询问是否解除连环状态
	if self:isGoodChainPartner() then
		return "."
	end
	local cards = self.player:getCards("he")
	local can_discard = {}
	for _,c in sgs.qlist(cards) do
		if c:isKindOf("BasicCard") then
		elseif self.player:canDiscard(self.player, c:getEffectiveId()) then
			table.insert(can_discard, c)
		end
	end
	if #can_discard > 0 then
		if self.player:getPhase() == sgs.Player_Play then
			self:sortByUseValue(can_discard, true)
		else
			self:sortByKeepValue(can_discard)
		end
		return "$"..can_discard[1]:getEffectiveId()
	end
	return "."
end
sgs.ai_skill_cardask["@MdkBianLianChain"] = function(self, data, pattern, target, target2, arg, arg2)
	--询问是否进入连环状态
	local invoke = false
	if self:isGoodChainPartner() then
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:deleteLater()
		local dummy_use = {
			isDummy = true,
		}
		self:useBasicCard(slash, dummy_use)
		if dummy_use.card then
			invoke = true
		end
	end
	if invoke and self:getCardsNum("Peach") > 0 then
		local cards = self.player:getCards("he")
		local can_discard = {}
		for _,c in sgs.qlist(cards) do
			if c:isKindOf("BasicCard") then
			elseif self.player:canDiscard(self.player, c:getEffectiveId()) then
				table.insert(can_discard, c)
			end
		end
		if #can_discard > 0 then
			self:sortByKeepValue(can_discard)
			return "$"..can_discard[1]:getEffectiveId()
		end
	end
	return "."
end
--room:askForUseCard(player, "@@MdkBianLian", "@MdkBianLianSlash")
sgs.ai_skill_use["@@MdkBianLian"] = function(self, prompt, method)
	local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	slash:deleteLater()
	local dummy_use = {
		isDummy = true,
		to = sgs.SPlayerList(),
	}
	self:useBasicCard(slash, dummy_use)
	if dummy_use.card and not dummy_use.to:isEmpty() then
		local targets = {}
		for _,p in sgs.qlist(dummy_use.to) do
			table.insert(targets, p:objectName())
		end
		targets = table.concat(targets, "+")
		local use_str = string.format("#BianLianSlashCard:.:->%s", targets)
		return use_str
	end
	return "."
end
--BianLianCard:Play
local bianlian_skill = {
	name = "MdkBianLian",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#MdkBianLianCard") then
			return nil
		end
		return sgs.Card_Parse("#MdkBianLianCard:.:")
	end,
}
table.insert(sgs.ai_skills, bianlian_skill)
sgs.ai_skill_use_func["#MdkBianLianCard"] = function(card, use, self)
	--判断是否需要翻面
	local faceUpNow = self.player:faceUp()
	local canTurnBySkill = false
	if self.player:isSkipped(sgs.Player_Finish) then
	elseif self.player:getPhases():contains(sgs.Player_Finish) then
		if self:hasSkills("jushou|nosjushou|neojushou|kuiwei|zhenggong") then
			canTurnBySkill = true
		end
		if self.player:hasSkill("MdkHuiZhuan") then
			faceUpNow = not faceUpNow
		end
	end
	if faceUpNow == canTurnBySkill then
		use.card = card
		return 
	end
	--判断是否要弃置防具
	local armor = self.player:getArmor()
	if armor and self.player:canDiscard(self.player, armor:getEffectiveId()) then
		if self:needToThrowArmor() then
			use.card = card
			return
		end
	end
	--判断是否需要空城
	if self.player:getHandcardNum() == 1 and self:needKongcheng() then
		local handcard = self.player:getHandcards():first()
		if handcard:isKindOf("BasicCard") then
		elseif self.player:canDiscard(self.player, handcard:getEffectiveId()) then
			use.card = card
			return
		end
	end
	--判断是否需要多使用一张【杀】
	if #self.enemies == 0 then
		return
	end
	local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	slash:deleteLater()
	if self.player:isLocked(slash) then
		return
	end
	local dummy_use = {
		isDummy = true,
		to = sgs.SPlayerList(),
	}
	self:useBasicCard(slash, dummy_use)
	local victim = nil
	if dummy_use.card and not dummy_use.to:isEmpty() then
		victim = dummy_use.to:first()
	else
		return
	end
	--判断是否能必杀对手
	if victim and self:isEnemy(victim) then
		local may_cause_death = false
		local no_jink = self:canHit(victim, self.player)
		if no_jink then
			local damage = self:hasHeavySlashDamage(self.player, slash, victim, true)
			local hp = victim:getHp()
			if damage >= hp and damage >= hp + self:getAllPeachNum(victim) then
				if victim:hasSkill("niepan") and victim:getMark("@nirvana") then
				elseif victim:hasSkill("fuli") and victim:getMark("@laoji") then
				elseif victim:hasSkill("buqu") and victim:getPile("buqu"):length() < 5 then
				elseif victim:hasSkill("nosbuqu") and victim:getPile("nosbuqu"):length() < 5 then
				else
					may_cause_death = true
					local can_save = false
					local alives = self.room:getAlivePlayers()
					for _,p in sgs.qlist(alives) do
						if self:isFriend(p, victim) then
							if p:hasSkill("MdkLunHui") and not p:isChained() then
								if p:objectName() == victim:objectName() or p:inMyAttackRange(victim) then
									local mark = p:getMark("@MdkLunHuiMark")
									if mark == 0 then
										can_save = true
										break
									elseif p:canDiscard(p, "he") and p:getCardCount() >= mark then
										can_save = true
										break
									end
								end
							end
							if p:hasSkill("MdkZhiYin") then
								if p:canDiscard(p, "he") and self:hasSuit("red", true, p) then
									can_save = true
									break
								end
							end
						end
					end
					if can_save then
						may_cause_death = false
					end
				end
			end
			if may_cause_death then
				local care_lord = ( self.role == "renegade" and self.room:alivePlayerCount() > 2 )
				if care_lord and victim:isLord() then
					return
				end
				use.card = card
				return 
			end
		end
	end
	--判断是否有非基本牌可供弃置以便翻回
	local find_to_discard = nil
	local cards = self.player:getCards("he")
	for _,c in sgs.qlist(cards) do
		if c:isKindOf("BasicCard") then
		else
			local id = c:getEffectiveId()
			if self.player:canDiscard(self.player, id) then
				find_to_discard = c
				local place = self.room:getCardPlace(id)
				if place == sgs.Player_PlaceEquip then
					local rangefix = 0
					if c:isKindOf("Weapon") then
						rangefix = sgs.weapon_range[c:getClassName()] or 1
						if rangefix == 1 then
							rangefix = 0
						end
					elseif c:isKindOf("OffensiveHorse") then
						rangefix = 1
					end
					if rangefix == 0 or self.player:canSlash(victim, slash, true, rangefix) then
					else
						find_to_discard = nil
					end
				end
				if find_to_discard then
					break
				end
			end
		end
	end
	if find_to_discard then
		use.card = card
		return
	end
	--若没有非基本牌，判断是否有能力依靠自己的技能或队友的配合翻回
	if self:isWeak() then
		return
	end
	if self:hasSkills("jiushi|guixin|toudu") then
		use.card = card
		return
	end
	for _,friend in ipairs(self.friends_noself) do
		if self:hasSkills("junxing|fangzhu|jilve", friend) then
			use.card = card
			return
		end
	end
end
--相关信息
sgs.ai_use_value["MdkBianLianCard"] = sgs.ai_use_value["Slash"]
sgs.ai_use_priority["MdkBianLianCard"] = sgs.ai_use_priority["Slash"] - 0.1
--[[
	技能：鼓舞（联动技->巴麻美、锁定技）
	描述：巴麻美每次回复的体力+1。当巴麻美失去最后的手牌时，你令其摸一张牌。
]]--
--相关信息
local System_getLeastHandcardNum = SmartAI.getLeastHandcardNum
function SmartAI:getLeastHandcardNum(player)
	player = player or self.player
	local result = System_getLeastHandcardNum(self, player)
	if result < 1 then
		if player:getGeneralName() == "TomoeMami" or player:getGeneral2Name() == "TomoeMami" then
			local alives = self.room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				if p:hasSkill("MdkGuWu") then
					result = 1
					break
				end
			end
		end
	end
	return result
end
--[[
	技能：解答（联动技->神·鹿目圆）
	描述：你从神·鹿目圆处获得牌时，你获得一枚“令”标记。你的手牌上限+X（X为你的“令”标记的数量）。神·鹿目圆或你攻击范围内的一名其他角色的回合结束时，你可以弃一枚“令”标记，交给其两张牌，然后你摸两张牌。
]]--
--room:askForUseCard(source, "@@MdkJieDa", prompt)
sgs.ai_skill_use["@@MdkJieDa"] = function(self, prompt, method)
	local target = self.room:getCurrent()
	local toMySelf, toFriend = false, false
	if target and target:objectName() == self.player:objectName() then
		toMySelf = true
	elseif target and self:isFriend(target) then
		toFriend = true
	else
		return "."
	end
	local cards = self.player:getCards("he")
	if cards:length() < 2 then
		return "."
	end
	local weak = self:isWeak(target)
	local n_seat_enemy = nil
	if target:isKongcheng() and self:needKongcheng(target) then
		local should_kongcheng = true
		if weak then
			if isMyself then
				should_kongcheng = false
			else
				n_seat_enemy = self:getEnemyNumBySeat(self.player, target)
				if n_seat_enemy >= 1 then
					should_kongcheng = false
				end
			end
		end
		if should_kongcheng then
			return "."
		end
	end
	local overflow = self:getOverflow()
	if toMySelf then
		local invoke = false
		local selected = {}
		local equips = self.player:getEquips()
		if equips:length() > 0 then
			invoke = true
			equips = sgs.QList2Table(equips)
			self:sortByKeepValue(equips)
			for _,equip in ipairs(equips) do
				table.insert(selected, equip:getEffectiveId())
				if #selected == 2 then
					break
				end
			end
		end
		if not invoke then
			if overflow <= -2 then
				invoke = true
			elseif overflow <= 0 then
				if self.player:hasSkill("manjuan") then
					invoke = true
				elseif self:hasSkills(sgs.notActive_cardneed_skill) then
					invoke = true
				end
			end
		end
		if not invoke then
			if weak and #self.enemies > 0 and overflow <= 1 then
				invoke = true
			end
		end
		if invoke then
			local to_obtain = {}
			local n = 2 - #selected
			if n > 0 then
				local hasFlag = self.player:hasFlag("Global_AIDiscardExchanging")
				if not hasFlag then
					self.player:setFlags("Global_AIDiscardExchanging")
				end
				to_obtain = self:askForDiscard("dummy", 2, 2, false, false)
				if not hasFlag then
					self.player:setFlags("-Global_AIDiscardExchanging")
				end
			end
			if #selected > 0 then
				for _,id in ipairs(selected) do
					table.insert(to_obtain, id)
				end
			end
			if #to_obtain == 2 then
				local use_str = string.format("#MdkJieDaCard:%s:->.", table.concat(to_obtain, "+"))
				return use_str
			end
		end
		return "."
	end
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards, true)
	local to_give, rest = {}, {}
	if weak and target:getHandcardNum() < 3 then
		n_seat_enemy = n_seat_enemy or self:getEnemyNumBySeat(self.player, target)
		for _,c in ipairs(cards) do
			local flag = false
			if isCard("Peach", c, target) or isCard("Analeptic", c, target) then
				table.insert(to_give, c:getEffectiveId())
				flag = true
			elseif isCard("Jink", c, target) and n_seat_enemy > 0 then
				table.insert(to_give, c:getEffectiveId())
				flag = true
			end
			if flag then
				if #to_give == 2 then
					break
				end
			else
				table.insert(rest, c)
			end
		end
	end
	local crossbow = self:hasCrossbowEffect(target)
	if #to_give < 2 and not crossbow then
		if #rest > 0 then
			cards, rest = rest, {}
		end
		if self:hasSkill("longdan|longhun|wusheng|wushen|keji", target) and target:getHandcardNum() > 2 then
			for index, c in ipairs(cards) do
				if c:isKindOf("Crossbow") then
					table.insert(to_give, c:getEffectiveId())
					table.remove(cards, index)
					crossbow = true
					break
				end
			end
		end
	end
	local has_slash_target = false
	if #to_give < 2 and crossbow then
		if #rest > 0 then
			cards, rest = rest, {}
		end
		if #self.enemies > 0 then
			for _,enemy in ipairs(self.enemies) do
				if target:distanceTo(enemy) <= 1 and sgs.isGoodTarget(enemy, self.enemies, self) then
					has_slash_target = true
					break
				end
			end
		end
		if has_slash_target then
			for _,c in ipairs(cards) do
				local flag = false
				if isCard("Slash", c, target) then
					table.insert(to_give, c:getEffectiveId())
					flag = true
				end
				if flag then
					if #to_give == 2 then
						break
					end
				else
					table.insert(rest, c)
				end
			end
		end
	end
	if #to_give < 2 and not has_slash_target then
		local range = target:getAttackRange()
		if #self.enemies > 0 then
			for _,enemy in ipairs(self.enemies) do
				if target:distanceTo(enemy) <= range and sgs.isGoodTarget(enemy, self.enemies, self) then
					has_slash_target = true
					break
				end
			end
		end
		if not has_slash_target then
			if #rest > 0 then
				cards, rest = rest, {}
			end
			local good_target = {}
			for index, c in ipairs(cards) do
				local flag = false
				if c:isKindOf("Weapon") and not target:getWeapon() then
					--local weapon_range = c:toWeapon():getRange()
					local weapon_range = sgs.weapon_range[c:getClassName()] or 1
					for _,enemy in ipairs(self.enemies) do
						local dist = target:distanceTo(enemy)
						if dist > range and dist <= range + weapon_range then
							local good = good_target[enemy:objectName()] 
							if type(good) == "nil" then
								good = sgs.isGoodTarget(enemy, self.enemies, self)
								good_target[enemy:objectName()] = good
							end
							if good then
								table.insert(to_give, c:getEffectiveId())
								table.remove(cards, index)
								flag = true
								break
							end
						end
					end
				elseif c:isKindOf("OffensiveHorse") and not target:getOffensiveHorse() then
					for _,enemy in ipairs(self.enemies) do
						local dist = target:distanceTo(enemy)
						if dist > range and dist <= range + 1 then
							local good = good_target[enemy:objectName()] 
							if type(good) == "nil" then
								good = sgs.isGoodTarget(enemy, self.enemies, self)
								good_target[enemy:objectName()] = good
							end
							if good then
								table.insert(to_give, c:getEffectiveId())
								table.remove(cards, index)
								flag = true
								break
							end
						end
					end
				end
				if flag then
					break
				end
			end
		end
	end
	if #to_give < 2 then
		if #rest > 0 then
			cards, rest = rest, {}
		end
		local skills = target:getVisibleSkillList(true)
		for _,c in ipairs(cards) do
			local flag = false
			for _,skill in sgs.qlist(skills) do
				local callback = sgs.ai_cardneed[skill:objectName()]
				if type(callback) == "function" then
					if callback(target, c, self) then
						table.insert(to_give, c:getEffectiveId())
						flag = true
						break
					end
				end
			end
			if flag then
				if #to_give == 2 then
					break
				end
			else
				table.insert(rest, c)
			end
		end
	end
	if #to_give < 2 and self.player:getHandcardNum() <= 2 - #to_give then
		if self:needKongcheng() or not self:hasLoseHandcardEffective() then
			if #rest > 0 then
				cards, rest = rest, {}
			end
			for _,c in ipairs(cards) do
				local flag = false
				local id = c:getEffectiveId()
				if self.room:getCardPlace(id) == sgs.Player_PlaceHand then
					table.insert(to_give, id)
					flag = true
				end
				if flag then
					if #to_give == 2 then
						break
					end
				else
					table.insert(rest, c)
				end
			end
		end
	end
	if #to_give < 2 and overflow <= 0 then
		if #rest > 0 then
			cards, rest = rest, {}
		end
		for _,c in ipairs(cards) do
			table.insert(to_give, c:getEffectiveId())
			if #to_give == 2 then
				break
			end
		end
	end
	if #to_give == 2 then
		local use_str = string.format("#MdkJieDaCard:%s:->.", table.concat(to_give, "+"))
		return use_str
	end
	return "."
end
--相关信息
sgs.ai_choicemade_filter["cardUsed"]["@@MdkJieDa"] = function(self, player, promptlist)
	--cardUsed:@@MdkJieDa:@MdkJieDa:sgs2::nil
end
function MdkJieDaCard_intention(self, player, use)
	local skillcard = use.card
	if skillcard and skillcard:objectName() == "MdkJieDaCard" then
		local target = self.room:getCurrent()
		if target and target:objectName() ~= player:objectName() then
			sgs.updateIntention(player, target, -25)
		end
	end
end
table.insert(sgs.ai_choicemade_filter["cardUsed"], MdkJieDaCard_intention)
--[[****************************************************************
	编号：MDK - 10
	武将：魔女之夜（Walpurgis Night）[隐藏武将]
	称号：最终的狂欢
	性别：女
	势力：神
	体力上限：6勾玉
]]--****************************************************************
--[[
	技能：飓风（锁定技）
	描述：游戏开始后或你脱离濒死状态后的第一个出牌阶段开始时，你视为发动了一次“乱武”。
]]--
--room:askForUseSlashTo(p, targets, "@luanwu-slash")
--[[
	技能：肆虐（锁定技）
	描述：出牌阶段，若你未造成过伤害，你使用【杀】无次数限制；你对其他角色造成伤害时，你弃置目标一张装备牌。
]]--
--room:askForCardChosen(player, victim, "e", "MdkSiNve", false, sgs.Card_MethodDiscard)
--[[
	技能：舞台（锁定技）
	描述：其他角色计算的与你的距离+1；你受到的无属性伤害-1。
]]--
local system_damageIsEffective_ = SmartAI.damageIsEffective_
function SmartAI:damageIsEffective_(damageStruct)
	if not system_damageIsEffective_(self, damageStruct) then
		return false
	end
	local victim = damageStruct.to
	if victim and victim:hasSkill("MdkWuTai") then
		local nature = damageStruct.nature or sgs.DamageStruct_Normal
		if nature ~= sgs.DamageStruct_Fire then
			local JinXuanDi = self.room:findPlayerBySkillName("wuling")
			if JinXuanDi and JinXuanDi:getMark("@fire") then
				nature = sgs.DamageStruct_Fire
			end
		end
		if nature == sgs.DamageStruct_Normal then
			local x = ( damageStruct.damage or 1 ) - 1
			return x > 0
		end
	end
	return true
end
--[[
	技能：回转（锁定技）
	描述：回合结束时，你将武将牌翻面并获得一枚“回转”标记。回合开始时，若你的“回转”标记不少于场上人数，你弃掉所有“回转”标记，令所有距离你最近的角色依次失去1点体力上限。
]]--
--[[****************************************************************
	编号：MDK - 11
	武将：神·鹿目圆[隐藏武将]
	称号：希望之神
	性别：女
	势力：神
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：箭雨
	描述：你可以将一张武器牌或红色的【杀】当作【万箭齐发】使用。
]]--
--JianYu:Play
local jianyu_skill = {
	name = "MdkJianYu",
	getTurnUseCard = function(self, inclusive)
		local cards = self.player:getCards("he")
		local can_use = {}
		for _,c in sgs.qlist(cards) do
			if c:isKindOf("Weapon") then
				table.insert(can_use, c)
			elseif c:isKindOf("Slash") and c:isRed() then
				table.insert(can_use, c)
			end
		end
		if #can_use == 0 then
			return nil
		end
		self:sortByKeepValue(can_use)
		local to_use = can_use[1]
		local id = to_use:getEffectiveId()
		local suit = to_use:getSuit()
		local point = to_use:getNumber()
		local card_str = string.format("archery_attack:MdkJianYu[%s:%d]=%d", suit, point, id)
		return sgs.Card_Parse(card_str)
	end,
}
table.insert(sgs.ai_skills, jianyu_skill)
--相关信息
sgs.ai_cardneed["MdkJianYu"] = function(friend, hcard, self)
	if hcard:isKindOf("Weapon") then
		return true
	elseif hcard:isKindOf("Slash") and hcard:isRed() then
		return true
	end
	return false
end
--[[
	技能：指引
	描述：一名角色进入濒死状态时，你可以弃一张红色牌，展示该角色所有手牌并弃置其区域中的所有黑色牌。若如此做，该角色回复1点体力。
		出牌阶段限一次，你可以弃至少一张黑色牌，然后摸等量的牌。
]]--
--ZhiYinCard:Play
local zhiyin_skill = {
	name = "MdkZhiYin",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#MdkZhiYinCard") then
			return nil
		elseif self.player:isNude() then
			return nil
		elseif self.player:canDiscard(self.player, "he") then
			return sgs.Card_Parse("#MdkZhiYinCard:.:")
		end
	end,
}
table.insert(sgs.ai_skills, zhiyin_skill)
sgs.ai_skill_use_func["#MdkZhiYinCard"] = function(card, use, self)
	local unpreferedCards = {}
	local cards = sgs.QList2Table(self.player:getHandcards())

	if self.player:getHp() < 3 then
		local zcards = self.player:getCards("he")
		local use_slash, keep_jink, keep_analeptic, keep_weapon = false, false, false
		local keep_slash = self.player:getTag("JilveWansha"):toBool()
		for _, zcard in sgs.qlist(zcards) do
			if not zcard:isBlack() then
			elseif not isCard("Peach", zcard, self.player) and not isCard("ExNihilo", zcard, self.player) then
				local shouldUse = true
				if isCard("Slash", zcard, self.player) and not use_slash then
					local dummy_use = { isDummy = true , to = sgs.SPlayerList()}
					self:useBasicCard(zcard, dummy_use)
					if dummy_use.card then
						if keep_slash then shouldUse = false end
						if dummy_use.to then
							for _, p in sgs.qlist(dummy_use.to) do
								if p:getHp() <= 1 then
									shouldUse = false
									if self.player:distanceTo(p) > 1 then keep_weapon = self.player:getWeapon() end
									break
								end
							end
							if dummy_use.to:length() > 1 then shouldUse = false end
						end
						if not self:isWeak() then shouldUse = false end
						if not shouldUse then use_slash = true end
					end
				end
				if zcard:getTypeId() == sgs.Card_TypeTrick then
					local dummy_use = { isDummy = true }
					self:useTrickCard(zcard, dummy_use)
					if dummy_use.card then shouldUse = false end
				end
				if zcard:getTypeId() == sgs.Card_TypeEquip and not self.player:hasEquip(zcard) then
					local dummy_use = { isDummy = true }
					self:useEquipCard(zcard, dummy_use)
					if dummy_use.card then shouldUse = false end
					if keep_weapon and zcard:getEffectiveId() == keep_weapon:getEffectiveId() then shouldUse = false end
				end
				if self.player:hasEquip(zcard) and zcard:isKindOf("Armor") and not self:needToThrowArmor() then shouldUse = false end
				if self.player:hasEquip(zcard) and zcard:isKindOf("DefensiveHorse") and not self:needToThrowArmor() then shouldUse = false end
				if self.player:hasEquip(zcard) and zcard:isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length() > 0 then shouldUse = false end	--yun
				if isCard("Jink", zcard, self.player) and not keep_jink then
					keep_jink = true
					shouldUse = false
				end
				if self.player:getHp() == 1 and isCard("Analeptic", zcard, self.player) and not keep_analeptic then
					keep_analeptic = true
					shouldUse = false
				end
				if shouldUse then table.insert(unpreferedCards, zcard:getId()) end
			end
		end
	end

	if #unpreferedCards == 0 then
		local use_slash_num = 0
		self:sortByKeepValue(cards)
		for _, card in ipairs(cards) do
			if not card:isBlack() then
			elseif card:isKindOf("Slash") then
				local will_use = false
				if use_slash_num <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, card) then
					local dummy_use = { isDummy = true }
					self:useBasicCard(card, dummy_use)
					if dummy_use.card then
						will_use = true
						use_slash_num = use_slash_num + 1
					end
				end
				if not will_use then table.insert(unpreferedCards, card:getId()) end
			end
		end

		local num = self:getCardsNum("Jink") - 1
		if self.player:getArmor() then num = num + 1 end
		if num > 0 then
			for _, card in ipairs(cards) do
				if not card:isBlack() then
				elseif card:isKindOf("Jink") and num > 0 then
					table.insert(unpreferedCards, card:getId())
					num = num - 1
				end
			end
		end
		for _, card in ipairs(cards) do
			if not card:isBlack() then
			elseif (card:isKindOf("Weapon") and self.player:getHandcardNum() < 3) or card:isKindOf("OffensiveHorse")
				or self:getSameEquip(card, self.player) or card:isKindOf("AmazingGrace") then
				table.insert(unpreferedCards, card:getId())
			elseif card:getTypeId() == sgs.Card_TypeTrick then
				local dummy_use = { isDummy = true }
				self:useTrickCard(card, dummy_use)
				if not dummy_use.card then table.insert(unpreferedCards, card:getId()) end
			end
		end

		local weapon = self.player:getWeapon()
		if weapon and weapon:isBlack() and self.player:getHandcardNum() < 3 then
			table.insert(unpreferedCards, weapon:getId())
		end

		local armor = self.player:getArmor()
		if armor and armor:isBlack() and self:needToThrowArmor() then
			table.insert(unpreferedCards, armor:getId())
		end

		local ohorse = self.player:getOffensiveHorse()
		if ohorse and ohorse:isBlack() and self.player:getWeapon() then
			table.insert(unpreferedCards, ohorse:getId())
		end
	end
	
	local use_cards = {}
	for index = #unpreferedCards, 1, -1 do
		if not self.player:isJilei(sgs.Sanguosha:getCard(unpreferedCards[index])) then table.insert(use_cards, unpreferedCards[index]) end
	end

	if #use_cards > 0 then
		local card_str = string.format("#MdkZhiYinCard:%s:", table.concat(use_cards, "+"))
		local acard = sgs.Card_Parse(card_str)
		use.card = acard
	end
end
--room:askForCard(source, ".|red", prompt, data, "MdkZhiYin")
sgs.ai_skill_cardask["@MdkZhiYin"] = function(self, data, pattern, target, target2, arg, arg2)
	if not self:isFriend(target) then
		return "."
	end
	local n_peach_all = self:getAllPeachNum(target)
	if n_peach_all + target:getHp() > 0 then
		return "."
	end
	if self:needDeath(target) then
		return "."
	end
	local can_discard = {}
	local cards = self.player:getCards("he")
	for _,c in sgs.qlist(cards) do
		if c:isRed() and self.player:canDiscard(self.player, c:getEffectiveId()) then
			table.insert(can_discard, c)
		end
	end
	if #can_discard == 0 then
		return "."
	end
	local black_handcards, black_equips, black_judges = {}, {}, {}
	if not target:isKongcheng() then
		local handcards = target:getHandcards()
		if target:objectName() == self.player:objectName() then
			for _,c in sgs.qlist(handcards) do
				if c:isBlack() then
					table.insert(black_handcards, c)
				end
			end
		else
			local flag = string.format("visible_%s_%s", self.player:objectName(), target:objectName())
			for _,c in sgs.qlist(handcards) do
				if c:hasFlag("visible") or c:hasFlag(flag) then
					if c:isBlack() then
						table.insert(black_handcards, c)
					end
				end
			end
		end
	end
	local n_analeptic = 0
	if #black_handcards > 0 then
		for _,c in ipairs(black_handcards) do
			if target:isCardLimited(c, sgs.Card_MethodUse, true) then
			elseif isCard("Analeptic", c, target) then
				n_analeptic = n_analeptic + 1
			end
		end
	end
	if n_analeptic > 0 then
		return "."
	end
	local current = self.room:getCurrent()
	if current and self:isEnemy(current, target) then
		if current:hasSkill("nosjuece") and not target:isKongcheng() then
			if #black_handcards == target:getHandcardNum() then
				return "."
			end
		end
	end
	local equips = target:getEquips()
	if not equips:isEmpty() then
		for _,c in sgs.qlist(equips) do
			if c:isBlack() then
				table.insert(black_equips, c)
			end
		end
	end
	local judges = target:getJudgingArea()
	if not judges:isEmpty() then
		for _,c in sgs.qlist(judges) do
			if c:isBlack() then
				table.insert(black_judges, c)
			end
		end
	end
	self:sortByKeepValue(can_discard)
	local can_use_peach = true
	if self.player:hasFlag("Global_PreventPeach") then
		can_use_peach = false
	elseif current and current:hasSkill("wansha") then
		if current:objectName() == self.player:objectName() then
		elseif target:objectName() == self.player:objectName() then
		else
			can_use_peach = false
		end
	end
	local can_use_analeptic = false
	if target:objectName() == self.player:objectName() then
		can_use_analeptic = true
	end
	local to_discard = nil
	for _,c in ipairs(can_discard) do
		if self.player:isCardLimited(c, sgs.Card_MethodUse) then
			to_discard = c
			break
		elseif can_use_peach and isCard("Peach", c, self.player) then
		elseif can_use_analeptic and isCard("Analeptic", c, self.player) then
		else
			to_discard = c
			break
		end
	end
	if to_discard then
		return "$"..to_discard:getEffectiveId()
	end
	return "."
end
--相关信息
sgs.ai_use_value["MdkZhiYinCard"] = sgs.ai_use_value["ZhihengCard"] or 9
sgs.ai_use_priority["MdkZhiYinCard"] = sgs.ai_use_priority["ZhihengCard"] or 2.61
sgs.dynamic_value.benefit["MdkZhiYinCard"] = true
--[[
	技能：神格（锁定技）
	描述：其他角色计算的与你的距离+X（X为该角色的体力）；你不能被指定为其他角色使用的延时性锦囊牌的目标。
]]--
--[[
	技能：光辉（限定技）
	描述：出牌阶段，除你以外，若一名角色满足：1、体力最多；2、攻击范围内包含所有其他角色，你可以摸三张牌，视为对其使用了一张【决斗】（不可被【无懈可击】抵消）。此【决斗】对其造成伤害时，该角色立即死亡，且所有其他角色重置武将牌并回复所有体力。
]]--
--GuangHuiCard:Play
local guanghui_skill = {
	name = "MdkGuangHui",
	getTurnUseCard = function(self, inclusive)
		if self.player:getMark("@MdkGuangHuiMark") == 0 then
			return nil
		end
		return sgs.Card_Parse("#MdkGuangHuiCard:.:")
	end,
}
table.insert(sgs.ai_skills, guanghui_skill)
sgs.ai_skill_use_func["#MdkGuangHuiCard"] = function(card, use, self)
	local others = self.room:getOtherPlayers(self.player)
	local maxhp = 0
	local target = nil
	for _,p in sgs.qlist(others) do
		local hp = p:getHp()
		if hp > maxhp then
			maxhp = hp
			target = p
			for _,p2 in sgs.qlist(others) do
				if p2:objectName() == p:objectName() then
				elseif p:inMyAttackRange(p2) then
				else
					target = nil
					break
				end
			end
		elseif hp == maxhp then
			target = nil
		end
	end
	if target and self:isEnemy(target) then
		if self.role == "renegade" and self.room:alivePlayerCount() > 2 then
			if target:isLord() then
				return 
			end
			local care = not self:hasSkill("jueqing|MdkWuQing")
			if care and target:hasSkill("duanchang") then
				return 
			end
			if target:hasSkill("wuhun") then
				local mark = self.player:getMark("@nightmare") + ( care and 1 or 0 )
				local lord = self.room:getLord()
				local lord_mark = lord and lord:getMark("@nightmare") or 0
				local safe_mark = math.max(mark, lord_mark)
				if safe_mark > 0 then
					local safe = false
					local others = room:getOtherPlayers(self.player)
					for _,p in sgs.qlist(others) do
						if p:getMark("@nightmare") > safe_mark then
							safe = true
							break
						end
					end
					if not safe then
						return 
					end
				end
			end
		end
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		if duel:targetFilter(sgs.PlayerList(), target, self.player) then
			if self:getCardsNum("Slash", "he", false) < getCardsNum("Slash", target, self.player) then
				return 
			end
			use.card = card
			if use.to then
				use.to:append(target)
			end
		end
	end
end
--相关信息
sgs.ai_use_value["MdkGuangHuiCard"] = 10
sgs.ai_use_priority["MdkGuangHuiCard"] = sgs.ai_use_priority["Duel"]
sgs.ai_card_intention["MdkGuangHuiCard"] = 400
--[[
	技能：朋友（联动技->晓美焰）
	描述：你对晓美焰造成伤害后，你可以令晓美焰回复1点体力。
]]--
--player:askForSkillInvoke("MdkPengYou", ai_data)
sgs.ai_skill_invoke["MdkPengYou"] = function(self, data)
	local target = data:toPlayer()
	if target and self:isFriend(target) then
		if target:getHp() >= getBestHp(target) then
			return false
		end
		return true
	end
	return false
end
--[[
	技能：计遣（联动技->美树沙耶香、百江渚）
	描述：出牌阶段结束时，你可以将一张非基本牌交给美树沙耶香或百江渚。若如此做，此回合结束后，该角色获得一个额外的回合。
	说明：在因“计遣”获得的额外回合中，不能再次发动“计遣”
]]--
--room:askForUseCard(player, "@@MdkJiQian", "@MdkJiQian")
sgs.ai_skill_use["@@MdkJiQian"] = function(self, prompt, method)
	local targets = {}
	for _,friend in ipairs(self.friends) do
		local name = friend:getGeneralName()
		if name == "MikiSayaka" or name == "MomoeNagisa" then
			table.insert(targets, friend)
		else
			name = friend:getGeneral2Name()
			if name == "MikiSayaka" or name == "MomoeNagisa" then
				table.insert(targets, friend)
			end
		end
	end
	if #targets == 0 then
		return "."
	end
	local can_use = {}
	local cards = self.player:getCards("he")
	for _,c in sgs.qlist(cards) do
		if not c:isKindOf("BasicCard") then
			table.insert(can_use, c)
		end
	end
	if #can_use == 0 then
		return "."
	end
	self:sort(targets, "threat")
	self:sortByUseValue(can_use)
	local target = targets[1]
	local to_use = can_use[1]
	if target:objectName() == self.player:objectName() then
		if self:hasSkills("MdkShenShi|MdkJieDa", self.player) then
			local card_id = to_use:getEffectiveId()
			if self.room:getCardPlace(card_id) == sgs.Player_PlaceHand then
				for _,c in ipairs(can_use) do
					local id = c:getEffectiveId()
					if self.room:getCardPlace(id) == sgs.Player_PlaceEquip then
						to_use = c
						break
					end
				end
			end
		end
	elseif target:hasSkill("manjuan") then
		to_use = can_use[#can_use]
	end
	local use_str = string.format("#MdkJiQianCard:%d:->%s", to_use:getEffectiveId(), target:objectName())
	return use_str
end
--相关信息
function MdkJiQianCard_intention(self, player, use)
	local skillcard = use.card
	if skillcard and skillcard:objectName() == "MdkJiQianCard" then
		for _,target in sgs.qlist(use.to) do
			if target:objectName() ~= player:objectName() then
				sgs.updateIntention(player, target, -80)
			end
		end
	end
end
table.insert(sgs.ai_choicemade_filter["cardUsed"], MdkJiQianCard_intention)
--[[****************************************************************
	编号：MDK - 12
	武将：魔·晓美焰[隐藏武将]
	称号：炽爱之魔
	性别：女
	势力：神
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：银庭
	描述：摸牌阶段，你额外摸一张牌，然后你可以将一张手牌置于武将牌上，称为“欲”；一名角色的判定牌生效前，你可以打出一张“欲”牌替换之。
]]--
--room:askForUseCard(player, "@@MdkYinTing", "@MdkYinTing")
sgs.ai_skill_use["@@MdkYinTing"] = function(self, prompt, method)
	local handcards = self.player:getHandcards()
	handcards = sgs.QList2Table(handcards)
	self:sortByUseValue(handcards, true)
	local pile = self.player:getPile("MdkYinTingPile")
	local exists = {}
	for _,id in sgs.qlist(pile) do
		local c = sgs.Sanguosha:getCard(id)
		table.insert(exists, c)
	end
	--For Special: 武魂
	local to_use = nil
	local victims = self:getWuhunRevengeTargets()
	if #victims > 0 then
		local need_protect_friend = false
		local need_attack_enemy = false
		local care_lord = ( self.role == "renegade" and self.room:alivePlayerCount() > 0 )
		for _,victim in ipairs(victims) do
			if self:isFriend(victim) then
				need_protect_friend = true
			elseif care_lord and victim:isLord() then
				need_protect_friend = true
			else
				need_attack_enemy = true
			end
		end
		if need_protect_friend then
			for _,c in ipairs(exists) do
				if c:isKindOf("Peach") or c:isKindOf("GodSalvation") then
					need_protect_friend = false
					break
				end
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(exists) do
				if c:isKindOf("Peach") or c:isKindOf("GodSalvation") then
				else
					need_attack_enemy = false
					break
				end
			end
		end
		if need_protect_friend then
			for _,c in ipairs(handcards) do
				if c:isKindOf("Peach") or c:isKindOf("GodSalvation") then
					to_use = c
					break
				end
			end
		elseif need_attack_enemy then
			for _,c in ipairs(handcards) do
				if c:isKindOf("Peach") or c:isKindOf("GodSalvation") then
				else
					to_use = c
					break
				end
			end
		end
	end
	--For Lightning
	local alives = self.room:getAlivePlayers()
	if not to_use then
		local has_lightning = false
		for _,p in sgs.qlist(alives) do
			if p:containsTrick("lightning") then
				has_lightning = true
				break
			end
		end
		if has_lightning then
			local need_protect_friend = false
			for _,friend in ipairs(self.friends) do
				if self:hasSkill("hongyan|MdkShenGe|MdkMoDao", friend) then
				elseif friend:containsTrick("YanxiaoCard") then
				else
					need_protect_friend = true
					break
				end
			end
			if need_protect_friend then
				for _,c in ipairs(exists) do
					if c:getSuit() ~= sgs.Card_Spade then
						need_protect_friend = false
						break
					elseif c:getNumber() < 2 or c:getNumber() > 9 then
						need_protect_friend = false
						break
					end
				end
			end
			if need_protect_friend then
				for _,c in ipairs(handcards) do
					if c:getSuit() ~= sgs.Card_Spade then
						to_use = c
						break
					elseif c:getNumber() < 2 or c:getNumber() > 9 then
						to_use = c
						break
					end
				end
			end
			if not to_use then
				local need_attack_enemy = false
				for _,enemy in ipairs(self.enemies) do
					if self:hasSkill("hongyan|MdkShenGe|MdkMoDao", enemy) then
					elseif enemy:containsTrick("YanxiaoCard") then
					else
						need_attack_enemy = true
						break
					end
				end
				if need_attack_enemy then
					for _,c in ipairs(exists) do
						if c:getSuit() == sgs.Card_Spade and c:getNumber() >= 2 and c:getNumber() <= 9 then
							need_attack_enemy = false
							break
						end
					end
				end
				if need_attack_enemy then
					for _,c in ipairs(handcards) do
						if c:getSuit() == sgs.Card_Spade and c:getNumber() >= 2 and c:getNumber() <= 9 then
							to_use = c
							break
						end
					end
				end
			end
		end
	end
	--For Indulgence, 国色
	if not to_use then
		local need_protect_friend = false
		for _,friend in ipairs(self.friends) do
			if friend:containsTrick("Indulgence") and not friend:containsTrick("YanxiaoCard") then
				need_protect_friend = true
				break
			end
		end
		if need_protect_friend then
			for _,c in ipairs(exists) do
				if c:getSuit() == sgs.Card_Heart then
					need_protect_friend = false
					break
				end
			end
		end
		if need_protect_friend then
			for _,c in ipairs(handcards) do
				if c:getSuit() == sgs.Card_Heart then
					to_use = c
					break
				end
			end
		end
	end
	if not to_use then
		local need_attack_enemy = false
		for _,enemy in ipairs(self.enemies) do
			if enemy:containsTrick("Indulgence") and not enemy:containsTrick("YanxiaoCard") then
				need_attack_enemy = true
				break
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(exists) do
				if c:getSuit() ~= sgs.Card_Heart then
					need_attack_enemy = false
					break
				end
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(handcards) do
				if c:getSuit() ~= sgs.Card_Heart then
					to_use = c
					break
				end
			end
		end
	end
	--For SupplyShortage, 断粮
	if not to_use then
		local need_protect_friend = false
		for _,friend in ipairs(self.friends) do
			if friend:containsTrick("supply_shortage") and not friend:containsTrick("YanxiaoCard") then
				need_protect_friend = true
				break
			end
		end
		if need_protect_friend then
			for _,c in ipairs(exists) do
				if c:getSuit() == sgs.Card_Club then
					need_protect_friend = false
					break
				end
			end
		end
		if need_protect_friend then
			for _,c in ipairs(handcards) do
				if c:getSuit() == sgs.Card_Club then
					to_use = c
					break
				end
			end
		end
	end
	if not to_use then
		local need_attack_enemy = false
		for _,enemy in ipairs(self.enemies) do
			if enemy:containsTrick("supply_shortage") and not enemy:containsTrick("YanxiaoCard") then
				need_attack_enemy = true
				break
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(exists) do
				if c:getSuit() ~= sgs.Card_Club then
					need_attack_enemy = false
					break
				end
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(handcards) do
				if c:getSuit() ~= sgs.Card_Club then
					to_use = c
					break
				end
			end
		end
	end
	--For Heart Card: 屯田、刚烈3v3、刚烈tw、刚烈neo、屯田heg、刚烈nos、潜袭nos
	if not to_use then
		local need_attack_enemy = false
		local hongyan_flag = false
		for _,enemy in ipairs(self.enemies) do
			if self:hasSkill("tuntian|vsganglie|neoganglie|nosganglie|nosqianxi", enemy) then
				need_attack_enemy = true
				hongyan_flag = enemy:hasSkill("hongyan")
				break
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(exists) do
				if hongyan_flag and c:getSuit() == sgs.Card_Spade then
				elseif c:getSuit() ~= sgs.Card_Heart then
					need_attack_enemy = false
					break
				end
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(handcards) do
				if hongyan_flag and c:getSuit() == sgs.Card_Spade then
				elseif c:getSuit() ~= sgs.Card_Heart then
					to_use = c
					break
				end
			end
		end
	end
	--For Red Card: 八阵、铁骑tw、铁骑nos、烧营
	if not to_use then
		local need_attack_enemy = false
		local hongyan_flag = false
		for _,enemy in ipairs(self.enemies) do
			if self:hasSkill("bazhen|nostieji|shaoying", enemy) or enemy:hasArmorEffect("eight_diagram") then
				need_attack_enemy = true
				hongyan_flag = enemy:hasSkill("hongyan")
				break
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(exists) do
				if hongyan_flag and c:getSuit() == sgs.Card_Spade then
				elseif not c:isRed() then
					need_attack_enemy = false
					break
				end
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(handcards) do
				if hongyan_flag and c:getSuit() == sgs.Card_Spade then
				elseif not c:isRed() then
					to_use = c
					break
				end
			end
		end
	end
	--For Black Card: 洛神、雷击、洛神1v1、雷击ol、洛神tw、洛神heg、秘计nos
	if not to_use then
		local need_attack_enemy = false
		local hongyan_flag = false
		for _,enemy in ipairs(self.enemies) do
			if self:hasSkills("luoshen|leiji|olleiji|nosmiji", enemy) then
				need_attack_enemy = true
				hongyan_flag = enemy:hasSkill("hongyan")
				break
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(exists) do
				if hongyan_flag and c:getSuit() == sgs.Card_Spade then
					need_attack_enemy = false
					break
				elseif not c:isBlack() then
					need_attack_enemy = false
					break
				end
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(handcards) do
				if hongyan_flag and c:getSuit() == sgs.Card_Spade then
					to_use = c 
					break
				elseif not c:isBlack() then
					to_use = c
					break
				end
			end
		end
	end
	--For Spade: 暴虐、雷击nos
	if not to_use then
		local need_attack_enemy = false
		for _,enemy in ipairs(self.enemies) do
			if enemy:hasSkill("hongyan") then
			elseif enemy:hasLordSkill("baonve") or enemy:hasSkill("nosleiji") then
				need_attack_enemy = true
				break
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(exists) do
				if not c:getSuit() == sgs.Card_Spade then
					need_attack_enemy = false
					break
				end
			end
		end
		if need_attack_enemy then
			for _,c in ipairs(handcards) do
				if not c:getSuit() == sgs.Card_Spade then
					to_use = c
					break
				end
			end
		end
	end
	--For MdkGanShe
	if to_use then
	elseif self.player:hasSkill("MdkGanShe") then
		local no_need = {}
		for _,c in ipairs(exists) do
			no_need[c:getSuitString()] = true
		end
		for _,c in ipairs(handcards) do
			if not no_need[c:getSuitString()] then
				to_use = c
				break
			end
		end
	end
	if to_use then
	elseif self:getOverflow() > 2 then
		if self:hasCrossbowEffect(self.player) then
		elseif self:hasSkills("keji|qiaobian|conghui", self.player) then
		elseif #self.friends_noself > 0 and self:hasSkills("rende|nosrende|olrende|mizhao|mingjian", self.player) then
		else
			to_use = handcards[1]
		end
	end
	if to_use then
		local use_str = string.format("#MdkYinTingCard:%d:->.", to_use:getEffectiveId())
		return use_str
	end
	return "."
end
--room:askForSkillInvoke(player, "MdkYinTing", ai_data)
sgs.ai_skill_invoke["MdkYinTing"] = function(self, data)
	local judge = self.room:getTag("MdkYinTingData"):toJudge()
	if judge and self:needRetrial(judge) then
		local pile = self.player:getPile("MdkYinTingPile")
		local cards = {}
		for _,id in sgs.qlist(pile) do
			local card = sgs.Sanguosha:getCard(id)
			table.insert(cards, card)
		end
		local id = self:getRetrialCardId(cards, judge, false)
		if id >= 0 then
			sgs.ai_MdkYinTing_RetrialID = id
			return true
		end
	end
	return false
end
--room:askForAG(player, pile, false, "MdkYinTing")
sgs.ai_skill_askforag["MdkYinTing"] = function(self, card_ids)
	local retrial_id = sgs.ai_MdkYinTing_RetrialID
	if retrial_id then
		sgs.ai_MdkYinTing_RetrialID = nil
		for _,id in ipairs(card_ids) do
			if id == retrial_id then
				return id
			end
		end
	end
	local judge = self.room:getTag("MdkYinTingData"):toJudge()
	if judge then
		local cards = {}
		for _,id in sgs.qlist(pile) do
			local card = sgs.Sanguosha:getCard(id)
			table.insert(cards, card)
		end
		local id = self:getRetrialCardId(cards, judge, false)
		return id
	end
	return -1
end
--[[
	技能：干涉（阶段技）
	描述：你可以弃四张花色各不相同的“欲”，令一名角色失去一项技能；你受到其他角色造成的伤害时，你也可以对该角色发动此技能。
]]--
--room:askForChoice(source, "MdkGanShe", choices, ai_data)
sgs.ai_skill_choice["MdkGanShe"] = function(self, choices, data)
	local target = data:toPlayer()
	local items = choices:split("+")
	if #items == 1 then
		return items[1]
	end
	local bad_skills = sgs.bad_skills or "benghuai|wumou|shiyong|yaowu|zaoyao|chanyuan|chouhai|ranshang"
	bad_skills = bad_skills .. "|MdkCanTi"
	if self:isFriend(target) then
		for _,item in ipairs(items) do
			if string.find(bad_skills, item) then
				return item
			end
		end
	else
		local groups = {
			sgs.priority_skill,
			sgs.masochism_skill.."|"..sgs.exclusive_skill,
			sgs.save_skill,
			sgs.drawpeach_skill.."|"..sgs.lose_equip_skill,
			sgs.recover_skill,
		}
		for _,skills in ipairs(groups) do
			for _,item in ipairs(items) do
				if string.find(skills, item) then
					return item
				end
			end
		end
		for _,item in ipairs(items) do
			if not string.find(bad_skills, item) then
				return item
			end
		end
	end
	return items[math.random(1, #items)]
end
--GanSheCard:Play
local ganshe_skill = {
	name = "MdkGanShe",
	getTurnUseCard = function(self, inclusive)
		if self.player:hasUsed("#MdkGanSheCard") then
			return nil
		end
		local pile = self.player:getPile("MdkYinTingPile")
		if pile:length() < 4 then
			return nil
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
		if total >= 4 then
			return sgs.Card_Parse("#MdkGanSheCard:.:")
		end
	end,
}
table.insert(sgs.ai_skills, ganshe_skill)
local function getGanSheUseCardsFromPile(self, pile)
	local cards = {}
	for _,id in sgs.qlist(pile) do
		local c = sgs.Sanguosha:getCard(id)
		table.insert(cards, c)
	end
	self:sortByKeepValue(cards)
	local to_use = {}
	local existed = {}
	for _,c in ipairs(cards) do
		local suit = c:getSuitString()
		if not existed[suit] then
			table.insert(to_use, c:getEffectiveId())
			if #to_use == 4 then
				return table.concat(to_use, "+")
			end
			existed[suit] = true
		end
	end
	return nil
end
sgs.ai_skill_use_func["#MdkGanSheCard"] = function(card, use, self)
	local bad_skills = sgs.bad_skills or "benghuai|wumou|shiyong|yaowu|zaoyao|chanyuan|chouhai|ranshang"
	bad_skills = bad_skills .. "|MdkCanTi"
	local target = nil
	self:sort(self.friends, "defense")
	for _,friend in ipairs(self.friends) do
		if self:hasSkills(bad_skills, friend) then
			target = friend
			break
		end
	end
	if not target then
		if #self.enemies == 0 then
			return 
		end
		self:sort(self.enemies, "threat")
		local groups = {
			sgs.priority_skill,
			sgs.masochism_skill.."|"..sgs.exclusive_skill,
			sgs.save_skill,
			sgs.drawpeach_skill.."|"..sgs.lose_equip_skill,
			sgs.recover_skill,
		}
		for _,skills in ipairs(groups) do
			for _,enemy in ipairs(self.enemies) do
				if self:hasSkill(skills, enemy) then
					target = enemy
					break
				end
			end
		end
	end
	if not target then
		for _,enemy in ipairs(self.enemies) do
			local has_good_skill = false
			local skills = enemy:getVisibleSkillList()
			for _,skill in sgs.qlist(skills) do
				if skill:inherits("SPConvertSkill") then
				elseif skill:isLordSkill() and not enemy:hasLordSkill(skill:objectName()) then
				elseif skill:isAttachedLordSkill() then
				elseif string.find(bad_skills, skill:objectName()) then
				else
					has_good_skill = true
					break
				end
			end
			if has_good_skill then
				target = enemy
				break
			end
		end
	end
	if target then
		local pile = self.player:getPile("MdkYinTingPile")
		local to_use = getGanSheUseCardsFromPile(self, pile)
		if to_use then
			local card_str = string.format("#MdkGanSheCard:%s:->%s", to_use, target:objectName())
			local acard = sgs.Card_Parse(card_str)
			use.card = acard
			if use.to then
				use.to:append(target)
			end
		end
	end
end
--room:askForUseCard(player, "@@MdkGanShe", prompt)
sgs.ai_skill_use["@@MdkGanShe"] = function(self, prompt, method)
	local name = self.player:property("MdkGanSheTarget"):toString()
	local target = nil
	local alives = self.room:getAlivePlayers()
	for _,p in sgs.qlist(alives) do
		if p:objectName() == name then
			target = p
			break
		end
	end
	if target then
		local bad_skills = sgs.bad_skills or "benghuai|wumou|shiyong|yaowu|zaoyao|chanyuan|chouhai|ranshang"
		bad_skills = bad_skills .. "|MdkCanTi"
		local skills = target:getVisibleSkillList()
		local has_good_skill = false
		local has_bad_skill = false
		local is_friend = self:isFriend(target)
		for _,skill in sgs.qlist(skills) do
			if skill:inherits("SPConvertSkill") then
			elseif skill:isLordSkill() and not target:hasLordSkill(skill:objectName()) then
			elseif skill:isAttachedLordSkill() then
			elseif string.find(bad_skills, skill:objectName()) then
				has_bad_skill = true
				if is_friend then
					break
				end
			else
				has_good_skill = true
				if not is_friend then
					break
				end
			end
		end
		local invoke = is_friend and has_bad_skill or has_good_skill
		if invoke then
			local pile = self.player:getPile("MdkYinTingPile")
			local to_use = getGanSheUseCardsFromPile(self, pile)
			if to_use then
				local use_str = string.format("#MdkGanSheCard:%s:->%s", to_use, target:objectName())
				return use_str
			end
		end
	end
	return "."
end
--相关信息
sgs.ai_use_value["MdkGanSheCard"] = 3.5
sgs.ai_use_priority["MdkGanSheCard"] = 2.7
sgs.ai_choicemade_filter["skillChoice"]["MdkGanShe"] = function(self, player, promptlist)
	--skillChoice:MdkGanShe:olleiji
	local target = self.room:getTag("MdkGanSheVictim"):toPlayer()
	if target and target:objectName() ~= player:objectName() then
		local skill = promptlist[3]
		local bad_skills = sgs.bad_skills or "benghuai|wumou|shiyong|yaowu|zaoyao|chanyuan|chouhai|ranshang"
		bad_skills = bad_skills .. "|MdkCanTi"
		if string.find(bad_skills, skill) then
			sgs.updateIntention(player, target, -80)
		else
			sgs.updateIntention(player, target, 80)
		end
	end
end
--[[
	技能：魔道（锁定技）
	描述：你的回合内，你的攻击范围无限；其他角色对你使用延时性锦囊牌时，你获得此牌。
]]--
--[[
	技能：独舞（限定技）
	描述：出牌阶段，你可以摸三张牌，与一名手牌数多于体力的其他角色拼点。若你赢，该角色失去所有技能并获得技能“崩坏”。
	说明：若没有手牌数多于体力的其他角色，不能发动此技能；即，不可以只摸牌不拼点。
]]--
--DuWuCard:Play
local duwu_skill = {
	name = "MdkDuWu",
	getTurnUseCard = function(self, inclusive)
		if self.player:getMark("@MdkDuWuMark") == 0 then
			return nil
		elseif #self.enemies == 0 then
			return nil
		elseif self.player:isKongcheng() then
			return nil
		end
		return sgs.Card_Parse("#MdkDuWuCard:.:")
	end,
}
table.insert(sgs.ai_skills, duwu_skill)
sgs.ai_skill_use_func["#MdkDuWuCard"] = function(card, use, self)
	local handcards = self.player:getHandcards()
	local max_point = 0
	local max_cards = {}
	for _,c in sgs.qlist(handcards) do
		local point = c:getNumber()
		if point > max_point then
			max_point = point
			max_cards = {c}
		elseif point == max_point then
			table.insert(max_cards, c)
		end
	end
	self:sort(self.enemies, "threat")
	local groupA = {} --肯定能拼过的
	local groupB = {} --不确定的
	local groupC = {} --肯定拼不过的
	local groupD = {} --没必要拼的
	local bad_skills = sgs.bad_skills or "benghuai|wumou|shiyong|yaowu|zaoyao|chanyuan|chouhai|ranshang"
	bad_skills = bad_skills .. "|MdkCanTi"
	local care_lord = ( self.role == "renegade" and self.room:alivePlayerCount() > 2 )
	for _,enemy in ipairs(self.enemies) do
		if enemy:isKongcheng() then
		elseif enemy:isLord() and care_lord and enemy:getHp() <= 0 then
		elseif enemy:getHandcardNum() > enemy:getHp() then
			local has_good_skill = false
			local skills = enemy:getVisibleSkillList()
			for _,skill in sgs.qlist(skills) do
				if skill:inherits("SPConvertSkill") then
				elseif skill:isLordSkill() and not enemy:hasLordSkill(skill:objectName()) then
				elseif skill:isAttachedLordSkill() then
				elseif string.find(bad_skills, skill:objectName()) then
				else
					has_good_skill = true
					break
				end
			end
			if has_good_skill then
				local flag = string.format("visible_%s_%s", self.player:objectName(), enemy:objectName())
				local enemy_max_point = 0
				local enemy_handcards = enemy:getHandcards()
				local has_unknown_card = false
				for _,c in sgs.qlist(enemy_handcards) do
					if c:hasFlag("visible") or c:hasFlag(flag) then
						local point = c:getNumber()
						if point > enemy_max_point then
							enemy_max_point = point
							if point >= max_point then
								break
							end
						end
					else
						has_unknown_card = true
					end
				end
				if enemy_max_point >= max_point then
					table.insert(groupC, enemy)
				elseif has_unknown_card then
					table.insert(groupB, enemy)
				else
					table.insert(groupA, enemy)
					break
				end
			else
				table.insert(groupD, enemy)
			end
		end
	end
	local target = groupA[1]
	if not target then
		if max_point == 13 and #groupB > 0 then
			target = groupB[1]
		end
	end
	if not target then
		if max_point > 10 and #groupB > 0 then
			local will_die = false
			if self:isWeak() and self:getAllPeachNum() == 0 then
				for _,enemy in ipairs(self.enemies) do
					if enemy:inMyAttackRange(self.player) then
						will_die = true
						break
					end
				end
			end
			if will_die then
				target = groupB[1]
			end
		end
	end
	if target then
		self:sortByUseValue(max_cards, true)
		local id = max_cards[1]:getEffectiveId()
		local card_str = string.format("#MdkDuWuCard:%d:->%s", id, target:objectName())
		local acard = sgs.Card_Parse(card_str)
		use.card = acard
		if use.to then
			use.to:append(target)
		end
	end
end
--相关信息
sgs.ai_use_value["MdkDuWuCard"] = 10
sgs.ai_use_priority["MdkDuWuCard"] = 7
sgs.ai_card_intention["MdkDuWuCard"] = function(self, card, from, tos)
	local bad_skills = sgs.bad_skills or "benghuai|wumou|shiyong|yaowu|zaoyao|chanyuan|chouhai|ranshang"
	bad_skills = bad_skills .. "|MdkCanTi"
	for _,to in ipairs(tos) do
		local has_good_skill = false
		local has_bad_skill = false
		local skills = to:getVisibleSkillList()
		for _,skill in sgs.qlist(skills) do
			if skill:inherits("SPConvertSkill") then
			elseif skill:isLordSkill() and not to:hasLordSkill(skill:objectName()) then
			elseif skill:isAttachedLordSkill() then
			elseif skill:objectName() == "benghuai" then
			elseif string.find(bad_skills, skill:objectName()) then
				has_bad_skill = true
			else
				has_good_skill = true
				break
			end
		end
		if has_good_skill then
			sgs.updateIntention(from, to, 400)
		elseif has_bad_skill then
			sgs.updateIntention(from, to, -200)
		end
	end
end
--[[
	技能：执念（联动技->神·鹿目圆）
	描述：神·鹿目圆令你回复体力时，你可以获得其一张牌，令其变身为鹿目圆并执行一次“轮回”的效果。然后本局游戏中你可以额外发动一次“独舞”。
]]--
--player:askForSkillInvoke("MdkZhiNian", ai_data)
sgs.ai_skill_invoke["MdkZhiNian"] = function(self, data)
	local target = data:toPlayer()
	local can_save = false
	if target:hasSkill("MdkZhiYin") and target:canDiscard(target, "he") then
		if self:getSuitNum("red", true, target) > 0 then
			can_save = true
		end
	end
	local can_attack = false
	if target:hasSkill("MdkGuangHui") and target:getMark("@MdkGuangHuiMark") > 0 then
		can_attack = true
	end
	if can_save or can_attack then
		if self:isEnemy(target) then
			return true
		end
	end
	if self:isFriend(target) then
		local is_in_danger = false
		if target:isLord() and sgs.isLordInDanger() then
			is_in_danger = true
		elseif self:isWeak(target) then
			local n_peach = self:getAllPeachNum(target)
			if can_save then
				n_peach = n_peach + 1
			end
			local n_enemy = 0
			local enemies = self:getEnemies(target)
			for _,enemy in ipairs(enemies) do
				if enemy:inMyAttackRange(target) then
					n_enemy = n_enemy + 1
				end
			end
			if n_enemy >= n_peach + target:getHp() then
				is_in_danger = true
			end
		end
		if is_in_danger then
			return true
		elseif can_save or can_attack then
			return false
		end
	end
	return self.player:hasSkill("MdkDuWu")
end
--room:askForCardChosen(player, source, "he", "MdkZhiNian")