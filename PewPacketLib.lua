function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'><b>[PewPacketLib]</b> </font> <font color=\'#FF0000\'>'..text..'</font>')
		return
	end
	print('<font color=\'#0099FF\'><b>[PewPacketLib]</b> </font> <font color=\'#FF6600\'>'..text..'</font>')
end

class "PewLibUpdate"
local version = 7.9
function PewLibUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
  self.LocalVersion = version
  self.Host = 'raw.githubusercontent.com'
  self.VersionPath = '/BoL/TCPUpdater/GetScript5.php?script='..self:Base64Encode(self.Host..'/PewPewPew2/BoL/master/Versions/PewPacketLib.version')..'&rand='..math.random(99999999)
  self.ScriptPath = '/BoL/TCPUpdater/GetScript5.php?script='..self:Base64Encode(self.Host..'/PewPewPew2/BoL/master/PewPacketLib.lua')..'&rand='..math.random(99999999)
  self.SavePath = LIB_PATH..'\\PewPacketLib.lua'
	self.CallbackUpdate = function() Print('Update complete, please reload (F9 F9)', true) end
	self.CallbackNoUpdate = function() return end
	self.CallbackNewVersion = function() Print('New version found, downloading now...', true) end
	self.CallbackError = function() Print('Error during download.', true) end
  self:CreateSocket(self.VersionPath)
  self.DownloadStatus = 'Connect to Server for VersionInfo'
  AddTickCallback(function() self:GetOnlineVersion() end)
end

function PewLibUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function PewLibUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function PewLibUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</s'..'ize>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function PewLibUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading Script (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.NewFile:find('<sc'..'ript>')
        local ContentEnd, _ = self.NewFile:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
                return
            end
            local newf = Base64Decode(newf)
            if type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
                f:write(newf)
                f:close()
                if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                    self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
                end
            end
        end
        self.GotScriptUpdate = true
    end
end

if PewUpdate then  
  PewUpdate(version, 
    LIB_PATH..'/PewPacketLib.lua', 
    'raw.githubusercontent.com', 
    '/PewPewPew2/BoL/master/Versions/PewPacketLib.version', 
    nil,
    '/PewPewPew2/BoL/master/PewPacketLib.lua', 
    function() return end, 
    function() Print('New version found, downloading now...', true) end, 
    function() Print('Update complete, please reload (F9 F9)', true) end,
    function() Print('Error during download.', true) end
  ) 
else  
  PewLibUpdate()
end

local GameVersion = GetGameVersion():sub(1,4)

function GetAggroPacketData()
	local _data = {
		['7.8.'] = {
			['GainAggro'] = { ['Header'] = 0x00B7, ['targetPos'] = 22, },
			['LoseAggro'] = { ['Header'] = 0x0022, },		
			['table'] = {[0x00] = 0x2A, [0x01] = 0xA2, [0x02] = 0x41, [0x03] = 0x36, [0x04] = 0x57, [0x05] = 0xE5, [0x06] = 0xB2, [0x07] = 0x08, [0x08] = 0x0E, [0x09] = 0x80, [0x0A] = 0xEC, [0x0B] = 0xC3, [0x0C] = 0xCF, [0x0D] = 0xD6, [0x0E] = 0x4A, [0x0F] = 0xC8, [0x10] = 0x91, [0x11] = 0xAA, [0x12] = 0xC4, [0x13] = 0x81, [0x14] = 0x43, [0x15] = 0xD2, [0x16] = 0x07, [0x17] = 0xFC, [0x18] = 0x05, [0x19] = 0x1C, [0x1A] = 0x20, [0x1B] = 0xE9, [0x1C] = 0x68, [0x1D] = 0xD1, [0x1E] = 0xDF, [0x1F] = 0x59, [0x20] = 0x14, [0x21] = 0x90, [0x22] = 0xA4, [0x23] = 0x7C, [0x24] = 0xD9, [0x25] = 0x37, [0x26] = 0xF2, [0x27] = 0xDC, [0x28] = 0x7F, [0x29] = 0x8E, [0x2A] = 0xE1, [0x2B] = 0x25, [0x2C] = 0xC5, [0x2D] = 0x33, [0x2E] = 0xF1, [0x2F] = 0x9F, [0x30] = 0x93, [0x31] = 0xC9, [0x32] = 0xE3, [0x33] = 0xA7, [0x34] = 0xD3, [0x35] = 0xA8, [0x36] = 0x32, [0x37] = 0x26, [0x38] = 0xC2, [0x39] = 0x01, [0x3A] = 0xA1, [0x3B] = 0x51, [0x3C] = 0x5E, [0x3D] = 0x46, [0x3E] = 0x21, [0x3F] = 0x44, [0x40] = 0xBD, [0x41] = 0xD0, [0x42] = 0x8A, [0x43] = 0x72, [0x44] = 0xB3, [0x45] = 0xFA, [0x46] = 0x52, [0x47] = 0xCE, [0x48] = 0xEF, [0x49] = 0x2B, [0x4A] = 0x67, [0x4B] = 0xF8, [0x4C] = 0xA6, [0x4D] = 0x28, [0x4E] = 0xC6, [0x4F] = 0x5B, [0x50] = 0x19, [0x51] = 0x84, [0x52] = 0xF0, [0x53] = 0x7E, [0x54] = 0x1E, [0x55] = 0x61, [0x56] = 0x99, [0x57] = 0xBC, [0x58] = 0x5D, [0x59] = 0x5C, [0x5A] = 0x9B, [0x5B] = 0x2D, [0x5C] = 0x95, [0x5D] = 0x58, [0x5E] = 0x4D, [0x5F] = 0x10, [0x60] = 0x35, [0x61] = 0x6F, [0x62] = 0xAC, [0x63] = 0x89, [0x64] = 0x94, [0x65] = 0x0A, [0x66] = 0x79, [0x67] = 0x63, [0x68] = 0xBE, [0x69] = 0x4C, [0x6A] = 0x39, [0x6B] = 0x96, [0x6C] = 0x69, [0x6D] = 0x50, [0x6E] = 0xD7, [0x6F] = 0xAF, [0x70] = 0xE2, [0x71] = 0x3F, [0x72] = 0xF9, [0x73] = 0x4B, [0x74] = 0x8F, [0x75] = 0x30, [0x76] = 0xE6, [0x77] = 0x3E, [0x78] = 0x7D, [0x79] = 0x73, [0x7A] = 0x22, [0x7B] = 0x7A, [0x7C] = 0x3B, [0x7D] = 0xF3, [0x7E] = 0xCB, [0x7F] = 0x92, [0x80] = 0x66, [0x81] = 0xB8, [0x82] = 0xAB, [0x83] = 0x7B, [0x84] = 0x1A, [0x85] = 0xB0, [0x86] = 0x27, [0x87] = 0x23, [0x88] = 0xFB, [0x89] = 0xF4, [0x8A] = 0x85, [0x8B] = 0xED, [0x8C] = 0x8B, [0x8D] = 0xB6, [0x8E] = 0x71, [0x8F] = 0xB1, [0x90] = 0x2E, [0x91] = 0x9C, [0x92] = 0x3A, [0x93] = 0x62, [0x94] = 0x48, [0x95] = 0xD8, [0x96] = 0xD5, [0x97] = 0xE4, [0x98] = 0x09, [0x99] = 0x02, [0x9A] = 0x1D, [0x9B] = 0x06, [0x9C] = 0x9E, [0x9D] = 0x54, [0x9E] = 0xCD, [0x9F] = 0xF7, [0xA0] = 0xAE, [0xA1] = 0xB9, [0xA2] = 0x0D, [0xA3] = 0x65, [0xA4] = 0x53, [0xA5] = 0x76, [0xA6] = 0xBA, [0xA7] = 0x77, [0xA8] = 0x31, [0xA9] = 0x3D, [0xAA] = 0x78, [0xAB] = 0xFE, [0xAC] = 0x83, [0xAD] = 0xCC, [0xAE] = 0x86, [0xAF] = 0xBB, [0xB0] = 0xDE, [0xB1] = 0xBF, [0xB2] = 0xEA, [0xB3] = 0x04, [0xB4] = 0x8C, [0xB5] = 0xA9, [0xB6] = 0x9D, [0xB7] = 0x45, [0xB8] = 0xE7, [0xB9] = 0x60, [0xBA] = 0x56, [0xBB] = 0xDB, [0xBC] = 0x47, [0xBD] = 0x2C, [0xBE] = 0x6D, [0xBF] = 0x42, [0xC0] = 0xE0, [0xC1] = 0x4F, [0xC2] = 0x18, [0xC3] = 0xDA, [0xC4] = 0x0F, [0xC5] = 0x74, [0xC6] = 0x0C, [0xC7] = 0x70, [0xC8] = 0x88, [0xC9] = 0xD4, [0xCA] = 0xFF, [0xCB] = 0xEB, [0xCC] = 0xB7, [0xCD] = 0x1F, [0xCE] = 0x00, [0xCF] = 0xCA, [0xD0] = 0xAD, [0xD1] = 0xF6, [0xD2] = 0x4E, [0xD3] = 0x6B, [0xD4] = 0x13, [0xD5] = 0x82, [0xD6] = 0x49, [0xD7] = 0xA3, [0xD8] = 0xF5, [0xD9] = 0x64, [0xDA] = 0x03, [0xDB] = 0xFD, [0xDC] = 0x38, [0xDD] = 0x5A, [0xDE] = 0x12, [0xDF] = 0xA0, [0xE0] = 0x3C, [0xE1] = 0x16, [0xE2] = 0xEE, [0xE3] = 0xC0, [0xE4] = 0xA5, [0xE5] = 0x97, [0xE6] = 0x1B, [0xE7] = 0xB4, [0xE8] = 0x6C, [0xE9] = 0x6A, [0xEA] = 0x5F, [0xEB] = 0x98, [0xEC] = 0x9A, [0xED] = 0xC7, [0xEE] = 0xE8, [0xEF] = 0x34, [0xF0] = 0x15, [0xF1] = 0x40, [0xF2] = 0x55, [0xF3] = 0x87, [0xF4] = 0x29, [0xF5] = 0xC1, [0xF6] = 0x8D, [0xF7] = 0xB5, [0xF8] = 0x0B, [0xF9] = 0x11, [0xFA] = 0x75, [0xFB] = 0x24, [0xFC] = 0x6E, [0xFD] = 0x17, [0xFE] = 0xDD, [0xFF] = 0x2F, },
		},
		['7.9.'] = {
			['GainAggro'] = { ['Header'] = 0x0062, ['targetPos'] = 19, },
			['LoseAggro'] = { ['Header'] = 0x00A5, },		
			['table'] = {[0x00] = 0x2A, [0x01] = 0x0A, [0x02] = 0x3A, [0x03] = 0x1A, [0x04] = 0x32, [0x05] = 0x12, [0x06] = 0x02, [0x07] = 0x22, [0x08] = 0x36, [0x09] = 0x16, [0x0A] = 0x06, [0x0B] = 0x26, [0x0C] = 0x3E, [0x0D] = 0x1E, [0x0E] = 0x0E, [0x0F] = 0x2E, [0x10] = 0x28, [0x11] = 0x08, [0x12] = 0x38, [0x13] = 0x18, [0x14] = 0x30, [0x15] = 0x10, [0x16] = 0x00, [0x17] = 0x20, [0x18] = 0x34, [0x19] = 0x14, [0x1A] = 0x04, [0x1B] = 0x24, [0x1C] = 0x3C, [0x1D] = 0x1C, [0x1E] = 0x0C, [0x1F] = 0x2C, [0x20] = 0x29, [0x21] = 0x09, [0x22] = 0x39, [0x23] = 0x19, [0x24] = 0x31, [0x25] = 0x11, [0x26] = 0x01, [0x27] = 0x21, [0x28] = 0x35, [0x29] = 0x15, [0x2A] = 0x05, [0x2B] = 0x25, [0x2C] = 0x3D, [0x2D] = 0x1D, [0x2E] = 0x0D, [0x2F] = 0x2D, [0x30] = 0x37, [0x31] = 0x17, [0x32] = 0x07, [0x33] = 0x27, [0x34] = 0x3F, [0x35] = 0x1F, [0x36] = 0x0F, [0x37] = 0x2F, [0x38] = 0x33, [0x39] = 0x13, [0x3A] = 0x03, [0x3B] = 0x23, [0x3C] = 0x3B, [0x3D] = 0x1B, [0x3E] = 0x0B, [0x3F] = 0x2B, [0x40] = 0xAA, [0x41] = 0x8A, [0x42] = 0xBA, [0x43] = 0x9A, [0x44] = 0xB2, [0x45] = 0x92, [0x46] = 0x82, [0x47] = 0xA2, [0x48] = 0xB6, [0x49] = 0x96, [0x4A] = 0x86, [0x4B] = 0xA6, [0x4C] = 0xBE, [0x4D] = 0x9E, [0x4E] = 0x8E, [0x4F] = 0xAE, [0x50] = 0xA8, [0x51] = 0x88, [0x52] = 0xB8, [0x53] = 0x98, [0x54] = 0xB0, [0x55] = 0x90, [0x56] = 0x80, [0x57] = 0xA0, [0x58] = 0xB4, [0x59] = 0x94, [0x5A] = 0x84, [0x5B] = 0xA4, [0x5C] = 0xBC, [0x5D] = 0x9C, [0x5E] = 0x8C, [0x5F] = 0xAC, [0x60] = 0xA9, [0x61] = 0x89, [0x62] = 0xB9, [0x63] = 0x99, [0x64] = 0xB1, [0x65] = 0x91, [0x66] = 0x81, [0x67] = 0xA1, [0x68] = 0xB5, [0x69] = 0x95, [0x6A] = 0x85, [0x6B] = 0xA5, [0x6C] = 0xBD, [0x6D] = 0x9D, [0x6E] = 0x8D, [0x6F] = 0xAD, [0x70] = 0xB7, [0x71] = 0x97, [0x72] = 0x87, [0x73] = 0xA7, [0x74] = 0xBF, [0x75] = 0x9F, [0x76] = 0x8F, [0x77] = 0xAF, [0x78] = 0xB3, [0x79] = 0x93, [0x7A] = 0x83, [0x7B] = 0xA3, [0x7C] = 0xBB, [0x7D] = 0x9B, [0x7E] = 0x8B, [0x7F] = 0xAB, [0x80] = 0xEA, [0x81] = 0xCA, [0x82] = 0xFA, [0x83] = 0xDA, [0x84] = 0xF2, [0x85] = 0xD2, [0x86] = 0xC2, [0x87] = 0xE2, [0x88] = 0xF6, [0x89] = 0xD6, [0x8A] = 0xC6, [0x8B] = 0xE6, [0x8C] = 0xFE, [0x8D] = 0xDE, [0x8E] = 0xCE, [0x8F] = 0xEE, [0x90] = 0xE8, [0x91] = 0xC8, [0x92] = 0xF8, [0x93] = 0xD8, [0x94] = 0xF0, [0x95] = 0xD0, [0x96] = 0xC0, [0x97] = 0xE0, [0x98] = 0xF4, [0x99] = 0xD4, [0x9A] = 0xC4, [0x9B] = 0xE4, [0x9C] = 0xFC, [0x9D] = 0xDC, [0x9E] = 0xCC, [0x9F] = 0xEC, [0xA0] = 0xE9, [0xA1] = 0xC9, [0xA2] = 0xF9, [0xA3] = 0xD9, [0xA4] = 0xF1, [0xA5] = 0xD1, [0xA6] = 0xC1, [0xA7] = 0xE1, [0xA8] = 0xF5, [0xA9] = 0xD5, [0xAA] = 0xC5, [0xAB] = 0xE5, [0xAC] = 0xFD, [0xAD] = 0xDD, [0xAE] = 0xCD, [0xAF] = 0xED, [0xB0] = 0xF7, [0xB1] = 0xD7, [0xB2] = 0xC7, [0xB3] = 0xE7, [0xB4] = 0xFF, [0xB5] = 0xDF, [0xB6] = 0xCF, [0xB7] = 0xEF, [0xB8] = 0xF3, [0xB9] = 0xD3, [0xBA] = 0xC3, [0xBB] = 0xE3, [0xBC] = 0xFB, [0xBD] = 0xDB, [0xBE] = 0xCB, [0xBF] = 0xEB, [0xC0] = 0x69, [0xC1] = 0x49, [0xC2] = 0x79, [0xC3] = 0x59, [0xC4] = 0x71, [0xC5] = 0x51, [0xC6] = 0x41, [0xC7] = 0x61, [0xC8] = 0x75, [0xC9] = 0x55, [0xCA] = 0x45, [0xCB] = 0x65, [0xCC] = 0x7D, [0xCD] = 0x5D, [0xCE] = 0x4D, [0xCF] = 0x6D, [0xD0] = 0x77, [0xD1] = 0x57, [0xD2] = 0x47, [0xD3] = 0x67, [0xD4] = 0x7F, [0xD5] = 0x5F, [0xD6] = 0x4F, [0xD7] = 0x6F, [0xD8] = 0x73, [0xD9] = 0x53, [0xDA] = 0x43, [0xDB] = 0x63, [0xDC] = 0x7B, [0xDD] = 0x5B, [0xDE] = 0x4B, [0xDF] = 0x6B, [0xE0] = 0x68, [0xE1] = 0x48, [0xE2] = 0x78, [0xE3] = 0x58, [0xE4] = 0x70, [0xE5] = 0x50, [0xE6] = 0x40, [0xE7] = 0x60, [0xE8] = 0x74, [0xE9] = 0x54, [0xEA] = 0x44, [0xEB] = 0x64, [0xEC] = 0x7C, [0xED] = 0x5C, [0xEE] = 0x4C, [0xEF] = 0x6C, [0xF0] = 0x76, [0xF1] = 0x56, [0xF2] = 0x46, [0xF3] = 0x66, [0xF4] = 0x7E, [0xF5] = 0x5E, [0xF6] = 0x4E, [0xF7] = 0x6E, [0xF8] = 0x72, [0xF9] = 0x52, [0xFA] = 0x42, [0xFB] = 0x62, [0xFC] = 0x7A, [0xFD] = 0x5A, [0xFE] = 0x4A, [0xFF] = 0x6A, },
		},
		['7.7.'] = {
			['GainAggro'] = { ['Header'] = 0x0077, ['targetPos'] = 34, },
			['LoseAggro'] = { ['Header'] = 0x011D, },		
			['table'] = {[0x00] = 0xE9, [0x01] = 0xEB, [0x02] = 0xED, [0x03] = 0xEF, [0x04] = 0x69, [0x05] = 0x6B, [0x06] = 0x6D, [0x07] = 0x6F, [0x08] = 0xE8, [0x09] = 0xEA, [0x0A] = 0xEC, [0x0B] = 0xEE, [0x0C] = 0x68, [0x0D] = 0x6A, [0x0E] = 0x6C, [0x0F] = 0x6E, [0x10] = 0xC9, [0x11] = 0xCB, [0x12] = 0xCD, [0x13] = 0xCF, [0x14] = 0x49, [0x15] = 0x4B, [0x16] = 0x4D, [0x17] = 0x4F, [0x18] = 0xC8, [0x19] = 0xCA, [0x1A] = 0xCC, [0x1B] = 0xCE, [0x1C] = 0x48, [0x1D] = 0x4A, [0x1E] = 0x4C, [0x1F] = 0x4E, [0x20] = 0xA9, [0x21] = 0xAB, [0x22] = 0xAD, [0x23] = 0xAF, [0x24] = 0x29, [0x25] = 0x2B, [0x26] = 0x2D, [0x27] = 0x2F, [0x28] = 0xA8, [0x29] = 0xAA, [0x2A] = 0xAC, [0x2B] = 0xAE, [0x2C] = 0x28, [0x2D] = 0x2A, [0x2E] = 0x2C, [0x2F] = 0x2E, [0x30] = 0x89, [0x31] = 0x8B, [0x32] = 0x8D, [0x33] = 0x8F, [0x34] = 0x09, [0x35] = 0x0B, [0x36] = 0x0D, [0x37] = 0x0F, [0x38] = 0x88, [0x39] = 0x8A, [0x3A] = 0x8C, [0x3B] = 0x8E, [0x3C] = 0x08, [0x3D] = 0x0A, [0x3E] = 0x0C, [0x3F] = 0x0E, [0x40] = 0xE1, [0x41] = 0xE3, [0x42] = 0xE5, [0x43] = 0xE7, [0x44] = 0x61, [0x45] = 0x63, [0x46] = 0x65, [0x47] = 0x67, [0x48] = 0xE0, [0x49] = 0xE2, [0x4A] = 0xE4, [0x4B] = 0xE6, [0x4C] = 0x60, [0x4D] = 0x62, [0x4E] = 0x64, [0x4F] = 0x66, [0x50] = 0xC1, [0x51] = 0xC3, [0x52] = 0xC5, [0x53] = 0xC7, [0x54] = 0x41, [0x55] = 0x43, [0x56] = 0x45, [0x57] = 0x47, [0x58] = 0xC0, [0x59] = 0xC2, [0x5A] = 0xC4, [0x5B] = 0xC6, [0x5C] = 0x40, [0x5D] = 0x42, [0x5E] = 0x44, [0x5F] = 0x46, [0x60] = 0xA1, [0x61] = 0xA3, [0x62] = 0xA5, [0x63] = 0xA7, [0x64] = 0x21, [0x65] = 0x23, [0x66] = 0x25, [0x67] = 0x27, [0x68] = 0xA0, [0x69] = 0xA2, [0x6A] = 0xA4, [0x6B] = 0xA6, [0x6C] = 0x20, [0x6D] = 0x22, [0x6E] = 0x24, [0x6F] = 0x26, [0x70] = 0x81, [0x71] = 0x83, [0x72] = 0x85, [0x73] = 0x87, [0x74] = 0x01, [0x75] = 0x03, [0x76] = 0x05, [0x77] = 0x07, [0x78] = 0x80, [0x79] = 0x82, [0x7A] = 0x84, [0x7B] = 0x86, [0x7C] = 0x00, [0x7D] = 0x02, [0x7E] = 0x04, [0x7F] = 0x06, [0x80] = 0xF9, [0x81] = 0xFB, [0x82] = 0xFD, [0x83] = 0xFF, [0x84] = 0x79, [0x85] = 0x7B, [0x86] = 0x7D, [0x87] = 0x7F, [0x88] = 0xF8, [0x89] = 0xFA, [0x8A] = 0xFC, [0x8B] = 0xFE, [0x8C] = 0x78, [0x8D] = 0x7A, [0x8E] = 0x7C, [0x8F] = 0x7E, [0x90] = 0xD9, [0x91] = 0xDB, [0x92] = 0xDD, [0x93] = 0xDF, [0x94] = 0x59, [0x95] = 0x5B, [0x96] = 0x5D, [0x97] = 0x5F, [0x98] = 0xD8, [0x99] = 0xDA, [0x9A] = 0xDC, [0x9B] = 0xDE, [0x9C] = 0x58, [0x9D] = 0x5A, [0x9E] = 0x5C, [0x9F] = 0x5E, [0xA0] = 0xB9, [0xA1] = 0xBB, [0xA2] = 0xBD, [0xA3] = 0xBF, [0xA4] = 0x39, [0xA5] = 0x3B, [0xA6] = 0x3D, [0xA7] = 0x3F, [0xA8] = 0xB8, [0xA9] = 0xBA, [0xAA] = 0xBC, [0xAB] = 0xBE, [0xAC] = 0x38, [0xAD] = 0x3A, [0xAE] = 0x3C, [0xAF] = 0x3E, [0xB0] = 0x99, [0xB1] = 0x9B, [0xB2] = 0x9D, [0xB3] = 0x9F, [0xB4] = 0x19, [0xB5] = 0x1B, [0xB6] = 0x1D, [0xB7] = 0x1F, [0xB8] = 0x98, [0xB9] = 0x9A, [0xBA] = 0x9C, [0xBB] = 0x9E, [0xBC] = 0x18, [0xBD] = 0x1A, [0xBE] = 0x1C, [0xBF] = 0x1E, [0xC0] = 0xF1, [0xC1] = 0xF3, [0xC2] = 0xF5, [0xC3] = 0xF7, [0xC4] = 0x71, [0xC5] = 0x73, [0xC6] = 0x75, [0xC7] = 0x77, [0xC8] = 0xF0, [0xC9] = 0xF2, [0xCA] = 0xF4, [0xCB] = 0xF6, [0xCC] = 0x70, [0xCD] = 0x72, [0xCE] = 0x74, [0xCF] = 0x76, [0xD0] = 0xD1, [0xD1] = 0xD3, [0xD2] = 0xD5, [0xD3] = 0xD7, [0xD4] = 0x51, [0xD5] = 0x53, [0xD6] = 0x55, [0xD7] = 0x57, [0xD8] = 0xD0, [0xD9] = 0xD2, [0xDA] = 0xD4, [0xDB] = 0xD6, [0xDC] = 0x50, [0xDD] = 0x52, [0xDE] = 0x54, [0xDF] = 0x56, [0xE0] = 0xB1, [0xE1] = 0xB3, [0xE2] = 0xB5, [0xE3] = 0xB7, [0xE4] = 0x31, [0xE5] = 0x33, [0xE6] = 0x35, [0xE7] = 0x37, [0xE8] = 0xB0, [0xE9] = 0xB2, [0xEA] = 0xB4, [0xEB] = 0xB6, [0xEC] = 0x30, [0xED] = 0x32, [0xEE] = 0x34, [0xEF] = 0x36, [0xF0] = 0x91, [0xF1] = 0x93, [0xF2] = 0x95, [0xF3] = 0x97, [0xF4] = 0x11, [0xF5] = 0x13, [0xF6] = 0x15, [0xF7] = 0x17, [0xF8] = 0x90, [0xF9] = 0x92, [0xFA] = 0x94, [0xFB] = 0x96, [0xFC] = 0x10, [0xFD] = 0x12, [0xFE] = 0x14, [0xFF] = 0x16, },
		},
	}
	return _data[GameVersion]
end

function GetLoseVisionPacketData()
	local _data = {
		['7.7.'] = {
			['Header'] = 0x0162,
			['Pos'] = 2,	
		},
		['7.8.'] = {
			['Header'] = 0x00F1,
			['Pos'] = 2,
		},
		['7.9.'] = {
			['Header'] = 0x008C, 
			['Pos'] = 2,	
		},
	}
	return _data[GameVersion]
end

function GetGainVisionPacketData()
	local _data = {
		['7.7.'] = {
			['Header'] = 0x0108, 
			['pos'] = 2,
		},
		['7.8.'] = { 
			['Header'] = 0x017D, 
			['pos'] = 2,
		},
		['7.9.'] = {
			['Header'] = 0x0010, 
			['pos'] = 2,	
		},
	}
	return _data[GameVersion]
end

function GetMasteryEmoteData()
	local cVersion = GetGameVersion()
	if cVersion:find('7.7.182.1428') then
		return {
			['Header'] = 0x012B,
			['vTable'] = 0x10F85EC,
			['hash'] = 0xBBBBBBBB,
		}
	elseif cVersion:find('7.9.186.1051') then
		return {
			['Header'] = 0x0165,
			['vTable'] = 0xFC81EC,
			['hash'] = 0x3D3D3D3D,
		}
	elseif cVersion:find('7.8.184.113') then
		return {
			['Header'] = 0x00D6,
			['vTable'] = 0x10AC114,
			['hash'] = 0x46464646,
		}
	end
end
