local lshift, rshift, band, bxor = bit32.lshift, bit32.rshift, bit32.band, bit32.bxor
local floor, ceil, huge, cos, sin, pi, pi2, abs, sqrt = math.floor, math.ceil, math.huge, math.cos, math.sin, math.pi, math.pi*2, math.abs, math.sqrt
local clock, pairs, ipairs, tostring = os.clock, pairs, ipairs, tostring
local TEAM_ENEMY, TEAM_ALLY
local COLOR_WHITE, COLOR_GREEN, COLOR_RED, COLOR_YELLOW, COLOR_TRANS_WHITE, COLOR_GREY = ARGB(0xFF,0xFF,0xFF,0xFF), ARGB(0xFF,0x00,170,0x00), ARGB(0xFF,0xFF,0x00,0x00), ARGB(0xFF,0xFF,0xFF,0x00), ARGB(0xAA,0xFF,0xFF,0xFF), ARGB(255,128,128,128) 
local COLOR_TRANS_GREEN, COLOR_TRANS_RED, COLOR_TRANS_YELLOW, COLOR_ORANGE, COLOR_BLACK = ARGB(0x96,0x00,0xFF,0x00), ARGB(0x96,0xFF,0x00,0x00), ARGB(0x96,0xFF,0xFF,0x00), ARGB(255,255,125,000), ARGB(255,0,0,000)
local MainMenu, IDBytes, GlobalAnchors = nil, nil, {}
local menuKey = (GetSave('scriptConfig') and GetSave('scriptConfig')['Menu']) and GetSave('scriptConfig')['Menu']['menuKey'] or 16

local _Game, _Map, _HUD

local function GetGame2()
    if not _Game then
        _Game = {
			['Map'] = {
				['Name'] = 'unknown',
				['Min'] = { ['x'] = 0, ['y'] = 0 },
				['Max'] = { ['x'] = 0, ['y'] = 0 },
				['x'] = 1,
				['y'] = 1,
			}
		}
        for i = 1, objManager.maxObjects do
            local object = objManager:getObject(i)
            if object and object.valid then
                if object.type == 'obj_Shop' and object.team == 100 then
                    if math.floor(object.x) == 232 and math.floor(object.y) == 163 and math.floor(object.z) == 1277 then --all wrong??
                        _Game.Map = { 
							['Name'] = 'SummonerRift', 
							['Min'] = { ['x'] = 80, ['y'] = 140 }, 
							['Max'] = { ['x'] = 14279, ['y'] = 14527 }, 
							['x'] = 14817, 
							['y'] = 14692, 
						}
                        break
                    elseif math.floor(object.x) == 1313 and math.floor(object.y) == 123 and math.floor(object.z) == 8005 then
						_Game.Map = { 
							['Name'] = 'TwistedTreeline', 
							['Min'] = { ['x'] = 150, y = 250}, 
							['Max'] = { ['x'] = 14120, y = 13877 }, 
							['x'] = 15116, 
							['y'] = 15116, 
						}
                        break
                    elseif math.floor(object.x) == 16 and math.floor(object.y) == 168 and math.floor(object.z) == 4452 then
					    _Game.Map = { 
							['Name'] = 'CrystalScar', 
							['Min'] = { ['x'] = 52, ['y'] = 150 }, 
							['Max'] = { ['x'] = 13911, ['y'] = 13703 }, 
							['x'] = 13911, 
							['y'] = 13703, 
						}
                        break
                    elseif math.floor(object.x) == 497 and math.floor(object.y) == -40 and math.floor(object.z) == 1932 then
						_Game.Map = { 
							['Name'] = 'HowlingAbyss', 
							['Min'] = { ['x'] = -20, ['y'] = 40 }, 
							['Max'] = { ['x'] = 12820, ['y'] = 12839 }, 
							['x'] = 12876, 
							['y'] = 12877, 
						}
                        break
                    elseif math.floor(object.x) == 497 and math.floor(object.y) == -180 and math.floor(object.z) == 1932 then
						_Game.Map = { 
							['Name'] = 'ButchersBridge', 
							['Min'] = { ['x'] = -20, ['y'] = 40 }, 
							['Max'] = { ['x'] = 12820, ['y'] = 12839 }, 
							['x'] = 12876, 
							['y'] = 12877, 
						}
                        break
                    end
                end
            end
        end
    end
    return _Game
end

local function GetHUDSettings()
	if not _HUD then
		_HUD = ReadIni(GAME_PATH .. "\\DATA\\menu\\hud\\hud" .. WINDOW_W .. "x" .. WINDOW_H .. ".ini")
	end
	return _HUD
end

local function _Map_Load()
    if not _Map then
		local Ratio, Flip, Settings = 1, false, GetGameSettings()
		if Settings and Settings.General and Settings.General.Width and Settings.General.Height then
			Ratio = (Settings.HUD and Settings.HUD.MinimapScale) and (WINDOW_H / 1080) * (0.75 + (Settings.HUD.MinimapScale * 0.25)) or WINDOW_H / 1080
			Flip = Settings.HUD and Settings.HUD.FlipMiniMap and Settings.HUD.FlipMiniMap == 1
		end
		local Map = GetGame2().Map
		_Map = {
			['Step'] = { 
				['x'] = (257 * Ratio) / Map.x, 
				['y'] = (-253 * Ratio) / Map.y 
			},
		}
		_Map.x = Flip and (20 + Ratio) - _Map.Step.x * Map.Min.x or WINDOW_W - (Ratio * 266) - _Map.Step.x * Map.Min.x
		_Map.y = WINDOW_H - 15 + ((1-Ratio) * 10) - _Map.Step.y * Map.Min.y
    end 
    return _Map ~= nil
end

local function GetMinimap(v)
	_Map_Load()
	return _Map_Load() and D3DXVECTOR2(_Map.x + (_Map.Step.x * v.x), _Map.y + (_Map.Step.y * v.z)) or D3DXVECTOR2(-100, -100)
end

local function GetScale(int, scl)
	return floor((scl / 100) * int)
end

local function GetScale2(int, scl)
	return (scl / 100) * int
end

-- AddDrawCallback(function()
	-- local v = GetMinimap(myHero)
	-- DrawLine(v.x-10,v.y,v.x+10,v.y,1,ARGB(255,255,255,255))
	-- DrawLine(v.x,v.y-10,v.x,v.y+10,1,ARGB(255,255,255,255))
-- end)

AddLoadCallback(function()
	local Version = 5.245
	HookPackets()
	TEAM_ALLY, TEAM_ENEMY = myHero.team, 300-myHero.team
	MainMenu = scriptConfig('Pewtility', 'Pewtility')
	MainMenu:addParam('update', 'Enable AutoUpdate', SCRIPT_PARAM_ONOFF, true)
	IDBytes = GetGameVersion():sub(1,4) == '5.23' and {[0x00] = 0xFC, [0x01] = 0x41, [0x02] = 0xC1, [0x03] = 0x51, [0x04] = 0xD1, [0x05] = 0x61, [0x06] = 0xE1, [0x07] = 0x71, [0x08] = 0xF1, [0x09] = 0x45, [0x0A] = 0xC5, [0x0B] = 0x55, [0x0C] = 0xD5, [0x0D] = 0x65, [0x0E] = 0xE5, [0x0F] = 0x75, [0x10] = 0xF5, [0x11] = 0x49, [0x12] = 0xC9, [0x13] = 0x59, [0x14] = 0xD9, [0x15] = 0x69, [0x16] = 0xE9, [0x17] = 0x79, [0x18] = 0xF9, [0x19] = 0x4D, [0x1A] = 0xCD, [0x1B] = 0x5D, [0x1C] = 0xDD, [0x1D] = 0x6D, [0x1E] = 0xED, [0x1F] = 0x7D, [0x20] = 0xFD, [0x21] = 0x42, [0x22] = 0xC2, [0x23] = 0x52, [0x24] = 0xD2, [0x25] = 0x62, [0x26] = 0xE2, [0x27] = 0x72, [0x28] = 0xF2, [0x29] = 0x46, [0x2A] = 0xC6, [0x2B] = 0x56, [0x2C] = 0xD6, [0x2D] = 0x66, [0x2E] = 0xE6, [0x2F] = 0x76, [0x30] = 0xF6, [0x31] = 0x4A, [0x32] = 0xCA, [0x33] = 0x5A, [0x34] = 0xDA, [0x35] = 0x6A, [0x36] = 0xEA, [0x37] = 0x7A, [0x38] = 0xFA, [0x39] = 0x4E, [0x3A] = 0xCE, [0x3B] = 0x5E, [0x3C] = 0xDE, [0x3D] = 0x6E, [0x3E] = 0xEE, [0x3F] = 0x7E, [0x40] = 0xFE, [0x41] = 0x43, [0x42] = 0xC3, [0x43] = 0x53, [0x44] = 0xD3, [0x45] = 0x63, [0x46] = 0xE3, [0x47] = 0x73, [0x48] = 0xF3, [0x49] = 0x47, [0x4A] = 0xC7, [0x4B] = 0x57, [0x4C] = 0xD7, [0x4D] = 0x67, [0x4E] = 0xE7, [0x4F] = 0x77, [0x50] = 0xF7, [0x51] = 0x4B, [0x52] = 0xCB, [0x53] = 0x5B, [0x54] = 0xDB, [0x55] = 0x6B, [0x56] = 0xEB, [0x57] = 0x7B, [0x58] = 0xFB, [0x59] = 0x4F, [0x5A] = 0xCF, [0x5B] = 0x5F, [0x5C] = 0xDF, [0x5D] = 0x6F, [0x5E] = 0xEF, [0x5F] = 0x7F, [0x60] = 0xFF, [0x61] = 0x00, [0x62] = 0x80, [0x63] = 0x10, [0x64] = 0x90, [0x65] = 0x20, [0x66] = 0xA0, [0x67] = 0x30, [0x68] = 0xB0, [0x69] = 0x04, [0x6A] = 0x84, [0x6B] = 0x14, [0x6C] = 0x94, [0x6D] = 0x24, [0x6E] = 0xA4, [0x6F] = 0x34, [0x70] = 0xB4, [0x71] = 0x08, [0x72] = 0x88, [0x73] = 0x18, [0x74] = 0x98, [0x75] = 0x28, [0x76] = 0xA8, [0x77] = 0x38, [0x78] = 0xB8, [0x79] = 0x0C, [0x7A] = 0x8C, [0x7B] = 0x1C, [0x7C] = 0x9C, [0x7D] = 0x2C, [0x7E] = 0xAC, [0x7F] = 0x3C, [0x80] = 0xBC, [0x81] = 0x01, [0x82] = 0x81, [0x83] = 0x11, [0x84] = 0x91, [0x85] = 0x21, [0x86] = 0xA1, [0x87] = 0x31, [0x88] = 0xB1, [0x89] = 0x05, [0x8A] = 0x85, [0x8B] = 0x15, [0x8C] = 0x95, [0x8D] = 0x25, [0x8E] = 0xA5, [0x8F] = 0x35, [0x90] = 0xB5, [0x91] = 0x09, [0x92] = 0x89, [0x93] = 0x19, [0x94] = 0x99, [0x95] = 0x29, [0x96] = 0xA9, [0x97] = 0x39, [0x98] = 0xB9, [0x99] = 0x0D, [0x9A] = 0x8D, [0x9B] = 0x1D, [0x9C] = 0x9D, [0x9D] = 0x2D, [0x9E] = 0xAD, [0x9F] = 0x3D, [0xA0] = 0xBD, [0xA1] = 0x02, [0xA2] = 0x82, [0xA3] = 0x12, [0xA4] = 0x92, [0xA5] = 0x22, [0xA6] = 0xA2, [0xA7] = 0x32, [0xA8] = 0xB2, [0xA9] = 0x06, [0xAA] = 0x86, [0xAB] = 0x16, [0xAC] = 0x96, [0xAD] = 0x26, [0xAE] = 0xA6, [0xAF] = 0x36, [0xB0] = 0xB6, [0xB1] = 0x0A, [0xB2] = 0x8A, [0xB3] = 0x1A, [0xB4] = 0x9A, [0xB5] = 0x2A, [0xB6] = 0xAA, [0xB7] = 0x3A, [0xB8] = 0xBA, [0xB9] = 0x0E, [0xBA] = 0x8E, [0xBB] = 0x1E, [0xBC] = 0x9E, [0xBD] = 0x2E, [0xBE] = 0xAE, [0xBF] = 0x3E, [0xC0] = 0xBE, [0xC1] = 0x03, [0xC2] = 0x83, [0xC3] = 0x13, [0xC4] = 0x93, [0xC5] = 0x23, [0xC6] = 0xA3, [0xC7] = 0x33, [0xC8] = 0xB3, [0xC9] = 0x07, [0xCA] = 0x87, [0xCB] = 0x17, [0xCC] = 0x97, [0xCD] = 0x27, [0xCE] = 0xA7, [0xCF] = 0x37, [0xD0] = 0xB7, [0xD1] = 0x0B, [0xD2] = 0x8B, [0xD3] = 0x1B, [0xD4] = 0x9B, [0xD5] = 0x2B, [0xD6] = 0xAB, [0xD7] = 0x3B, [0xD8] = 0xBB, [0xD9] = 0x0F, [0xDA] = 0x8F, [0xDB] = 0x1F, [0xDC] = 0x9F, [0xDD] = 0x2F, [0xDE] = 0xAF, [0xDF] = 0x3F, [0xE0] = 0xBF, [0xE1] = 0x40, [0xE2] = 0xC0, [0xE3] = 0x50, [0xE4] = 0xD0, [0xE5] = 0x60, [0xE6] = 0xE0, [0xE7] = 0x70, [0xE8] = 0xF0, [0xE9] = 0x44, [0xEA] = 0xC4, [0xEB] = 0x54, [0xEC] = 0xD4, [0xED] = 0x64, [0xEE] = 0xE4, [0xEF] = 0x74, [0xF0] = 0xF4, [0xF1] = 0x48, [0xF2] = 0xC8, [0xF3] = 0x58, [0xF4] = 0xD8, [0xF5] = 0x68, [0xF6] = 0xE8, [0xF7] = 0x78, [0xF8] = 0xF8, [0xF9] = 0x4C, [0xFA] = 0xCC, [0xFB] = 0x5C, [0xFC] = 0xDC, [0xFD] = 0x6C, [0xFE] = 0xEC, [0xFF] = 0x7C,} 
	or GetGameVersion():sub(1,4) == '5.24' and {[0x01] = 0x6A, [0x02] = 0xDC, [0x03] = 0xFB, [0x04] = 0x94, [0x05] = 0x24, [0x06] = 0xB1, [0x07] = 0x9A, [0x08] = 0x14, [0x09] = 0x80, [0x0A] = 0xF9, [0x0B] = 0x77, [0x0C] = 0x4D, [0x0D] = 0x2F, [0x0E] = 0xFF, [0x0F] = 0xC2, [0x10] = 0xE8, [0x11] = 0x35, [0x12] = 0xD5, [0x13] = 0xD3, [0x14] = 0x20, [0x15] = 0x6B, [0x16] = 0x6D, [0x17] = 0x9D, [0x18] = 0xD0, [0x19] = 0x48, [0x1A] = 0xD1, [0x1B] = 0xD9, [0x1C] = 0x92, [0x1D] = 0x7A, [0x1E] = 0x00, [0x1F] = 0x70, [0x20] = 0x8A, [0x21] = 0x6E, [0x22] = 0x73, [0x23] = 0xC9, [0x24] = 0x2B, [0x25] = 0x61, [0x26] = 0xAF, [0x27] = 0xCD, [0x28] = 0xB0, [0x29] = 0x5D, [0x2A] = 0xAD, [0x2B] = 0x2E, [0x2C] = 0xE3, [0x2D] = 0x15, [0x2E] = 0xCB, [0x2F] = 0x53, [0x30] = 0x87, [0x31] = 0xB6, [0x32] = 0x05, [0x33] = 0x1E, [0x34] = 0xA7, [0x35] = 0x7D, [0x36] = 0xD2, [0x37] = 0xA3, [0x38] = 0x4E, [0x39] = 0xE5, [0x3A] = 0x02, [0x3B] = 0xA9, [0x3C] = 0xC6, [0x3D] = 0x7E, [0x3E] = 0x75, [0x3F] = 0x42, [0x40] = 0xEE, [0x41] = 0x04, [0x42] = 0x0D, [0x43] = 0xBC, [0x44] = 0x47, [0x45] = 0xE0, [0x46] = 0x3F, [0x47] = 0x88, [0x48] = 0x5B, [0x49] = 0x68, [0x4A] = 0x3E, [0x4B] = 0x3D, [0x4C] = 0x74, [0x4D] = 0x28, [0x4E] = 0x22, [0x4F] = 0xE6, [0x50] = 0x32, [0x51] = 0xCF, [0x52] = 0x4A, [0x53] = 0x16, [0x54] = 0xA2, [0x55] = 0x50, [0x56] = 0xEB, [0x57] = 0x0E, [0x58] = 0xF0, [0x59] = 0x62, [0x5A] = 0xCA, [0x5B] = 0x6C, [0x5C] = 0x1B, [0x5D] = 0xC8, [0x5E] = 0xF3, [0x5F] = 0x19, [0x60] = 0xE9, [0x61] = 0x98, [0x62] = 0x63, [0x63] = 0x96, [0x64] = 0xF4, [0x65] = 0x12, [0x66] = 0xDA, [0x67] = 0x89, [0x68] = 0x08, [0x69] = 0x31, [0x6A] = 0xCE, [0x6B] = 0x17, [0x6C] = 0x81, [0x6D] = 0x4F, [0x6E] = 0xE4, [0x6F] = 0xBD, [0x70] = 0xC4, [0x71] = 0x93, [0x72] = 0x2D, [0x73] = 0xA6, [0x74] = 0x56, [0x75] = 0x45, [0x76] = 0x8E, [0x77] = 0x09, [0x78] = 0xBF, [0x79] = 0xC1, [0x7A] = 0x21, [0x7B] = 0xC3, [0x7C] = 0x34, [0x7D] = 0xDE, [0x7E] = 0x97, [0x7F] = 0x95, [0x80] = 0x3A, [0x81] = 0x25, [0x82] = 0xAB, [0x83] = 0x55, [0x84] = 0x66, [0x85] = 0xA8, [0x86] = 0x71, [0x87] = 0x59, [0x88] = 0xEC, [0x89] = 0x0F, [0x8A] = 0x83, [0x8B] = 0x91, [0x8C] = 0xB9, [0x8D] = 0x33, [0x8E] = 0xFC, [0x8F] = 0xDB, [0x90] = 0xC5, [0x91] = 0x9F, [0x92] = 0xAC, [0x93] = 0x29, [0x94] = 0x5E, [0x95] = 0xA0, [0x96] = 0xD4, [0x97] = 0x76, [0x98] = 0x78, [0x99] = 0x64, [0x9A] = 0x11, [0x9B] = 0x7B, [0x9C] = 0x1D, [0x9D] = 0x10, [0x9E] = 0x44, [0x9F] = 0x67, [0xA0] = 0xD6, [0xA1] = 0x13, [0xA2] = 0x58, [0xA3] = 0x8D, [0xA4] = 0x8B, [0xA5] = 0x06, [0xA6] = 0x65, [0xA7] = 0x1A, [0xA8] = 0x03, [0xA9] = 0xC7, [0xAA] = 0x9B, [0xAB] = 0xB5, [0xAC] = 0x3C, [0xAD] = 0x82, [0xAE] = 0x37, [0xAF] = 0xF2, [0xB0] = 0xAE, [0xB1] = 0xE2, [0xB2] = 0x57, [0xB3] = 0xB7, [0xB4] = 0x23, [0xB5] = 0xCC, [0xB6] = 0xA5, [0xB7] = 0x8C, [0xB8] = 0x6F, [0xB9] = 0x72, [0xBA] = 0xFD, [0xBB] = 0x49, [0xBC] = 0x41, [0xBD] = 0xF8, [0xBE] = 0xBA, [0xBF] = 0x40, [0xC0] = 0xAA, [0xC1] = 0xE1, [0xC2] = 0x85, [0xC3] = 0x84, [0xC4] = 0x0B, [0xC5] = 0x90, [0xC6] = 0x07, [0xC7] = 0x38, [0xC8] = 0xEA, [0xC9] = 0x5F, [0xCA] = 0xA4, [0xCB] = 0xBE, [0xCC] = 0x5A, [0xCD] = 0x43, [0xCE] = 0x86, [0xCF] = 0x79, [0xD0] = 0xDF, [0xD1] = 0x26, [0xD2] = 0x27, [0xD3] = 0x01, [0xD4] = 0x1C, [0xD5] = 0xC0, [0xD6] = 0x39, [0xD7] = 0x3B, [0xD8] = 0xBB, [0xD9] = 0x46, [0xDA] = 0x7C, [0xDB] = 0xDD, [0xDC] = 0x9C, [0xDD] = 0xD7, [0xDE] = 0x2C, [0xDF] = 0x52, [0xE0] = 0x54, [0xE1] = 0x2A, [0xE2] = 0x36, [0xE3] = 0xF7, [0xE4] = 0x4B, [0xE5] = 0xB3, [0xE6] = 0x51, [0xE7] = 0xF6, [0xE8] = 0x69, [0xE9] = 0x8F, [0xEA] = 0xED, [0xEB] = 0xB4, [0xEC] = 0x99, [0xED] = 0x60, [0xEE] = 0xF1, [0xEF] = 0xD8, [0xF0] = 0xB8, [0xF1] = 0xFA, [0xF2] = 0x0A, [0xF3] = 0xA1, [0xF4] = 0x4C, [0xF5] = 0xE7, [0xF6] = 0x9E, [0xF7] = 0xB2, [0xF8] = 0xFE, [0xF9] = 0x0C, [0xFA] = 0xEF, [0xFB] = 0x30, [0xFC] = 0x5C, [0xFD] = 0xF5, [0xFE] = 0x18, [0xFF] = 0x7F, [0x00] = 0x1F,}
	if not IDBytes then
		Print('Core decode bytes outdated!!', true)
	end
	if FileExist(LIB_PATH..'\\Saves\\Pewtility.save') then
		local file = io.open(LIB_PATH ..'Saves\\Pewtility.save', 'r')
		if file then
			local content = file:read('*all')
			if content and content:sub(1, 6) ~= 'return' then
				local SaveTable = JSON:decode(content)
				if SaveTable and type(SaveTable) == 'table' then
					GlobalAnchors = SaveTable
				end
			end
		end
	end
	local function SaveAnchors()
		local savefile = io.open(LIB_PATH..'\\Saves\\Pewtility.save', 'w')
		local content = JSON:encode(GlobalAnchors)
		savefile:write(content)
		savefile:close()
	end
	AddBugsplatCallback(SaveAnchors)
	AddUnloadCallback(SaveAnchors)
	AddExitCallback(SaveAnchors)
	
	WARD()
	MISS()
	TIMERS()
	TRINKET()
	OTHER()
	MAGWARDS()
	SKILLS()
	AwareUpdate(
		Version,
		'raw.githubusercontent.com', 
		'/PewPewPew2/BoL/master/Versions/Pewtility.version', 
		'/PewPewPew2/BoL/master/Pewtility.lua', 
		SCRIPT_PATH.._ENV.FILE_NAME, 
		function() Print('Update Complete. Reload(F9 F9)') end, 
		function() Print('Load Complete') end, 
		function() Print(MainMenu.update and 'New Version Found, please wait...' or 'New Version found please download manually or enable AutoUpdate') end, 
		function() Print('An Error Occured in Update.') end
	)
end)

