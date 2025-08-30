local _M = {}

function splitByNl(a) -- taken from another lua projectery
	local b={}
	for c in a:gmatch("([^\n]*)\n?")do(table.insert)(b,c)end
	return(b)
end

function indentStr(str, idnt)
	local tbl = splitByNl(str)
	for idx, ln in pairs(tbl) do
		if ln~="" then tbl[idx] = string.char(32):rep(idnt)..ln end
	end
	return table.concat(tbl, "\n")
end

function srz(v, indent)
	if type(v) == "number" or type(v) == "boolean" then return " "..tostring(v) end
	if type(v) == "string" then
		return " |\n"..indentStr(v, indent)
	end
	if type(v) == "table" then
		local pureList = true
		local biggestIdx = 0
		for k,v in pairs(v) do
			pureList = pureList and (tonumber(k)~=nil)
			if not pureList then break end -- "ok ok i get it"
			biggestIdx = math.max(biggestIdx, k)
		end
		if pureList then
			local res = ""
			local count = 1
			while count <= biggestIdx do
				res = res.."\n"..indentStr("-"..srz(v[count], indent), indent)
				count = count + 1
			end
			return res
		end
		return "\n"..indentStr(_M.encd(v, {indent=indent}),indent)
	end
	if (v == nil) or (v == require("enkoder").null) then return " null" end -- handling nil bcuz just in case™
end

function _M.encd(tbl, opts)
	local indent = 4
	if tonumber(opts.indent) then indent = tonumber(opts.indent) end -- first use of opts to do smth cooler!!
	indent = math.max(indent,2) -- min val is 2, just to be saef.
	local res = {}
	for k,v in pairs(tbl) do
		local add = k..":"..srz(v, indent)
		table.insert(res, add)
	end
	return table.concat(res,"\n")
end

function _M.decd(str, opts)
	error("not implemented")
end

return _M