do

local function user_print_name(user)
  if user.print_name then
    return user.print_name
  end
  local text = ''
  if user.first_name then
    text = user.last_name..' '
  end
  if user.lastname then
    text = text..user.last_name
  end
  return text
end

local function scan_name(extra, success, result)
  vardump(extra)
  vardump(result)
  local founds = {}
  for k,member in pairs(result.members) do
    local fields = {'first_name', 'print_name', 'username'}
      for k,field in pairs(fields) do
        if member[field] and type(member[field]) == "string" then
          if member[field]:match(extra.user) then
            local id = tostring(member.id)
            print(id, member.id)
            founds[id] = member
          end
        end
      end
    end
    if next(founds) == nil then -- Empty table
      send_msg(extra.receiver, extra.user.." not found on this chat.", ok_cb, false)
    else
      local text = ""
      for k,user in pairs(founds) do
        local first_name = user.first_name or ""
        local print_name = user.print_name or ""
        local user_name = user.user_name or ""
        local id = user.id  or "" -- This would be funny
        text = text.."First name: "..first_name.."\n"
            .."Print name: "..print_name.."\n"
            .."User name: "..user_name.."\n"
            .."ID: "..id.."\n\n"
      end
    send_msg(extra.receiver, text, ok_cb, false)
  end
end

local function res_user_callback(extra, success, result)
  if success == 1 then
    send_msg(extra.receiver, "ID for "..extra.user.." is: "..result.id, ok_cb, false)
  else
    send_msg(extra.receiver, extra.user.." not found on this chat.", ok_cb, false)
  end
end

local function action_by_reply(extra, success, result)
  local text = ' ألأسم :'.. string.gsub(result.from.print_name, '_', ' ') .. '\n'
             ..' ألمعرف:@' .. (result.from.username or "") ..'\n'
             ..' ألايدي :'  .. result.from.id
  send_msg(extra.receiver, text, ok_cb,  true)
end

local function returnids(extra, success, result)
  vardump(result)
  vardump(extra)
  local text = 'IDs for chat '.. string.gsub(result.print_name, '_', ' ')
  ..' ('..result.id..')\n'
  ..'There are '..result.members_num..' members'
  ..'\n 🔹 ~~~~~~~~~~~~~~~~~~~~~~~ 🔹\n'
  i = 0
  for k,v in pairs(result.members) do
    i = i+1
    text = text .. i .. ". "..v.id.." ⋆ @"..(v.username or "")..' ⋆ '.. string.gsub(v.print_name,' ~ ', ' ') .."\n"
  end
  send_large_msg(extra.receiver, text)
end

local function run(msg, matches)
  local receiver = get_receiver(msg)
  local user = matches[1]
  print(tostring(matches))
  local text = "ID for "..user.." is: "
  if msg.to.type == 'chat' then
    if msg.text == '/id' then
      if msg.reply_id then
        msgr = get_message(msg.reply_id, action_by_reply, {receiver=receiver})
      else
        local text = 'ألأسم : '.. string.gsub(user_print_name(msg.from),'_', ' ') .. '\n ألأيدي : ' .. msg.from.id
        local text = text .. "\n\n أنت في مجموعه " .. string.gsub(user_print_name(msg.to), '_', ' ') .. " ( ألأيدي: " .. msg.to.id  .. ")"
        return text
      end
    elseif matches[1] == "chat" then
      if matches[2] and is_sudo(msg) then
        local chat = 'chat#id41710448'
        print(chat)
        chat_info(chat, returnids, {receiver=receiver})
      else
        chat_info(receiver, returnids, {receiver=receiver})
      end
    elseif string.match(user, '^@.+$') then
      username = string.gsub(user, '@', '')
      msgr = res_user(username, res_user_callback, {receiver=receiver, user=user, text=text})
    else
      user = string.gsub(user, ' ', '_')
      chat_info(receiver, scan_name, {receiver=receiver, user=user, text=text})
    end
  else
    return 'You are not in a group.'
  end
end

return {
  description = "Know your id or the id of a chat members.",
  usage = {
    "/id:  [عرض الايدي الخاص بك]",
    "/id: [عرض المعرف والايدي عبر الرد]",
    "/id chat: [عرض جميع معرفات الاعضاء ]",
    "/id user: [ عرض الايدي عبر المعرف ]",
  },
  patterns = {
    "^/id$",
    "^/id (chat) (%d+)$",
    "^/id (.*)$",
    "^/id (%d+)$"
  },
  run = run
}

end