class 'AwareUpdate'
  
function AwareUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion, CallbackError)	
	if LocalVersion == 'isSprite' then
		self.isSprite = true
		self.Host = Host
		self.SavePath = SavePath
		self.CallbackUpdate = CallbackUpdate
		self.CallbackNoUpdate = CallbackNoUpdate
		self.CallbackNewVersion = CallbackNewVersion
		self.CallbackError = CallbackError
		self:CreateSocket('/Updater.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999))
		AddTickCallback(function() self:DownloadUpdate() end)
	else
		self.LocalVersion = LocalVersion
		self.Host = Host
		self.VersionPath = '/Updater.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
		self.ScriptPath = '/Updater.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
		self.SavePath = SavePath
		self.CallbackUpdate = CallbackUpdate
		self.CallbackNoUpdate = CallbackNoUpdate
		self.CallbackNewVersion = CallbackNewVersion
		self.CallbackError = CallbackError
		self:CreateSocket(self.VersionPath)
		self.DownloadStatus = 'Connect to Server for VersionInfo'
		AddTickCallback(function() self:GetOnlineVersion() end)
	end
end

function AwareUpdate:OnDraw()
	local bP = {['x1'] = WINDOW_W - (WINDOW_W - 390),['x2'] = WINDOW_W - (WINDOW_W - 20),['y1'] = WINDOW_H / 2,['y2'] = (WINDOW_H / 2) + 20,}
	local text = 'Download Status: '..(self.DownloadStatus or 'Unknown')
	DrawLine(bP.x1, bP.y1 + 10, bP.x2,  bP.y1 + 10, 18, ARGB(0x7D,0xE1,0xE1,0xE1))
	local xOff
	if self.File and self.Size then
		local c = math.round(100/self.Size*self.File:len(),2)/100
		xOff = c < 1 and math.ceil(370 * c) or 370
	else
		xOff = 0
	end
	DrawLine(bP.x2 + xOff, bP.y1 + 10, bP.x2, bP.y1 + 10, 18, ARGB(0xC8,0xE1,0xE1,0xE1))
	DrawLines2({D3DXVECTOR2(bP.x1, bP.y1),D3DXVECTOR2(bP.x2, bP.y1),D3DXVECTOR2(bP.x2, bP.y2),D3DXVECTOR2(bP.x1, bP.y2),D3DXVECTOR2(bP.x1, bP.y1),}, 3, ARGB(0xB9, 0x0A, 0x0A, 0x0A))
	DrawText(text, 16, WINDOW_W - (WINDOW_W - 205) - (GetTextArea(text, 16).x / 2), bP.y1 + 2, ARGB(0xB9,0x0A,0x0A,0x0A))
end

function AwareUpdate:CreateSocket(url)
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
    self.Socket:connect('pewpewpew.website', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function AwareUpdate:Base64Encode(data)
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

function AwareUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: pewpewpew.website\r\n\r\n")
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
        if self.File:find('<lua'..'file>') then
            local _,ScriptFind = self.File:find('<lua'..'file>')
            local ScriptEnd = self.File:find('</lua'..'file>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</lua'..'file>') then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.File:find('<lua'..'file>')
        local ContentEnd, _ = self.File:find('</lua'..'file>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if self.OnlineVersion and self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
				if not MainMenu.update then return end
				AddDrawCallback(function() self:OnDraw() end)
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

function AwareUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: pewpewpew.website\r\n\r\n")
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
        if self.File:find('<lua'..'file>') then
            local _,ScriptFind = self.File:find('<lua'..'file>')
            local ScriptEnd = self.File:find('</lua'..'file>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</lua'..'file>') then
        self.DownloadStatus = 'Downloading Script (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.NewFile:find('<lua'..'file>')
        local ContentEnd, _ = self.NewFile:find('</lua'..'file>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
				print('Error1')
				self.CallbackError()
            end
        else
            local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
					print('Error2')
                    self.CallbackError()
                end
                return
            end
            local newf = Base64Decode(newf)
            if not self.isSprite and type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
					print('Error2')
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
				if f then
					f:write(newf)
					f:close()
					if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
						self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
					end
				end
            end
        end
        self.GotScriptUpdate = true
    end
end

function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'>[Pewtility] </font> <font color=\'#FF0000\'>'..text..'</font>')
		return
	end
	print('<font color=\'#0099FF\'>[Pewtility] </font> <font color=\'#FF6600\'>'..text..'.</font>')
end

class 'WARD'

function WARD:__init()
	self.Types = {
		['YellowTrinket'] 		= { ['color'] = COLOR_YELLOW,			 	['duration'] = 60,   ['isWard'] = true,  },
		['BlueTrinket'] 		= { ['color'] = 0xFF0000BB,			 		['duration'] = huge, ['isWard'] = false, },
		['SightWard'] 			= { ['color'] = ARGB(255,0,255,0),			['duration'] = 150,  ['isWard'] = true,  },
		['VisionWard']  		= { ['color'] = ARGB(255, 255, 50, 255), 	['duration'] = huge, ['isWard'] = true,  },
		['TeemoMushroom'] 		= { ['color'] = COLOR_RED,					['duration'] = 600,  ['isWard'] = false, },
		['CaitlynTrap'] 		= { ['color'] = COLOR_RED,					['duration'] = 90,   ['isWard'] = false, },
		['Nidalee_Spear'] 		= { ['color'] = COLOR_RED,					['duration'] = 120,  ['isWard'] = false, },
		['ShacoBox'] 			= { ['color'] = COLOR_RED,					['duration'] = 60, 	 ['isWard'] = false, },
		['DoABarrelRoll'] 		= { ['color'] = COLOR_RED,					['duration'] = 35, 	 ['isWard'] = false, },
	}
	self.OnSpell = {
		['trinkettotemlvl1'] 	= { ['color'] = COLOR_YELLOW,			 	['duration'] = 60,   ['isWard'] = true,  },
		['trinketorblvl3'] 		= { ['color'] = 0xFF0000BB,			 		['duration'] = huge, ['isWard'] = false, },
		['itemghostward'] 		= { ['color'] = ARGB(255,0,255,0),			['duration'] = 150,  ['isWard'] = true,  },
		['visionward']  		= { ['color'] = ARGB(255, 255, 50, 255), 	['duration'] = huge, ['isWard'] = true,  },
		['bantamtrap'] 		 	= { ['color'] = COLOR_RED,					['duration'] = 600,  ['isWard'] = false, },
		['caitlynyordletrap']	= { ['color'] = COLOR_RED,					['duration'] = 90,   ['isWard'] = false, },
		['bushwhack'] 		 	= { ['color'] = COLOR_RED,					['duration'] = 120,  ['isWard'] = false, },
		['jackinthebox'] 		= { ['color'] = COLOR_RED,					['duration'] = 60, 	 ['isWard'] = false, },
		['maokaisapling'] 		= { ['color'] = COLOR_RED,					['duration'] = 35, 	 ['isWard'] = false, },
	}
	
	self.BGColor = ARGB(100, 0, 0, 0)
	self.Anchor = {
		['x'] = GlobalAnchors.WardTracker and GlobalAnchors.WardTracker.x or 40,
		['y'] = GlobalAnchors.WardTracker and GlobalAnchors.WardTracker.y or WINDOW_H - 72,
	}
	self.Hex = {D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0)}
	self.MyWards = {}
	self.Active = {}
	self.Known = {}
	self.Last_LBUTTONDOWN = 0
	self:CreateMenu()	
	self.Packet = GetGameVersion():sub(1,4)=='5.23' and {
		['Header'] = 0x00E0,
		['sourcePos'] = 10,
		['stringPos'] = 60,
		['bytes'] = {[0x00] = 0x67, [0x01] = 0xEA, [0x02] = 0x87, [0x03] = 0xC8, [0x04] = 0xA6, [0x05] = 0x02, [0x06] = 0x7B, [0x07] = 0x57, [0x08] = 0xA7, [0x09] = 0x1A, [0x0A] = 0xCA, [0x0B] = 0x31, [0x0C] = 0x78, [0x0D] = 0x5C, [0x0E] = 0x4D, [0x0F] = 0x69, [0x10] = 0x46, [0x11] = 0xE2, [0x12] = 0xDB, [0x13] = 0xAC, [0x14] = 0x2D, [0x15] = 0xAF, [0x16] = 0xBD, [0x17] = 0x7F, [0x18] = 0x34, [0x19] = 0xD0, [0x1A] = 0xEE, [0x1B] = 0x54, [0x1C] = 0x2C, [0x1D] = 0x44, [0x1E] = 0xDE, [0x1F] = 0xA0, [0x20] = 0x43, [0x21] = 0xA9, [0x22] = 0x49, [0x23] = 0xB5, [0x24] = 0x60, [0x25] = 0x50, [0x26] = 0x66, [0x27] = 0x63, [0x28] = 0x3B, [0x29] = 0x3A, [0x2A] = 0x58, [0x2B] = 0xE6, [0x2C] = 0xD8, [0x2D] = 0x11, [0x2E] = 0x06, [0x2F] = 0x8B, [0x30] = 0xCD, [0x31] = 0x53, [0x32] = 0x03, [0x33] = 0x95, [0x34] = 0x9B, [0x35] = 0x55, [0x36] = 0xDC, [0x37] = 0xD7, [0x38] = 0x23, [0x39] = 0x9E, [0x3A] = 0x42, [0x3B] = 0xFD, [0x3C] = 0x52, [0x3D] = 0x61, [0x3E] = 0xC6, [0x3F] = 0x9C, [0x40] = 0x88, [0x41] = 0xE9, [0x42] = 0xC7, [0x43] = 0x48, [0x44] = 0x59, [0x45] = 0xE8, [0x46] = 0x65, [0x47] = 0xCE, [0x48] = 0xB7, [0x49] = 0xD3, [0x4A] = 0x51, [0x4B] = 0x99, [0x4C] = 0x8E, [0x4D] = 0x4F, [0x4E] = 0x3F, [0x4F] = 0x90, [0x50] = 0xF6, [0x51] = 0x97, [0x52] = 0x75, [0x53] = 0x1B, [0x54] = 0xC9, [0x55] = 0xF3, [0x56] = 0x8D, [0x57] = 0xEC, [0x58] = 0xDA, [0x59] = 0x98, [0x5A] = 0x9D, [0x5B] = 0x22, [0x5C] = 0x2E, [0x5D] = 0xF5, [0x5E] = 0x05, [0x5F] = 0x15, [0x60] = 0xBB, [0x61] = 0x7D, [0x62] = 0x1D, [0x63] = 0x12, [0x64] = 0x37, [0x65] = 0xEF, [0x66] = 0xF9, [0x67] = 0x4A, [0x68] = 0x6B, [0x69] = 0x41, [0x6A] = 0x1F, [0x6B] = 0x6E, [0x6C] = 0xD2, [0x6D] = 0x2A, [0x6E] = 0x7E, [0x6F] = 0x47, [0x70] = 0x56, [0x71] = 0x07, [0x72] = 0x14, [0x73] = 0x45, [0x74] = 0xB3, [0x75] = 0xC4, [0x76] = 0x1C, [0x77] = 0x89, [0x78] = 0x71, [0x79] = 0xCF, [0x7A] = 0x01, [0x7B] = 0xA2, [0x7C] = 0x33, [0x7D] = 0xD9, [0x7E] = 0x68, [0x7F] = 0xEB, [0x80] = 0x93, [0x81] = 0xBF, [0x82] = 0x6D, [0x83] = 0xF4, [0x84] = 0x38, [0x85] = 0xA8, [0x86] = 0x5E, [0x87] = 0x85, [0x88] = 0x9A, [0x89] = 0x4C, [0x8A] = 0x0E, [0x8B] = 0x5F, [0x8C] = 0x36, [0x8D] = 0x24, [0x8E] = 0x96, [0x8F] = 0x84, [0x90] = 0x83, [0x91] = 0x3D, [0x92] = 0xCC, [0x93] = 0xF8, [0x94] = 0x86, [0x95] = 0x8C, [0x96] = 0xBC, [0x97] = 0xFA, [0x98] = 0x40, [0x99] = 0x77, [0x9A] = 0x6F, [0x9B] = 0xD5, [0x9C] = 0xB2, [0x9D] = 0xA5, [0x9E] = 0xA4, [0x9F] = 0xB0, [0xA0] = 0x17, [0xA1] = 0xC0, [0xA2] = 0x2B, [0xA3] = 0x39, [0xA4] = 0xC2, [0xA5] = 0x5B, [0xA6] = 0x6A, [0xA7] = 0xFF, [0xA8] = 0xDD, [0xA9] = 0x94, [0xAA] = 0x7A, [0xAB] = 0xFB, [0xAC] = 0xED, [0xAD] = 0x7C, [0xAE] = 0x4B, [0xAF] = 0xD1, [0xB0] = 0x18, [0xB1] = 0x08, [0xB2] = 0x35, [0xB3] = 0xB9, [0xB4] = 0xBE, [0xB5] = 0x1E, [0xB6] = 0xF0, [0xB7] = 0xA3, [0xB8] = 0xDF, [0xB9] = 0xB4, [0xBA] = 0x91, [0xBB] = 0x09, [0xBC] = 0xFC, [0xBD] = 0x76, [0xBE] = 0x80, [0xBF] = 0xAE, [0xC0] = 0x10, [0xC1] = 0xF2, [0xC2] = 0xA1, [0xC3] = 0x72, [0xC4] = 0xC1, [0xC5] = 0x8F, [0xC6] = 0x30, [0xC7] = 0xE4, [0xC8] = 0x82, [0xC9] = 0xE3, [0xCA] = 0xCB, [0xCB] = 0x0D, [0xCC] = 0xC5, [0xCD] = 0x27, [0xCE] = 0xC3, [0xCF] = 0xE5, [0xD0] = 0xB8, [0xD1] = 0x64, [0xD2] = 0xF1, [0xD3] = 0x3E, [0xD4] = 0xD4, [0xD5] = 0xAB, [0xD6] = 0x0C, [0xD7] = 0x9F, [0xD8] = 0xE0, [0xD9] = 0xAA, [0xDA] = 0x16, [0xDB] = 0xB6, [0xDC] = 0x62, [0xDD] = 0x26, [0xDE] = 0x13, [0xDF] = 0xAD, [0xE0] = 0x32, [0xE1] = 0x74, [0xE2] = 0x4E, [0xE3] = 0x21, [0xE4] = 0xE7, [0xE5] = 0x70, [0xE6] = 0x8A, [0xE7] = 0x92, [0xE8] = 0xF7, [0xE9] = 0x20, [0xEA] = 0xD6, [0xEB] = 0xBA, [0xEC] = 0x25, [0xED] = 0x29, [0xEE] = 0x00, [0xEF] = 0xE1, [0xF0] = 0x0F, [0xF1] = 0x79, [0xF2] = 0x2F, [0xF3] = 0x0A, [0xF4] = 0xFE, [0xF5] = 0xB1, [0xF6] = 0x04, [0xF7] = 0x5D, [0xF8] = 0x3C, [0xF9] = 0x73, [0xFA] = 0x6C, [0xFB] = 0x0B, [0xFC] = 0x5A, [0xFD] = 0x28, [0xFE] = 0x81, [0xFF] = 0x19, }
	} or GetGameVersion():sub(1,4)=='5.24' and {
		['Header'] = 0x0143,
		['sourcePos'] = 72,
		['stringPos'] = 35,
		['bytes'] = {[0x00] = 0x97, [0x01] = 0x8C, [0x02] = 0x8D, [0x03] = 0x8E, [0x04] = 0x8F, [0x05] = 0xA8, [0x06] = 0xA9, [0x07] = 0xAA, [0x08] = 0xAB, [0x09] = 0xA0, [0x0A] = 0xA1, [0x0B] = 0xA2, [0x0C] = 0xA3, [0x0D] = 0xA4, [0x0E] = 0xA5, [0x0F] = 0xA6, [0x10] = 0xA7, [0x11] = 0x9C, [0x12] = 0x9D, [0x13] = 0x9E, [0x14] = 0x9F, [0x15] = 0xB8, [0x16] = 0xB9, [0x17] = 0xBA, [0x18] = 0xBB, [0x19] = 0xB0, [0x1A] = 0xB1, [0x1B] = 0xB2, [0x1C] = 0xB3, [0x1D] = 0xB4, [0x1E] = 0xB5, [0x1F] = 0xB6, [0x20] = 0xB7, [0x21] = 0xFC, [0x22] = 0xFD, [0x23] = 0xFE, [0x24] = 0xFF, [0x25] = 0x08, [0x26] = 0x09, [0x27] = 0x0A, [0x28] = 0x0B, [0x29] = 0x00, [0x2A] = 0x01, [0x2B] = 0x02, [0x2C] = 0x03, [0x2D] = 0x04, [0x2E] = 0x05, [0x2F] = 0x06, [0x30] = 0x07, [0x31] = 0x2C, [0x32] = 0x2D, [0x33] = 0x2E, [0x34] = 0x2F, [0x35] = 0x18, [0x36] = 0x19, [0x37] = 0x1A, [0x38] = 0x1B, [0x39] = 0x10, [0x3A] = 0x11, [0x3B] = 0x12, [0x3C] = 0x13, [0x3D] = 0x14, [0x3E] = 0x15, [0x3F] = 0x16, [0x40] = 0x17, [0x41] = 0x0C, [0x42] = 0x0D, [0x43] = 0x0E, [0x44] = 0x0F, [0x45] = 0x28, [0x46] = 0x29, [0x47] = 0x2A, [0x48] = 0x2B, [0x49] = 0x20, [0x4A] = 0x21, [0x4B] = 0x22, [0x4C] = 0x23, [0x4D] = 0x24, [0x4E] = 0x25, [0x4F] = 0x26, [0x50] = 0x27, [0x51] = 0x1C, [0x52] = 0x1D, [0x53] = 0x1E, [0x54] = 0x1F, [0x55] = 0x38, [0x56] = 0x39, [0x57] = 0x3A, [0x58] = 0x3B, [0x59] = 0x30, [0x5A] = 0x31, [0x5B] = 0x32, [0x5C] = 0x33, [0x5D] = 0x34, [0x5E] = 0x35, [0x5F] = 0x36, [0x60] = 0x37, [0x61] = 0xBC, [0x62] = 0xBD, [0x63] = 0xBE, [0x64] = 0xBF, [0x65] = 0x48, [0x66] = 0x49, [0x67] = 0x4A, [0x68] = 0x4B, [0x69] = 0x40, [0x6A] = 0x41, [0x6B] = 0x42, [0x6C] = 0x43, [0x6D] = 0x44, [0x6E] = 0x45, [0x6F] = 0x46, [0x70] = 0x47, [0x71] = 0x6C, [0x72] = 0x6D, [0x73] = 0x6E, [0x74] = 0x6F, [0x75] = 0x58, [0x76] = 0x59, [0x77] = 0x5A, [0x78] = 0x5B, [0x79] = 0x50, [0x7A] = 0x51, [0x7B] = 0x52, [0x7C] = 0x53, [0x7D] = 0x54, [0x7E] = 0x55, [0x7F] = 0x56, [0x80] = 0x57, [0x81] = 0x4C, [0x82] = 0x4D, [0x83] = 0x4E, [0x84] = 0x4F, [0x85] = 0x68, [0x86] = 0x69, [0x87] = 0x6A, [0x88] = 0x6B, [0x89] = 0x60, [0x8A] = 0x61, [0x8B] = 0x62, [0x8C] = 0x63, [0x8D] = 0x64, [0x8E] = 0x65, [0x8F] = 0x66, [0x90] = 0x67, [0x91] = 0x5C, [0x92] = 0x5D, [0x93] = 0x5E, [0x94] = 0x5F, [0x95] = 0x78, [0x96] = 0x79, [0x97] = 0x7A, [0x98] = 0x7B, [0x99] = 0x70, [0x9A] = 0x71, [0x9B] = 0x72, [0x9C] = 0x73, [0x9D] = 0x74, [0x9E] = 0x75, [0x9F] = 0x76, [0xA0] = 0x77, [0xA1] = 0x7C, [0xA2] = 0x7D, [0xA3] = 0x7E, [0xA4] = 0x7F, [0xA5] = 0xC8, [0xA6] = 0xC9, [0xA7] = 0xCA, [0xA8] = 0xCB, [0xA9] = 0xC0, [0xAA] = 0xC1, [0xAB] = 0xC2, [0xAC] = 0xC3, [0xAD] = 0xC4, [0xAE] = 0xC5, [0xAF] = 0xC6, [0xB0] = 0xC7, [0xB1] = 0xEC, [0xB2] = 0xED, [0xB3] = 0xEE, [0xB4] = 0xEF, [0xB5] = 0xD8, [0xB6] = 0xD9, [0xB7] = 0xDA, [0xB8] = 0xDB, [0xB9] = 0xD0, [0xBA] = 0xD1, [0xBB] = 0xD2, [0xBC] = 0xD3, [0xBD] = 0xD4, [0xBE] = 0xD5, [0xBF] = 0xD6, [0xC0] = 0xD7, [0xC1] = 0xCC, [0xC2] = 0xCD, [0xC3] = 0xCE, [0xC4] = 0xCF, [0xC5] = 0xE8, [0xC6] = 0xE9, [0xC7] = 0xEA, [0xC8] = 0xEB, [0xC9] = 0xE0, [0xCA] = 0xE1, [0xCB] = 0xE2, [0xCC] = 0xE3, [0xCD] = 0xE4, [0xCE] = 0xE5, [0xCF] = 0xE6, [0xD0] = 0xE7, [0xD1] = 0xDC, [0xD2] = 0xDD, [0xD3] = 0xDE, [0xD4] = 0xDF, [0xD5] = 0xF8, [0xD6] = 0xF9, [0xD7] = 0xFA, [0xD8] = 0xFB, [0xD9] = 0xF0, [0xDA] = 0xF1, [0xDB] = 0xF2, [0xDC] = 0xF3, [0xDD] = 0xF4, [0xDE] = 0xF5, [0xDF] = 0xF6, [0xE0] = 0xF7, [0xE1] = 0x3C, [0xE2] = 0x3D, [0xE3] = 0x3E, [0xE4] = 0x3F, [0xE5] = 0x88, [0xE6] = 0x89, [0xE7] = 0x8A, [0xE8] = 0x8B, [0xE9] = 0x80, [0xEA] = 0x81, [0xEB] = 0x82, [0xEC] = 0x83, [0xED] = 0x84, [0xEE] = 0x85, [0xEF] = 0x86, [0xF0] = 0x87, [0xF1] = 0xAC, [0xF2] = 0xAD, [0xF3] = 0xAE, [0xF4] = 0xAF, [0xF5] = 0x98, [0xF6] = 0x99, [0xF7] = 0x9A, [0xF8] = 0x9B, [0xF9] = 0x90, [0xFA] = 0x91, [0xFB] = 0x92, [0xFC] = 0x93, [0xFD] = 0x94, [0xFE] = 0x95, [0xFF] = 0x96, }
	}
	AddDrawCallback(function() self:Draw() end)
	AddProcessSpellCallback(function(u, s) self:ProcessSpell(u, s) end)
	AddDeleteObjCallback(function(o) self:DeleteObj(o) end)
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
	if self.Packet then
		AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
	end
end

function WARD:CreateMenu()
	MainMenu:addSubMenu('Ward Tracker', 'WardTracker')
	self.Menu = MainMenu.WardTracker
	self.Menu:addParam('EnableEnemy', 'Enable Ward Timers', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('EnableSelf', 'Enable Self Ward Tracker', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Scale', 'Self Ward Tracker Scale', SCRIPT_PARAM_SLICE, 100, 50 , 100)
	self.Menu:addParam('Type', 'Timer Type', SCRIPT_PARAM_LIST, 1, { 'Seconds', 'Minutes' })
	self.Menu:addParam('DrawHex', 'Draw Hexagon on Timers', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Size', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	self.Menu:addParam('MapSize', 'Minimap Marker Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	self.Menu:addParam('MapType', 'Minimap Marker Type', SCRIPT_PARAM_LIST, 1, { 'Marker', 'Timer' })
	self.Menu:addParam('DrawRange', 'Draw Ward Vision Radius', SCRIPT_PARAM_ONKEYDOWN, false, ('G'):byte())
	self.Menu:addParam('Info1', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('Info2', 'Double Click a ward to manually remove it.', SCRIPT_PARAM_INFO, '')
end

function WARD:DeleteObj(o)
	if o.valid and o.type == 'obj_AI_Minion' and self.Types[o.charName] then
		for i, ward in ipairs(self.Known) do
			if ward.wardID == o.networkID then
				table.remove(self.Known, i)
				return
			end
		end	
	end
end

function WARD:Draw()
	if self.Menu.EnableEnemy then 
		for i, ward in ipairs(self.Known) do
			if ward.pos then
				if ward.isWard and self.Menu.DrawRange then
					local wts = WorldToScreen(D3DXVECTOR3(ward.pos.x, ward.pos.y, ward.pos.z))
					local d32 = D3DXVECTOR2(wts.x,wts.y)
					if d32.x > 0 and d32.x < WINDOW_W and d32.y > 0 and d32.y < WINDOW_W then
						local vision = {}
						for theta = 0, (pi2+(pi2/30)), (pi2/30) do
							local p
							for i=20, 1100, 20 do
								local p2 = D3DXVECTOR3(ward.pos.x+(i*cos(theta)), ward.pos.y, ward.pos.z-(i*sin(theta)))
								if IsWall(p2) or i==1100 then
									p = p2
									break
								end
							end
							local tS = WorldToScreen(p)
							vision[#vision + 1] = D3DXVECTOR2(tS.x, tS.y)
						end
						DrawLines2(vision,2,ward.color)
					end
				end
				local text, mapText
				if ward.endTime == huge then
					mapText = 'o'
					text = ward.charName
				else
					local timer = ward.endTime-clock()
					if self.Menu.Type == 1 then
						mapText = ('%d'):format(timer)
						text = mapText..'\n'..ward.charName
					else
						mapText = ('%d:%.2d'):format(timer/60, timer%60)
						text = mapText..'\n'..ward.charName
					end
				end	
				DrawText3D(text, ward.pos.x, ward.pos.y+85, ward.pos.z+10, self.Menu.Size, ward.color, true)
				local c = GetTextArea(mapText, self.Menu.MapSize)
				DrawText(mapText, self.Menu.MapSize, ward.mapPos.x - (c.x / 2), ward.mapPos.y - (c.y / 2), ward.color)
				if self.Menu.DrawHex then
					self:DrawHex(ward.pos.x, ward.pos.y, ward.pos.z, ward.color)
				end
				if ward.endTime < clock() then
					table.remove(self.Known, i)
					return
				end
			elseif ward.wardID then
				local o = objManager:GetObjectByNetworkId(ward.wardID)
				if o and o.valid then 
					for i, ward2 in ipairs(self.Known) do
						if ward2 and ward2.pos and GetDistanceSqr(ward2.pos, o) < 50000 then
							table.remove(self.Known, i)
							break
						end
					end
					ward['pos'] = Vector(o.pos)
					ward['mapPos'] = GetMinimap(Vector(o.pos))					
					ward['endTime'] = ward.endTime==huge and huge or o.mana+clock()					
				end
			end
		end
	end
	if self.Menu.EnableSelf then
		local isMenuOpen = IsKeyDown(menuKey) 
		DrawLine( --Background
			self.Anchor.x - GetScale(8, self.Menu.Scale) - 2, 
			self.Anchor.y, 
			self.Anchor.x + GetScale(181, self.Menu.Scale) + 2, 
			self.Anchor.y, 
			GetScale(95, self.Menu.Scale) + 4, 
			0x55FFFFFF
		)
		DrawLine( --Background
			self.Anchor.x - GetScale(8, self.Menu.Scale), 
			self.Anchor.y, 
			self.Anchor.x + GetScale(181, self.Menu.Scale), 
			self.Anchor.y, 
			GetScale(95, self.Menu.Scale), 
			isMenuOpen and ARGB(255, 85,85,85) or ARGB(100, 0, 0, 0)
		)
		for k=1, 3 do
			local v = self.Active[k]
			if v then
				if v.object then
					local t = v.endTime - clock()
					if t < 1 or not v.object or not v.object.valid or v.object.dead then
						table.remove(self.Active, k)
						return
					else
						DrawText(
							isMenuOpen and 'Ward Position' or k..(' - %d:%.2d'):format(t / 60, t % 60), 
							GetScale(26, self.Menu.Scale), 
							self.Anchor.x, 
							self.Anchor.y + GetScale(42 - (k * 22), self.Menu.Scale), 
							COLOR_TRANS_GREEN
						)
					end
				elseif v.wardID then
					v.object = objManager:GetObjectByNetworkId(v.wardID)
				end
			else
				DrawText(
					isMenuOpen and 'Ward Position' or k..' - Not Active', 
					GetScale(26, self.Menu.Scale), 
					self.Anchor.x, 
					self.Anchor.y + GetScale(42 - (k * 22), self.Menu.Scale), 
					COLOR_ORANGE
				)		
			end
		end
		if self.Active['Pink'] then
			if type(self.Active['Pink'])=='number' then
				local o = objManager:GetObjectByNetworkId(self.Active['Pink'])
				if o and o.valid then self.Active['Pink'] = o end
			elseif self.Active['Pink'].valid and not self.Active['Pink'].dead then
				DrawText(
					isMenuOpen and 'Ward Position' or 'Pink - Active', 
					GetScale(26, self.Menu.Scale), 
					self.Anchor.x, 
					self.Anchor.y - GetScale(46, self.Menu.Scale),  
					ARGB(200, 255, 50, 255)
				)
			else
				self.Active['Pink'] = nil
			end
		else
			DrawText(
				isMenuOpen and 'Ward Position' or 'Pink - Not Active', 
				GetScale(26, self.Menu.Scale),
				self.Anchor.x, 
				self.Anchor.y - GetScale(46, self.Menu.Scale),  
				COLOR_TRANS_RED
			)
		end	
		if self.IsMoving then
			local CursorPos = GetCursorPos()
			self.Anchor.x = CursorPos.x-self.MovingOffset.x
			self.Anchor.y = CursorPos.y-self.MovingOffset.y
			GlobalAnchors.WardTracker = {
				['x'] = self.Anchor.x,
				['y'] = self.Anchor.y,
			}
		end
	end
end

function WARD:WndMsg(m,k)
	if m==WM_LBUTTONDBLCLK then
		for i, ward in ipairs(self.Known) do
			if GetDistanceSqr(mousePos, ward.pos) < 5625 then			
				table.remove(self.Known, i)
				return
			end			
		end	
	end
	if m==WM_LBUTTONDOWN and IsKeyDown(menuKey) then
		local CursorPos = GetCursorPos()
		if CursorPos.x > self.Anchor.x - GetScale(8, self.Menu.Scale) and CursorPos.x < self.Anchor.x + GetScale(181, self.Menu.Scale) then
			if CursorPos.y > self.Anchor.y - GetScale(47.5, self.Menu.Scale) and CursorPos.y < self.Anchor.y + GetScale(47.5, self.Menu.Scale) then
				self.IsMoving = true
				self.MovingOffset = {x=CursorPos.x-self.Anchor.x, y=CursorPos.y-self.Anchor.y,}
			end
		end
	end
	if m==WM_LBUTTONUP and self.IsMoving then
		self.IsMoving=false
	end
end

function WARD:ProcessSpell(u, s)
	if u.valid and self.OnSpell[s.name:lower()] then
		local name = s.name:lower()
		if u.team == TEAM_ENEMY then
			local duration = name == 'trinkettotemlvl1' and 56.5 + (u.level * 3.5) or self.OnSpell[name].duration
			self.Known[#self.Known+1] = {
				['pos'] 	 = Vector(s.endPos),
				['mapPos']   = GetMinimap(Vector(s.endPos)),
				['color'] 	 = self.OnSpell[name].color,
				['endTime']  = clock()+duration,
				['charName'] = u.charName or 'Unknown',
				['isWard']   = self.OnSpell[name].isWard,
			}
		end
	end
end

function WARD:RecvPacket(p)
	if p.header == self.Packet.Header then
		p.pos=2
		local wardID = p:DecodeF()
		p.pos=self.Packet.sourcePos
		local bytes = {}
		for i=4, 1, -1 do
			bytes[i] = self.Packet.bytes[p:Decode1()]
		end
		local netID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
		local source = objManager:GetObjectByNetworkId(DwordToFloat(netID))
		if source and source.valid then
			p.pos=self.Packet.stringPos
			local str = ''
			for i=p.pos, p.size do
				local d1 = p:Decode1()
				if not self.Types[str] then
					str=str..string.char(d1)
				end
			end
			if self.Types[str] then
				if source.isMe and self.Types[str].isWard then
					if self.Types[str].duration then								
						if self.Types[str].duration ~= huge then
							local duration = str == 'YellowTrinket' and 56.5 + (source.level * 3.5) or self.Types[str].duration
							table.insert(self.Active, 1, {
								['wardID'] = wardID,
								['endTime'] = clock() + duration,
								['startTime'] = clock(),
							})
							if self.Active[4] then table.remove(self.Active, 4) end
						else
							self.Active['Pink'] = wardID
						end
					end
				elseif source.team == TEAM_ENEMY then
					local duration = str == 'YellowTrinket' and 56.5 + (source.level * 3.5) or self.Types[str].duration
					self.Known[#self.Known + 1] = {
						['color']	 = self.Types[str].color, 
						['endTime']	 = self.Types[str].duration == huge and huge or clock() + duration,
						['charName'] = source.charName,
						['isWard']   = self.Types[str].isWard,
						['wardID']	 = wardID,
					}					
				end
			end
		end
	end
end

function WARD:DrawHex(x, y, z, c)
	local p1 = WorldToScreen(D3DXVECTOR3(x+75, y, z))
	if p1.x > -100 and p1.x < WINDOW_W+100 and p1.y < WINDOW_H+100 and p1.y > -100 then
		local count = 1
		self.Hex[count].x, self.Hex[count].y = p1.x, p1.y
		for theta = (pi2/6), pi2, (pi2/6) do
			count=count+1
			local tS = WorldToScreen(D3DXVECTOR3(x+(75*cos(theta)), y, z-(75*sin(theta))))
			self.Hex[count].x, self.Hex[count].y = tS.x, tS.y
		end
		DrawLines2(self.Hex, 1, c)
	end
end

class 'MISS'

function MISS:__init()
	if not FileExist(SPRITE_PATH..'mapIcons/'..myHero.charName..'.png') then
		Print('Minimap Sprites Not Found!!! Please Download from forum')
		if not FileExist(SPRITE_PATH..'Generic.png') then
			AwareUpdate(
				'isSprite', 
				'i.imgur.com',
				nil, 
				'/6dSBvc1.png',
				SPRITE_PATH..'Generic.png', 
				function() Print('Sprite Download complete') end, 
				function() return end, 
				function() return end, 
				function() Print('An error occured downloading sprite') end
			)
		end
	end
	if not FileExist(SPRITE_PATH..'mapIcons/Illaoi.png') then
		AwareUpdate(
			'isSprite',
			'i.imgur.com',
			nil, 
			'/D2mdvwd.png',
			SPRITE_PATH..'mapIcons/Illaoi.png', 
			function() Print('Sprite Download complete') end, 
			function() return end, 
			function() return end, 
			function() Print('An error occured downloading sprite') end
		)
	end
	self.missing = {}
	self.VisibleSince = {}
	self.ActiveRecalls = {}
	self.Sprites = {}	
	for i=0, objManager.maxObjects do
		local o = objManager:getObject(i)
		if o and o.name and o.name:find('__Spawn_T') and o.team == TEAM_ENEMY then
			self.recallEndPos = GetMinimap(Vector(o.pos))
		end
	end
	self.recallTimes = {
		['recall'] = 7.9,
		['odinrecall'] = 4.4,
		['odinrecallimproved'] = 3.9,
		['recallimproved'] = 6.9,
		['superrecall'] = 3.9,
		['teleport'] = 3.15,
	}
	self.Allies = {}
	self.Enemies = {}
	local DefaultAnchor = GetMinimap(Vector(0, 0, 25000))
	self.Anchor = {
		['x'] = GlobalAnchors.RecallBar and GlobalAnchors.RecallBar.x or DefaultAnchor.x,
		['x2'] = WINDOW_W - 10 - DefaultAnchor.x,
		['y'] = GlobalAnchors.RecallBar and GlobalAnchors.RecallBar.y or DefaultAnchor.y,
	}
	self.Anchor2 = {
		['x'] = GlobalAnchors.JungleTracker and GlobalAnchors.JungleTracker.x or ceil(WINDOW_W/2),
		['y'] = GlobalAnchors.JungleTracker and GlobalAnchors.JungleTracker.y or ceil(WINDOW_H/8),
	}
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if hero.team == TEAM_ENEMY then
			self.Enemies[#self.Enemies + 1] = hero
			self.VisibleSince[hero.networkID] = clock()
			self.missing[hero.networkID] = nil
			if FileExist(SPRITE_PATH..'mapIcons/'..hero.charName..'.png') then
				self.Sprites[hero.networkID] = createSprite('mapIcons/'.. hero.charName ..'.png')
			elseif FileExist(SPRITE_PATH..'Pewtility/CharacterIcons'..hero.charName..'.png') then
				self.Sprites[hero.networkID] = createSprite(SPRITE_PATH..'Pewtility/CharacterIcons'..hero.charName..'.png')			
			else
				self.Sprites[hero.networkID] = createSprite('Generic.png')
			end
            self.Sprites[hero.networkID]:SetScale(0.45, 0.45)
			self.Sprites[hero.networkID].scale = 0.45
		else
			self.Allies[#self.Allies + 1] = hero
		end
	end
	for k, v in pairs(self.Sprites) do
		v:SetScale(0.45, 0.45)
		v.scale = 0.45
	end
	self.Packets = GetGameVersion():sub(1, 4) == '5.23' and {
		['LoseVision'] = { ['Header'] = 0x0108, ['pos'] = 2, },
		['GainVision'] = { ['Header'] = 0x00E9, ['pos'] = 2, },
		['Recall'] = { ['Header'] = 0x0152, ['pos'] = 79, ['stringPos'] = 54, ['tpPos'] = 22, ['isTP'] = 0x08,},
		['Aggro'] = { ['Header'] = 0x00E2, ['pos'] = 2, },
		['Reset'] = { ['Header'] = 0x0117, ['pos'] = 2, ['pos2'] = 10, },
		['Missile'] = { ['Header'] = 0x0104, ['pos'] = 2, },
		['JunglePos'] = {
			[0x89BE0B2F] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_Krug11.1.2',           ['text'] = 'Top Krugs'    },
			[0x9DE04D82] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_KrugMini11.1.1',       ['text'] = 'Top Krugs'    },
			[0x51079939] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.2',        ['text'] = 'Top Red'       },
			[0x89452480] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_Red10.1.1',            ['text'] = 'Top Red'      },
			[0x89B4F68B] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.3',        ['text'] = 'Top Red'      },
			[0xD6B90245] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.2',   ['text'] = 'Top Raptors'  },
			[0x51FF5070] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_Razorbeak9.1.1',       ['text'] = 'Top Raptors'  },
			[0x896F4BA7] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.3',   ['text'] = 'Top Raptors'  },
			[0x9D302A38] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.4',   ['text'] = 'Top Raptors'  },
			[0x89B45C81] = { ['pos'] = GetMinimap(Vector(2200, 60, 8500)),  ['name'] = 'SRU_Gromp13.1.1',          ['text'] = 'Bot Gromp'    },
			[0x51C54490] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini21.1.3',       ['text'] = 'Bot Blue',    },
			[0x51DB965C] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini1.1.2',        ['text'] = 'Bot Blue',    },
			[0x5183A8C7] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_Blue1.1.1',            ['text'] = 'Bot Blue',    },
			[0x5110899E] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_Murkwolf2.1.1',        ['text'] = 'Bot Wolves'   },
			[0x51EA9F9F] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.2',    ['text'] = 'Bot Wolves'   },
			[0x51830E9A] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.3',    ['text'] = 'Bot Wolves'   },
			[0x43EE6BB4] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)),  ['name'] = 'SRU_Krug5.1.2',            ['text'] = 'Bot Krugs'    },
			[0xB1F16D25] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)),  ['name'] = 'SRU_KrugMini5.1.1',        ['text'] = 'Bot Krugs'    },
			[0x51B41862] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.3',         ['text'] = 'Bot Red'      },
			[0x515E8070] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_Red4.1.1',             ['text'] = 'Bot Red'      },
			[0xD66F5C2D] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.2',         ['text'] = 'Bot Red'      },
			[0x89134D77] = { ['pos'] = GetMinimap(Vector(9866, 60, 4414)),  ['name'] = 'SRU_Dragon6.1.1',          ['text'] = 'Dragon'       },
			[0x511FA88A] = { ['pos'] = GetMinimap(Vector(12600, 60, 6400)), ['name'] = 'SRU_Gromp14.1.1',          ['text'] = 'Top Gromp'    },
			[0x8905EEBC] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini27.1.3',       ['text'] = 'Top Blue',    },
			[0x8958470F] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini7.1.2',        ['text'] = 'Top Blue',    },
			[0x892A90AF] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_Blue7.1.1',            ['text'] = 'Top Blue',    },
			[0x89B68FB7] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_Murkwolf8.1.1',        ['text'] = 'Top Wolves'   },
			[0x89987CD8] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.3',    ['text'] = 'Top Wolves'   },
			[0x89106CFD] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.2',    ['text'] = 'Top Wolves'   },		
		},	
	} or GetGameVersion():sub(1, 4) == '5.24' and {
		['LoseVision'] = { ['Header'] = 0x0106, ['pos'] = 2, },
		['GainVision'] = { ['Header'] = 0x0063, ['pos'] = 2, },
		['Recall'] = { ['Header'] = 0x011A, ['pos'] = 80, ['stringPos'] = 56, ['tpPos'] = 22, ['isTP'] = 0x08, },
		['Reset'] = { ['Header'] = 0x00AE, ['pos'] = 2, ['pos2'] = 10, },
		['Aggro'] = { ['Header'] = 0X0148, ['pos'] = 2, },
		['Missile'] = { ['Header'] = 0x00F5, ['pos'] = 2, },
		['JunglePos'] = {
			[0x6B59E01F] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)),  ['name'] = 'SRU_Krug5.1.2',            ['text'] = 'Bot Krugs'    },
			[0x248FDF12] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)),  ['name'] = 'SRU_KrugMini5.1.1',        ['text'] = 'Bot Krugs'    },
			[0xCF193250] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.2',         ['text'] = 'Bot Red'      },
			[0x6152C24E] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_Red4.1.1',             ['text'] = 'Bot Red'      },
			[0x611FE246] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.3',         ['text'] = 'Bot Red'      },
			[0x6B68ACAA] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.2',   ['text'] = 'Bot Raptors'  },
			[0xD9737D43] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_Razorbeak3.1.1',       ['text'] = 'Bot Raptors'  },
			[0xD91FF0EB] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.4',   ['text'] = 'Bot Raptors'  },
			[0x61639943] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.3',   ['text'] = 'Bot Raptors'  },
			[0xD9B8800B] = { ['pos'] = GetMinimap(Vector(9866, 60, 4414)),  ['name'] = 'SRU_Dragon6.1.1',          ['text'] = 'Dragon'       },
			[0x6175652C] = { ['pos'] = GetMinimap(Vector(12600, 60, 6400)), ['name'] = 'SRU_Gromp14.1.1',          ['text'] = 'Top Gromp'    },
			[0xD9515998] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini27.1.3',       ['text'] = 'Top Blue',    },
			[0xD99AECD7] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_Blue7.1.1',            ['text'] = 'Top Blue',    },
			[0xD9E97217] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini7.1.2',        ['text'] = 'Top Blue',    },
			[0xD9C090F5] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.2',    ['text'] = 'Top Wolves'   },
			[0xD90F77B9] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_Murkwolf8.1.1',        ['text'] = 'Top Wolves'   },
			[0xD96EFBB3] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.3',    ['text'] = 'Top Wolves'   },
			[0xCF78495E] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.2',   ['text'] = 'Top Raptors'  },
			[0xD9198BF1] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.3',   ['text'] = 'Top Raptors'  },
			[0x61FE064E] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_Razorbeak9.1.1',       ['text'] = 'Top Raptors'  },
			[0x7AE59A10] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.4',   ['text'] = 'Top Raptors'  },
			[0xD97B5CE8] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_Krug11.1.2',           ['text'] = 'Top Krugs'    },
			[0x7AF080B4] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_KrugMini11.1.1',       ['text'] = 'Top Krugs'    },
			[0xD95EEBC2] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_Red10.1.1',            ['text'] = 'Top Red'      },
			[0xD91FBDC1] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.3',        ['text'] = 'Top Red'      },
			[0x61CBF47C] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.2',        ['text'] = 'Top Red'       },
			[0xD91F320C] = { ['pos'] = GetMinimap(Vector(2200, 60, 8500)),  ['name'] = 'SRU_Gromp13.1.1',          ['text'] = 'Bot Gromp'    },
			[0x61763322] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.3',    ['text'] = 'Bot Wolves'   },
			[0x61E78EEC] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini21.1.3',       ['text'] = 'Bot Blue',    },
			[0x611AFD32] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini1.1.2',        ['text'] = 'Bot Blue',    },
			[0x61766557] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_Blue1.1.1',            ['text'] = 'Bot Blue',    },
			[0x61C0D985] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_Murkwolf2.1.1',        ['text'] = 'Bot Wolves'   },
			[0x61740808] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.2',    ['text'] = 'Bot Wolves'   },		
		},			
	}
	self.Arrows = string.char(26)..' '..string.char(27)
	self.ArrowsSize = GetTextArea(self.Arrows, 35)
	self.JungleTracker = {}
	self:CreateMenu()
	if not self.Packets then
		Print('Missing Enemies packets are outdated!!', true)
		return
	end
	if GetGame().map.shortName == 'summonerRift' then
		AddRecvPacketCallback2(function(p) self:JunglePackets(p) end)
	end
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
	AddDrawCallback(function() self:Draw() end)
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
end

