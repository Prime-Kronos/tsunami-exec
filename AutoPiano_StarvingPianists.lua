-- AUTO PIANO v3.0 | Starving Pianists
-- Работает с: Synapse X, KRNL, Fluxus, Hydrogen

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ══════════════════════════════════════════
-- НАЖАТИЕ КЛАВИШ
-- ══════════════════════════════════════════
local function pressNote(key)
    local vk = game:GetService("VirtualInputManager")
    local kc = Enum.KeyCode[key]
    if kc then
        vk:SendKeyEvent(true, kc, false, game)
        task.wait(0.04)
        vk:SendKeyEvent(false, kc, false, game)
    end
end

local NOTE_MAP = {
    C3="Z", Cs3="S", D3="X", Ds3="D", E3="C", F3="V",
    Fs3="G", G3="B", Gs3="H", A3="N", As3="J", B3="M",
    C4="Q", Cs4="Two", D4="W", Ds4="Three", E4="E", F4="R",
    Fs4="Five", G4="T", Gs4="Six", A4="Y", As4="Seven", B4="U",
    C5="I", Cs5="Nine", D5="O", Ds5="Zero", E5="P", F5="LeftBracket",
    Fs5="Equals", G5="RightBracket", Gs5="BackSlash", A5="BackSpace",
}

local function playNote(noteName)
    noteName = noteName:gsub("%s",""):gsub("#","s"):gsub("b","s")
    local key = NOTE_MAP[noteName]
    if key then pressNote(key) end
end

-- ══════════════════════════════════════════
-- БАЗА ПЕСЕН
-- ══════════════════════════════════════════
local SONGS = {}

local function S(...)
    local t = {...}
    local result = {}
    for i=1,#t,2 do result[#result+1] = {t[i], t[i+1]} end
    return result
end

-- 🎂 КЛАССИКА
SONGS["Happy Birthday"] = {cat="🎂 Классика", notes=S(
    "C4",0,"C4",0.3,"D4",0.3,"C4",0.6,"F4",0.6,"E4",1.2,
    "C4",0.6,"C4",0.3,"D4",0.3,"C4",0.6,"G4",0.6,"F4",1.2,
    "C4",0.6,"C4",0.3,"C5",0.3,"A4",0.6,"F4",0.6,"E4",0.6,"D4",0.6,
    "As4",0.3,"As4",0.3,"A4",0.6,"F4",0.6,"G4",0.6,"F4",1.2)}

SONGS["Twinkle Twinkle Little Star"] = {cat="🎂 Классика", notes=S(
    "C4",0,"C4",0.3,"G4",0.3,"G4",0.3,"A4",0.3,"A4",0.3,"G4",0.6,
    "F4",0.3,"F4",0.3,"E4",0.3,"E4",0.3,"D4",0.3,"D4",0.3,"C4",0.6,
    "G4",0.3,"G4",0.3,"F4",0.3,"F4",0.3,"E4",0.3,"E4",0.3,"D4",0.6,
    "G4",0.3,"G4",0.3,"F4",0.3,"F4",0.3,"E4",0.3,"E4",0.3,"D4",0.6,
    "C4",0.3,"C4",0.3,"G4",0.3,"G4",0.3,"A4",0.3,"A4",0.3,"G4",0.6,
    "F4",0.3,"F4",0.3,"E4",0.3,"E4",0.3,"D4",0.3,"D4",0.3,"C4",0.6)}

SONGS["Fur Elise"] = {cat="🎂 Классика", notes=S(
    "E5",0,"Ds5",0.15,"E5",0.15,"Ds5",0.15,"E5",0.15,"B4",0.15,"D5",0.15,"C5",0.15,
    "A4",0.3,"C4",0.15,"E4",0.15,"A4",0.15,"B4",0.3,"E4",0.15,"Gs4",0.15,"B4",0.15,
    "C5",0.3,"E4",0.15,"E5",0.15,"Ds5",0.15,"E5",0.15,"Ds5",0.15,"E5",0.15,
    "B4",0.15,"D5",0.15,"C5",0.15,"A4",0.3,"C4",0.15,"E4",0.15,"A4",0.15,
    "B4",0.3,"E4",0.15,"C5",0.15,"B4",0.15,"A4",0.6)}

SONGS["Ode to Joy"] = {cat="🎂 Классика", notes=S(
    "E4",0,"E4",0.3,"F4",0.3,"G4",0.3,"G4",0.3,"F4",0.3,"E4",0.3,"D4",0.3,
    "C4",0.3,"C4",0.3,"D4",0.3,"E4",0.3,"E4",0.45,"D4",0.15,"D4",0.6,
    "E4",0.3,"E4",0.3,"F4",0.3,"G4",0.3,"G4",0.3,"F4",0.3,"E4",0.3,"D4",0.3,
    "C4",0.3,"C4",0.3,"D4",0.3,"E4",0.3,"D4",0.45,"C4",0.15,"C4",0.6)}

SONGS["Jingle Bells"] = {cat="🎂 Классика", notes=S(
    "E4",0,"E4",0.3,"E4",0.6,"E4",0.3,"E4",0.3,"E4",0.6,
    "E4",0.3,"G4",0.3,"C4",0.3,"D4",0.3,"E4",1.2,
    "F4",0.3,"F4",0.3,"F4",0.45,"F4",0.15,"F4",0.3,"E4",0.3,"E4",0.3,"E4",0.15,"E4",0.15,
    "E4",0.3,"D4",0.3,"D4",0.3,"E4",0.3,"D4",0.6,"G4",0.6)}

SONGS["Mary Had a Little Lamb"] = {cat="🎂 Классика", notes=S(
    "E4",0,"D4",0.3,"C4",0.3,"D4",0.3,"E4",0.3,"E4",0.3,"E4",0.6,
    "D4",0.3,"D4",0.3,"D4",0.6,"E4",0.3,"G4",0.3,"G4",0.6,
    "E4",0.3,"D4",0.3,"C4",0.3,"D4",0.3,"E4",0.3,"E4",0.3,"E4",0.3,"E4",0.3,
    "D4",0.3,"D4",0.3,"E4",0.3,"D4",0.3,"C4",0.6)}

SONGS["London Bridge Is Falling Down"] = {cat="🎂 Классика", notes=S(
    "G4",0,"A4",0.3,"G4",0.3,"F4",0.3,"E4",0.3,"F4",0.3,"G4",0.6,
    "D4",0.3,"E4",0.3,"F4",0.6,"E4",0.3,"F4",0.3,"G4",0.6,
    "G4",0.3,"A4",0.3,"G4",0.3,"F4",0.3,"E4",0.3,"F4",0.3,"G4",0.3,"D4",0.3,
    "G4",0.3,"E4",0.3,"C4",0.6)}

SONGS["Moonlight Sonata"] = {cat="🎂 Классика", notes=S(
    "Gs4",0,"Cs5",0.3,"E5",0.3,"Gs4",0.3,"Cs5",0.3,"E5",0.3,
    "Gs4",0.3,"Cs5",0.3,"E5",0.3,"Gs4",0.3,"Cs5",0.3,"E5",0.3,
    "A4",0.3,"Cs5",0.3,"E5",0.3,"A4",0.3,"Cs5",0.3,"E5",0.3,
    "Fs4",0.3,"A4",0.3,"Ds5",0.3,"Fs4",0.3,"A4",0.3,"Ds5",0.3)}

