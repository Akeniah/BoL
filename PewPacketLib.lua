function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'><b>[PewPacketLib]</b> </font> <font color=\'#FF0000\'>'..text..'</font>')
		return
	end
	print('<font color=\'#0099FF\'><b>[PewPacketLib]</b> </font> <font color=\'#FF6600\'>'..text..'</font>')
end

class "PewLibUpdate"
local version = 7.97
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
		['7.14'] = {
			['GainAggro'] = { ['Header'] = 0x014F, ['targetPos'] = 10, },
			['LoseAggro'] = { ['Header'] = 0x0179, },		
			['table'] = {[0x00] = 0xBD, [0x01] = 0x3C, [0x02] = 0xBC, [0x03] = 0x3F, [0x04] = 0xBF, [0x05] = 0x3E, [0x06] = 0xBE, [0x07] = 0x39, [0x08] = 0xB9, [0x09] = 0x38, [0x0A] = 0xB8, [0x0B] = 0x3B, [0x0C] = 0xBB, [0x0D] = 0x3A, [0x0E] = 0xBA, [0x0F] = 0x35, [0x10] = 0xB5, [0x11] = 0x34, [0x12] = 0xB4, [0x13] = 0x37, [0x14] = 0xB7, [0x15] = 0x36, [0x16] = 0xB6, [0x17] = 0x31, [0x18] = 0xB1, [0x19] = 0x30, [0x1A] = 0xB0, [0x1B] = 0x33, [0x1C] = 0xB3, [0x1D] = 0x32, [0x1E] = 0xB2, [0x1F] = 0x2D, [0x20] = 0xAD, [0x21] = 0x2C, [0x22] = 0xAC, [0x23] = 0x2F, [0x24] = 0xAF, [0x25] = 0x2E, [0x26] = 0xAE, [0x27] = 0x29, [0x28] = 0xA9, [0x29] = 0x28, [0x2A] = 0xA8, [0x2B] = 0x2B, [0x2C] = 0xAB, [0x2D] = 0x2A, [0x2E] = 0xAA, [0x2F] = 0x25, [0x30] = 0xA5, [0x31] = 0x24, [0x32] = 0xA4, [0x33] = 0x27, [0x34] = 0xA7, [0x35] = 0x26, [0x36] = 0xA6, [0x37] = 0x21, [0x38] = 0xA1, [0x39] = 0x20, [0x3A] = 0xA0, [0x3B] = 0x23, [0x3C] = 0xA3, [0x3D] = 0x22, [0x3E] = 0xA2, [0x3F] = 0x1D, [0x40] = 0x9D, [0x41] = 0x1C, [0x42] = 0x9C, [0x43] = 0x1F, [0x44] = 0x9F, [0x45] = 0x1E, [0x46] = 0x9E, [0x47] = 0x19, [0x48] = 0x99, [0x49] = 0x18, [0x4A] = 0x98, [0x4B] = 0x1B, [0x4C] = 0x9B, [0x4D] = 0x1A, [0x4E] = 0x9A, [0x4F] = 0x15, [0x50] = 0x95, [0x51] = 0x14, [0x52] = 0x94, [0x53] = 0x17, [0x54] = 0x97, [0x55] = 0x16, [0x56] = 0x96, [0x57] = 0x11, [0x58] = 0x91, [0x59] = 0x10, [0x5A] = 0x90, [0x5B] = 0x13, [0x5C] = 0x93, [0x5D] = 0x12, [0x5E] = 0x92, [0x5F] = 0x0D, [0x60] = 0x8D, [0x61] = 0x0C, [0x62] = 0x8C, [0x63] = 0x0F, [0x64] = 0x8F, [0x65] = 0x0E, [0x66] = 0x8E, [0x67] = 0x09, [0x68] = 0x89, [0x69] = 0x08, [0x6A] = 0x88, [0x6B] = 0x0B, [0x6C] = 0x8B, [0x6D] = 0x0A, [0x6E] = 0x8A, [0x6F] = 0x05, [0x70] = 0x85, [0x71] = 0x04, [0x72] = 0x84, [0x73] = 0x07, [0x74] = 0x87, [0x75] = 0x06, [0x76] = 0x86, [0x77] = 0x01, [0x78] = 0x81, [0x79] = 0x00, [0x7A] = 0x80, [0x7B] = 0x03, [0x7C] = 0x83, [0x7D] = 0x02, [0x7E] = 0x82, [0x7F] = 0x7D, [0x80] = 0xFD, [0x81] = 0x7C, [0x82] = 0xFC, [0x83] = 0x7F, [0x84] = 0xFF, [0x85] = 0x7E, [0x86] = 0xFE, [0x87] = 0x79, [0x88] = 0xF9, [0x89] = 0x78, [0x8A] = 0xF8, [0x8B] = 0x7B, [0x8C] = 0xFB, [0x8D] = 0x7A, [0x8E] = 0xFA, [0x8F] = 0x75, [0x90] = 0xF5, [0x91] = 0x74, [0x92] = 0xF4, [0x93] = 0x77, [0x94] = 0xF7, [0x95] = 0x76, [0x96] = 0xF6, [0x97] = 0x71, [0x98] = 0xF1, [0x99] = 0x70, [0x9A] = 0xF0, [0x9B] = 0x73, [0x9C] = 0xF3, [0x9D] = 0x72, [0x9E] = 0xF2, [0x9F] = 0x6D, [0xA0] = 0xED, [0xA1] = 0x6C, [0xA2] = 0xEC, [0xA3] = 0x6F, [0xA4] = 0xEF, [0xA5] = 0x6E, [0xA6] = 0xEE, [0xA7] = 0x69, [0xA8] = 0xE9, [0xA9] = 0x68, [0xAA] = 0xE8, [0xAB] = 0x6B, [0xAC] = 0xEB, [0xAD] = 0x6A, [0xAE] = 0xEA, [0xAF] = 0x65, [0xB0] = 0xE5, [0xB1] = 0x64, [0xB2] = 0xE4, [0xB3] = 0x67, [0xB4] = 0xE7, [0xB5] = 0x66, [0xB6] = 0xE6, [0xB7] = 0x61, [0xB8] = 0xE1, [0xB9] = 0x60, [0xBA] = 0xE0, [0xBB] = 0x63, [0xBC] = 0xE3, [0xBD] = 0x62, [0xBE] = 0xE2, [0xBF] = 0x5D, [0xC0] = 0xDD, [0xC1] = 0x5C, [0xC2] = 0xDC, [0xC3] = 0x5F, [0xC4] = 0xDF, [0xC5] = 0x5E, [0xC6] = 0xDE, [0xC7] = 0x59, [0xC8] = 0xD9, [0xC9] = 0x58, [0xCA] = 0xD8, [0xCB] = 0x5B, [0xCC] = 0xDB, [0xCD] = 0x5A, [0xCE] = 0xDA, [0xCF] = 0x55, [0xD0] = 0xD5, [0xD1] = 0x54, [0xD2] = 0xD4, [0xD3] = 0x57, [0xD4] = 0xD7, [0xD5] = 0x56, [0xD6] = 0xD6, [0xD7] = 0x51, [0xD8] = 0xD1, [0xD9] = 0x50, [0xDA] = 0xD0, [0xDB] = 0x53, [0xDC] = 0xD3, [0xDD] = 0x52, [0xDE] = 0xD2, [0xDF] = 0x4D, [0xE0] = 0xCD, [0xE1] = 0x4C, [0xE2] = 0xCC, [0xE3] = 0x4F, [0xE4] = 0xCF, [0xE5] = 0x4E, [0xE6] = 0xCE, [0xE7] = 0x49, [0xE8] = 0xC9, [0xE9] = 0x48, [0xEA] = 0xC8, [0xEB] = 0x4B, [0xEC] = 0xCB, [0xED] = 0x4A, [0xEE] = 0xCA, [0xEF] = 0x45, [0xF0] = 0xC5, [0xF1] = 0x44, [0xF2] = 0xC4, [0xF3] = 0x47, [0xF4] = 0xC7, [0xF5] = 0x46, [0xF6] = 0xC6, [0xF7] = 0x41, [0xF8] = 0xC1, [0xF9] = 0x40, [0xFA] = 0xC0, [0xFB] = 0x43, [0xFC] = 0xC3, [0xFD] = 0x42, [0xFE] = 0xC2, [0xFF] = 0x3D, },
		},
		['7.15'] = {
			['GainAggro'] = { ['Header'] = 0x013F, ['targetPos'] = 40, },
			['LoseAggro'] = { ['Header'] = 0x01A7, },		
			['table'] = {[0x00] = 0x29, [0x01] = 0xF6, [0x02] = 0x0A, [0x03] = 0x3F, [0x04] = 0x63, [0x05] = 0xFD, [0x06] = 0x2A, [0x07] = 0xA6, [0x08] = 0x18, [0x09] = 0xA3, [0x0A] = 0x99, [0x0B] = 0xB3, [0x0C] = 0xF4, [0x0D] = 0xBC, [0x0E] = 0xC8, [0x0F] = 0x53, [0x10] = 0x11, [0x11] = 0x34, [0x12] = 0xE1, [0x13] = 0x66, [0x14] = 0xB8, [0x15] = 0xA5, [0x16] = 0xAA, [0x17] = 0x55, [0x18] = 0xC7, [0x19] = 0xFA, [0x1A] = 0x8B, [0x1B] = 0xDC, [0x1C] = 0xA9, [0x1D] = 0x14, [0x1E] = 0xE4, [0x1F] = 0xE0, [0x20] = 0xC3, [0x21] = 0x2D, [0x22] = 0xEA, [0x23] = 0x27, [0x24] = 0x82, [0x25] = 0xDA, [0x26] = 0x85, [0x27] = 0x87, [0x28] = 0xCE, [0x29] = 0x1F, [0x2A] = 0x33, [0x2B] = 0x0B, [0x2C] = 0x78, [0x2D] = 0x54, [0x2E] = 0x00, [0x2F] = 0xD6, [0x30] = 0xA4, [0x31] = 0xAF, [0x32] = 0x70, [0x33] = 0x24, [0x34] = 0x6C, [0x35] = 0x37, [0x36] = 0xA1, [0x37] = 0xCB, [0x38] = 0xF1, [0x39] = 0x52, [0x3A] = 0x3A, [0x3B] = 0xD1, [0x3C] = 0xBA, [0x3D] = 0x58, [0x3E] = 0x10, [0x3F] = 0x86, [0x40] = 0x9E, [0x41] = 0x39, [0x42] = 0xE8, [0x43] = 0x56, [0x44] = 0x9B, [0x45] = 0x5A, [0x46] = 0x0F, [0x47] = 0x8E, [0x48] = 0x97, [0x49] = 0x09, [0x4A] = 0x02, [0x4B] = 0x36, [0x4C] = 0x51, [0x4D] = 0x3D, [0x4E] = 0x81, [0x4F] = 0xBD, [0x50] = 0xF0, [0x51] = 0x50, [0x52] = 0x68, [0x53] = 0x79, [0x54] = 0xAC, [0x55] = 0x06, [0x56] = 0xD5, [0x57] = 0x41, [0x58] = 0x16, [0x59] = 0xE3, [0x5A] = 0x6E, [0x5B] = 0x42, [0x5C] = 0xAD, [0x5D] = 0x4B, [0x5E] = 0x62, [0x5F] = 0xE6, [0x60] = 0x4F, [0x61] = 0x13, [0x62] = 0xEF, [0x63] = 0x8F, [0x64] = 0xB7, [0x65] = 0x8D, [0x66] = 0x88, [0x67] = 0x69, [0x68] = 0x73, [0x69] = 0xDE, [0x6A] = 0x74, [0x6B] = 0x89, [0x6C] = 0x49, [0x6D] = 0x71, [0x6E] = 0xC6, [0x6F] = 0x40, [0x70] = 0x15, [0x71] = 0xF8, [0x72] = 0x46, [0x73] = 0x07, [0x74] = 0x92, [0x75] = 0xA2, [0x76] = 0x20, [0x77] = 0x1A, [0x78] = 0x75, [0x79] = 0x6B, [0x7A] = 0xBF, [0x7B] = 0x2C, [0x7C] = 0x4E, [0x7D] = 0xBB, [0x7E] = 0x6F, [0x7F] = 0x3E, [0x80] = 0x23, [0x81] = 0x5F, [0x82] = 0xC9, [0x83] = 0x12, [0x84] = 0x7C, [0x85] = 0x48, [0x86] = 0x44, [0x87] = 0x90, [0x88] = 0x3C, [0x89] = 0xF3, [0x8A] = 0x2E, [0x8B] = 0x47, [0x8C] = 0x32, [0x8D] = 0xED, [0x8E] = 0xC1, [0x8F] = 0x72, [0x90] = 0x22, [0x91] = 0xD7, [0x92] = 0x31, [0x93] = 0x8C, [0x94] = 0x43, [0x95] = 0x1C, [0x96] = 0xD2, [0x97] = 0x7E, [0x98] = 0xFB, [0x99] = 0xFF, [0x9A] = 0xE2, [0x9B] = 0x61, [0x9C] = 0x59, [0x9D] = 0x9A, [0x9E] = 0x03, [0x9F] = 0x76, [0xA0] = 0xAB, [0xA1] = 0xCD, [0xA2] = 0x5E, [0xA3] = 0x64, [0xA4] = 0x30, [0xA5] = 0xD0, [0xA6] = 0xEB, [0xA7] = 0x67, [0xA8] = 0x9D, [0xA9] = 0xC0, [0xAA] = 0x01, [0xAB] = 0x3B, [0xAC] = 0x5D, [0xAD] = 0xE9, [0xAE] = 0x28, [0xAF] = 0x21, [0xB0] = 0x19, [0xB1] = 0xC4, [0xB2] = 0x1E, [0xB3] = 0x57, [0xB4] = 0xB5, [0xB5] = 0x7F, [0xB6] = 0x83, [0xB7] = 0xDB, [0xB8] = 0x08, [0xB9] = 0x0E, [0xBA] = 0xEC, [0xBB] = 0x1D, [0xBC] = 0x2B, [0xBD] = 0xD4, [0xBE] = 0x38, [0xBF] = 0xF7, [0xC0] = 0xFC, [0xC1] = 0x45, [0xC2] = 0xAE, [0xC3] = 0x7D, [0xC4] = 0x7B, [0xC5] = 0x65, [0xC6] = 0x0D, [0xC7] = 0xF9, [0xC8] = 0x05, [0xC9] = 0xCF, [0xCA] = 0x80, [0xCB] = 0xCC, [0xCC] = 0xA7, [0xCD] = 0xF5, [0xCE] = 0xC2, [0xCF] = 0x25, [0xD0] = 0xE5, [0xD1] = 0x04, [0xD2] = 0xCA, [0xD3] = 0x7A, [0xD4] = 0xB2, [0xD5] = 0x17, [0xD6] = 0xB0, [0xD7] = 0xB1, [0xD8] = 0x6D, [0xD9] = 0xBE, [0xDA] = 0xA0, [0xDB] = 0x4A, [0xDC] = 0xDD, [0xDD] = 0xFE, [0xDE] = 0x35, [0xDF] = 0x4D, [0xE0] = 0x2F, [0xE1] = 0x93, [0xE2] = 0x84, [0xE3] = 0x60, [0xE4] = 0xA8, [0xE5] = 0x96, [0xE6] = 0x6A, [0xE7] = 0xC5, [0xE8] = 0x77, [0xE9] = 0xD3, [0xEA] = 0xB9, [0xEB] = 0x91, [0xEC] = 0x9C, [0xED] = 0xD8, [0xEE] = 0xDF, [0xEF] = 0x26, [0xF0] = 0x5C, [0xF1] = 0xB4, [0xF2] = 0x94, [0xF3] = 0x98, [0xF4] = 0xD9, [0xF5] = 0xF2, [0xF6] = 0x4C, [0xF7] = 0x9F, [0xF8] = 0x5B, [0xF9] = 0x1B, [0xFA] = 0x95, [0xFB] = 0xEE, [0xFC] = 0xE7, [0xFD] = 0xB6, [0xFE] = 0x0C, [0xFF] = 0x8A, },
		},
		['7.16'] = {
			['GainAggro'] = { ['Header'] = 0x00EE, ['targetPos'] = 43, },
			['LoseAggro'] = { ['Header'] = 0x0196, },		
			['table'] = {[0x00] = 0x8B, [0x01] = 0x85, [0x02] = 0x89, [0x03] = 0x87, [0x04] = 0x8C, [0x05] = 0x86, [0x06] = 0x8A, [0x07] = 0x88, [0x08] = 0x0B, [0x09] = 0x05, [0x0A] = 0x09, [0x0B] = 0x07, [0x0C] = 0x0C, [0x0D] = 0x06, [0x0E] = 0x0A, [0x0F] = 0x08, [0x10] = 0x4B, [0x11] = 0x45, [0x12] = 0x49, [0x13] = 0x47, [0x14] = 0x4C, [0x15] = 0x46, [0x16] = 0x4A, [0x17] = 0x48, [0x18] = 0xCB, [0x19] = 0xC5, [0x1A] = 0xC9, [0x1B] = 0xC7, [0x1C] = 0xCC, [0x1D] = 0xC6, [0x1E] = 0xCA, [0x1F] = 0xC8, [0x20] = 0x6B, [0x21] = 0x65, [0x22] = 0x69, [0x23] = 0x67, [0x24] = 0x6C, [0x25] = 0x66, [0x26] = 0x6A, [0x27] = 0x68, [0x28] = 0xEB, [0x29] = 0xE5, [0x2A] = 0xE9, [0x2B] = 0xE7, [0x2C] = 0xEC, [0x2D] = 0xE6, [0x2E] = 0xEA, [0x2F] = 0xE8, [0x30] = 0x2B, [0x31] = 0x25, [0x32] = 0x29, [0x33] = 0x27, [0x34] = 0x2C, [0x35] = 0x26, [0x36] = 0x2A, [0x37] = 0x28, [0x38] = 0xAB, [0x39] = 0xA5, [0x3A] = 0xA9, [0x3B] = 0xA7, [0x3C] = 0xAC, [0x3D] = 0xA6, [0x3E] = 0xAA, [0x3F] = 0xA8, [0x40] = 0x6D, [0x41] = 0x71, [0x42] = 0x6F, [0x43] = 0x73, [0x44] = 0x6E, [0x45] = 0x72, [0x46] = 0x70, [0x47] = 0x74, [0x48] = 0xED, [0x49] = 0xF1, [0x4A] = 0xEF, [0x4B] = 0xF3, [0x4C] = 0xEE, [0x4D] = 0xF2, [0x4E] = 0xF0, [0x4F] = 0xF4, [0x50] = 0x2D, [0x51] = 0x31, [0x52] = 0x2F, [0x53] = 0x33, [0x54] = 0x2E, [0x55] = 0x32, [0x56] = 0x30, [0x57] = 0x34, [0x58] = 0xAD, [0x59] = 0xB1, [0x5A] = 0xAF, [0x5B] = 0xB3, [0x5C] = 0xAE, [0x5D] = 0xB2, [0x5E] = 0xB0, [0x5F] = 0xB4, [0x60] = 0x4D, [0x61] = 0x51, [0x62] = 0x4F, [0x63] = 0x53, [0x64] = 0x4E, [0x65] = 0x52, [0x66] = 0x50, [0x67] = 0x54, [0x68] = 0xCD, [0x69] = 0xD1, [0x6A] = 0xCF, [0x6B] = 0xD3, [0x6C] = 0xCE, [0x6D] = 0xD2, [0x6E] = 0xD0, [0x6F] = 0xD4, [0x70] = 0x0D, [0x71] = 0x11, [0x72] = 0x0F, [0x73] = 0x13, [0x74] = 0x0E, [0x75] = 0x12, [0x76] = 0x10, [0x77] = 0x14, [0x78] = 0x8D, [0x79] = 0x91, [0x7A] = 0x8F, [0x7B] = 0x93, [0x7C] = 0x8E, [0x7D] = 0x92, [0x7E] = 0x90, [0x7F] = 0x94, [0x80] = 0x7D, [0x81] = 0x81, [0x82] = 0x7F, [0x83] = 0x83, [0x84] = 0x7E, [0x85] = 0x82, [0x86] = 0x80, [0x87] = 0x84, [0x88] = 0xFD, [0x89] = 0x01, [0x8A] = 0xFF, [0x8B] = 0x03, [0x8C] = 0xFE, [0x8D] = 0x02, [0x8E] = 0x00, [0x8F] = 0x04, [0x90] = 0x3D, [0x91] = 0x41, [0x92] = 0x3F, [0x93] = 0x43, [0x94] = 0x3E, [0x95] = 0x42, [0x96] = 0x40, [0x97] = 0x44, [0x98] = 0xBD, [0x99] = 0xC1, [0x9A] = 0xBF, [0x9B] = 0xC3, [0x9C] = 0xBE, [0x9D] = 0xC2, [0x9E] = 0xC0, [0x9F] = 0xC4, [0xA0] = 0x5D, [0xA1] = 0x61, [0xA2] = 0x5F, [0xA3] = 0x63, [0xA4] = 0x5E, [0xA5] = 0x62, [0xA6] = 0x60, [0xA7] = 0x64, [0xA8] = 0xDD, [0xA9] = 0xE1, [0xAA] = 0xDF, [0xAB] = 0xE3, [0xAC] = 0xDE, [0xAD] = 0xE2, [0xAE] = 0xE0, [0xAF] = 0xE4, [0xB0] = 0x1D, [0xB1] = 0x21, [0xB2] = 0x1F, [0xB3] = 0x23, [0xB4] = 0x1E, [0xB5] = 0x22, [0xB6] = 0x20, [0xB7] = 0x24, [0xB8] = 0x9D, [0xB9] = 0xA1, [0xBA] = 0x9F, [0xBB] = 0xA3, [0xBC] = 0x9E, [0xBD] = 0xA2, [0xBE] = 0xA0, [0xBF] = 0xA4, [0xC0] = 0x75, [0xC1] = 0x79, [0xC2] = 0x77, [0xC3] = 0x7B, [0xC4] = 0x76, [0xC5] = 0x7A, [0xC6] = 0x78, [0xC7] = 0x7C, [0xC8] = 0xF5, [0xC9] = 0xF9, [0xCA] = 0xF7, [0xCB] = 0xFB, [0xCC] = 0xF6, [0xCD] = 0xFA, [0xCE] = 0xF8, [0xCF] = 0xFC, [0xD0] = 0x35, [0xD1] = 0x39, [0xD2] = 0x37, [0xD3] = 0x3B, [0xD4] = 0x36, [0xD5] = 0x3A, [0xD6] = 0x38, [0xD7] = 0x3C, [0xD8] = 0xB5, [0xD9] = 0xB9, [0xDA] = 0xB7, [0xDB] = 0xBB, [0xDC] = 0xB6, [0xDD] = 0xBA, [0xDE] = 0xB8, [0xDF] = 0xBC, [0xE0] = 0x55, [0xE1] = 0x59, [0xE2] = 0x57, [0xE3] = 0x5B, [0xE4] = 0x56, [0xE5] = 0x5A, [0xE6] = 0x58, [0xE7] = 0x5C, [0xE8] = 0xD5, [0xE9] = 0xD9, [0xEA] = 0xD7, [0xEB] = 0xDB, [0xEC] = 0xD6, [0xED] = 0xDA, [0xEE] = 0xD8, [0xEF] = 0xDC, [0xF0] = 0x15, [0xF1] = 0x19, [0xF2] = 0x17, [0xF3] = 0x1B, [0xF4] = 0x16, [0xF5] = 0x1A, [0xF6] = 0x18, [0xF7] = 0x1C, [0xF8] = 0x95, [0xF9] = 0x99, [0xFA] = 0x97, [0xFB] = 0x9B, [0xFC] = 0x96, [0xFD] = 0x9A, [0xFE] = 0x98, [0xFF] = 0x9C, },
		},
	}
	return _data[GameVersion]
