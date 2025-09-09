local _M = {}

local function eatJsonStr(a)
	if a:sub(1,1) ~= "\"" then return error(string.format("expected double quotes, got \"%s\"", a:sub(1,1))) end
	a = a:sub(2)
	local k = ""
	while a:sub(1,1)~="\"" do
		if a:sub(1,1) == "\\" then
			local snd = a:sub(2,2)
			-- according to json.org, json strings support \", \/, \\, \b, \f, \n, \r, \t and \uXXXX.
			if snd == "\"" or snd == "/" or snd == "\\" then
				k = k..snd
				a = a:sub(3)
				goto __enkoder__srz__json__continue1
			end
			local idx = string.find("btnfr",snd,1,true)
			if idx ~= nil then
				k = k..string.char(({8,9,10,12,13})[idx])
				a = a:sub(3)
				goto __enkoder__srz__json__continue1
			end
			if snd == "u" then
				k = k..utf8.char(tonumber("0x"..a:sub(3,6)))
				a = a:sub(7)
				goto __enkoder__srz__json__continue1
			end
			return error(string.format("unknown escape \\%s", snd))
		end
		k = k..a:sub(1,1)
		a = a:sub(2)
		::__enkoder__srz__json__continue1::
	end
	return k,a:sub(2)
end

local function srz(v)
	if type(v) == "number" or type(v) == "boolean" then return tostring(v) end
	if type(v) == "table" then return _M.encd(v,{}) end
	if type(v) == "string" then
		local out = "\""
		local count = 1
		while count <= utf8.len(v) do -- time to sweep everything under the \uXXXX rug
			local cp = utf8.codepoint(v,utf8.offset(v,count))
			local h, l
			if cp <= 0xffff then
				out = out..string.format("\\u%04x",cp)
				goto __enkoder__srz__json__continue0
			end
			cp = cp - 0x10000
			h = 0xD800+math.floor(cp/0x400)
			l = 0xDC00+(cp%0x400)
			out = out..string.format("\\u%04x\\u%04x",h,l)
			::__enkoder__srz__json__continue0::
			count = count + 1
		end
		return out.."\""
	end
	if (v == nil) or (v == require("enkoder").null) then return "null" end -- handling nil bcuz just in case™
	error(string.format("expected type table, string, number, nil or enkoder.null, got %s",type(v)))
end

function _M.encd(tbl, _)
	local out = "["
	local bgstNum = -1
	local looped = false
	for a in pairs(tbl) do
		if tostring(a):match("^(%d+)$") == nil then
			out="{"
			for k,v in pairs(tbl) do
				if looped then out = out.."," end
				looped = true
				if v~=nil then out = out.."\""..tostring(k):gsub("\"", "\\\"").."\":"..srz(v) end -- tbl[k] = v means making k vanish so were doing that too
			end
			return out.."}"
		end
		a=a+0
		if a > bgstNum then bgstNum = a end
	end
	local count = 1
	while count<=bgstNum do
		if looped then out = out.."," end
		looped = true
		out = out..srz(tbl[count])
		count = count + 1
	end
	return out.."]"
end

function handleV(str)
	local v
	if str:sub(1,1) == "\"" then
		v, str = eatJsonStr(str)
		return v, str
	end
	if str:sub(1,1):match("([0-9])")~=nil then
		v = str:match("^(-?%d+%.?%d*[eE]?-?%d*)")
		str = str:sub(#v+1)
		return tonumber(v), str
	end
	if str:sub(1,1) == "{" or str:sub(1,1) == "[" then
		local strt = str:sub(1,1)
		local oEnd = ({["{"]="}",["["]="]"})[strt] -- stupid lua reserving "end" as a kwrd
		local bCnt = 0
		v = ""
		while true do
			if str:sub(1,1) == strt then bCnt = bCnt + 1 end
			if str:sub(1,1) == oEnd then bCnt = bCnt - 1 end
			v = v..str:sub(1,1)
			str = str:sub(2) -- i already yank away chars that i do end up usinh
			if bCnt==0 then break end -- it only breaks *after* i yanked away a char
		end
		v = _M.dcde(v,{},true) -- yeah im just gonna recurse here lmfao
		return v, str
	end
	local booler = (str:match("^(false)") or str:match("^(true)")) -- hehe get it? spooler but also bool lmfao im a comedy genius
	if booler~=nil then
		v=booler=="true"
		str = str:sub(#booler+1) -- hehehey get yank'd
		return v, str
	end
	local null = str:match("^(null)")
	if null~=nil then -- the legendary battle of js null vs lua nil!! who wins?!!!
		v=require("enkoder").null
		str = str:sub(#null+1) -- hehehey get yank'd x2
		return v, str
	end
	error("blursed value") -- me handling this better make lua raise to >=25% for my most used langs stat smh
end

function _M.dcde(str, _, noEof)
	str = str..""
	local ch = str:sub(1,1)
	local res = {}
	if ch == "{" then
		if str:sub(-1,-1) ~= "}" then return error(string.format("unfinished object: %s", str)) end
		str = str:sub(2) -- slices off first `{`
		while true do -- idefk
			local k,v
			k, str = eatJsonStr(str)
			str = str:gsub("^(%s+)","") -- our first likely place for whitespace...
			if str:sub(1,1) ~= ":" then return error(string.format("expected \":\", got \"%s\"", str:sub(1,1))) end
			str = str:sub(2):gsub("^(%s+)","")
			v, str = handleV(str)
			str = str:gsub("^(%s+)","")
			ch = str:sub(1,1)
			res[k]=v
			if (ch ~= ",") and (ch ~= "}") then return error(string.format("expected comma or closing curly bracket, got \"%s\"", ch)) end -- you got me jumping like: boom shakalaka! boom shakalaka... boom!! boom shakalaka! boom shakalaka! boom.. boom shakala... boom shakala.. ahhhh!!
			if ch == "," then str = str:sub(2) end
			if ch == "}" then break end
			str = str:gsub("^(%s+)","")
		end
		str = str:sub(2)
		if str~="" and noEof~=true then return error(string.format("expected eof after closing curly bracket, got %q", str)) end
		return res
	end
	if ch == "[" then
		if str:sub(-1,-1) ~= "]" then return error(string.format("unfinished array: %s", str)) end
		str = str:sub(2) -- slices off first `{`
		while true do
			local v
			str = str:gsub("^(%s+)","")
			v, str = handleV(str)
			str = str:gsub("^(%s+)","")
			ch = str:sub(1,1)
			table.insert(res, v)
			if (ch ~= ",") and (ch ~= "]") then return error(string.format("expected comma or closing square bracket, got \"%s\"", ch)) end -- see line 148 😔
			if ch == "," then str = str:sub(2) end
			if ch == "]" then break end
			str = str:gsub("^(%s+)","")
		end
		return res
	end
	local handleV_Res = {handleV(str)} -- might error on funny valeus but oh fucking well
	if handleV_Res[2]~="" then return error("blursed value") end
	return handleV_Res[1]
end

return _M