SONGS["Canon in D"] = {cat="🎂 Классика", notes=S(
    "Fs5",0,"E5",0.3,"D5",0.3,"Cs5",0.3,"B4",0.3,"A4",0.3,"B4",0.3,"Cs5",0.3,
    "D5",0.3,"Cs5",0.3,"B4",0.3,"A4",0.3,"G4",0.3,"Fs4",0.3,"G4",0.3,"A4",0.3,
    "D4",0.3,"Cs4",0.3,"D4",0.3,"E4",0.3,"Fs4",0.3,"G4",0.3,"A4",0.3,"B4",0.3)}

SONGS["Clair de Lune"] = {cat="🎂 Классика", notes=S(
    "Db5",0,"Bb4",0.4,"Gb4",0.4,"Db5",0.4,"Bb4",0.4,"Gb4",0.4,"Db5",0.8,
    "Eb5",0.4,"C5",0.4,"Ab4",0.4,"Eb5",0.4,"C5",0.4,"Ab4",0.4,"Eb5",0.8,
    "F5",0.4,"Db5",0.4,"Ab4",0.4,"Eb4",0.4,"Db4",0.4,"Ab3",0.4,"Gb3",0.8)}

-- 😴 LIMELANE / LOFI
SONGS["Limelane - Chill Lofi"] = {cat="😴 Limelane/Lofi", notes=S(
    "C4",0,"E4",0.4,"G4",0.4,"A4",0.4,"G4",0.4,"E4",0.4,
    "F4",0.4,"A4",0.4,"C5",0.4,"A4",0.4,"G4",0.4,"E4",0.4,
    "D4",0.4,"F4",0.4,"A4",0.4,"G4",0.4,"E4",0.4,"C4",0.4,
    "C4",0.4,"E4",0.4,"G4",0.4,"B4",0.4,"A4",0.4,"G4",0.8)}

SONGS["Limelane - Peaceful"] = {cat="😴 Limelane/Lofi", notes=S(
    "G3",0,"B3",0.35,"D4",0.35,"G4",0.35,"Fs4",0.35,"E4",0.35,
    "D4",0.35,"C4",0.35,"B3",0.35,"A3",0.35,"G3",0.7,
    "A3",0.35,"B3",0.35,"C4",0.35,"D4",0.35,"E4",0.35,"Fs4",0.35,"G4",0.7,
    "A4",0.35,"G4",0.35,"Fs4",0.35,"E4",0.35,"D4",0.35,"C4",0.35,"B3",0.35,"G3",0.7)}

SONGS["Limelane - Coffee Shop"] = {cat="😴 Limelane/Lofi", notes=S(
    "C4",0,"E4",0.3,"G4",0.3,"C5",0.3,"B4",0.3,"A4",0.3,"G4",0.3,
    "F4",0.3,"E4",0.3,"D4",0.3,"C4",0.3,"D4",0.3,"E4",0.3,"G4",0.3,
    "A4",0.3,"C5",0.3,"B4",0.3,"A4",0.3,"G4",0.3,"E4",0.3,"C4",0.6)}

SONGS["Limelane - Midnight Jazz"] = {cat="😴 Limelane/Lofi", notes=S(
    "F3",0,"A3",0.25,"C4",0.25,"F4",0.25,"E4",0.25,"D4",0.25,"C4",0.25,
    "Bb3",0.25,"A3",0.25,"G3",0.25,"F3",0.5,"G3",0.25,"A3",0.25,
    "Bb3",0.25,"C4",0.25,"D4",0.25,"F4",0.25,"G4",0.25,"F4",0.25,
    "D4",0.25,"C4",0.25,"Bb3",0.25,"A3",0.25,"G3",0.25,"F3",0.5)}

SONGS["Limelane - Summer Rain"] = {cat="😴 Limelane/Lofi", notes=S(
    "A4",0,"G4",0.35,"E4",0.35,"C4",0.35,"D4",0.35,"F4",0.35,"A4",0.35,
    "B4",0.35,"A4",0.35,"G4",0.35,"F4",0.35,"E4",0.35,"D4",0.35,
    "C4",0.35,"B3",0.35,"A3",0.35,"G3",0.35,"A3",0.35,"C4",0.35,"E4",0.35,"A4",0.7)}

SONGS["Limelane - Ocean Breeze"] = {cat="😴 Limelane/Lofi", notes=S(
    "E4",0,"G4",0.4,"A4",0.4,"C5",0.4,"B4",0.4,"A4",0.4,"G4",0.4,
    "E4",0.4,"D4",0.4,"E4",0.4,"G4",0.4,"A4",0.4,"B4",0.4,
    "C5",0.4,"B4",0.4,"A4",0.4,"G4",0.4,"E4",0.4,"D4",0.4,"C4",0.8)}

SONGS["Limelane - Forest Walk"] = {cat="😴 Limelane/Lofi", notes=S(
    "G4",0,"Fs4",0.3,"E4",0.3,"D4",0.3,"C4",0.3,"B3",0.3,"A3",0.3,"G3",0.6,
    "A3",0.3,"B3",0.3,"C4",0.3,"D4",0.3,"E4",0.3,"Fs4",0.3,"G4",0.6,
    "A4",0.3,"B4",0.3,"C5",0.3,"B4",0.3,"A4",0.3,"G4",0.3,"Fs4",0.3,"E4",0.3,
    "D4",0.3,"C4",0.3,"B3",0.3,"G3",0.6)}

SONGS["Lofi - Late Night Study"] = {cat="😴 Limelane/Lofi", notes=S(
    "C4",0,"Eb4",0.5,"G4",0.5,"Bb4",0.5,"C5",0.5,"Bb4",0.5,
    "Ab4",0.5,"G4",0.5,"F4",0.5,"Eb4",0.5,"D4",0.5,"C4",1.0,
    "F3",0.5,"Ab3",0.5,"C4",0.5,"Eb4",0.5,"F4",0.5,"Eb4",0.5,
    "Db4",0.5,"C4",0.5,"Bb3",0.5,"Ab3",0.5,"G3",0.5,"F3",1.0)}

SONGS["Lofi - Rainy Window"] = {cat="😴 Limelane/Lofi", notes=S(
    "E4",0,"G4",0.45,"B4",0.45,"E5",0.45,"D5",0.45,"C5",0.45,
    "B4",0.45,"A4",0.45,"G4",0.45,"Fs4",0.45,"E4",0.45,"D4",0.45,
    "C4",0.45,"B3",0.45,"A3",0.45,"G3",0.45,"A3",0.45,"B3",0.45,"C4",0.9)}

SONGS["Lofi - Nostalgia"] = {cat="😴 Limelane/Lofi", notes=S(
    "A3",0,"E4",0.4,"A4",0.4,"B4",0.4,"C5",0.4,"B4",0.4,"A4",0.4,
    "E4",0.4,"A3",0.4,"E4",0.4,"A4",0.4,"B4",0.4,"D5",0.4,"C5",0.4,
    "B4",0.4,"A4",0.4,"E4",0.4,"A3",0.4,"E4",0.4,"A4",0.4,
    "G4",0.4,"Fs4",0.4,"E4",0.4,"A4",0.8)}

SONGS["Lofi - Quiet Morning"] = {cat="😴 Limelane/Lofi", notes=S(
    "D4",0,"F4",0.4,"A4",0.4,"D5",0.4,"C5",0.4,"Bb4",0.4,"A4",0.4,
    "G4",0.4,"F4",0.4,"E4",0.4,"D4",0.4,"E4",0.4,"F4",0.4,"A4",0.4,
    "Bb4",0.4,"C5",0.4,"D5",0.4,"C5",0.4,"Bb4",0.4,"A4",0.4,"G4",0.4,"F4",0.8)}

