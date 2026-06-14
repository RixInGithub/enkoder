-- enkoder: a particularily nifty *enkoder* and decoder of popular serialisation formats
-- such as json, msgpack and yaml
-- huge wip

function nullStr() return "enkoder.null" end

local dkNull = (function()
	local okay, res = pcall(function() return require("dkjson").null end)
	return okay and res or nil
end)()
local _M = {}
_M.null = setmetatable({}, {
	__tostring = nullStr,
	__tojson = function() return "null" end, -- dkjson compatability
	__call = function() return _M.null end,
	__eq = function(a,b)
		return _M.isNull(a) and _M.isNull(b)
	end
})

function _M.isNull(a)
	local mt = getmetatable(a)
	if mt == nil then mt = {} end
	local aStr = mt.__tostring
	if dkNull~=nil and aStr == nil then -- explicit safeguard
		if tostring(a)==tostring(dkNull) then return true end
	end
	return aStr==nullStr
end

return setmetatable(_M, { -- basically can be called, but also has enkoder.null
	__call = function(_, inp, fmt)
		if type(fmt) == "string" then return _M(inp, {fmt}) end
		-- if type(inp) ~= "table" and type(inp) ~= "string" then return error(string.format("input must either be a table (to encode) or a string (to decode), instead got \"%s\"", type(inp))) end
		local opts = {}
		for k,v in pairs(fmt) do
			if type(tonumber(k)) == "number" then
				k = v
				v = {}
			end
			if type(k) ~= "string" then return error(string.format("expected type \"string\" for key, got \"%s\"", type(k))) end
			-- currently handled: {[num] = "..."}, {["..."] = {...?}} and prob mixed
			if type(v) ~= "table" then return error(string.format("expected type \"table\" for key, got \"%s\"", type(v))) end
			for vK, vV in pairs(v) do
				if type(tonumber(vK)) == "number" then return error(string.format("expected type \"string\" for key of value, got \"%s\"", type(vK))) end
			end
			-- k="...", v={([key]: value)?}
			if opts[k] == nil then opts[k] = {} end
			for vK, vV in pairs(v) do opts[k][vK] = vV end
		end
		-- opts={[fmt]={([key]: value)?}}
		local res = {}
		local srzs = require("enkoder.srz")
		local oCnt = 0
		local firstO
		local toCall = "dcde"
		if type(inp) ~= "string" then toCall = "encd" end
		for oFmt,o in pairs(opts) do
			for nm,srz in pairs(srzs) do
				if nm == oFmt then
					res[nm] = srz[toCall](inp, o)
				end
			end
			if not res[oFmt] then return error(string.format("unknown format %q", oFmt)) end
			oCnt = oCnt + 1
			if firstO == nil then firstO = oFmt end
		end
		if oCnt == 1 then return res[firstO] end
		return res
	end
})