function MISS:CreateMenu()
	MainMenu:addSubMenu('Missing Enemies', 'MissTracker')
	self.Menu = MainMenu.MissTracker
	self.Menu:addParam('Enable', 'Enable Missing Timers', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('TextSize', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	self.Menu:addParam('SpriteSize', 'Sprite Size', SCRIPT_PARAM_SLICE, 45, 1, 100)
	self.Menu:addParam('EnableRecall', 'Display Recall Status', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('RecallScale', 'Recall Bar Scale', SCRIPT_PARAM_SLICE, 100, 50, 100)
	self.Menu:addParam('EnableJungle', 'Display Jungle Tracker', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('JungleScale', 'Jungle Tracker Bar Scale', SCRIPT_PARAM_SLICE, 75, 50, 100)
	self.LastCheck = self.Menu.SpriteSize
	AddTickCallback(function()
		if self.Menu.SpriteSize ~= self.LastCheck then
			for k, v in pairs(self.Sprites) do
				v:SetScale(self.Menu.SpriteSize / 100, self.Menu.SpriteSize / 100)
				v.scale = self.Menu.SpriteSize / 100
			end			
		end
	end)
end

function MISS:RecvPacket(p)
	if p.header == self.Packets.LoseVision.Header then
		p.pos=self.Packets.LoseVision.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			if o.dead then
				self.missing[o.networkID] = {
					['pos'] = self.recallEndPos,
					['name'] = o.charName, 
					['mTime'] = clock(),
				}			
			else
				self.missing[o.networkID] = {
					['pos'] = GetMinimap(Vector(o.pos)),
					['pos2'] = Vector(o.pos),
					['name'] = o.charName, 
					['mTime'] = clock(),
					['unit'] = o,
				}
				if GetDistance(o, o.endPath) > 100 then
					self.missing[o.networkID].direction = GetMinimap(Vector(o) + (Vector(o.endPath) - Vector(o)):normalized() * 1200)
				end
				return
			end
		end	
	end
	if p.header == self.Packets.GainVision.Header then
		p.pos=self.Packets.GainVision.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			self.missing[o.networkID] = nil
			self.VisibleSince[o.networkID] = clock()
			return
		end
	end
	if p.header == self.Packets.Recall.Header then
		p.pos = self.Packets.Recall.pos
		local bytes = {}
		for i=4, 1, -1 do
			bytes[i] = IDBytes[p:Decode1()]
		end
		local netID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
		local o = objManager:GetObjectByNetworkId(DwordToFloat(netID))
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			p.pos = self.Packets.Recall.tpPos
			local isTP = p:Decode1() == self.Packets.Recall.isTP
			local str = ''
			if not isTP then
				p.pos=self.Packets.Recall.stringPos
				for i=1, p.size do
					local b = p:Decode1()
					if b == 0 then break end
					str=str..string.char(b)
				end
			else
				str = 'teleport'
			end
			if self.recallTimes[str:lower()] then
				self.ActiveRecalls[o.networkID] = {
					name = o.charName,
					startT = clock(),
					duration = self.recallTimes[str:lower()],
					endT = clock() + self.recallTimes[str:lower()],	
					isTP = isTP
				}
				return			
			elseif self.ActiveRecalls[o.networkID] then
				if self.ActiveRecalls[o.networkID].endT > clock() then
					self.ActiveRecalls[o.networkID] = nil
					return
				else
					if not self.ActiveRecalls[o.networkID].isTP then
						self.missing[o.networkID] = {pos = self.recallEndPos, name = o.charName, mTime = clock(),}
					end
					self.ActiveRecalls[o.networkID].complete = clock() + 3
					return
				end
			end
		end
	end
end

function MISS:WndMsg(m,k)
	if m==WM_LBUTTONDOWN and IsKeyDown(menuKey) then
		local CursorPos = GetCursorPos()
		if CursorPos.x > self.Anchor.x and CursorPos.x < self.Anchor.x + GetScale(self.Anchor.x2, self.Menu.RecallScale) then
			if CursorPos.y < self.Anchor.y and CursorPos.y > self.Anchor.y - GetScale(128, self.Menu.RecallScale) then
				self.IsMoving = true
				self.MovingOffset = {x=CursorPos.x-self.Anchor.x, y=CursorPos.y-self.Anchor.y,}
			end
		end
		if CursorPos.x > self.Anchor2.x - GetScale(100, self.Menu.JungleScale) and CursorPos.x < self.Anchor2.x + GetScale(100, self.Menu.JungleScale) then
			if CursorPos.y < self.Anchor2.y + GetScale(25, self.Menu.JungleScale) and CursorPos.y > self.Anchor2.y - GetScale(25, self.Menu.JungleScale) then		
				self.IsMoving2 = true
				self.MovingOffset2 = {x=CursorPos.x-self.Anchor2.x, y=CursorPos.y-self.Anchor2.y,}
			end			
		end
	end
	if m==WM_LBUTTONUP and (self.IsMoving or self.IsMoving2) then
		self.IsMoving=false
		self.IsMoving2=false
	end
end

function MISS:JunglePackets(p)
	if p.header == self.Packets.Reset.Header then
		p.pos=self.Packets.Reset.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if (not o) or (o.valid and not o.visible) then
			p.pos=self.Packets.Reset.pos2
			local d4 = p:Decode4()
			if self.Packets.JunglePos[d4] then
				for i, camp in ipairs(self.JungleTracker) do
					if camp.pos.x == self.Packets.JunglePos[d4].pos.x then 
						return 
					end
				end
				if o then
					for i, ally in ipairs(self.Allies) do
						if ally.valid and GetDistanceSqr(ally.pos, o.pos) < 2250000 then
							return
						end
					end
				end
				self.JungleTracker[#self.JungleTracker + 1] = { ['pos'] = self.Packets.JunglePos[d4].pos, ['endTime'] = os.clock() + 10, ['text'] = self.Packets.JunglePos[d4].text, }
			end
		end
	elseif p.header == self.Packets.Aggro.Header then
		p.pos=self.Packets.Aggro.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and not o.visible then
			local index
			for _, camp in pairs(self.Packets.JunglePos) do
				if camp.name == o.name then
					index = _
				end
			end
			if index then
				for i, camp in ipairs(self.JungleTracker) do
					if camp.pos.x == self.Packets.JunglePos[index].pos.x then
						return 
					end
				end
				for i, ally in ipairs(self.Allies) do
					if ally.valid and GetDistanceSqr(ally.pos, o.pos) < 2250000 then
						return
					end
				end
				self.JungleTracker[#self.JungleTracker + 1] = { ['pos'] = self.Packets.JunglePos[index].pos, ['endTime'] = os.clock() + 10, ['text'] = self.Packets.JunglePos[index].text, }
			end
		end
	elseif p.header == self.Packets.Missile.Header then
		p.pos=self.Packets.Missile.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.team == 300 and not o.visible then
			local index
			for i, info in pairs(self.Packets.JunglePos) do
				if info.name == o.name then
					index = i
					break
				end
			end
			if index then
				for i, camp in ipairs(self.JungleTracker) do
					if camp.pos.x == self.Packets.JunglePos[index].pos.x then 
						return 
					end
				end
				for i, ally in ipairs(self.Allies) do
					if ally.valid and GetDistanceSqr(ally.pos, o.pos) < 2250000 then
						return
					end
				end
				self.JungleTracker[#self.JungleTracker + 1] = { ['pos'] = self.Packets.JunglePos[index].pos, ['endTime'] = os.clock() + 10, ['text'] = self.Packets.JunglePos[index].text, }
			end
		end		
	end
end

function MISS:Draw()
	if not self.Menu.Enable then return end
	local isMenuOpen = IsKeyDown(menuKey)
	local mCount = 1
	for _, info in pairs(self.missing) do
		if info then
			local scale = (self.Sprites[_].scale * self.Sprites[_].width) * 0.5
			if info.direction then
				DrawLine(info.direction.x,info.direction.y,info.pos.x,info.pos.y,3,COLOR_RED)
			end
			self.Sprites[_]:SetScale(self.Menu.SpriteSize * 0.01, self.Menu.SpriteSize * 0.01)
			self.Sprites[_]:Draw(info.pos.x-scale, info.pos.y-scale, 255)
			local t = ('%d'):format(clock()-info.mTime)
			local ta = GetTextArea(t, self.Menu.TextSize)
			DrawText(t, self.Menu.TextSize, info.pos.x-(ta.x*0.5), info.pos.y-(ta.y*0.5)+scale, COLOR_RED)
			if info.pos2 then
				local wts = WorldToScreen(D3DXVECTOR3(info.pos2.x,info.pos2.y,info.pos2.z))
				if wts.x>-100 and wts.x<WINDOW_W+100 and wts.y>-100 and wts.y<WINDOW_H+100 then
					self.Sprites[_]:SetScale(1, 1)
					self.Sprites[_]:Draw(wts.x, wts.y, 255)
					local text = ('%u / %u'):format(info.unit.health, info.unit.maxHealth)
					local textArea = GetTextArea(text, 16).x * 0.5
					DrawLine(wts.x+23-textArea,wts.y+62,wts.x+31+textArea,wts.y+62,18,0x99888888)
					local width = (wts.x+31+textArea) - (wts.x+23-textArea)
					DrawLine(wts.x+24-textArea,wts.y+62,wts.x+23-textArea + (width * (info.unit.health / info.unit.maxHealth))-1,wts.y+62,16,0x99008800)
					DrawText(text,16,wts.x+27-textArea,wts.y+54,0xFFFFFFFF)
					DrawText(t, 30, wts.x+27-(GetTextArea(t, 30).x * 0.5), wts.y-12, 0xFFFF0000)					
				end
			end
		end
	end
	if self.Menu.EnableRecall then		
		local Scale0 = GetScale(12, self.Menu.RecallScale)
		local Scale1 = GetScale(8, self.Menu.RecallScale)
		local Scale2 = GetScale(2, self.Menu.RecallScale)
		local Scale3 = GetScale(self.Anchor.x2, self.Menu.RecallScale)
		if isMenuOpen then
			for i=0, 4 do 
				local Scale4 = GetScale(i * 30, self.Menu.RecallScale)
				DrawLine(
					self.Anchor.x-2, 
					self.Anchor.y - Scale4, 
					self.Anchor.x + Scale3 + 2, 
					self.Anchor.y - Scale4, 
					GetScale(16, self.Menu.RecallScale) + 4, 
					0x77FFFFFF
				)
				DrawText(
					'Recall Bar Position', 
					Scale0, 
					self.Anchor.x + (Scale3 / 2) - (GetTextArea('Recall Bar Position', Scale0).x / 2), 
					self.Anchor.y - GetScale(6, self.Menu.RecallScale) - Scale4, 
					COLOR_WHITE
				)	
			end
			if self.IsMoving then
				local CursorPos = GetCursorPos()
				self.Anchor.x = CursorPos.x-self.MovingOffset.x
				self.Anchor.y = CursorPos.y-self.MovingOffset.y
				GlobalAnchors.RecallBar = {
					['x'] = self.Anchor.x,
					['y'] = self.Anchor.y,
				}
			end
		else
			local RecallCount = 0
			for _, info in pairs(self.ActiveRecalls) do
				local Scale4 = GetScale(RecallCount * 30, self.Menu.RecallScale)
				local percent = (info.endT - clock()) / info.duration
				local x2 = self.Anchor.x + (Scale3 * (percent < 1 and percent or 1))
				DrawLine(
					self.Anchor.x-2, 
					self.Anchor.y - Scale4, 
					self.Anchor.x + Scale3 + 2, 
					self.Anchor.y - Scale4, 
					GetScale(16, self.Menu.RecallScale) + 4, 
					info.isTP and 0x770099FF or 0x77FFFFFF
				)
				DrawLine(
					self.Anchor.x, 
					self.Anchor.y - Scale4, 
					(x2 > self.Anchor.x+1 and x2 or self.Anchor.x), 
					self.Anchor.y - Scale4, 
					GetScale(16, self.Menu.RecallScale), 
					ARGB(255, 255 * percent, 255 - (255 * percent), 0)
				)
				if info.complete and info.complete < clock() then
					self.ActiveRecalls[_] = nil
					return
				end
				local text = info.complete and info.name..' Completed.' or info.isTP and info.name..': Teleport '..ceil(percent * 100)..'%' or info.name..' '..ceil(percent * 100)..'%'
				DrawText(
					text, 
					Scale0, 
					self.Anchor.x + (Scale3 / 2) - (GetTextArea(text, Scale0).x / 2), 
					self.Anchor.y - GetScale(6, self.Menu.RecallScale) - Scale4, 
					COLOR_WHITE
				)	
				RecallCount = RecallCount + 1
			end
		end
	end
	if self.Menu.EnableJungle then		
		local Scale0 = GetScale(100, self.Menu.JungleScale)
		local Scale1 = Scale0 * 0.25
		if isMenuOpen then			
			DrawLine(self.Anchor2.x - Scale0-2, self.Anchor2.y, self.Anchor2.x + Scale0+2, self.Anchor2.y, (Scale0 * 0.5) + 4, 0x77FFFFFF)
			DrawLine(self.Anchor2.x - Scale0, self.Anchor2.y, self.Anchor2.x + Scale0, self.Anchor2.y, Scale0 * 0.5, COLOR_TRANS_RED)
			DrawText(
				'Position', 
				(Scale0 * 0.32), 
				self.Anchor2.x - (GetTextArea('Position', (Scale0 * 0.32)).x / 2), 
				self.Anchor2.y - (Scale0 * 0.1), 
				COLOR_TRANS_WHITE
			)
			DrawText(
				'Jungle Tracker',
				Scale0 * 0.16,
				self.Anchor2.x - (Scale0 * 0.45),
				self.Anchor2.y - Scale1,
				COLOR_TRANS_WHITE
			)
			if self.IsMoving2 then
				local CursorPos = GetCursorPos()
				self.Anchor2.x = CursorPos.x-self.MovingOffset2.x
				self.Anchor2.y = CursorPos.y-self.MovingOffset2.y
				GlobalAnchors.JungleTracker = {
					['x'] = self.Anchor2.x,
					['y'] = self.Anchor2.y,
				}
			end
		else
			for i, camp in ipairs(self.JungleTracker) do
				if camp.endTime < os.clock() then
					table.remove(self.JungleTracker, i)
					return
				end
				DrawText(string.char(26)..' '..string.char(27),35,camp.pos.x - (self.ArrowsSize.x / 2),camp.pos.y - (self.ArrowsSize.y / 2),COLOR_RED)
			end
			if #self.JungleTracker == 1 then
				DrawLine(self.Anchor2.x - Scale0-2, self.Anchor2.y, self.Anchor2.x + Scale0+2, self.Anchor2.y, (Scale0 * 0.5) + 4, 0x77FFFFFF)
				DrawLine(self.Anchor2.x - Scale0, self.Anchor2.y, self.Anchor2.x + Scale0, self.Anchor2.y, Scale0 * 0.5, COLOR_TRANS_RED)
				DrawText(
					self.JungleTracker[1].text, 
					(Scale0 * 0.32), 
					self.Anchor2.x - (GetTextArea(self.JungleTracker[1].text, (Scale0 * 0.32)).x / 2), 
					self.Anchor2.y - (Scale0 * 0.1), 
					COLOR_TRANS_WHITE
				)
				DrawText(
					'Jungle Tracker',
					Scale0 * 0.16,
					self.Anchor2.x - (Scale0 * 0.45),
					self.Anchor2.y - Scale1,
					COLOR_TRANS_WHITE
				)
			end
		end
	end
end

class 'SKILLS'

function SKILLS:__init()
	CreateDirectory(SPRITE_PATH..'Pewtility/')
	local pngChecks = {
		['barTemplate.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/barTemplate.png',
			['url'] = '/KwTTvQ4.png',
		},
		['summonerbarrier.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerbarrier.png',
			['url'] = '/68VUJSl.png',
		},
		['summonerboost.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerboost.png',
			['url'] = '/CAVVQ9B.png',
		},
		['summonerclairvoyance.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerclairvoyance.png',
			['url'] = '/gvYFTpu.png',
		},
		['summonerdot.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerdot.png',
			['url'] = '/kCD3WjZ.png',
		},
		['summonerexhaust.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerexhaust.png',
			['url'] = '/8EsF90W.png',
		},
		['summonerflash.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerflash.png',
			['url'] = '/LhnU93g.png',
		},
		['summonerhaste.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerhaste.png',
			['url'] = '/K4fmF83.png',
		},
		['summonerheal.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerheal.png',
			['url'] = '/yTwLorm.png',
		},
		['summonermana.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonermana.png',
			['url'] = '/Rt0i7HR.png',
		},
		['summonerodingarrison.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerodingarrison.png',
			['url'] = '/nCHmZra.png',
		},
		['summonersmite.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonersmite.png',
			['url'] = '/j6XAgXK.png',
		},
		['summonersnowball.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonersnowball.png',
			['url'] = '/D5TIXXe.png',
		},
		['summonerteleport.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerteleport.png',
			['url'] = '/uY8WKfV.png',
		},
	}
	for k, v in pairs(pngChecks) do
		if not FileExist(v.localPath) then
			AwareUpdate(
				'isSprite', 
				'i.imgur.com',
				nil, 
				v.url,
				SPRITE_PATH..'Pewtility/'..k, 
				function() Print('Sprite Download complete') end, 
				function() return end, 
				function() return end, 
				function() Print('An error occured downloading sprite') end
			)			
		end
	end
	
	self.Heroes = {}
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if not hero.isMe then
			self.Heroes[#self.Heroes+1] = {
				['hero'] = hero,
				['sum1'] = createSprite('Pewtility/'..hero:GetSpellData(SUMMONER_1).name..'.png'),
				['sum2'] = createSprite('Pewtility/'..hero:GetSpellData(SUMMONER_2).name..'.png'),
			}
		end
	end
	self.xOffsets = {
		['AniviaEgg'] = -0.1,
		['Darius'] = -0.05,
		['Renekton'] = -0.05,
		['Sion'] = -0.05,
		['Thresh'] = -0.03,
	}
	self.ParTypes = {['Ashe'] = 0xFF00AAFF, ['Caitlyn'] = 0xFF00AAFF, ['Corki'] = 0xFF00AAFF, ['Draven'] = 0xFF00AAFF, ['Ezreal'] = 0xFF00AAFF, ['Graves'] = 0xFF00AAFF,	['Jayce'] = 0xFF00AAFF, ['Jinx'] = 0xFF00AAFF, ['Kalista'] = 0xFF00AAFF, ['Kindred'] = 0xFF00AAFF, ['KogMaw'] = 0xFF00AAFF, ['Lucian'] = 0xFF00AAFF, 	['MasterYi'] = 0xFF00AAFF, ['MissFortune'] = 0xFF00AAFF, ['Pantheon'] = 0xFF00AAFF, ['Quinn'] = 0xFF00AAFF,['Shaco'] = 0xFF00AAFF, ['Sivir'] = 0xFF00AAFF, ['Talon'] = 0xFF00AAFF, ['Tristana'] = 0xFF00AAFF, ['Twitch'] = 0xFF00AAFF, ['Urgot'] = 0xFF00AAFF, ['Varus'] = 0xFF00AAFF, ['Vayne'] = 0xFF00AAFF, ['Fiora'] = 0xFF00AAFF, ['Annie'] = 0xFF00AAFF, ['Ahri'] = 0xFF00AAFF, ['Azir'] = 0xFF00AAFF, ['Bard'] = 0xFF00AAFF, ['Anivia'] = 0xFF00AAFF, ['Brand'] = 0xFF00AAFF, ['Cassiopeia'] = 0xFF00AAFF, ['Diana'] = 0xFF00AAFF, ['Ekko'] = 0xFF00AAFF, ['Evelynn'] = 0xFF00AAFF, ['FiddleSticks'] = 0xFF00AAFF, ['Fizz'] = 0xFF00AAFF, ['Heimerdinger'] = 0xFF00AAFF, ['Illaoi'] = 0xFF00AAFF, ['Karthus'] = 0xFF00AAFF, ['Kassadin'] = 0xFF00AAFF, ['Kayle'] = 0xFF00AAFF, ['Leblanc'] = 0xFF00AAFF, ['Lissandra'] = 0xFF00AAFF, ['Lux'] = 0xFF00AAFF, ['Malzahar'] = 0xFF00AAFF, ['Morgana'] = 0xFF00AAFF, ['Nidalee'] = 0xFF00AAFF,	['Orianna'] = 0xFF00AAFF, ['Ryze'] = 0xFF00AAFF, ['Swain'] = 0xFF00AAFF, ['Syndra'] = 0xFF00AAFF, ['Teemo'] = 0xFF00AAFF, ['TwistedFate'] = 0xFF00AAFF, ['Veigar'] = 0xFF00AAFF, ['Viktor'] = 0xFF00AAFF,['Xerath'] = 0xFF00AAFF, ['Ziggs'] = 0xFF00AAFF, ['Zyra'] = 0xFF00AAFF, ['Velkoz'] = 0xFF00AAFF, ['Zilean'] = 0xFF00AAFF, ['Alistar'] = 0xFF00AAFF, ['Blitzcrank'] = 0xFF00AAFF, ['Braum'] = 0xFF00AAFF, ['Galio'] = 0xFF00AAFF, ['Janna'] = 0xFF00AAFF, ['Karma'] = 0xFF00AAFF, ['Leona'] = 0xFF00AAFF, ['Lulu'] = 0xFF00AAFF, ['Nami'] = 0xFF00AAFF, ['Nunu'] = 0xFF00AAFF, ['Sona'] = 0xFF00AAFF, ['Soraka'] = 0xFF00AAFF, ['TahmKench'] = 0xFF00AAFF, ['Taric'] = 0xFF00AAFF, ['Thresh'] = 0xFF00AAFF, ['Darius'] = 0xFF00AAFF, ['Elise'] = 0xFF00AAFF, ['Gangplank'] = 0xFF00AAFF,['Gnar'] = 0xFF00AAFF, ['Gragas'] = 0xFF00AAFF, ['Irelia'] = 0xFF00AAFF, ['JarvanIV'] = 0xFF00AAFF, ['Jax'] = 0xFF00AAFF, ['Khazix'] = 0xFF00AAFF, ['Nocturne'] = 0xFF00AAFF, ['Olaf'] = 0xFF00AAFF, ['Poppy'] = 0xFF00AAFF, ['RekSai'] = 0xFF00AAFF, ['Trundle'] = 0xFF00AAFF, ['Udyr'] = 0xFF00AAFF, ['Vi'] = 0xFF00AAFF, ['MonkeyKing'] = 0xFF00AAFF, ['XinZhao'] = 0xFF00AAFF, ['Amumu'] = 0xFF00AAFF, ['Chogath'] = 0xFF00AAFF,['Hecarim'] = 0xFF00AAFF, ['Malphite'] = 0xFF00AAFF, ['Maokai'] = 0xFF00AAFF, ['Nasus'] = 0xFF00AAFF, ['Rammus'] = 0xFF00AAFF, ['Sejuani'] = 0xFF00AAFF, ['Nautilus'] = 0xFF00AAFF, ['Sion'] = 0xFF00AAFF, ['Singed'] = 0xFF00AAFF, ['Skarner'] = 0xFF00AAFF, ['Volibear'] = 0xFF00AAFF, ['Warwick'] = 0xFF00AAFF, ['Yorick'] = 0xFF00AAFF, ['Vladimir'] = 0xFF000000, ['Katarina'] = 0xFF000000, ['Garen'] = 0xFF000000, ['Riven'] = 0xFF000000, ['DrMundo'] = 0xFF000000, ['Zac'] = 0xFF000000, ['Zed'] = 0xFFFFBB00, ['Akali'] = 0xFFFFBB00, ['Kennen'] = 0xFFFFBB00, ['LeeSin'] = 0xFFFFBB00, ['Shen'] = 0xFFFFBB00, ['Mordekaiser'] = 0xFF555555, ['Tryndamere'] = 0xFFFF3300,}
	self.SpecialParTypes = {
		['Aatrox'] = function(unit) return unit.mana == 100 and 0xFFFF3300 or 0xFF555555 end, 
		['Renekton'] = function(unit) return unit.mana > 50 and 0xFFFF3300 or 0xFF555555 end, 
		['Rengar'] = function(unit) return unit.mana < 5 and 0xFF555555 or 0xFFFF3300 end,
		['Rumble'] = function(unit) return unit.mana < 50 and 0xFF555555 or unit.mana < 100 and 0xFFFF9900 end,
		['Shyvana'] = function(unit) return unit.mana == 100 and 0xFFFF3300 or 0xFFFF9900 end,
		['Yasuo'] = function(unit) return unit.mana==unit.maxMana and 0xFFFF3300 or 0xFF555555 end, 
	}
	self:CreateMenu()
	self.Sprite = createSprite('Pewtility/barTemplate.png')
	
	self.Sprite:SetScale(0.3,0.3)
	
	AddDrawCallback(function() self:Draw() end)
	--[[
	self.CallTimers = {}
	AddMsgCallback(function(m,k)
		if m==513 and k==1 then
			if self.Menu.Key then
				local cursor = GetCursorPos()
				for k, v in pairs(self.CallTimers) do
					if cursor.x > v.x and cursor.x < v.x + 44 and cursor.y > v.y and cursor.y < v.y+12 then
						print(k:lower():sub(1,4)..' '..v.text:lower():gsub('summoner', '')..' '..('%d %.2d'):format(v.t/60, v.t%60))
					end
				end
			end
		end
	end)
	--]]
	SendChat('Hello')
end

function SKILLS:CreateMenu()
	MainMenu:addSubMenu('Cooldown Tracker', 'CooldownTracker2')
	self.Menu = MainMenu.CooldownTracker2
	self.Menu:addParam('Enemy', 'Enable Enemy Cooldown Tracker', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Ally', 'Enable Ally Cooldown Tracker', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Scale', 'HP Bar Scale', SCRIPT_PARAM_SLICE, 75, 75, 100)
	self.Menu:addParam('Text', 'Draw Text (Timers)', SCRIPT_PARAM_ONOFF, true)
	--sM:addParam('Key', 'Chat Summoner Cooldowns', SCRIPT_PARAM_ONKEYDOWN, false, ('N'):byte())
end

function SKILLS:Draw()
	local s = self.Menu.Scale
	self.Sprite:SetScale(GetScale2(0.3, s), GetScale2(0.3, s))	
	for _, info in ipairs(self.Heroes) do
		if info.hero.valid and info.hero.visible and not info.hero.dead and ((info.hero.team == myHero.team and self.Menu.Ally) or (info.hero.team ~= myHero.team and self.Menu.Enemy)) then
			local barX, barY = self:BarData(info.hero)
			local barX, barY = barX - GetScale(100, s), barY+GetScale(15, s)
			if barX > -100 and barX < WINDOW_W + 100 and barY > -100 and barY < WINDOW_H + 100 then
				--HP
				local hpMidX = barX + GetScale(61 + (187 * info.hero.health / (info.hero.maxHealth+info.hero.shield)), s)
				local hpY = GetScale(17, s)
				local hpFS = GetScale(24,s)
				DrawLine(barX + GetScale(61,s), barY + hpY, hpMidX, barY + hpY,hpFS,info.hero.team==TEAM_ALLY and 0xFF0088FF or 0xFFFF4400)
				local slopeI=0
				for i=1, info.hero.health*0.01 do
					local x = barX + GetScale(61 + (187 * (100*i) / (info.hero.maxHealth+info.hero.shield)), s)
					local l, w = 12, 1
					if x<barX+GetScale(148,s) then
						l=22
						slopeI = 3
					elseif x<barX+GetScale(156,s) then
						l=l+GetScale(2.25*slopeI,s)
						slopeI = math.max(slopeI - 1, 0)						
					end
					if i==10 or i==20 or i==30 or i==40 or i==50 then
						l, w = 28, 2
					end
					local l = GetScale(l, s)
					DrawLine(x,barY,x,barY+l,w,0xFF000000)
				end
				if info.hero.shield > 0 then
					local shieldMidX = hpMidX + GetScale(187 * info.hero.shield / info.hero.maxHealth, s)
					DrawLine(hpMidX, barY + hpY, shieldMidX,barY + hpY,hpFS,0xFFCCCCCC)
					hpMidX = shieldMidX
				end
				DrawLine(hpMidX, barY + hpY, barX + GetScale(248,s),barY + hpY,hpFS,0xFF000000)
				if self.Menu.Text then
					local hText = ('%u / %u'):format(info.hero.health + info.hero.shield, info.hero.maxHealth)
					local hTextArea = GetTextArea(hText, hpY)
					DrawText(hText,hpY,barX+GetScale(107,s)-(hTextArea.x*0.5),barY+GetScale(18,s)-(hTextArea.y*0.5),0xFFFFFFFF)
				end
				
				--MP
				local mpMid = barX + GetScale(165 + (info.hero.maxMana~=0 and 58 * info.hero.mana / info.hero.maxMana or 0), s)
				local mpColor = self.ParTypes[info.hero.charName] or self.SpecialParTypes[info.hero.charName] and self.SpecialParTypes[info.hero.charName](info.hero) or 0xFF00AAFF
				local mpY = GetScale(33, s)
				DrawLine(barX + GetScale(165, s),barY + mpY, mpMid,barY + mpY,hpY,mpColor)
				DrawLine(mpMid,barY + mpY, barX + GetScale(223, s),barY + mpY,hpY,0xFF000000)
				
				if self.Menu.Text then
					local mText = ('%u / %u'):format(info.hero.mana, info.hero.maxMana)
					local mpFS = GetScale(14, s)
					local mTextArea = GetTextArea(mText, mpFS)
					DrawText(mText,mpFS,barX+GetScale(193-(mTextArea.x*0.5),s),barY+GetScale(34-(mTextArea.y*0.5),s),0xFFFFFFFF)
				end
				
				--Spells
				for i=_Q, _R do
					local d = info.hero:GetSpellData(i)
					local color = d.level == 0 and 0xFF000000 or 0==d.currentCd and 0xFF00AA00 or 0xFFAA0000
					local h = (d.level == 0 or 0==d.currentCd) and 24 or 24*(d.cd~=0 and d.currentCd/d.cd or 0)
					local cdMid = barY+GetScale(29-h, s)
					local cdX = GetScale(28+(i*7.5), s)
					local cdFS = GetScale(7,s)
					DrawLine(barX+cdX,barY+GetScale(29, s),barX+cdX,cdMid,cdFS,color)
					DrawLine(barX+cdX,cdMid,barX+cdX,barY+GetScale(5,s),cdFS,0xFF000000)
				end
				
				self.Sprite:Draw(barX, barY, 255)
				
				--Summoners
				local sumX = GetScale(7.5,s)
				info.sum1:SetScale(GetScale2(0.2,s), GetScale2(0.2,s))
				info.sum1:Draw(barX+sumX, barY+GetScale(4,s), 255)
				local sum1Cd = info.hero:GetSpellData(SUMMONER_1).currentCd
				local sumFS = GetScale(14,s)
				if sum1Cd~=0 then
					local mText = ('%u'):format(sum1Cd)
					local mTextArea = GetTextArea(mText, sumFS)
					DrawText(mText,sumFS,barX+GetScale(13,s)-(mTextArea.x*0.5),barY+sumFS-(mTextArea.y*0.5),0xFFFFFFFF)
				end
				info.sum2:Draw(barX+sumX, barY+GetScale(18,s), 255)
				info.sum2:SetScale(GetScale2(0.2,s), GetScale2(0.2,s))
				local sum2Cd = info.hero:GetSpellData(SUMMONER_2).currentCd
				if sum2Cd~=0 then
					local mText = ('%u'):format(sum2Cd)
					local mTextArea = GetTextArea(mText, sumFS)
					DrawText(mText,sumFS,barX+GetScale(13,s)-(mTextArea.x*0.5),barY+GetScale(24,s)-(mTextArea.y*0.5),0xFFFFFFFF)
				end
				DrawText(info.hero.level..'',GetScale(16,s),barX+GetScale(242,s),barY+GetScale(25,s),0xFFFFFFFF)
			end
		end
	end
end

function SKILLS:BarData(enemy)
	local barPos = GetUnitHPBarPos(enemy)
	local barOff = GetUnitHPBarOffset(enemy)
	return barPos.x + ((self.xOffsets[enemy.charName] or 0) * 140) - 38, barPos.y + (barOff.y * 53) - 22
end

class 'TIMERS'

function TIMERS:__init()
	self.map = GetGame2().Map.Name
	self.Packets = GetGameVersion():sub(1,4) == '5.23' and {
		['Jungle'] = { ['Header'] = 0x0031, ['campPos'] = 12, ['idPos'] = 7,},
		['Inhibitor'] = { ['Header'] = 0x005B, ['pos'] = 2, },  --pick the one that is size 23
		['Dragon'] = { ['pos'] =  Vector(9866, 60, 4414), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  },
		['Baron'] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), },
		['SummonerRift'] = {
			[0x7A] = { ['pos'] =  Vector(3850, 60, 7880), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3850, 60, 7880)),  }, --Blue Side Blue Buff
			[0x05] = { ['pos'] =  Vector(3800, 60, 6500), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(3800, 60, 6500)),  }, --Blue Side Wolves
			[0x32] = { ['pos'] =  Vector(7000, 60, 5400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7000, 60, 5400)),  }, --Blue Side Raptors
			[0xF6] = { ['pos'] =  Vector(7800, 60, 4000), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7800, 60, 4000)),  }, --Blue Side Red Buff
			[0x5E] = { ['pos'] =  Vector(8400, 60, 2700), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(8400, 60, 2700)),  }, --Blue Side Krugs
			[0x2E] = { ['pos'] =  Vector(9866, 60, 4414), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  }, --Dragon
			[0x71] = { ['pos'] = Vector(10950, 60, 7030), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(10950, 60, 7030)), }, --Red Side Blue Buff
			[0xB1] = { ['pos'] = Vector(11000, 60, 8400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(11000, 60, 8400)), }, --Red Side Wolves
			[0xBB] = { ['pos'] =  Vector(7850, 60, 9500), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7850, 60, 9500)),  }, --Red Side Raptors
			[0xF3] = { ['pos'] = Vector(7100, 60, 10900), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7100, 60, 10900)), }, --Red Side Red Buff
			[0xFB] = { ['pos'] = Vector(6400, 60, 12250), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(6400, 60, 12250)), }, --Red Side Krugs
			[0xD6] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), }, --Baron
			[0x2D] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), ['isHerald'] = true, }, --Rift Herald
			[0xCB] = { ['pos'] = Vector(2200, 60, 8500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(2200, 60, 8500)),  }, --Blue Side Gromp
			[0x8A] = { ['pos'] = Vector(12600, 60, 6400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(12600, 60, 6400)), }, --Red Side Gromp
			[0xF0] = { ['pos'] = Vector(10500, 60, 5170), ['time'] = 180, ['mapPos'] = GetMinimap(Vector(10500, 60, 5170)), }, --Dragon Crab
			[0xC0] = { ['pos'] = Vector(4400, 60, 9600),  ['time'] = 180, ['mapPos'] = GetMinimap(Vector(4400, 60, 9600)),  }, --Baron Crab
			[0xFFD23C3E] = { ['pos'] = Vector(1170, 90, 3570),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(1170, 91, 3570)),   }, --Blue Top Inhibitor
			[0xFF4A20F1] = { ['pos'] = Vector(3203, 92, 3208),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3203, 92, 3208)),   }, --Blue Middle Inhibitor
			[0xFF9303E1] = { ['pos'] = Vector(3452, 89, 1236),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3452, 89, 1236)),   }, --Blue Bottom Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(11261, 88, 13676), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11261, 88, 13676)), }, --Red Top Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(11598, 89, 11667), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11598, 89, 11667)), }, --Red Middle Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13604, 89, 11316), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(13604, 89, 11316)), }, --Red Bottom Inhibitor			
		},
		['TwistedTreeline'] = {
			[0x7A] = { ['pos'] =  Vector(4414, 60, 5774), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(4414, 60, 5774)),  },
			[0x05] = { ['pos'] =  Vector(5088, 60, 8065), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(5088, 60, 8065)),  },
			[0x32] = { ['pos'] =  Vector(6148, 60, 5993), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(6148, 60, 5993)),  },
			[0xF6] = { ['pos'] = Vector(11008, 60, 5775), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(11008, 60, 5775)), },
			[0x5E] = { ['pos'] = Vector(10341, 60, 8084), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(10341, 60, 8084)), },
			[0x2E] = { ['pos'] =  Vector(9239, 60, 6022), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(9239, 60, 6022)),  },
			[0x71] = { ['pos'] =  Vector(7711, 60, 6722), ['time'] =  90, ['mapPos'] = GetMinimap(Vector(7711, 60, 6722)),  },
			[0xB1] = { ['pos'] = Vector(7711, 60, 10080), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(7711, 60, 10080)), },
			[0xFF9303E1] = { ['pos'] = Vector(2126, 11, 6146),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2126, 11, 6146)),   }, --Left Bottom Inhibitor
			[0xFFD23C3E] = { ['pos'] = Vector(2146, 11, 8420),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2146, 11, 8420)),   }, --Left Top Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(13285, 17, 6124),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13285, 17, 6124)),  }, --Right Bottom Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13275, 17, 8416),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13275, 17, 8416)),  }, --Right Top Inhibitor		
		},
		['HowlingAbyss'] = {
			[0x7A] = { ['pos'] = Vector(7582, -100, 6785), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(7582, -100, 6785)), },
			[0x05] = { ['pos'] = Vector(5929, -100, 5190), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(5929, -100, 5190)), },
			[0x32] = { ['pos'] = Vector(8893, -100, 7889), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(8893, -100, 7889)), },
			[0xF6] = { ['pos'] = Vector(4790, -100, 3934), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(4790, -100, 3934)), },
			[0xFF4A20F1] = { ['pos'] = Vector(3110, -201, 3189), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3110, -201, 3189)), }, --Bottom Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(9689, -190, 9524), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(9689, -190, 9524)), }, --Top Inhibitor			
		},
		['ButchersBridge'] = {
			[0x7A] = { ['pos'] = Vector(7582, -100, 6785), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(7582, -100, 6785)), },
			[0x05] = { ['pos'] = Vector(5929, -100, 5190), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(5929, -100, 5190)), },
			[0x32] = { ['pos'] = Vector(8893, -100, 7889), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(8893, -100, 7889)), },
			[0xF6] = { ['pos'] = Vector(4790, -100, 3934), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(4790, -100, 3934)), },
			[0xFF4A20F1] = { ['pos'] = Vector(3110, -201, 3189), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3110, -201, 3189)), }, --Bottom Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(9689, -190, 9524), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(9689, -190, 9524)), }, --Top Inhibitor			
		},
		['CrystalScar'] = {
			[0xD1] = { ['pos'] = Vector(4948, -100, 9329),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(4948, -100, 9329)),  }, 
			[0x46] = { ['pos'] = Vector(8972, -100, 9329),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(8972, -100, 9329)),  }, 
			[0xE5] = { ['pos'] = Vector(6949, -100, 2855),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(6949, -100, 2855)),  },
			[0xFA] = { ['pos'] = Vector(6947, -100, 12116), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(6947, -100, 12116)), },
			[0x82] = { ['pos'] = Vector(12881, -100, 8294), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(12881, -100, 8294)), },
			[0x0F] = { ['pos'] = Vector(10242, -100, 1519), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(10242, -100, 1519)), },
			[0xA6] = { ['pos'] = Vector(3639, -100, 1490),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(3639, -100, 1490)),  },
			[0x68] = { ['pos'] = Vector(1027, -100, 8288),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(1027, -100, 8288)),  },
			[0x6B] = { ['pos'] = Vector(4324, -100, 5500),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(4324, -100, 5500)),  },
			[0x9A] = { ['pos'] = Vector(9573, -100, 5530),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(9573, -100, 5530)),  },			
		},
	} or GetGameVersion():sub(1,4) == '5.24' and {
		['Jungle'] = { ['Header'] = 0x0015, ['campPos'] = 20, ['idPos'] = 8,},
		['Inhibitor'] = { ['Header'] = 0x004F, ['pos'] = 2, },  --pick the one that is size 23
		['Dragon'] = { ['pos'] =  Vector(9866, 60, 4414), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  },
		['Baron'] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), }, 
		['SummonerRift'] = {
			[0x2A] = { ['pos'] = Vector(3850, 60, 7880),  ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3850, 60, 7880)),  }, --Blue Side Blue Buff
			[0x2B] = { ['pos'] = Vector(3800, 60, 6500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(3800, 60, 6500)),  }, --Blue Side Wolves
			[0x2C] = { ['pos'] = Vector(7000, 60, 5400),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7000, 60, 5400)),  }, --Blue Side Raptors
			[0x2D] = { ['pos'] = Vector(7800, 60, 4000),  ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7800, 60, 4000)),  }, --Blue Side Red Buff
			[0x2E] = { ['pos'] = Vector(8400, 60, 2700),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(8400, 60, 2700)),  }, --Blue Side Krugs
			[0x2F] = { ['pos'] = Vector(9866, 60, 4414),  ['time'] = 360, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  }, --Dragon
			[0x30] = { ['pos'] = Vector(10950, 60, 7030), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(10950, 60, 7030)), }, --Red Side Blue Buff
			[0x25] = { ['pos'] = Vector(11000, 60, 8400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(11000, 60, 8400)), }, --Red Side Wolves	
			[0x26] = { ['pos'] = Vector(7850, 60, 9500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7850, 60, 9500)),  }, --Red Side Raptors
			[0x27] = { ['pos'] = Vector(7100, 60, 10900), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7100, 60, 10900)), }, --Red Side Red Buff
			[0x28] = { ['pos'] = Vector(6400, 60, 12250), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(6400, 60, 12250)), }, --Red Side Krugs
			[0x41] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), }, --Baron
			[0x3A] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), ['isHerald'] = true, }, --Rift Herald
			[0x42] = { ['pos'] = Vector(2200, 60, 8500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(2200, 60, 8500)),  }, --Blue Side Gromp
			[0x43] = { ['pos'] = Vector(12600, 60, 6400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(12600, 60, 6400)), }, --Red Side Gromp
			[0x44] = { ['pos'] = Vector(10500, 60, 5170), ['time'] = 180, ['mapPos'] = GetMinimap(Vector(10500, 60, 5170)), }, --Dragon Crab
			[0x39] = { ['pos'] = Vector(4400, 60, 9600),  ['time'] = 180, ['mapPos'] = GetMinimap(Vector(4400, 60, 9600)),  }, --Baron Crab
			[0xFFD23C3E] = { ['pos'] = Vector(1170, 90, 3570),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(1170, 91, 3570)),   }, --Blue Top Inhibitor
			[0xFF4A20F1] = { ['pos'] = Vector(3203, 92, 3208),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3203, 92, 3208)),   }, --Blue Middle Inhibitor
			[0xFF9303E1] = { ['pos'] = Vector(3452, 89, 1236),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3452, 89, 1236)),   }, --Blue Bottom Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(11261, 88, 13676), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11261, 88, 13676)), }, --Red Top Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(11598, 89, 11667), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11598, 89, 11667)), }, --Red Middle Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13604, 89, 11316), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(13604, 89, 11316)), }, --Red Bottom Inhibitor				
		},
		['TwistedTreeline'] = {
			[0x2A] = { ['pos'] =  Vector(4414, 60, 5774), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(4414, 60, 5774)),  },
			[0x2B] = { ['pos'] =  Vector(5088, 60, 8065), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(5088, 60, 8065)),  },
			[0x2C] = { ['pos'] =  Vector(6148, 60, 5993), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(6148, 60, 5993)),  },
			[0x2D] = { ['pos'] = Vector(11008, 60, 5775), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(11008, 60, 5775)), },
			[0x2E] = { ['pos'] = Vector(10341, 60, 8084), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(10341, 60, 8084)), },
			[0x2F] = { ['pos'] =  Vector(9239, 60, 6022), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(9239, 60, 6022)),  },
			[0x30] = { ['pos'] =  Vector(7711, 60, 6722), ['time'] =  90, ['mapPos'] = GetMinimap(Vector(7711, 60, 6722)),  },
			[0x25] = { ['pos'] = Vector(7711, 60, 10080), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7711, 60, 10080)), },
			[0xFF9303E1] = { ['pos'] = Vector(2126, 11, 6146),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2126, 11, 6146)),   }, --Left Bottom Inhibitor
			[0xFFD23C3E] = { ['pos'] = Vector(2146, 11, 8420),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2146, 11, 8420)),   }, --Left Top Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(13285, 17, 6124),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13285, 17, 6124)),  }, --Right Bottom Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13275, 17, 8416),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13275, 17, 8416)),  }, --Right Top Inhibitor			
		},
		['HowlingAbyss'] = {
			[0x2A] = { ['pos'] = Vector(7582, -100, 6785), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(7582, -100, 6785)), },
			[0x2B] = { ['pos'] = Vector(5929, -100, 5190), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(5929, -100, 5190)), },
			[0x2C] = { ['pos'] = Vector(8893, -100, 7889), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(8893, -100, 7889)), },
			[0x2D] = { ['pos'] = Vector(4790, -100, 3934), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(4790, -100, 3934)), },
			[0xFF4A20F1] = { ['pos'] = Vector(3110, -201, 3189), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3110, -201, 3189)), }, --Bottom Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(9689, -190, 9524), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(9689, -190, 9524)), }, --Top Inhibitor			
		},
		['ButchersBridge'] = {
			[0x2A] = { ['pos'] = Vector(7582, -100, 6785), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(7582, -100, 6785)), },
			[0x2B] = { ['pos'] = Vector(5929, -100, 5190), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(5929, -100, 5190)), },
			[0x2C] = { ['pos'] = Vector(8893, -100, 7889), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(8893, -100, 7889)), },
			[0x2D] = { ['pos'] = Vector(4790, -100, 3934), ['time'] =  40, ['mapPos'] = GetMinimap(Vector(4790, -100, 3934)), },
			[0xFF4A20F1] = { ['pos'] = Vector(3110, -201, 3189), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3110, -201, 3189)), }, --Bottom Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(9689, -190, 9524), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(9689, -190, 9524)), }, --Top Inhibitor			
		},
		['CrystalScar'] = {
			[0x8D] = { ['pos'] = Vector(4948, -100, 9329),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(4948, -100, 9329)),  }, 
			[0x8E] = { ['pos'] = Vector(8972, -100, 9329),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(8972, -100, 9329)),  }, 
			[0x99] = { ['pos'] = Vector(6949, -100, 2855),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(6949, -100, 2855)),  },
			[0x71] = { ['pos'] = Vector(6947, -100, 12116), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(6947, -100, 12116)), },
			[0x72] = { ['pos'] = Vector(12881, -100, 8294), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(12881, -100, 8294)), },
			[0x86] = { ['pos'] = Vector(10242, -100, 1519), ['time'] = 30, ['mapPos'] = GetMinimap(Vector(10242, -100, 1519)), },
			[0x87] = { ['pos'] = Vector(3639, -100, 1490),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(3639, -100, 1490)),  },
			[0x88] = { ['pos'] = Vector(1027, -100, 8288),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(1027, -100, 8288)),  },
			[0x73] = { ['pos'] = Vector(4324, -100, 5500),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(4324, -100, 5500)),  },
			[0x74] = { ['pos'] = Vector(9573, -100, 5530),  ['time'] = 30, ['mapPos'] = GetMinimap(Vector(9573, -100, 5530)),  },			
		},
	}
	self.activeTimers = {}
	self.checkLastDragon = false
	self.checkLastBaron = false
	self.tM = self:Menu()
	if not self.Packets then
		Print('Object Timers packets are outdated!!', true)
		return
	end
	AddDrawCallback(function() self:Draw() end)
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
	AddDeleteObjCallback(function(o) self:DeleteObj(o) end)