SONGS["Lofi - Soft Glow"] = {cat="😴 Limelane/Lofi", notes=S(
    "G4",0,"B4",0.35,"D5",0.35,"G5",0.35,"Fs5",0.35,"E5",0.35,"D5",0.35,
    "C5",0.35,"B4",0.35,"A4",0.35,"G4",0.35,"Fs4",0.35,"E4",0.35,
    "D4",0.35,"E4",0.35,"Fs4",0.35,"G4",0.35,"B4",0.35,"D5",0.35,"G5",0.7)}

SONGS["Lofi - Autumn Leaves"] = {cat="😴 Limelane/Lofi", notes=S(
    "Fs4",0,"A4",0.4,"C5",0.4,"Fs5",0.4,"E5",0.4,"D5",0.4,"C5",0.4,
    "B4",0.4,"A4",0.4,"G4",0.4,"Fs4",0.4,"E4",0.4,"D4",0.4,
    "G4",0.4,"B4",0.4,"D5",0.4,"G5",0.4,"Fs5",0.4,"E5",0.4,"D5",0.4,"C5",0.8)}

SONGS["Lofi - Stargazing"] = {cat="😴 Limelane/Lofi", notes=S(
    "B4",0,"Fs4",0.45,"B3",0.45,"Fs3",0.45,"B3",0.45,"Fs4",0.45,"B4",0.45,
    "Cs5",0.45,"B4",0.45,"A4",0.45,"Gs4",0.45,"Fs4",0.45,"E4",0.45,
    "D4",0.45,"E4",0.45,"Fs4",0.45,"A4",0.45,"B4",0.45,"Cs5",0.45,"E5",0.9)}

SONGS["Lofi - Fading Light"] = {cat="😴 Limelane/Lofi", notes=S(
    "Eb4",0,"G4",0.4,"Bb4",0.4,"Eb5",0.4,"Db5",0.4,"C5",0.4,"Bb4",0.4,
    "Ab4",0.4,"G4",0.4,"F4",0.4,"Eb4",0.4,"Db4",0.4,"C4",0.4,
    "Db4",0.4,"Eb4",0.4,"G4",0.4,"Bb4",0.4,"Eb5",0.4,"Db5",0.4,"Bb4",0.8)}

SONGS["Lofi - Haze"] = {cat="😴 Limelane/Lofi", notes=S(
    "F4",0,"A4",0.5,"C5",0.5,"F5",0.5,"E5",0.5,"D5",0.5,"C5",0.5,
    "Bb4",0.5,"A4",0.5,"G4",0.5,"F4",0.5,"G4",0.5,"A4",0.5,
    "C5",0.5,"D5",0.5,"F5",0.5,"E5",0.5,"D5",0.5,"C5",0.5,"A4",0.5,"F4",1.0)}

SONGS["Lofi - Bittersweet"] = {cat="😴 Limelane/Lofi", notes=S(
    "A4",0,"E4",0.3,"A3",0.3,"C4",0.3,"E4",0.3,"A4",0.3,"B4",0.3,
    "C5",0.3,"B4",0.3,"A4",0.3,"G4",0.3,"Fs4",0.3,"E4",0.3,
    "D4",0.3,"C4",0.3,"D4",0.3,"E4",0.3,"G4",0.3,"A4",0.3,"B4",0.3,"C5",0.6)}

SONGS["Lofi - Still Waters"] = {cat="😴 Limelane/Lofi", notes=S(
    "C5",0,"B4",0.4,"A4",0.4,"G4",0.4,"F4",0.4,"E4",0.4,"D4",0.4,"C4",0.8,
    "G4",0.4,"F4",0.4,"E4",0.4,"D4",0.4,"C4",0.4,"B3",0.4,"A3",0.4,"G3",0.8,
    "E4",0.4,"D4",0.4,"C4",0.4,"B3",0.4,"A3",0.4,"G3",0.4,"F3",0.4,"E3",0.8)}

SONGS["Lofi - Wistful"] = {cat="😴 Limelane/Lofi", notes=S(
    "D5",0,"C5",0.35,"Bb4",0.35,"A4",0.35,"G4",0.35,"F4",0.35,"Eb4",0.35,"D4",0.7,
    "A4",0.35,"G4",0.35,"F4",0.35,"Eb4",0.35,"D4",0.35,"C4",0.35,"Bb3",0.35,"A3",0.7,
    "F4",0.35,"Eb4",0.35,"D4",0.35,"C4",0.35,"Bb3",0.35,"Ab3",0.35,"G3",0.35,"F3",0.7)}

SONGS["Lofi - Afterglow"] = {cat="😴 Limelane/Lofi", notes=S(
    "G4",0,"E4",0.4,"C4",0.4,"G3",0.4,"E3",0.4,"G3",0.4,"C4",0.4,"E4",0.4,
    "G4",0.4,"A4",0.4,"C5",0.4,"E5",0.4,"D5",0.4,"C5",0.4,"A4",0.4,"G4",0.8)}

-- 🌀 DREAMCORE / LIMINAL
SONGS["Dreamcore - Liminal Space"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "E3",0,"G3",0.6,"B3",0.6,"E4",0.6,"D4",0.6,"C4",0.6,
    "B3",0.6,"A3",0.6,"G3",0.6,"Fs3",0.6,"E3",0.6,"Fs3",0.6,
    "G3",0.6,"A3",0.6,"B3",0.6,"C4",0.6,"D4",0.6,"E4",0.6,
    "Fs4",0.6,"G4",0.6,"Fs4",0.6,"E4",0.6,"D4",0.6,"C4",0.6,"B3",1.2)}

SONGS["Dreamcore - Empty Mall"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "Ab3",0,"C4",0.5,"Eb4",0.5,"Ab4",0.5,"G4",0.5,"F4",0.5,
    "Eb4",0.5,"Db4",0.5,"C4",0.5,"Bb3",0.5,"Ab3",0.5,"G3",0.5,
    "Ab3",0.5,"Bb3",0.5,"C4",0.5,"Eb4",0.5,"F4",0.5,"Ab4",1.0)}

SONGS["Dreamcore - Floating World"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "C4",0,"F4",0.5,"Ab4",0.5,"C5",0.5,"Bb4",0.5,"Ab4",0.5,
    "F4",0.5,"Eb4",0.5,"C4",0.5,"Eb4",0.5,"F4",0.5,"Ab4",0.5,
    "Bb4",0.5,"C5",0.5,"Db5",0.5,"C5",0.5,"Ab4",0.5,"F4",1.0)}

SONGS["Dreamcore - VHS Memories"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "D4",0,"F4",0.45,"A4",0.45,"D5",0.45,"C5",0.45,"Bb4",0.45,
    "A4",0.45,"G4",0.45,"F4",0.45,"E4",0.45,"D4",0.45,"E4",0.45,
    "F4",0.45,"G4",0.45,"A4",0.45,"Bb4",0.45,"C5",0.45,"D5",0.9)}

SONGS["Dreamcore - 3AM Pool"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "A3",0,"C4",0.55,"E4",0.55,"A4",0.55,"G4",0.55,"F4",0.55,
    "E4",0.55,"D4",0.55,"C4",0.55,"B3",0.55,"A3",0.55,"G3",0.55,
    "F3",0.55,"G3",0.55,"A3",0.55,"C4",0.55,"E4",0.55,"A4",1.1)}

SONGS["Dreamcore - Forgotten Hotel"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "F3",0,"Ab3",0.5,"C4",0.5,"F4",0.5,"Eb4",0.5,"Db4",0.5,
    "C4",0.5,"Bb3",0.5,"Ab3",0.5,"G3",0.5,"F3",0.5,"Eb3",0.5,
    "Db3",0.5,"Eb3",0.5,"F3",0.5,"Ab3",0.5,"C4",0.5,"Eb4",1.0)}

