tag = {}

tag.players = {}

tag.tagged_player = ""

tag.game = false

minetest.register_privilege("tag", "Can start and end tag games.")

tag.new_game = function()
    for _, player in pairs(minetest.get_connected_players()) do
        table.insert(tag.players, player:get_player_name())
    end
    local tagged = math.random(1, #tag.players)
    tag.tagged_player = tag.players[tagged]
    tag.game = true
    minetest.chat_send_all("Started a new game of tag.")
    minetest.chat_send_all("The tagged player's name is: " .. tag.tagged_player)
    local tplayer = minetest.get_player_by_name(tag.tagged_player)
    tplayer:set_properties({textures = {"character.png^[colorize:#FF0000:150"}})
end

tag.end_game = function()
    tag.players = {}
    local player = minetest.get_player_by_name(tag.tagged_player)
    player:set_properties({textures = {"character.png"}})
    minetest.chat_send_all("Ended the current game of tag. " .. tag.tagged_player .. " lost!")
    tag.tagged_player = ""
    tag.game = false
end

tag.handle_punch = function(player, hitter)
    if tag.game then
        if hitter:get_player_name() == tag.tagged_player then
            tag.tagged_player = player:get_player_name()
            minetest.chat_send_all("The tagged player's name is: " .. tag.tagged_player)
            
            minetest.after(0.05, function()
                hitter:set_properties({textures = {"character.png"}})
                player:set_properties({textures = {"character.png^[colorize:#FF0000:150"}})
            end)
        end
    else
        minetest.chat_send_player(hitter:get_player_name(), "No game of tag is currently going on.")
    end
end

minetest.register_chatcommand("new_tag", {
    description = "Start a new game of tag",
    privs = {tag=true},
    func = function(name, _)
        if not tag.game then
        	if #minetest.get_connected_players() > 1 then
            	tag.new_game()
            else
            	minetest.chat_send_player(name, "You need more than one person online to be able to start a game of tag.")
            end
        else
            minetest.chat_send_player(name, "There is currently a game of tag going on, to end it, do /end_tag")
        end
    end,
})

minetest.register_chatcommand("end_tag", {
    description = "End the current game of tag",
    privs = {tag=true},
    func = function(name, _)
        if tag.game then
            tag.end_game()
        else
            minetest.chat_send_player(name, "There is no game of tag currently going on, to start one, do /new_tag")
        end
    end,
})

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    tag.handle_punch(player, hitter)
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if not player then return end
	if hp_change < 0 then
		hp_change = 0
	end
	return hp_change
end, true)

tag.spam_tagged_player = function()
	if tag.game then
		minetest.chat_send_player(tag.tagged_player, "" .. minetest.colorize("#EE0", "*YOU ARE THE TAGGED PLAYER") .. "")
	end
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 3 then 
		-- Send "Minetest" to all players every 5 seconds
		tag.spam_tagged_player()
		timer = 0
	end
end)