end

function TIMERS:Menu()
	MainMenu:addSubMenu('Object Timers', 'ObjectTimers')
	local tM = MainMenu.ObjectTimers
	tM:addParam('draw', 'Enable Object Timers', SCRIPT_PARAM_ONOFF, true)
	tM:addParam('type', 'Timer Type', SCRIPT_PARAM_LIST, 1, { 'Seconds', 'Minutes' })
	tM:addParam('size', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	tM:addParam('RGB', 'Text Color', SCRIPT_PARAM_COLOR, {255,255,255,255})	
	tM:addParam('mapsize', 'Minimap Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	tM:addParam('mapRGB', 'Minimap Text Color', SCRIPT_PARAM_COLOR, {255,255,255,255})
	tM:addParam('modKey', 'Modifier Key(Default: Alt)', SCRIPT_PARAM_ONKEYDOWN, false, 18)
	tM:addParam('', 'ModKey+LeftClick a camp to start a timer.', SCRIPT_PARAM_INFO, '')
	return tM
end

function TIMERS:Draw()
	-- for k, v in pairs(self.Packets.SummonerRift) do
		-- DrawText3D(('0x%02X'):format(k),v.pos.x,v.pos.y,v.pos.z,22,ARGB(255,255,255,255))
	-- end
	
	if not self.tM.draw then return end
	for i, info in ipairs(self.activeTimers) do
		if not info.isHerald or GetInGameTimer() < 1195 then
			local timer = info.spawnTime-clock()
			local text = (self.tM.type == 1) and ('%d'):format(timer) or ('%d:%.2d'):format(timer/60, timer%60)
			DrawText3D(text, info.pos.x, info.pos.y, (info.pos.z-50), self.tM.size, ARGB(self.tM.RGB[1], self.tM.RGB[2], self.tM.RGB[3], self.tM.RGB[4]))
			DrawText(text, self.tM.mapsize, info.minimap.x-5, info.minimap.y-5, ARGB(self.tM.mapRGB[1], self.tM.mapRGB[2], self.tM.mapRGB[3], self.tM.mapRGB[4]))
			if timer <= 1 then 
				table.remove(self.activeTimers,i)
			end
		end
	end
end

function TIMERS:DeleteObj(o)
	if o.valid then
		if o.name == 'SRU_JungleBuff_Dragon_Activation_Buf.troy' then
			for i, timer in ipairs(self.activeTimers) do
				if timer.pos == self.Packets.Dragon.pos then
					table.remove(self.activeTimers, i)
				end
			end
			self.activeTimers[#self.activeTimers + 1] = {
				['spawnTime'] = clock()+self.Packets.Dragon.time, 
				['pos'] = self.Packets.Dragon.pos, 
				['minimap'] = self.Packets.Dragon.mapPos,
				['valid'] = true,
			}			
		elseif o.name == 'SRU_Baron_Death.troy' then
			for i, timer in ipairs(self.activeTimers) do
				if timer.pos == self.Packets.Baron.pos then
					table.remove(self.activeTimers, i)
				end
			end
			self.activeTimers[#self.activeTimers + 1] = {
				['spawnTime'] = clock()+self.Packets.Baron.time, 
				['pos'] = self.Packets.Baron.pos, 
				['minimap'] = self.Packets.Baron.mapPos,
				['valid'] = true,
			}			
		end
	end
end

function TIMERS:RecvPacket(p)
	if p.header == self.Packets.Jungle.Header then
		p.pos = self.Packets.Jungle.campPos
		local camp = p:Decode1()
		-- print(('0x%02X'):format(camp))
		
		if self.Packets[self.map][camp] then
			p.pos = self.Packets.Jungle.idPos
			local bytes = {}
			for i=4, 1, -1 do
				bytes[i] = IDBytes[p:Decode1()]
			end
			local o = objManager:GetObjectByNetworkId(DwordToFloat(bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))))
			if o or self.Packets[self.map][camp].isGlobal then
				for i, timer in ipairs(self.activeTimers) do
					if timer.pos == self.Packets[self.map][camp].pos then
						table.remove(self.activeTimers, i)
					end
				end
				self.activeTimers[#self.activeTimers + 1] = {
					['spawnTime'] = clock()+self.Packets[self.map][camp].time, 
					['pos'] = self.Packets[self.map][camp].pos, 
					['minimap'] = self.Packets[self.map][camp].mapPos,
					['isHerald'] = self.Packets[self.map][camp].isHerald,
					['valid'] = true,
				}
			end
		end
		return
	end
	if p.header == self.Packets.Inhibitor.Header then
		p.pos=self.Packets.Inhibitor.pos
		local inhib = p:Decode4()
		if self.Packets[self.map][inhib] then
			self.activeTimers[#self.activeTimers + 1] = {
				['spawnTime'] = clock()+self.Packets[self.map][inhib].time, 
				['pos'] = self.Packets[self.map][inhib].pos, 
				['minimap'] = self.Packets[self.map][inhib].mapPos,
			}
		end
		return
	end