SONGS["Dreamcore - Yellow Wallpaper"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "Bb3",0,"D4",0.5,"F4",0.5,"Bb4",0.5,"Ab4",0.5,"G4",0.5,
    "F4",0.5,"Eb4",0.5,"D4",0.5,"C4",0.5,"Bb3",0.5,"C4",0.5,
    "D4",0.5,"F4",0.5,"G4",0.5,"Bb4",0.5,"A4",0.5,"G4",1.0)}

SONGS["Dreamcore - Abandoned School"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "Db4",0,"F4",0.5,"Ab4",0.5,"Db5",0.5,"C5",0.5,"Bb4",0.5,
    "Ab4",0.5,"Gb4",0.5,"F4",0.5,"Eb4",0.5,"Db4",0.5,"C4",0.5,
    "Db4",0.5,"Eb4",0.5,"F4",0.5,"Ab4",0.5,"Bb4",0.5,"Db5",1.0)}

SONGS["Liminal - Endless Corridor"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "E4",0,"G4",0.6,"B4",0.6,"E5",0.6,"D5",0.6,"C5",0.6,"B4",0.6,
    "A4",0.6,"G4",0.6,"Fs4",0.6,"E4",0.6,"D4",0.6,"C4",0.6,
    "D4",0.6,"E4",0.6,"G4",0.6,"A4",0.6,"B4",0.6,"E5",1.2)}

SONGS["Liminal - Silent Suburb"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "C4",0,"Eb4",0.55,"G4",0.55,"C5",0.55,"Bb4",0.55,"Ab4",0.55,
    "G4",0.55,"F4",0.55,"Eb4",0.55,"D4",0.55,"C4",0.55,"Bb3",0.55,
    "Ab3",0.55,"Bb3",0.55,"C4",0.55,"Eb4",0.55,"G4",0.55,"C5",1.1)}

SONGS["Liminal - Fluorescent Buzz"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "G3",0,"Bb3",0.5,"D4",0.5,"G4",0.5,"F4",0.5,"Eb4",0.5,
    "D4",0.5,"C4",0.5,"Bb3",0.5,"Ab3",0.5,"G3",0.5,"F3",0.5,
    "Eb3",0.5,"F3",0.5,"G3",0.5,"Bb3",0.5,"D4",0.5,"F4",1.0)}

SONGS["Liminal - Waiting Room"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "Ab4",0,"F4",0.5,"Db4",0.5,"Ab3",0.5,"Db4",0.5,"F4",0.5,"Ab4",0.5,
    "Bb4",0.5,"Ab4",0.5,"Gb4",0.5,"F4",0.5,"Eb4",0.5,"Db4",0.5,
    "Eb4",0.5,"F4",0.5,"Ab4",0.5,"Bb4",0.5,"Db5",0.5,"C5",1.0)}

SONGS["Liminal - Hospital Hallway"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "D4",0,"F4",0.6,"Ab4",0.6,"D5",0.6,"Db5",0.6,"C5",0.6,"Bb4",0.6,
    "Ab4",0.6,"G4",0.6,"F4",0.6,"Eb4",0.6,"D4",0.6,"C4",0.6,
    "D4",0.6,"Eb4",0.6,"F4",0.6,"Ab4",0.6,"C5",0.6,"D5",1.2)}

SONGS["Liminal - Sunken Pool"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "Fs4",0,"A4",0.5,"C5",0.5,"Fs5",0.5,"E5",0.5,"D5",0.5,"C5",0.5,
    "B4",0.5,"A4",0.5,"G4",0.5,"Fs4",0.5,"E4",0.5,"D4",0.5,
    "E4",0.5,"Fs4",0.5,"A4",0.5,"C5",0.5,"E5",0.5,"Fs5",1.0)}

SONGS["Liminal - Last Train"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "Bb3",0,"Db4",0.5,"F4",0.5,"Bb4",0.5,"Ab4",0.5,"Gb4",0.5,
    "F4",0.5,"Eb4",0.5,"Db4",0.5,"C4",0.5,"Bb3",0.5,"Ab3",0.5,
    "Gb3",0.5,"Ab3",0.5,"Bb3",0.5,"Db4",0.5,"F4",0.5,"Ab4",1.0)}

SONGS["Liminal - Neon Motel"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "E4",0,"G4",0.45,"B4",0.45,"E5",0.45,"Ds5",0.45,"D5",0.45,"Cs5",0.45,
    "C5",0.45,"B4",0.45,"A4",0.45,"Gs4",0.45,"G4",0.45,"Fs4",0.45,
    "G4",0.45,"A4",0.45,"B4",0.45,"D5",0.45,"E5",0.45,"Fs5",0.9)}

SONGS["Weirdcore - Distorted"] = {cat="🌀 Dreamcore/Liminal", notes=S(
    "C4",0,"Eb4",0.4,"Gb4",0.4,"A4",0.4,"C5",0.4,"A4",0.4,"Gb4",0.4,
    "Eb4",0.4,"C4",0.4,"A3",0.4,"Gb3",0.4,"Eb3",0.4,"C3",0.4,
    "Eb3",0.4,"Gb3",0.4,"A3",0.4,"C4",0.4,"Eb4",0.4,"Gb4",0.4,"A4",0.8)}

-- 🎮 ИГРЫ
SONGS["Minecraft - Sweden"] = {cat="🎮 Игры", notes=S(
    "C4",0,"E4",0.6,"G4",0.6,"E4",0.6,"C4",0.6,"A3",0.6,
    "C4",0.6,"E4",0.6,"G4",0.6,"A4",0.6,"G4",0.6,"E4",0.6,
    "D4",0.6,"F4",0.6,"A4",0.6,"G4",0.6,"E4",0.6,"C4",1.2)}

SONGS["Minecraft - Wet Hands"] = {cat="🎮 Игры", notes=S(
    "C4",0,"D4",0.4,"E4",0.4,"G4",0.4,"E4",0.4,"D4",0.4,"C4",0.4,
    "A3",0.4,"C4",0.4,"D4",0.4,"E4",0.4,"G4",0.4,"A4",0.4,
    "G4",0.4,"E4",0.4,"D4",0.4,"C4",0.8,"G3",0.4,"A3",0.4,
    "C4",0.4,"E4",0.4,"G4",0.4,"E4",0.4,"C4",0.8)}

SONGS["Undertale - Megalovania"] = {cat="🎮 Игры", notes=S(
    "D4",0,"D4",0.1,"D5",0.2,"A4",0.3,"Gs4",0.2,"G4",0.2,
    "F4",0.2,"D4",0.15,"F4",0.1,"G4",0.1,
    "C4",0.15,"C4",0.1,"D5",0.2,"A4",0.3,"Gs4",0.2,"G4",0.2,
    "F4",0.2,"D4",0.15,"F4",0.1,"G4",0.1,
    "B3",0.15,"B3",0.1,"D5",0.2,"A4",0.3,"Gs4",0.2,"G4",0.2,
    "F4",0.2,"D4",0.15,"F4",0.1,"G4",0.1)}

SONGS["Undertale - Hopes and Dreams"] = {cat="🎮 Игры", notes=S(
    "C5",0,"B4",0.3,"A4",0.3,"G4",0.3,"F4",0.3,"E4",0.3,"D4",0.3,"C4",0.6,
    "G4",0.3,"F4",0.3,"E4",0.3,"D4",0.3,"C4",0.3,"B3",0.3,"A3",0.3,"G3",0.6,
    "E4",0.3,"D4",0.3,"C4",0.3,"B3",0.3,"A3",0.3,"G3",0.3,"F3",0.3,"E3",0.6)}

