do

local function callback(extra, success, result)
	local receiver = extra.receiver
	local username = extra.username
	if success == 1 then
		print("Success!")
	else
		send_large_msg(resuser, "Sorry, i can't invite @"..username)
	end
end

local function resuser(extra, success, result)
  local receiver = extra.receiver
  local username = extra.username
  if success == 1 then
  	local user = "user#id"..result.id
  	chat_add_user(receiver, user, callback, {receiver=receiver, username=username})
  else
  	send_large_msg(receiver, "User not found!")
  end
end

local function run(msg, matches)
  local username = string.gsub(matches[2], "@", "")
  
  -- The message must come from a chat group
  if msg.to.type == "chat" then
    local chat = "chat#id"..msg.to.id
    res_user(username, resuser, {receiver=get_receiver(msg), username=username})
  else 
    return "This isn't a chat group!"
  end

end

return {
  description = "Invite other user to the chat group", 
  usage = {
  	moderator = {
  		"!invite <username> : Invite other user to this chat",
  		},
  	},
  patterns = {
    "^!(invite) (.*)$",
  }, 
  run = run,
  moderated = true 
}
end