end

function TIMERS:WndMsg(m,k)
	if m == WM_LBUTTONDOWN and IsKeyDown(self.tM._param[7].key) then --17 ctrl
		local cP = GetCursorPos()
		for _, info in pairs(self.Packets[self.map]) do
			if _ <= 0xFF then
				local miniMap = info.mapPos
				if abs(cP.x-miniMap.x) < 17 and abs(cP.y-miniMap.y) < 17 then
					for i, timer in ipairs(self.activeTimers) do
						if timer.pos == info.pos then
							if timer.valid then return end
							table.remove(self.activeTimers, i)					
						end
					end
					self.activeTimers[#self.activeTimers + 1] = {
						['spawnTime'] = clock()+info.time, 
						['pos'] = info.pos, 
						['minimap'] = info.mapPos,
						['valid'] = false,
					}
					return
				end
			end
		end
	end
end

class 'OTHER'

function OTHER:__init()
	self.Turrets = {}
	for i=1, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj and obj.valid and obj.type == 'obj_AI_Turret' and obj.name:find('Shrine') == nil then
			self.Turrets[#self.Turrets+1] = obj
		end
	end
	self.TurretRange = 850 + myHero.boundingRadius
	self.Enemies = {}
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.team == TEAM_ENEMY then
			self.Enemies[#self.Enemies+1] = h	
		end
	end
	self:CreateMenu()
	AddDrawCallback(function() self:Draw() end)
	-- print(GetGameVersion())
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.team == TEAM_ALLY and not h.isMe and h.charName == 'Thresh' then
			self.Packets = GetGameVersion():sub(1, 10) == '5.23.0.247' and {
				['Header'] = 0x00116,
				['vTable'] = 0xDF9520,
				['Hash'] = 0x04000000,				
			} or GetGameVersion():sub(1, 10) == '5.24.0.249' and {
				['Header'] = 0x00B0,
				['vTable'] = 0xE98380,
				['Hash'] = 0x03000000,
			} or GetGameVersion():sub(1, 10) == '5.21.0.297' and {
				['Header'] = 0x002C,
				['vTable'] = 0xDD9364,
				['Hash'] = 0xE0C006A0,				
			} or GetGameVersion():sub(1, 10) == '5.22.0.289' and {
				['Header'] = 0x012C,
				['vTable'] = 0xEC2160,
				['Hash'] = 0x05000000,				
			} or GetGameVersion():sub(1, 10) == '5.23.0.239' and {
				['Header'] = 0x0116,
				['vTable'] = 0xDFE390,
				['Hash'] = 0x05000000,				
			}
			if not self.Packets then
				Print('Thresh Lantern packets are outdated!!', true)
				return
			end
			Print('Ally Thresh detected, AutoLantern loaded')
			self.Menu:addParam('LanternKey', 'Thresh Lantern Key', SCRIPT_PARAM_ONKEYDOWN, false, 32)
			self.Menu:addParam('LanternHealth', 'Lantern if Health Less than (%)', SCRIPT_PARAM_SLICE, 25, 0, 100)
			self.Menu:addParam('LanternDelay', 'Lantern Humanizer Delay (ms)', SCRIPT_PARAM_SLICE, 250, 0, 1000)
			self.ReversedBytes = {}
			for i=0, 255 do self.ReversedBytes[IDBytes[i]] = i end
			self.LanternPacket = CLoLPacket(self.Packets.Header)
			self.LanternPacket.vTable = self.Packets.vTable
			self.LanternPacket:EncodeF(myHero.networkID)
			self.LanternPacket:Encode4(0x00000000)
			self.LanternPacket:Encode4(self.Packets.Hash)
			self.EncodePacket = CLoLPacket(0x0001)
			AddCreateObjCallback(function(o)
				if o.valid and o.team == TEAM_ALLY and o.name == 'ThreshLantern' then
					self.Lantern = o
					self.LanternDelay = clock() + (self.Menu.LanternDelay / 1000)
				end
			end)
			AddTickCallback(function()
				if self.Lantern and self.Lantern.valid and GetDistanceSqr(self.Lantern) < 105625 and self.LanternDelay < clock() then
					if self.Menu.LanternKey or (myHero.health * 100) / myHero.maxHealth <= self.Menu.LanternHealth then
						self.EncodePacket.pos=2
						self.EncodePacket:EncodeF(self.Lantern.networkID)
						self.EncodePacket.pos=2
						for i=1, 4 do self.LanternPacket:Replace1(self.ReversedBytes[self.EncodePacket:Decode1()], 5+i) end
						SendPacket(self.LanternPacket)
					end
				end
			end)
			break
		end
	end
end

function OTHER:CreateMenu()
	MainMenu:addSubMenu('Other Stuff', 'Other')
	self.Menu = MainMenu.Other
	self.Menu:addParam('path', 'Draw Enemy Paths', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('type', 'Path Draw Type', SCRIPT_PARAM_LIST, 1, { 'Lines', 'End Position', })
	self.Menu:addParam('turret', 'Draw Turret Ranges', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('AllyTurret', 'Draw Ally Turret Ranges', SCRIPT_PARAM_ONOFF, false)
end

function OTHER:Draw()
	if self.Menu.turret then
		for i, turret in ipairs(self.Turrets) do
			if turret and turret.valid and not turret.dead then
				local d = GetDistance(turret)
				if d < self.TurretRange+500 then
					local t = d-self.TurretRange
					if turret.team == TEAM_ENEMY then
						DrawCircle3D(turret.x,turret.y,turret.z,self.TurretRange,1, ARGB(t>0 and 255 * ((500-t) / 500) or 255, 255, 0, 0))
					elseif self.Menu.AllyTurret then
						local p = t>0 and ((500-t) / 500) or 1
						DrawCircle3D(turret.x,turret.y,turret.z,self.TurretRange,1, ARGB(t>0 and 255 * ((500-t) / 500) or 255, 255, 120, 120))
					end
				end
			else
				table.remove(self.Turrets, i)
			end
		end
	end	
	if self.Menu.path then
		for _, e in ipairs(self.Enemies) do
			if e and e.valid and not e.dead and e.visible and e.hasMovePath then
				local points = {}
				local eC = WorldToScreen(D3DXVECTOR3(e.x, 50, e.z))
				points[1] = D3DXVECTOR2(eC.x, eC.y)
				local pathLength = 0
				for i=e.pathIndex, e.pathCount do
					local p1 = e:GetPath(i)
					local p2 = e:GetPath(i-1)
					if p1 then
						local c = WorldToScreen(D3DXVECTOR3(p1.x, 50, p1.z))
						points[#points + 1] = D3DXVECTOR2(c.x, c.y)
						if p2 then
							if (i==e.pathIndex) then
								pathLength = pathLength + GetDistanceSqr(p1, e.pos)
							else
								pathLength = pathLength + GetDistanceSqr(p1, p2)
							end
						end
					end
				end			
				if self.Menu.type == 1 then
					local draw = false
					for i, point in ipairs(points) do
						if point.x > 0 and point.x < WINDOW_W and point.y > 0 and point.y < WINDOW_H then
							draw = true
							break
						end
					end
					if draw then
						DrawLines2(points, 2, COLOR_RED)
						local x, y = points[#points].x, points[#points].y
						DrawText(('%.2f'):format(sqrt(pathLength)/(e.ms))..'\n'..e.charName,12,x,y,COLOR_WHITE)
					end
				else
					local x, y = points[#points].x, points[#points].y
					if x > 0 and x < WINDOW_W and y > 0 and y < WINDOW_H then
						DrawText(('%.2f'):format(sqrt(pathLength)/(e.ms))..'\n'..e.charName,12,x,y,COLOR_WHITE)
					end
				end
			end
		end
	end
end

class 'TRINKET'

function TRINKET:__init()
	if GetGame().map.shortName ~= 'summonerRift' then return end
	self.trinketID = {
		['TrinketTotemLvl1'] = 3340,
		['TrinketSweeperLvl1'] = 3341,
		['TrinketOrbLvl3'] = 3363,
		['TrinketSweeperLvl3'] = 3364,
	}
	self.Packets = GetGameVersion():sub(1, 10) == '5.23.0.247' and {
		['Send'] = { ['Header'] = 0x0154, ['vTable'] = 0xDFBFCC, ['hash'] = 0xB1BC0000, },
		['Recv'] = { ['Header'] = 0x00A0, ['pos'] = 2, ['pos2'] = 13, },
	} or GetGameVersion():sub(1, 10) == '5.24.0.249' and {
		['Send'] = { ['Header'] = 0x00D1, ['vTable'] = 0xE97ABC, ['hash'] = 0x00000000, },
		['Recv'] = { ['Header'] = 0x007B, ['pos'] = 2, ['pos2'] = 14, },
	} or GetGameVersion():sub(1, 10) == '5.21.0.297' and {
		['Send'] = { ['Header'] = 0x011F, ['vTable'] = 0xDD25B4, ['hash'] = 0x00000000, },
		['Recv'] = { ['Header'] = 0x0084, ['pos'] = 2, ['pos2'] = 12, },
	} or GetGameVersion():sub(1, 10) == '5.22.0.289' and {
		['Send'] = { ['Header'] = 0x0121, ['vTable'] = 0xEE7E24, ['hash'] = 0x00000DFD, },
		['Recv'] = { ['Header'] = 0x00A6, ['pos'] = 2, ['pos2'] = 11, },
	} or GetGameVersion():sub(1, 10) == '5.23.0.239' and {
		['Send'] = { ['Header'] = 0x0154, ['vTable'] = 0xE3F108, ['hash'] = 0xB1BC0000, },
		['Recv'] = { ['Header'] = 0x00A0, ['pos'] = 2, ['pos2'] = 13, },
	}
	if not self.Packets then 
		Print('Trinket Utiltity packets are outdated!!', true)
		return
	end
	self.trM = self:Menu()
	if self.trM.ward and clock()/60 < 1.1 then 
		DelayAction(
		function() 
			if myHero:GetSpellData(ITEM_7).name == '' then
				self:BuyItem(3339+self.trM.type) 
			end
		end, 5)
	end
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
end

function TRINKET:Menu()
	MainMenu:addSubMenu('Trinket Helper', 'Trinket')
	local trM = MainMenu.Trinket
	trM:addParam('ward', 'Buy Trinket on Game Start', SCRIPT_PARAM_ONOFF, true)
	trM:addParam('type', 'Trinket on Game Start', SCRIPT_PARAM_LIST, 1, { 'Ward Totem', 'Sweeper' })
	trM:addParam('sweeper', 'Enable Sweeper Purchase', SCRIPT_PARAM_ONOFF, true)
	trM:addParam('timer', 'Buy Sweeper after x Minutes', SCRIPT_PARAM_SLICE, 10, 1, 60)
	trM:addParam('upgrade', 'Upgrade Trinket after Lvl 9', SCRIPT_PARAM_ONOFF, true)
	trM:addParam('sightstone', 'Buy Sweeper on Sightstone', SCRIPT_PARAM_ONOFF, true)
	return trM
end

function TRINKET:BuyItem(id)
	local rB = {}
	for i=0, 255 do rB[IDBytes[i]] = i end
	local p = CLoLPacket(self.Packets.Send.Header)
	p.vTable = self.Packets.Send.vTable
	p:EncodeF(myHero.networkID)
	local b1 = lshift(band(rB[band(rshift(band(id,0xFFFF),24),0xFF)],0xFF),24)
	local b2 = lshift(band(rB[band(rshift(band(id,0xFFFFFF),16),0xFF)],0xFF),16)
	local b3 = lshift(band(rB[band(rshift(band(id,0xFFFFFFFF),8),0xFF)],0xFF),8)
	local b4 = band(rB[band(id ,0xFF)],0xFF)
	p:Encode4(bxor(b1,b2,b3,b4))
	p:Encode4(self.Packets.Send.hash)
	SendPacket(p)
end

function TRINKET:RecvPacket(p)
	if p.header == self.Packets.Recv.Header then
		p.pos=self.Packets.Recv.pos
		if p:DecodeF() == myHero.networkID then
			p.pos=self.Packets.Recv.pos2
			local bytes = {}
			for i=4, 1, -1 do
				bytes[i] = IDBytes[p:Decode1()]
			end
			local itemID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
			local currentTrinket = myHero:GetSpellData(ITEM_7)
			if not currentTrinket then return end
			local gameTime = clock()/60
			if self.trM.sweeper and self.trinketID[currentTrinket.name] == 3340 and gameTime >= self.trM.timer then
				self:BuyItem(3341)
				return
			end
			if self.trM.sightstone and itemID == 2049 then
				if self.trinketID[currentTrinket.name] == 3340 then
					self:BuyItem(3341)
					return
				end
			end
			if myHero.level >= 9 and self.trM.upgrade then
				if currentTrinket.name == 'TrinketTotemLvl1' then
					self:BuyItem(3363)
				elseif currentTrinket.name == 'TrinketSweeperLvl1' then
					self:BuyItem(3364)
				end
			end
		end
	end
end

class 'MAGWARDS'

function MAGWARDS:__init()
	if GetGame().map.shortName ~= 'summonerRift' then return end	
	self:CreateMenu()
	self.Positions = {
		{['x']=6550, ['y']=49, ['z']=4789},
		{['x']=6609, ['y']=51, ['z']=3081},
		{['x']=5476, ['y']=52, ['z']=3535},
		{['x']=7890, ['y']=53, ['z']=3455},
		{['x']=8591, ['y']=53, ['z']=4877},
		{['x']=10446, ['y']=52, ['z']=3142},
		{['x']=11720, ['y']=-70, ['z']=4074},
		{['x']=10111, ['y']=-71, ['z']=4734},
		{['x']=10547, ['y']=-62, ['z']=5100},
		{['x']=9315, ['y']=-71, ['z']=5725},
		{['x']=10016, ['y']=49, ['z']=6608},
		{['x']=10079, ['y']=52, ['z']=7754},
		{['x']=11615, ['y']=52, ['z']=7057},
		{['x']=4692, ['y']=51, ['z']=7210},
		{['x']=3248, ['y']=52, ['z']=7843},
		{['x']=2875, ['y']=52, ['z']=8380},
		{['x']=11934, ['y']=52, ['z']=6572},
		{['x']=4419, ['y']=57, ['z']=11763},
		{['x']=6266, ['y']=55, ['z']=10118},
		{['x']=7041, ['y']=55, ['z']=11438},
		{['x']=7794, ['y']=57, ['z']=11880},
		{['x']=8281, ['y']=57, ['z']=11813},
		{['x']=9406, ['y']=53, ['z']=11418},
		{['x']=9136, ['y']=55, ['z']=11335},
		{['x']=8120, ['y']=53, ['z']=8106},
		{['x']=6576, ['y']=52, ['z']=6714},
		{['x']=5329, ['y']=51, ['z']=5593},
		{['x']=5763, ['y']=51, ['z']=1264},
		{['x']=4792, ['y']=-71, ['z']=10233},
		{['x']=4279, ['y']=-69, ['z']=9795},
		{['x']=8222, ['y']=50, ['z']=10218},
		{['x']=4835, ['y']=33, ['z']=8363},	
		{['x']=5364, ['y']=-71, ['z']=9139},	
		{['x']=3148, ['y']=-66, ['z']=10820},	
	}
	self.Jumps = {
		{
			['cast'] = {['x']=2003, ['y']=53, ['z']=10326},
			['pos'] = {['x']=1770, ['y']=52, ['z']=10851},
		},
		{
			['cast'] = {['x']=4006, ['y']=41, ['z']=11907},
			['pos'] = {['x']=3424, ['y']=-62, ['z']=11767},
		},
		{
			['cast'] = {['x']=10699, ['y']=48, ['z']=3036},
			['pos'] = {['x']=11252, ['y']=-68, ['z']=3248},
		},
		{
			['cast'] = {['x']=4600, ['y']=50, ['z']=11265},
			['pos'] = {['x']=4824, ['y']=-71, ['z']=10906},
		},
		{
			['cast'] = {['x']=8148, ['y']=52, ['z']=3426},
			['pos'] = {['x']=8372, ['y']=52, ['z']=2908},
		},
		{
			['cast'] = {['x']=8378, ['y']=51, ['z']=4598},
			['pos'] = {['x']=8008, ['y']=54, ['z']=4270},
		},
		{
			['cast'] = {['x']=5185, ['y']=51, ['z']=6783},
			['pos'] = {['x']=5424, ['y']=52, ['z']=6308},
		},
		{
			['cast'] = {['x']=4980, ['y']=51, ['z']=7168},
			['pos'] = {['x']=5392, ['y']=52, ['z']=7496},
		},
		{
			['cast'] = {['x']=6436, ['y']=52, ['z']=10387},
			['pos'] = {['x']=6874, ['y']=56, ['z']=10656},
		},
		{
			['cast'] = {['x']=9712, ['y']=52, ['z']=7756},
			['pos'] = {['x']=9186, ['y']=53, ['z']=7560},
		},
		{
			['cast'] = {['x']=12119, ['y']=-71, ['z']=4189},
			['pos'] = {['x']=12322, ['y']=52, ['z']=4558},
		},
		{
			['cast'] = {['x']=12777, ['y']=52, ['z']=4740},
			['pos'] = {['x']=13069, ['y']=52, ['z']=4237},
		},
		{
			['cast'] = {['x']=6690, ['y']=54, ['z']=11495},
			['pos'] = {['x']=6524, ['y']=57, ['z']=12006},
		},
		{
			['cast'] = {['x']=9630, ['y']=74, ['z']=8128},
			['pos'] = {['x']=9322, ['y']=52, ['z']=8556},
		},
	}
	self.Wards = {
		['sightward'] = true, 
		['VisionWard'] = true,
		['ItemGhostWard'] = true, 
		['TrinketTotemLvl2'] =  true,
		['TrinketTotemLvl1'] = true, 
		['TrinketTotemLvl3'] = true, 
		['TrinketTotemLvl3b'] = true, 
		['TrinketOrbLvl3'] = true,
	}
	AddCastSpellCallback(function(...) self:CastSpell(...) end)	
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
	AddDrawCallback(function() self:Draw() end)
end

function MAGWARDS:CreateMenu()
	MainMenu:addSubMenu('Warding Helper (beta)', 'MagWards')
	self.Menu = MainMenu.MagWards
	self.Menu:addParam('info', 'Match these to ingame keybindings.', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('Item1', 'Item Slot 1', SCRIPT_PARAM_ONKEYDOWN, false, ('1'):byte())
	self.Menu:addParam('Item2', 'Item Slot 2', SCRIPT_PARAM_ONKEYDOWN, false, ('2'):byte())
	self.Menu:addParam('Item3', 'Item Slot 3', SCRIPT_PARAM_ONKEYDOWN, false, ('3'):byte())
	self.Menu:addParam('Item4', 'Item Slot 4', SCRIPT_PARAM_ONKEYDOWN, false, ('5'):byte())
	self.Menu:addParam('Item5', 'Item Slot 5', SCRIPT_PARAM_ONKEYDOWN, false, ('6'):byte())
	self.Menu:addParam('Item6', 'Item Slot 6', SCRIPT_PARAM_ONKEYDOWN, false, ('7'):byte())
	self.Menu:addParam('Item7', 'Trinket Slot', SCRIPT_PARAM_ONKEYDOWN, false, ('4'):byte())
	self.Menu:addParam('info', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('QuickCast', 'QuickCast', SCRIPT_PARAM_ONOFF, false)	
end

function MAGWARDS:Draw()
	if self.DrawSpots then
		for _, p in ipairs(self.Positions) do
			local c = WorldToScreen(D3DXVECTOR3(p.x,p.y,p.z))
			if c.x > -100 and c.x < WINDOW_W+100 and c.y > -100 and c.y < WINDOW_H+100 then
				local color = GetDistanceSqr(p, mousePos) < 6400 and RGB(0,0,255) or RGB(255,255,255)
				for i=1, 5 do DrawCircle(p.x, p.y, p.z, 75, color) end
			end
		end
		for _, p in ipairs(self.Jumps) do
			local c = WorldToScreen(D3DXVECTOR3(p.pos.x,p.pos.y,p.pos.z))
			if c.x > -100 and c.x < WINDOW_W+100 and c.y > -100 and c.y < WINDOW_H+100 then
				local isHovered = GetDistanceSqr(mousePos, p.pos) < 6400 or GetDistanceSqr(mousePos, p.cast) < 6400
				local color = isHovered and RGB(0,0,255) or RGB(255,125,0)			
				for i=1, 5 do
					DrawCircle(p.pos.x, p.pos.y, p.pos.z, 75, color)
					DrawCircle(p.cast.x, p.cast.y, p.cast.z, 50, color)
				end
				local x, z = p.pos.x - p.cast.x, p.pos.z - p.cast.z
				local nLength  = sqrt(x * x + z * z)			
				DrawLine3D(
					p.pos.x + ((x / nLength) * -70), 
					p.pos.y, 
					p.pos.z + ((z / nLength) * -70),
					p.cast.x + ((x / nLength) * 50), 
					p.cast.y, 
					p.cast.z + ((z / nLength) * 50),
					2,
					isHovered and ARGB(100,0,0,255) or ARGB(100,175,225,0)
				)
			end
		end
	end
end

function MAGWARDS:WndMsg(m,k)
	if m==KEY_DOWN then
		for _, param in ipairs(self.Menu._param) do
			if param.pType == SCRIPT_PARAM_ONKEYDOWN and param.key == k then
				local slot = _G['ITEM_'..param.var:sub(#param.var, #param.var)]
				if self.Wards[myHero:GetSpellData(slot).name] then
					self.DrawSpots = slot
				end
				return
			end
		end
	elseif m==KEY_UP and self.DrawSpots and self.Menu.QuickCast then
		DelayAction(function() self.DrawSpots = nil end, 0.25)
	elseif (m==WM_LBUTTONDOWN or m==WM_RBUTTONDOWN) and not self.Menu.QuickCast then
		DelayAction(function() self.DrawSpots = nil end, 0.25)		
	end
end

function MAGWARDS:CastSpell(iSlot,startPos,endPos,target)
	if self.DrawSpots == iSlot then
		for _, p in ipairs(self.Positions) do
			if GetDistanceSqr(mousePos, p) < 6400 then
				endPos.x = p.x
				endPos.z = p.z
			end
		end
		for _, p in ipairs(self.Jumps) do
			local isHovered = GetDistanceSqr(mousePos, p.pos) < 6400 or GetDistanceSqr(mousePos, p.cast) < 6400
			if isHovered then
				endPos.x = p.cast.x
				endPos.z = p.cast.z
			end
		end
	end
end