SONGS["Terraria - Overworld Day"] = {cat="🎮 Игры", notes=S(
    "E4",0,"G4",0.2,"A4",0.2,"B4",0.2,"A4",0.2,"G4",0.2,"E4",0.2,
    "D4",0.2,"E4",0.2,"G4",0.2,"A4",0.2,"C5",0.2,"B4",0.2,"A4",0.2,
    "G4",0.2,"Fs4",0.2,"E4",0.2,"D4",0.2,"C4",0.2,"D4",0.2,"E4",0.2,
    "G4",0.2,"A4",0.2,"B4",0.2,"C5",0.2,"D5",0.2,"E5",0.4)}

SONGS["Among Us Theme"] = {cat="🎮 Игры", notes=S(
    "C4",0,"Eb4",0.3,"F4",0.3,"G4",0.3,"Ab4",0.3,"G4",0.3,"F4",0.3,
    "Eb4",0.3,"C4",0.3,"Bb3",0.3,"Ab3",0.3,"G3",0.3,"Ab3",0.3,
    "Bb3",0.3,"C4",0.3,"Eb4",0.3,"F4",0.3,"G4",0.3,"Ab4",0.6)}

SONGS["Mario - Main Theme"] = {cat="🎮 Игры", notes=S(
    "E4",0,"E4",0.3,"E4",0.3,"C4",0.2,"E4",0.3,"G4",0.5,"G3",0.5,
    "C4",0.3,"G3",0.3,"E3",0.3,"A3",0.3,"B3",0.3,"Bb3",0.2,"A3",0.3,
    "G3",0.2,"E4",0.2,"G4",0.2,"A4",0.3,"F4",0.2,"G4",0.3,"E4",0.3,
    "C4",0.2,"D4",0.2,"B3",0.3)}

SONGS["Tetris Theme"] = {cat="🎮 Игры", notes=S(
    "E5",0,"B4",0.2,"C5",0.2,"D5",0.2,"C5",0.2,"B4",0.2,"A4",0.4,
    "A4",0.2,"C5",0.2,"E5",0.4,"D5",0.2,"C5",0.2,"B4",0.4,
    "C5",0.2,"D5",0.2,"E5",0.4,"C5",0.4,"A4",0.4,"A4",0.4,
    "D5",0.2,"F5",0.2,"A5",0.4,"G5",0.2,"F5",0.2,"E5",0.4,
    "C5",0.2,"E5",0.4,"D5",0.2,"C5",0.2,"B4",0.4,"E5",0.4)}

SONGS["Pokemon - Main Theme"] = {cat="🎮 Игры", notes=S(
    "G4",0,"G4",0.2,"G4",0.2,"Eb4",0.15,"Bb4",0.15,"G4",0.4,
    "Eb4",0.15,"Bb4",0.15,"G4",0.4,"D5",0.4,"D5",0.4,"D5",0.4,
    "Eb5",0.15,"Bb4",0.15,"Fs4",0.4,"Eb4",0.15,"Bb4",0.15,"G4",0.4,
    "Eb5",0.2,"G5",0.2,"Bb5",0.2,"G5",0.4,"Eb5",0.4,"Bb4",0.4)}

SONGS["Zelda - Song of Storms"] = {cat="🎮 Игры", notes=S(
    "D4",0,"F4",0.15,"D5",0.4,"D4",0.15,"F4",0.15,"D5",0.4,
    "E5",0.2,"F5",0.2,"E5",0.2,"F5",0.2,"E5",0.2,"C5",0.2,"A4",0.4,
    "A4",0.2,"D4",0.2,"F4",0.2,"G4",0.4,"F4",0.2,"D4",0.4,
    "D4",0.2,"E4",0.2,"F4",0.2,"E4",0.2,"F4",0.2,"A4",0.4)}

-- 🌸 АНИМЕ
SONGS["Demon Slayer - Gurenge"] = {cat="🌸 Аниме", notes=S(
    "D4",0,"E4",0.25,"Fs4",0.25,"A4",0.25,"B4",0.25,"A4",0.25,
    "Fs4",0.25,"E4",0.25,"D4",0.25,"E4",0.25,"Fs4",0.25,"G4",0.25,
    "A4",0.25,"G4",0.25,"Fs4",0.25,"E4",0.25,"D4",0.5)}

SONGS["Naruto - Sadness and Sorrow"] = {cat="🌸 Аниме", notes=S(
    "A3",0,"C4",0.4,"E4",0.4,"A4",0.4,"G4",0.4,"E4",0.4,
    "D4",0.4,"C4",0.4,"B3",0.4,"A3",0.4,"B3",0.4,"C4",0.4,
    "D4",0.4,"E4",0.4,"F4",0.4,"E4",0.4,"D4",0.4,"C4",0.8)}

SONGS["Your Lie in April"] = {cat="🌸 Аниме", notes=S(
    "G4",0,"A4",0.2,"B4",0.2,"C5",0.2,"B4",0.2,"A4",0.2,"G4",0.2,
    "Fs4",0.2,"E4",0.2,"D4",0.2,"E4",0.2,"Fs4",0.2,"G4",0.2,
    "A4",0.2,"B4",0.2,"C5",0.2,"D5",0.2,"E5",0.4)}

SONGS["Spirited Away - One Summers Day"] = {cat="🌸 Аниме", notes=S(
    "C4",0,"E4",0.5,"G4",0.5,"E4",0.5,"C4",0.5,"D4",0.5,
    "F4",0.5,"A4",0.5,"G4",0.5,"E4",0.5,"C4",0.5,"E4",0.5,
    "G4",0.5,"C5",0.5,"B4",0.5,"A4",0.5,"G4",0.5,"F4",0.5,"E4",1.0)}

SONGS["Attack on Titan - Guren no Yumiya"] = {cat="🌸 Аниме", notes=S(
    "E4",0,"Fs4",0.2,"G4",0.2,"A4",0.2,"B4",0.2,"C5",0.2,"B4",0.2,
    "A4",0.2,"G4",0.2,"Fs4",0.2,"E4",0.2,"D4",0.2,"E4",0.2,
    "Fs4",0.2,"G4",0.2,"A4",0.2,"G4",0.2,"Fs4",0.4)}

SONGS["SAO - Crossing Field"] = {cat="🌸 Аниме", notes=S(
    "E4",0,"Fs4",0.2,"G4",0.2,"A4",0.2,"B4",0.2,"C5",0.2,
    "D5",0.2,"E5",0.2,"D5",0.2,"C5",0.2,"B4",0.2,"A4",0.2,
    "G4",0.2,"Fs4",0.2,"E4",0.4,"D4",0.2,"E4",0.2,"Fs4",0.2,
    "G4",0.2,"A4",0.2,"B4",0.2,"C5",0.2,"B4",0.2,"A4",0.4)}

-- 🎤 ПОП
SONGS["Adele - Someone Like You"] = {cat="🎤 Поп", notes=S(
    "A4",0,"E4",0.4,"A4",0.4,"Cs5",0.4,"E5",0.4,"D5",0.4,
    "Cs5",0.4,"B4",0.4,"A4",0.4,"Gs4",0.4,"A4",0.4,"B4",0.4,
    "Cs5",0.4,"D5",0.4,"E5",0.4,"Fs5",0.4,"E5",0.4,"D5",0.8)}

