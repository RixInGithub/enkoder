-- enkoder: a particularily nifty *enkoder* and decoder of popular serialisation formats
-- such as json, msgpack and yaml
-- huge wip

local _M = {}
_M.null = setmetatable({}, {
	__tostring = function()return"enkoder.null"end,
	__call = function() return _M.null end
})

return setmetatable(_M, { -- basically can be called, but also has enkoder.null
	__call = function(_, inp, fmt)
		if type(fmt) == "string" then return _M(inp, {fmt}) end
		if type(inp) ~= "table" and type(inp) ~= "string" then return error(string.format("input must either be a table (to encode) or a string (to decode), instead got \"%s\"", type(inp))) end
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
		for oFmt,o in pairs(opts) do
			for nm,srz in pairs(srzs) do
				if nm == oFmt then
					res[nm] = srz[({["table"]="encd",["string"]="dcde"})[type(inp)]](inp, o)
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