end

function GetLoseVisionPacketData()
	local _data = {
		['7.14'] = {
			['Header'] = 0x01A5,
			['Pos'] = 2,
		},
		['7.15'] = {
			['Header'] = 0x007A, 
			['Pos'] = 2,	
		},
		['7.16'] = {
			['Header'] = 0x001D,
			['Pos'] = 2,	
		},
	}
	return _data[GameVersion]
end

function GetGainVisionPacketData()
	local _data = {
		['7.14'] = { 
			['Header'] = 0x0177, 
			['pos'] = 2,
		},
		['7.15'] = {
			['Header'] = 0x0184, 
			['pos'] = 2,	
		},
		['7.16'] = {
			['Header'] = 0x0092,
			['pos'] = 2,
		},
	}
	return _data[GameVersion]
end

function GetMasteryEmoteData()
	local cVersion = GetGameVersion()
	if cVersion:find('7.16.198.3567') then
		return {
			['Header'] = 0x014D,
			['vTable'] = 0xFF6ABC,
			['hash'] = 0x76767676,
		}
	elseif cVersion:find('7.14.194.3950') then
		return {
			['Header'] = 0x000C,
			['vTable'] = 0xFE1F58,
			['hash'] = 0x85858585,
		}
	elseif cVersion:find('7.15.196.5272') then
		return {
			['Header'] = 0x0097,
			['vTable'] = 0x1048FEC,
			['hash'] = 0xB7B7B7B7,
		}
	end
end