SONGS["Ed Sheeran - Perfect"] = {cat="🎤 Поп", notes=S(
    "G4",0,"A4",0.5,"B4",0.5,"D5",0.5,"E5",0.5,"D5",0.5,
    "B4",0.5,"A4",0.5,"G4",0.5,"Fs4",0.5,"G4",0.5,"A4",0.5,
    "B4",0.5,"C5",0.5,"D5",0.5,"E5",0.5,"D5",0.5,"C5",0.8)}

SONGS["Billie Eilish - Bad Guy"] = {cat="🎤 Поп", notes=S(
    "C4",0,"C4",0.2,"C4",0.2,"G3",0.2,"Bb3",0.2,"C4",0.2,
    "C4",0.2,"Bb3",0.2,"Ab3",0.2,"G3",0.2,"F3",0.2,
    "G3",0.2,"Ab3",0.2,"Bb3",0.2,"C4",0.2,"D4",0.2,"Eb4",0.4)}

SONGS["The Weeknd - Blinding Lights"] = {cat="🎤 Поп", notes=S(
    "E4",0,"Fs4",0.2,"Gs4",0.2,"B4",0.2,"E5",0.2,"Ds5",0.2,
    "B4",0.2,"Gs4",0.2,"Fs4",0.2,"E4",0.2,"Ds4",0.2,"E4",0.2,
    "Fs4",0.2,"Gs4",0.2,"A4",0.2,"B4",0.2,"Cs5",0.2,"B4",0.2)}

SONGS["Coldplay - The Scientist"] = {cat="🎤 Поп", notes=S(
    "D4",0,"C4",0.4,"G3",0.4,"D4",0.4,"C4",0.4,"G3",0.4,
    "D4",0.4,"E4",0.4,"F4",0.4,"G4",0.4,"F4",0.4,"E4",0.4,
    "D4",0.4,"C4",0.4,"G3",0.4,"Bb3",0.4,"C4",0.4,"D4",0.8)}

SONGS["Sia - Chandelier"] = {cat="🎤 Поп", notes=S(
    "G4",0,"Bb4",0.25,"C5",0.25,"D5",0.25,"Eb5",0.25,"D5",0.25,
    "C5",0.25,"Bb4",0.25,"G4",0.25,"F4",0.25,"Eb4",0.25,"F4",0.25,
    "G4",0.25,"Bb4",0.25,"C5",0.25,"Eb5",0.25,"F5",0.25,"Eb5",0.25,
    "D5",0.25,"C5",0.25,"Bb4",0.25,"G4",0.25,"F4",0.5)}

SONGS["Shape of You"] = {cat="🎤 Поп", notes=S(
    "Cs4",0,"D4",0.2,"E4",0.2,"Fs4",0.2,"A4",0.2,"Fs4",0.2,
    "E4",0.2,"D4",0.2,"Cs4",0.2,"B3",0.2,"A3",0.2,"B3",0.2,
    "Cs4",0.2,"D4",0.2,"E4",0.2,"Fs4",0.2,"A4",0.2,"B4",0.2,
    "A4",0.2,"Fs4",0.2,"E4",0.2,"D4",0.4)}

SONGS["Imagine Dragons - Believer"] = {cat="🎤 Поп", notes=S(
    "A3",0,"A3",0.2,"C4",0.2,"E4",0.2,"A3",0.2,"G3",0.2,
    "A3",0.2,"A3",0.2,"C4",0.2,"E4",0.2,"D4",0.2,"C4",0.2,
    "B3",0.2,"A3",0.2,"G3",0.2,"F3",0.2,"G3",0.2,"A3",0.4)}

-- 🎬 ФИЛЬМЫ
SONGS["Pirates - He's a Pirate"] = {cat="🎬 Фильмы/ТВ", notes=S(
    "D4",0,"E4",0.25,"F4",0.25,"G4",0.25,"A4",0.25,"Bb4",0.25,
    "A4",0.25,"F4",0.25,"D4",0.25,"G4",0.25,"E4",0.25,"C4",0.5,
    "Bb3",0.25,"C4",0.25,"D4",0.25,"E4",0.25,"F4",0.25,"G4",0.25,
    "A4",0.25,"Bb4",0.25,"C5",0.25,"A4",0.5)}

SONGS["Game of Thrones Theme"] = {cat="🎬 Фильмы/ТВ", notes=S(
    "G4",0,"C4",0.5,"Eb4",0.5,"F4",0.25,"G4",0.75,"C4",0.5,
    "Eb4",0.5,"F4",0.25,"E4",0.75,"G4",0.5,"C5",0.5,"Bb4",0.25,
    "A4",0.75,"F4",0.5,"Ab4",0.5,"G4",0.5)}

SONGS["Harry Potter Theme"] = {cat="🎬 Фильмы/ТВ", notes=S(
    "B4",0,"E5",0.4,"G5",0.2,"Fs5",0.4,"E5",0.2,"B5",0.4,
    "A5",0.6,"Fs5",0.6,"E5",0.4,"G5",0.2,"Fs5",0.4,"D5",0.2,
    "F5",0.4,"B4",0.8)}

SONGS["Interstellar Theme"] = {cat="🎬 Фильмы/ТВ", notes=S(
    "C4",0,"G4",0.8,"E4",0.8,"C4",0.8,"G3",0.8,"F4",0.8,
    "C5",0.8,"A4",0.8,"F4",0.8,"Eb4",0.8,"Bb4",0.8,"G4",0.8,
    "Eb4",0.8,"Db4",0.8,"Ab4",0.8,"F4",0.8,"Db4",0.8,"C4",1.6)}

SONGS["Stranger Things Theme"] = {cat="🎬 Фильмы/ТВ", notes=S(
    "E4",0,"E4",0.5,"G4",0.5,"G4",0.5,"A4",0.5,"A4",0.5,
    "G4",0.5,"E4",0.5,"D4",0.5,"D4",0.5,"E4",0.5,"E4",0.5,
    "G4",0.5,"G4",0.5,"A4",0.5,"B4",0.5,"A4",0.5,"G4",1.0)}

-- 🌟 DISNEY
SONGS["Let It Go - Frozen"] = {cat="🌟 Disney", notes=S(
    "G4",0,"Ab4",0.3,"Bb4",0.3,"Eb5",0.3,"Db5",0.3,"C5",0.3,
    "Bb4",0.3,"Ab4",0.3,"G4",0.3,"F4",0.3,"Eb4",0.3,"F4",0.3,
    "G4",0.3,"Ab4",0.3,"Bb4",0.3,"C5",0.3,"Db5",0.3,"Eb5",0.6)}

SONGS["Beauty and the Beast"] = {cat="🌟 Disney", notes=S(
    "C4",0,"D4",0.5,"E4",0.5,"G4",0.5,"E4",0.5,"D4",0.5,"C4",0.5,
    "G3",0.5,"A3",0.5,"C4",0.5,"E4",0.5,"G4",0.5,"A4",0.5,
    "G4",0.5,"F4",0.5,"E4",0.5,"D4",0.5,"C4",1.0)}

SONGS["Circle of Life"] = {cat="🌟 Disney", notes=S(
    "Bb4",0,"Bb4",0.3,"Bb4",0.3,"F4",0.3,"Ab4",0.3,"Ab4",0.3,
    "Ab4",0.3,"Eb4",0.3,"Ab4",0.3,"Bb4",0.6,"F4",0.3,"Bb4",0.3,
    "Eb5",0.6,"Db5",0.3,"Eb5",0.3,"F5",0.6)}

SONGS["Under the Sea"] = {cat="🌟 Disney", notes=S(
    "C4",0,"C4",0.3,"G3",0.3,"G3",0.3,"A3",0.3,"A3",0.3,"G3",0.6,
    "F3",0.3,"F3",0.3,"E3",0.3,"E3",0.3,"D3",0.3,"D3",0.3,"C3",0.6,
    "G3",0.3,"G3",0.3,"F3",0.3,"F3",0.3,"E3",0.3,"E3",0.3,"D3",0.6)}

-- 🎹 ИНСТРУМЕНТАЛ
SONGS["River Flows in You"] = {cat="🎹 Инструментал", notes=S(
    "A3",0,"E4",0.3,"A4",0.3,"B4",0.3,"C5",0.3,"B4",0.3,"A4",0.3,
    "E4",0.3,"A3",0.3,"E4",0.3,"A4",0.3,"B4",0.3,"D5",0.3,"C5",0.3,
    "B4",0.3,"A4",0.3,"E4",0.3,"A3",0.3,"E4",0.3,"A4",0.3,
    "G4",0.3,"Fs4",0.3,"E4",0.3,"A4",0.6)}

SONGS["Gymnopédie No.1"] = {cat="🎹 Инструментал", notes=S(
    "D5",0,"B4",0.6,"A4",0.6,"G4",0.6,"E4",0.6,"G4",0.6,
    "A4",0.6,"G4",0.6,"E4",0.6,"D4",0.6,"G4",0.6,"B4",0.6,
    "D5",0.6,"E5",0.6,"D5",0.6,"B4",0.6,"A4",0.6,"G4",1.2)}

SONGS["Experience - Einaudi"] = {cat="🎹 Инструментал", notes=S(
    "E4",0,"B4",0.5,"E5",0.5,"B4",0.5,"E4",0.5,"B3",0.5,"E4",0.5,"B4",0.5,
    "D4",0.5,"A4",0.5,"D5",0.5,"A4",0.5,"D4",0.5,"A3",0.5,"D4",0.5,"A4",0.5,
    "C4",0.5,"G4",0.5,"C5",0.5,"G4",0.5,"C4",0.5,"G3",0.5,"C4",0.5,"G4",0.5)}

SONGS["Comptine dun autre ete"] = {cat="🎹 Инструментал", notes=S(
    "D4",0,"A4",0.3,"D5",0.3,"A4",0.3,"D4",0.3,"A4",0.3,"D5",0.3,"A4",0.3,
    "E4",0.3,"A4",0.3,"E5",0.3,"A4",0.3,"E4",0.3,"A4",0.3,"E5",0.3,"A4",0.3,
    "F4",0.3,"A4",0.3,"F5",0.3,"A4",0.3,"F4",0.3,"A4",0.3,"F5",0.3,"A4",0.3)}

-- 🔥 PHONK/EDM
SONGS["Phonk - Astronomia"] = {cat="🔥 Phonk/EDM", notes=S(
    "C4",0,"E4",0.2,"G4",0.2,"C5",0.2,"Bb4",0.2,"G4",0.2,
    "E4",0.2,"C4",0.2,"D4",0.2,"F4",0.2,"A4",0.2,"D5",0.2,
    "C5",0.2,"A4",0.2,"F4",0.2,"D4",0.2,"E4",0.2,"G4",0.2,
    "B4",0.2,"G4",0.2,"E4",0.2,"C4",0.4)}

SONGS["Avicii - Levels"] = {cat="🔥 Phonk/EDM", notes=S(
    "A4",0,"G4",0.2,"E4",0.2,"D4",0.2,"A4",0.2,"G4",0.2,"E4",0.2,"D4",0.2,
    "A4",0.2,"B4",0.2,"C5",0.2,"B4",0.2,"A4",0.2,"G4",0.2,"E4",0.2,"D4",0.4)}

SONGS["Phonk - Dead Inside"] = {cat="🔥 Phonk/EDM", notes=S(
    "A3",0,"C4",0.2,"E4",0.2,"A4",0.2,"G4",0.2,"F4",0.2,
    "E4",0.2,"D4",0.2,"C4",0.2,"Bb3",0.2,"A3",0.2,"G3",0.2,
    "Ab3",0.2,"Bb3",0.2,"C4",0.2,"Eb4",0.2,"F4",0.2,"Ab4",0.4)}

SONGS["Night Drive Phonk"] = {cat="🔥 Phonk/EDM", notes=S(
    "D4",0,"F4",0.25,"Ab4",0.25,"Bb4",0.25,"Ab4",0.25,"F4",0.25,
    "D4",0.25,"C4",0.25,"Bb3",0.25,"Ab3",0.25,"G3",0.25,"Ab3",0.25,
    "Bb3",0.25,"C4",0.25,"D4",0.25,"F4",0.25,"Ab4",0.25,"Bb4",0.5)}

-- ══════════════════════════════════════════
-- GUI
-- ══════════════════════════════════════════
if game.CoreGui:FindFirstChild("AutoPianoGUI") then
    game.CoreGui.AutoPianoGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoPianoGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 300, 0, 480)
Main.Position = UDim2.new(0, 10, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(13, 12, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(90, 65, 180)
stroke.Thickness = 1.5
stroke.Parent = Main

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 18, 42)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 10)
tc.Parent = TitleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(22, 18, 42)
titleFix.BorderSizePixel = 0
titleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "🎹 Auto Piano  |  " .. (function() local n=0 for _ in pairs(SONGS) do n=n+1 end return n end)() .. " песен"
TitleLabel.Size = UDim2.new(0.65, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.03, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(190, 165, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "─"
MinBtn.Size = UDim2.new(0, 28, 0, 22)
MinBtn.Position = UDim2.new(1, -62, 0.5, -11)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 90)
MinBtn.TextColor3 = Color3.fromRGB(210, 210, 255)
MinBtn.TextSize = 13
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 28, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 60)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

-- Контент
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -38)
Content.Position = UDim2.new(0, 0, 0, 38)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "⏸ Выбери песню"
StatusLabel.Size = UDim2.new(1, -16, 0, 26)
StatusLabel.Position = UDim2.new(0, 8, 0, 4)
StatusLabel.BackgroundColor3 = Color3.fromRGB(18, 16, 32)
StatusLabel.TextColor3 = Color3.fromRGB(140, 255, 140)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.BorderSizePixel = 0
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Content
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 6)
local sp = Instance.new("UIPadding")
sp.PaddingLeft = UDim.new(0, 7)
sp.Parent = StatusLabel

-- Управление в ряд
local CtrlFrame = Instance.new("Frame")
CtrlFrame.Size = UDim2.new(1, -16, 0, 28)
CtrlFrame.Position = UDim2.new(0, 8, 0, 34)
CtrlFrame.BackgroundTransparency = 1
CtrlFrame.Parent = Content

local StopBtn = Instance.new("TextButton")
StopBtn.Text = "⏹ Стоп"
StopBtn.Size = UDim2.new(0.45, 0, 1, 0)
StopBtn.BackgroundColor3 = Color3.fromRGB(160, 35, 55)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.TextSize = 12
StopBtn.Font = Enum.Font.GothamBold
StopBtn.BorderSizePixel = 0
StopBtn.Parent = CtrlFrame
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

local SpeedLabel2 = Instance.new("TextLabel")
SpeedLabel2.Text = "⚡ 1.0x"
SpeedLabel2.Size = UDim2.new(0.22, 0, 1, 0)
SpeedLabel2.Position = UDim2.new(0.48, 0, 0, 0)
SpeedLabel2.BackgroundTransparency = 1
SpeedLabel2.TextColor3 = Color3.fromRGB(180, 165, 220)
SpeedLabel2.TextSize = 12
SpeedLabel2.Font = Enum.Font.Gotham
SpeedLabel2.Parent = CtrlFrame

local SpdDn = Instance.new("TextButton")
SpdDn.Text = "−"
SpdDn.Size = UDim2.new(0.13, 0, 1, 0)
SpdDn.Position = UDim2.new(0.71, 0, 0, 0)
SpdDn.BackgroundColor3 = Color3.fromRGB(40, 35, 70)
SpdDn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpdDn.TextSize = 14
SpdDn.Font = Enum.Font.GothamBold
SpdDn.BorderSizePixel = 0
SpdDn.Parent = CtrlFrame
Instance.new("UICorner", SpdDn).CornerRadius = UDim.new(0, 5)

local SpdUp = Instance.new("TextButton")
SpdUp.Text = "+"
SpdUp.Size = UDim2.new(0.13, 0, 1, 0)
SpdUp.Position = UDim2.new(0.86, 0, 0, 0)
SpdUp.BackgroundColor3 = Color3.fromRGB(40, 35, 70)
SpdUp.TextColor3 = Color3.fromRGB(255, 255, 255)
SpdUp.TextSize = 14
SpdUp.Font = Enum.Font.GothamBold
SpdUp.BorderSizePixel = 0
SpdUp.Parent = CtrlFrame
Instance.new("UICorner", SpdUp).CornerRadius = UDim.new(0, 5)

-- Поиск
local SearchBox = Instance.new("TextBox")
SearchBox.PlaceholderText = "🔍 Поиск..."
SearchBox.Text = ""
SearchBox.Size = UDim2.new(1, -16, 0, 28)
SearchBox.Position = UDim2.new(0, 8, 0, 66)
SearchBox.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
SearchBox.TextColor3 = Color3.fromRGB(220, 215, 240)
SearchBox.PlaceholderColor3 = Color3.fromRGB(90, 85, 120)
SearchBox.TextSize = 12
SearchBox.Font = Enum.Font.Gotham
SearchBox.BorderSizePixel = 0
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Content
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 7)
local sbp = Instance.new("UIPadding")
sbp.PaddingLeft = UDim.new(0, 8)
sbp.Parent = SearchBox

-- Список
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -16, 1, -102)
ScrollFrame.Position = UDim2.new(0, 8, 0, 98)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(11, 10, 18)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(110, 85, 200)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = Content
Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 7)

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.Name
ListLayout.Padding = UDim.new(0, 2)
ListLayout.Parent = ScrollFrame

local ListPad = Instance.new("UIPadding")
ListPad.PaddingTop = UDim.new(0, 4)
ListPad.PaddingLeft = UDim.new(0, 4)
ListPad.PaddingRight = UDim.new(0, 4)
ListPad.Parent = ScrollFrame

-- ══════════════════════════════════════════
-- СОСТОЯНИЕ
-- ══════════════════════════════════════════
local State = { playing=false, speed=1.0, thread=nil, collapsed=false }
local songButtons = {}

local function setStatus(txt, col)
    StatusLabel.Text = txt
    StatusLabel.TextColor3 = col or Color3.fromRGB(140, 255, 140)
end

local function stopPlaying()
    State.playing = false
    if State.thread then pcall(task.cancel, State.thread) State.thread=nil end
    setStatus("⏸ Остановлено", Color3.fromRGB(200, 200, 200))
end

local function startSong(name)
    stopPlaying()
    local song = SONGS[name]
    if not song then return end
    State.playing = true
    setStatus("▶ " .. name, Color3.fromRGB(140, 255, 140))
    State.thread = task.spawn(function()
        for i, nd in ipairs(song.notes) do
            if not State.playing then break end
            if i > 1 and nd[2] > 0 then
                task.wait(nd[2] / State.speed)
            end
            if not State.playing then break end
            playNote(nd[1])
        end
        if State.playing then
            State.playing = false
            setStatus("✅ " .. name, Color3.fromRGB(180, 255, 180))
        end
    end)
end

local function buildList(filter)
    for _, b in ipairs(songButtons) do b:Destroy() end
    songButtons = {}

    local cats = {}
    local catOrder = {}
    for name, data in pairs(SONGS) do
        local show = filter=="" or name:lower():find(filter:lower(),1,true)
        if show then
            local c = data.cat or "Другое"
            if not cats[c] then cats[c]={} catOrder[#catOrder+1]=c end
            cats[c][#cats[c]+1] = name
        end
    end
    table.sort(catOrder)
    for _, c in ipairs(catOrder) do table.sort(cats[c]) end

    for _, cat in ipairs(catOrder) do
        local cl = Instance.new("TextLabel")
        cl.Text = " " .. cat
        cl.Size = UDim2.new(1, 0, 0, 20)
        cl.BackgroundColor3 = Color3.fromRGB(28, 22, 52)
        cl.TextColor3 = Color3.fromRGB(155, 125, 255)
        cl.TextSize = 10
        cl.Font = Enum.Font.GothamBold
        cl.BorderSizePixel = 0
        cl.TextXAlignment = Enum.TextXAlignment.Left
        cl.Parent = ScrollFrame
        Instance.new("UICorner", cl).CornerRadius = UDim.new(0, 5)
        songButtons[#songButtons+1] = cl

        for _, name in ipairs(cats[cat]) do
            local shortName = name:match("^[^%-]+%- (.+)") or name
            local btn = Instance.new("TextButton")
            btn.Text = " " .. shortName
            btn.Size = UDim2.new(1, 0, 0, 26)
            btn.BackgroundColor3 = Color3.fromRGB(18, 16, 30)
            btn.TextColor3 = Color3.fromRGB(200, 190, 230)
            btn.TextSize = 11
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 0
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = ScrollFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local n = name
            btn.MouseButton1Click:Connect(function()
                for _, b in ipairs(songButtons) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = Color3.fromRGB(18, 16, 30)
                        b.TextColor3 = Color3.fromRGB(200, 190, 230)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(55, 40, 105)
                btn.TextColor3 = Color3.fromRGB(255, 245, 255)
                startSong(n)
            end)
            songButtons[#songButtons+1] = btn
        end
    end
end

buildList("")

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0,0,0, ListLayout.AbsoluteContentSize.Y+8)
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    buildList(SearchBox.Text)
end)

StopBtn.MouseButton1Click:Connect(stopPlaying)

SpdDn.MouseButton1Click:Connect(function()
    State.speed = math.max(0.3, math.round((State.speed-0.1)*10)/10)
    SpeedLabel2.Text = "⚡ "..string.format("%.1f",State.speed).."x"
end)
SpdUp.MouseButton1Click:Connect(function()
    State.speed = math.min(3.0, math.round((State.speed+0.1)*10)/10)
    SpeedLabel2.Text = "⚡ "..string.format("%.1f",State.speed).."x"
end)

MinBtn.MouseButton1Click:Connect(function()
    State.collapsed = not State.collapsed
    if State.collapsed then
        TweenService:Create(Main, TweenInfo.new(0.2), {Size=UDim2.new(0,300,0,38)}):Play()
        MinBtn.Text = "□"
    else
        TweenService:Create(Main, TweenInfo.new(0.2), {Size=UDim2.new(0,300,0,480)}):Play()
        MinBtn.Text = "─"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopPlaying()
    ScreenGui:Destroy()
end)

print("🎹 AutoPiano v3.0 | Песен: "..(function() local n=0 for _ in pairs(SONGS) do n=n+1 end return n end)())
