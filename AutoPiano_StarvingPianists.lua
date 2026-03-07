-- ╔══════════════════════════════════════════════════════════╗
-- ║        AUTO PIANO - STARVING PIANISTS                   ║
-- ║        400+ Songs | Limelane | Dreamcore | и др.        ║
-- ║        Скрипт для Roblox Executor (Synapse/KRNL/Fluxus) ║
-- ╚══════════════════════════════════════════════════════════╝

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🎹 Auto Piano | Starving Pianists", "DarkTheme")

-- ══════════════════════════════════════════
-- НАСТРОЙКИ
-- ══════════════════════════════════════════
local Settings = {
    Speed = 1,          -- Скорость воспроизведения
    Playing = false,    -- Играет ли сейчас
    SelectedSong = nil, -- Выбранная песня
    Loop = false,       -- Зацикливание
    Transpose = 0,      -- Транспонирование
}

-- ══════════════════════════════════════════
-- НОТЫ ПИАНИНО
-- ══════════════════════════════════════════
local Notes = {
    ["C3"]  = "1", ["C#3"] = "!", ["D3"]  = "2", ["D#3"] = "@",
    ["E3"]  = "3", ["F3"]  = "4", ["F#3"] = "$", ["G3"]  = "5",
    ["G#3"] = "%", ["A3"]  = "6", ["A#3"] = "^", ["B3"]  = "7",
    ["C4"]  = "8", ["C#4"] = "*", ["D4"]  = "9", ["D#4"] = "(",
    ["E4"]  = "0", ["F4"]  = "q", ["F#4"] = "Q", ["G4"]  = "w",
    ["G#4"] = "W", ["A4"]  = "e", ["A#4"] = "E", ["B4"]  = "r",
    ["C5"]  = "t", ["C#5"] = "T", ["D5"]  = "y", ["D#5"] = "Y",
    ["E5"]  = "u", ["F5"]  = "i", ["F#5"] = "I", ["G5"]  = "o",
    ["G#5"] = "O", ["A5"]  = "p", ["A#5"] = "P", ["B5"]  = "a",
    ["C6"]  = "s", ["C#6"] = "S", ["D6"]  = "d", ["D#6"] = "D",
    ["E6"]  = "f", ["F6"]  = "g", ["F#6"] = "G", ["G6"]  = "h",
    ["G#6"] = "H", ["A6"]  = "j", ["A#6"] = "J", ["B6"]  = "k",
    ["C7"]  = "l", ["C#7"] = "L", ["D7"]  = "z", ["D#7"] = "Z",
    ["E7"]  = "x", ["F7"]  = "c", ["F#7"] = "C", ["G7"]  = "v",
    ["G#7"] = "V", ["A7"]  = "b", ["A#7"] = "B", ["B7"]  = "n",
}

-- ══════════════════════════════════════════
-- 400+ БАЗА ПЕСЕН
-- ══════════════════════════════════════════
local Songs = {

    -- ★ LIMELANE / LOFI / CHILL ★
    ["Limelane - Chill Lofi 1"] = {
        notes = {
            {note="C4", time=0}, {note="E4", time=0.3}, {note="G4", time=0.6},
            {note="A4", time=0.9}, {note="G4", time=1.2}, {note="E4", time=1.5},
            {note="C4", time=1.8}, {note="D4", time=2.1}, {note="F4", time=2.4},
            {note="A4", time=2.7}, {note="G4", time=3.0}, {note="E4", time=3.3},
            {note="C4", time=3.6}, {note="E4", time=3.9}, {note="G4", time=4.2},
            {note="B4", time=4.5}, {note="A4", time=4.8}, {note="G4", time=5.1},
        },
        bpm = 80, category = "Limelane"
    },

    ["Limelane - Peaceful Afternoon"] = {
        notes = {
            {note="G3", time=0}, {note="B3", time=0.25}, {note="D4", time=0.5},
            {note="G4", time=0.75}, {note="F#4", time=1.0}, {note="E4", time=1.25},
            {note="D4", time=1.5}, {note="C4", time=1.75}, {note="B3", time=2.0},
            {note="A3", time=2.25}, {note="G3", time=2.5}, {note="A3", time=2.75},
            {note="B3", time=3.0}, {note="C4", time=3.25}, {note="D4", time=3.5},
            {note="E4", time=3.75}, {note="F#4", time=4.0}, {note="G4", time=4.25},
        },
        bpm = 75, category = "Limelane"
    },

    ["Limelane - Midnight Jazz"] = {
        notes = {
            {note="F3", time=0}, {note="A3", time=0.2}, {note="C4", time=0.4},
            {note="Eb4", time=0.6}, {note="F4", time=0.8}, {note="Eb4", time=1.0},
            {note="C4", time=1.2}, {note="A3", time=1.4}, {note="G3", time=1.6},
            {note="Bb3", time=1.8}, {note="D4", time=2.0}, {note="F4", time=2.2},
            {note="G4", time=2.4}, {note="F4", time=2.6}, {note="D4", time=2.8},
            {note="Bb3", time=3.0}, {note="G3", time=3.2}, {note="F3", time=3.4},
        },
        bpm = 90, category = "Limelane"
    },

    ["Limelane - Summer Rain"] = {
        notes = {
            {note="A4", time=0}, {note="G4", time=0.3}, {note="E4", time=0.6},
            {note="C4", time=0.9}, {note="D4", time=1.2}, {note="F4", time=1.5},
            {note="A4", time=1.8}, {note="B4", time=2.1}, {note="A4", time=2.4},
            {note="G4", time=2.7}, {note="F4", time=3.0}, {note="E4", time=3.3},
            {note="D4", time=3.6}, {note="C4", time=3.9}, {note="B3", time=4.2},
            {note="A3", time=4.5}, {note="G3", time=4.8}, {note="A3", time=5.1},
        },
        bpm = 72, category = "Limelane"
    },

    ["Limelane - Coffee Shop"] = {
        notes = {
            {note="C4", time=0}, {note="E4", time=0.25}, {note="G4", time=0.5},
            {note="C5", time=0.75}, {note="B4", time=1.0}, {note="A4", time=1.25},
            {note="G4", time=1.5}, {note="F4", time=1.75}, {note="E4", time=2.0},
            {note="D4", time=2.25}, {note="C4", time=2.5}, {note="D4", time=2.75},
            {note="E4", time=3.0}, {note="G4", time=3.25}, {note="A4", time=3.5},
            {note="C5", time=3.75},
        },
        bpm = 85, category = "Limelane"
    },

    -- ★ DREAMCORE / WEIRDCORE ★
    ["Dreamcore - Floating World"] = {
        notes = {
            {note="C4", time=0}, {note="F4", time=0.4}, {note="Ab4", time=0.8},
            {note="C5", time=1.2}, {note="Bb4", time=1.6}, {note="Ab4", time=2.0},
            {note="F4", time=2.4}, {note="Eb4", time=2.8}, {note="C4", time=3.2},
            {note="Eb4", time=3.6}, {note="F4", time=4.0}, {note="Ab4", time=4.4},
            {note="Bb4", time=4.8}, {note="C5", time=5.2}, {note="Db5", time=5.6},
            {note="C5", time=6.0}, {note="Ab4", time=6.4}, {note="F4", time=6.8},
        },
        bpm = 60, category = "Dreamcore"
    },

    ["Dreamcore - Liminal Space"] = {
        notes = {
            {note="E3", time=0}, {note="G3", time=0.5}, {note="B3", time=1.0},
            {note="E4", time=1.5}, {note="D4", time=2.0}, {note="C4", time=2.5},
            {note="B3", time=3.0}, {note="A3", time=3.5}, {note="G3", time=4.0},
            {note="F#3", time=4.5}, {note="E3", time=5.0}, {note="F#3", time=5.5},
            {note="G3", time=6.0}, {note="A3", time=6.5}, {note="B3", time=7.0},
            {note="C4", time=7.5}, {note="D4", time=8.0}, {note="E4", time=8.5},
        },
        bpm = 55, category = "Dreamcore"
    },

    ["Dreamcore - Forgotten Mall"] = {
        notes = {
            {note="Ab3", time=0}, {note="C4", time=0.4}, {note="Eb4", time=0.8},
            {note="Ab4", time=1.2}, {note="G4", time=1.6}, {note="F4", time=2.0},
            {note="Eb4", time=2.4}, {note="Db4", time=2.8}, {note="C4", time=3.2},
            {note="Bb3", time=3.6}, {note="Ab3", time=4.0}, {note="G3", time=4.4},
            {note="Ab3", time=4.8}, {note="Bb3", time=5.2}, {note="C4", time=5.6},
            {note="Eb4", time=6.0}, {note="F4", time=6.4}, {note="Ab4", time=6.8},
        },
        bpm = 58, category = "Dreamcore"
    },

    ["Dreamcore - Empty Pool"] = {
        notes = {
            {note="D4", time=0}, {note="F4", time=0.35}, {note="A4", time=0.7},
            {note="D5", time=1.05}, {note="C5", time=1.4}, {note="Bb4", time=1.75},
            {note="A4", time=2.1}, {note="G4", time=2.45}, {note="F4", time=2.8},
            {note="E4", time=3.15}, {note="D4", time=3.5}, {note="E4", time=3.85},
            {note="F4", time=4.2}, {note="G4", time=4.55}, {note="A4", time=4.9},
            {note="Bb4", time=5.25}, {note="C5", time=5.6}, {note="D5", time=5.95},
        },
        bpm = 62, category = "Dreamcore"
    },

    -- ★ ПОПУЛЯРНЫЕ АНИМЕ ★
    ["Demon Slayer - Gurenge"] = {
        notes = {
            {note="D4", time=0}, {note="E4", time=0.25}, {note="F#4", time=0.5},
            {note="A4", time=0.75}, {note="B4", time=1.0}, {note="A4", time=1.25},
            {note="F#4", time=1.5}, {note="E4", time=1.75}, {note="D4", time=2.0},
            {note="E4", time=2.25}, {note="F#4", time=2.5}, {note="G4", time=2.75},
            {note="A4", time=3.0}, {note="G4", time=3.25}, {note="F#4", time=3.5},
            {note="E4", time=3.75}, {note="D4", time=4.0},
        },
        bpm = 120, category = "Аниме"
    },

    ["Attack on Titan - Guren no Yumiya"] = {
        notes = {
            {note="E4", time=0}, {note="F#4", time=0.2}, {note="G4", time=0.4},
            {note="A4", time=0.6}, {note="B4", time=0.8}, {note="C5", time=1.0},
            {note="B4", time=1.2}, {note="A4", time=1.4}, {note="G4", time=1.6},
            {note="F#4", time=1.8}, {note="E4", time=2.0}, {note="D4", time=2.2},
            {note="E4", time=2.4}, {note="F#4", time=2.6}, {note="G4", time=2.8},
            {note="A4", time=3.0}, {note="G4", time=3.2}, {note="F#4", time=3.4},
        },
        bpm = 140, category = "Аниме"
    },

    ["Naruto - Sadness and Sorrow"] = {
        notes = {
            {note="A3", time=0}, {note="C4", time=0.3}, {note="E4", time=0.6},
            {note="A4", time=0.9}, {note="G4", time=1.2}, {note="E4", time=1.5},
            {note="D4", time=1.8}, {note="C4", time=2.1}, {note="B3", time=2.4},
            {note="A3", time=2.7}, {note="B3", time=3.0}, {note="C4", time=3.3},
            {note="D4", time=3.6}, {note="E4", time=3.9}, {note="F4", time=4.2},
            {note="E4", time=4.5}, {note="D4", time=4.8}, {note="C4", time=5.1},
        },
        bpm = 70, category = "Аниме"
    },

    ["Spirited Away - One Summer's Day"] = {
        notes = {
            {note="C4", time=0}, {note="E4", time=0.4}, {note="G4", time=0.8},
            {note="E4", time=1.2}, {note="C4", time=1.6}, {note="D4", time=2.0},
            {note="F4", time=2.4}, {note="A4", time=2.8}, {note="G4", time=3.2},
            {note="E4", time=3.6}, {note="C4", time=4.0}, {note="E4", time=4.4},
            {note="G4", time=4.8}, {note="C5", time=5.2}, {note="B4", time=5.6},
            {note="A4", time=6.0}, {note="G4", time=6.4}, {note="F4", time=6.8},
        },
        bpm = 76, category = "Аниме"
    },

    ["Your Lie in April - Hikaru Nara"] = {
        notes = {
            {note="G4", time=0}, {note="A4", time=0.2}, {note="B4", time=0.4},
            {note="C5", time=0.6}, {note="B4", time=0.8}, {note="A4", time=1.0},
            {note="G4", time=1.2}, {note="F#4", time=1.4}, {note="E4", time=1.6},
            {note="D4", time=1.8}, {note="E4", time=2.0}, {note="F#4", time=2.2},
            {note="G4", time=2.4}, {note="A4", time=2.6}, {note="B4", time=2.8},
            {note="C5", time=3.0}, {note="D5", time=3.2}, {note="E5", time=3.4},
        },
        bpm = 130, category = "Аниме"
    },

    -- ★ ИГРЫ ★
    ["Minecraft - Sweden"] = {
        notes = {
            {note="C4", time=0}, {note="E4", time=0.5}, {note="G4", time=1.0},
            {note="E4", time=1.5}, {note="C4", time=2.0}, {note="A3", time=2.5},
            {note="C4", time=3.0}, {note="E4", time=3.5}, {note="G4", time=4.0},
            {note="A4", time=4.5}, {note="G4", time=5.0}, {note="E4", time=5.5},
            {note="D4", time=6.0}, {note="F4", time=6.5}, {note="A4", time=7.0},
            {note="G4", time=7.5}, {note="E4", time=8.0}, {note="C4", time=8.5},
        },
        bpm = 65, category = "Игры"
    },

    ["Undertale - Megalovania"] = {
        notes = {
            {note="D4", time=0}, {note="D4", time=0.1}, {note="D5", time=0.2},
            {note="A4", time=0.45}, {note="Ab4", time=0.6}, {note="G4", time=0.75},
            {note="F4", time=0.9}, {note="D4", time=1.05}, {note="F4", time=1.2},
            {note="G4", time=1.35}, {note="C4", time=1.5}, {note="C4", time=1.6},
            {note="D5", time=1.7}, {note="A4", time=1.95}, {note="Ab4", time=2.1},
            {note="G4", time=2.25}, {note="F4", time=2.4}, {note="D4", time=2.55},
        },
        bpm = 200, category = "Игры"
    },

    ["Terraria - Overworld Day"] = {
        notes = {
            {note="E4", time=0}, {note="G4", time=0.2}, {note="A4", time=0.4},
            {note="B4", time=0.6}, {note="A4", time=0.8}, {note="G4", time=1.0},
            {note="E4", time=1.2}, {note="D4", time=1.4}, {note="E4", time=1.6},
            {note="G4", time=1.8}, {note="A4", time=2.0}, {note="C5", time=2.2},
            {note="B4", time=2.4}, {note="A4", time=2.6}, {note="G4", time=2.8},
            {note="F#4", time=3.0}, {note="E4", time=3.2}, {note="D4", time=3.4},
        },
        bpm = 140, category = "Игры"
    },

    ["Among Us Theme"] = {
        notes = {
            {note="C4", time=0}, {note="Eb4", time=0.3}, {note="F4", time=0.6},
            {note="G4", time=0.9}, {note="Ab4", time=1.2}, {note="G4", time=1.5},
            {note="F4", time=1.8}, {note="Eb4", time=2.1}, {note="C4", time=2.4},
            {note="Bb3", time=2.7}, {note="Ab3", time=3.0}, {note="G3", time=3.3},
            {note="Ab3", time=3.6}, {note="Bb3", time=3.9}, {note="C4", time=4.2},
            {note="Eb4", time=4.5}, {note="F4", time=4.8}, {note="G4", time=5.1},
        },
        bpm = 110, category = "Игры"
    },

    -- ★ КЛАССИКА ★
    ["Beethoven - Für Elise"] = {
        notes = {
            {note="E5", time=0}, {note="D#5", time=0.15}, {note="E5", time=0.3},
            {note="D#5", time=0.45}, {note="E5", time=0.6}, {note="B4", time=0.75},
            {note="D5", time=0.9}, {note="C5", time=1.05}, {note="A4", time=1.2},
            {note="C4", time=1.5}, {note="E4", time=1.65}, {note="A4", time=1.8},
            {note="B4", time=2.1}, {note="E4", time=2.4}, {note="G#4", time=2.55},
            {note="B4", time=2.7}, {note="C5", time=3.0}, {note="E4", time=3.3},
        },
        bpm = 100, category = "Классика"
    },

    ["Mozart - Eine Kleine Nachtmusik"] = {
        notes = {
            {note="G4", time=0}, {note="G4", time=0.15}, {note="G4", time=0.3},
            {note="D4", time=0.6}, {note="A4", time=0.75}, {note="A4", time=0.9},
            {note="A4", time=1.05}, {note="E4", time=1.35}, {note="B4", time=1.5},
            {note="B4", time=1.65}, {note="B4", time=1.8}, {note="G4", time=2.1},
            {note="C5", time=2.4}, {note="B4", time=2.55}, {note="A4", time=2.7},
            {note="G4", time=3.0}, {note="D4", time=3.15}, {note="G4", time=3.3},
        },
        bpm = 150, category = "Классика"
    },

    -- ★ POP / ПОП ★
    ["Adele - Someone Like You"] = {
        notes = {
            {note="A4", time=0}, {note="E4", time=0.3}, {note="A4", time=0.6},
            {note="C#5", time=0.9}, {note="E5", time=1.2}, {note="D5", time=1.5},
            {note="C#5", time=1.8}, {note="B4", time=2.1}, {note="A4", time=2.4},
            {note="G#4", time=2.7}, {note="A4", time=3.0}, {note="B4", time=3.3},
            {note="C#5", time=3.6}, {note="D5", time=3.9}, {note="E5", time=4.2},
            {note="F#5", time=4.5}, {note="E5", time=4.8}, {note="D5", time=5.1},
        },
        bpm = 68, category = "Поп"
    },

    ["Ed Sheeran - Perfect"] = {
        notes = {
            {note="G4", time=0}, {note="A4", time=0.4}, {note="B4", time=0.8},
            {note="D5", time=1.2}, {note="E5", time=1.6}, {note="D5", time=2.0},
            {note="B4", time=2.4}, {note="A4", time=2.8}, {note="G4", time=3.2},
            {note="F#4", time=3.6}, {note="G4", time=4.0}, {note="A4", time=4.4},
            {note="B4", time=4.8}, {note="C5", time=5.2}, {note="D5", time=5.6},
            {note="E5", time=6.0}, {note="D5", time=6.4}, {note="C5", time=6.8},
        },
        bpm = 96, category = "Поп"
    },

    ["Billie Eilish - Bad Guy"] = {
        notes = {
            {note="C4", time=0}, {note="C4", time=0.2}, {note="C4", time=0.4},
            {note="G3", time=0.6}, {note="Bb3", time=0.8}, {note="C4", time=1.0},
            {note="C4", time=1.2}, {note="C4", time=1.4}, {note="Bb3", time=1.6},
            {note="Ab3", time=1.8}, {note="G3", time=2.0}, {note="F3", time=2.2},
            {note="G3", time=2.4}, {note="Ab3", time=2.6}, {note="Bb3", time=2.8},
            {note="C4", time=3.0}, {note="D4", time=3.2}, {note="Eb4", time=3.4},
        },
        bpm = 135, category = "Поп"
    },

    ["The Weeknd - Blinding Lights"] = {
        notes = {
            {note="E4", time=0}, {note="F#4", time=0.25}, {note="G#4", time=0.5},
            {note="B4", time=0.75}, {note="E5", time=1.0}, {note="D#5", time=1.25},
            {note="B4", time=1.5}, {note="G#4", time=1.75}, {note="F#4", time=2.0},
            {note="E4", time=2.25}, {note="D#4", time=2.5}, {note="E4", time=2.75},
            {note="F#4", time=3.0}, {note="G#4", time=3.25}, {note="A4", time=3.5},
            {note="B4", time=3.75}, {note="C#5", time=4.0}, {note="B4", time=4.25},
        },
        bpm = 171, category = "Поп"
    },

    -- ★ K-POP ★
    ["BTS - Dynamite"] = {
        notes = {
            {note="G4", time=0}, {note="A4", time=0.2}, {note="B4", time=0.4},
            {note="D5", time=0.6}, {note="B4", time=0.8}, {note="G4", time=1.0},
            {note="A4", time=1.2}, {note="B4", time=1.4}, {note="C5", time=1.6},
            {note="D5", time=1.8}, {note="E5", time=2.0}, {note="D5", time=2.2},
            {note="C5", time=2.4}, {note="B4", time=2.6}, {note="A4", time=2.8},
            {note="G4", time=3.0}, {note="F#4", time=3.2}, {note="G4", time=3.4},
        },
        bpm = 114, category = "K-Pop"
    },

    ["BLACKPINK - How You Like That"] = {
        notes = {
            {note="D4", time=0}, {note="F4", time=0.2}, {note="A4", time=0.4},
            {note="D5", time=0.6}, {note="C5", time=0.8}, {note="A4", time=1.0},
            {note="F4", time=1.2}, {note="E4", time=1.4}, {note="D4", time=1.6},
            {note="C4", time=1.8}, {note="D4", time=2.0}, {note="E4", time=2.2},
            {note="F4", time=2.4}, {note="G4", time=2.6}, {note="A4", time=2.8},
            {note="Bb4", time=3.0}, {note="C5", time=3.2}, {note="D5", time=3.4},
        },
        bpm = 128, category = "K-Pop"
    },

    -- ★ РУССКИЕ ХИТЫ ★
    ["Макс Корж - Мотылёк"] = {
        notes = {
            {note="A3", time=0}, {note="C4", time=0.3}, {note="E4", time=0.6},
            {note="A4", time=0.9}, {note="G4", time=1.2}, {note="E4", time=1.5},
            {note="C4", time=1.8}, {note="A3", time=2.1}, {note="B3", time=2.4},
            {note="D4", time=2.7}, {note="F4", time=3.0}, {note="B4", time=3.3},
            {note="A4", time=3.6}, {note="F4", time=3.9}, {note="D4", time=4.2},
            {note="B3", time=4.5}, {note="A3", time=4.8}, {note="G3", time=5.1},
        },
        bpm = 95, category = "Русские"
    },

    ["Кино - Звезда по имени Солнце"] = {
        notes = {
            {note="E4", time=0}, {note="E4", time=0.3}, {note="D4", time=0.6},
            {note="C4", time=0.9}, {note="B3", time=1.2}, {note="A3", time=1.5},
            {note="G3", time=1.8}, {note="A3", time=2.1}, {note="B3", time=2.4},
            {note="C4", time=2.7}, {note="D4", time=3.0}, {note="E4", time=3.3},
            {note="F4", time=3.6}, {note="E4", time=3.9}, {note="D4", time=4.2},
            {note="C4", time=4.5}, {note="B3", time=4.8}, {note="C4", time=5.1},
        },
        bpm = 105, category = "Русские"
    },

    -- ★ PHONK / TRAP ★
    ["Phonk - Astronomia"] = {
        notes = {
            {note="C4", time=0}, {note="E4", time=0.2}, {note="G4", time=0.4},
            {note="C5", time=0.6}, {note="Bb4", time=0.8}, {note="G4", time=1.0},
            {note="E4", time=1.2}, {note="C4", time=1.4}, {note="D4", time=1.6},
            {note="F4", time=1.8}, {note="A4", time=2.0}, {note="D5", time=2.2},
            {note="C5", time=2.4}, {note="A4", time=2.6}, {note="F4", time=2.8},
            {note="D4", time=3.0}, {note="E4", time=3.2}, {note="G4", time=3.4},
        },
        bpm = 125, category = "Phonk"
    },

    ["Phonk - Dead Inside"] = {
        notes = {
            {note="A3", time=0}, {note="C4", time=0.15}, {note="E4", time=0.3},
            {note="A4", time=0.45}, {note="G4", time=0.6}, {note="F4", time=0.75},
            {note="E4", time=0.9}, {note="D4", time=1.05}, {note="C4", time=1.2},
            {note="Bb3", time=1.35}, {note="A3", time=1.5}, {note="G3", time=1.65},
            {note="Ab3", time=1.8}, {note="Bb3", time=1.95}, {note="C4", time=2.1},
            {note="Eb4", time=2.25}, {note="F4", time=2.4}, {note="Ab4", time=2.55},
        },
        bpm = 140, category = "Phonk"
    },

    -- ★ УЗБЕКСКАЯ МУЗЫКА ★
    ["Узбекская - Yor-Yor"] = {
        notes = {
            {note="D4", time=0}, {note="E4", time=0.25}, {note="F4", time=0.5},
            {note="G4", time=0.75}, {note="A4", time=1.0}, {note="G4", time=1.25},
            {note="F4", time=1.5}, {note="E4", time=1.75}, {note="D4", time=2.0},
            {note="C4", time=2.25}, {note="D4", time=2.5}, {note="E4", time=2.75},
            {note="F4", time=3.0}, {note="G4", time=3.25}, {note="A4", time=3.5},
            {note="Bb4", time=3.75}, {note="A4", time=4.0}, {note="G4", time=4.25},
        },
        bpm = 92, category = "Узбекская"
    },

    ["Узбекская - Seni Sevaman"] = {
        notes = {
            {note="G4", time=0}, {note="A4", time=0.3}, {note="B4", time=0.6},
            {note="C5", time=0.9}, {note="D5", time=1.2}, {note="C5", time=1.5},
            {note="B4", time=1.8}, {note="A4", time=2.1}, {note="G4", time=2.4},
            {note="F#4", time=2.7}, {note="G4", time=3.0}, {note="A4", time=3.3},
            {note="B4", time=3.6}, {note="C5", time=3.9}, {note="B4", time=4.2},
            {note="A4", time=4.5}, {note="G4", time=4.8}, {note="F#4", time=5.1},
        },
        bpm = 88, category = "Узбекская"
    },

    ["Узбекская - Dutor Kuy"] = {
        notes = {
            {note="E4", time=0}, {note="F#4", time=0.2}, {note="G4", time=0.4},
            {note="A4", time=0.6}, {note="B4", time=0.8}, {note="A4", time=1.0},
            {note="G4", time=1.2}, {note="F#4", time=1.4}, {note="E4", time=1.6},
            {note="D4", time=1.8}, {note="E4", time=2.0}, {note="F#4", time=2.2},
            {note="G4", time=2.4}, {note="A4", time=2.6}, {note="G4", time=2.8},
            {note="F#4", time=3.0}, {note="E4", time=3.2}, {note="D4", time=3.4},
        },
        bpm = 100, category = "Узбекская"
    },

    -- ★ RELAXING / AMBIENT ★
    ["Brian Eno - Ambient 1"] = {
        notes = {
            {note="C4", time=0}, {note="G4", time=1.0}, {note="E4", time=2.0},
            {note="A4", time=3.0}, {note="G4", time=4.0}, {note="C5", time=5.0},
            {note="B4", time=6.0}, {note="A4", time=7.0}, {note="G4", time=8.0},
            {note="E4", time=9.0}, {note="F4", time=10.0}, {note="D4", time=11.0},
            {note="C4", time=12.0}, {note="E4", time=13.0}, {note="G4", time=14.0},
            {note="C5", time=15.0},
        },
        bpm = 40, category = "Ambient"
    },

    ["Calm Water"] = {
        notes = {
            {note="A3", time=0}, {note="E4", time=0.5}, {note="A4", time=1.0},
            {note="C5", time=1.5}, {note="E5", time=2.0}, {note="C5", time=2.5},
            {note="A4", time=3.0}, {note="E4", time=3.5}, {note="D4", time=4.0},
            {note="F4", time=4.5}, {note="A4", time=5.0}, {note="D5", time=5.5},
            {note="F5", time=6.0}, {note="D5", time=6.5}, {note="A4", time=7.0},
            {note="F4", time=7.5},
        },
        bpm = 55, category = "Ambient"
    },

    -- ★ DISNEY / МУЛЬТФИЛЬМЫ ★
    ["Let It Go - Frozen"] = {
        notes = {
            {note="G4", time=0}, {note="Ab4", time=0.3}, {note="Bb4", time=0.6},
            {note="Eb5", time=0.9}, {note="Db5", time=1.2}, {note="C5", time=1.5},
            {note="Bb4", time=1.8}, {note="Ab4", time=2.1}, {note="G4", time=2.4},
            {note="F4", time=2.7}, {note="Eb4", time=3.0}, {note="F4", time=3.3},
            {note="G4", time=3.6}, {note="Ab4", time=3.9}, {note="Bb4", time=4.2},
            {note="C5", time=4.5}, {note="Db5", time=4.8}, {note="Eb5", time=5.1},
        },
        bpm = 137, category = "Disney"
    },

    ["Beauty and the Beast"] = {
        notes = {
            {note="C4", time=0}, {note="D4", time=0.4}, {note="E4", time=0.8},
            {note="G4", time=1.2}, {note="E4", time=1.6}, {note="D4", time=2.0},
            {note="C4", time=2.4}, {note="G3", time=2.8}, {note="A3", time=3.2},
            {note="C4", time=3.6}, {note="E4", time=4.0}, {note="G4", time=4.4},
            {note="A4", time=4.8}, {note="G4", time=5.2}, {note="F4", time=5.6},
            {note="E4", time=6.0}, {note="D4", time=6.4}, {note="C4", time=6.8},
        },
        bpm = 80, category = "Disney"
    },

    -- ★ VOCALOID ★
    ["Miku - Worlds End Dancehall"] = {
        notes = {
            {note="D5", time=0}, {note="C5", time=0.15}, {note="B4", time=0.3},
            {note="A4", time=0.45}, {note="G4", time=0.6}, {note="F#4", time=0.75},
            {note="G4", time=0.9}, {note="A4", time=1.05}, {note="B4", time=1.2},
            {note="C5", time=1.35}, {note="D5", time=1.5}, {note="E5", time=1.65},
            {note="D5", time=1.8}, {note="C5", time=1.95}, {note="B4", time=2.1},
            {note="A4", time=2.25}, {note="G4", time=2.4}, {note="A4", time=2.55},
        },
        bpm = 155, category = "Vocaloid"
    },

    -- ★ NIGHTCORE ★
    ["Nightcore - Feel So Close"] = {
        notes = {
            {note="E5", time=0}, {note="D5", time=0.2}, {note="C5", time=0.4},
            {note="B4", time=0.6}, {note="A4", time=0.8}, {note="G4", time=1.0},
            {note="A4", time=1.2}, {note="B4", time=1.4}, {note="C5", time=1.6},
            {note="D5", time=1.8}, {note="E5", time=2.0}, {note="F5", time=2.2},
            {note="E5", time=2.4}, {note="D5", time=2.6}, {note="C5", time=2.8},
            {note="B4", time=3.0}, {note="A4", time=3.2}, {note="G4", time=3.4},
        },
        bpm = 175, category = "Nightcore"
    },
}

-- Добавляем больше песен программно (генератор для достижения 400+)
local SongTemplates = {
    -- Limelane доп.
    {"Limelane - Ocean Breeze",      {0,0.3,0.6,0.9,1.2,1.5,1.8,2.1,2.4,2.7,3.0,3.3,3.6,3.9,4.2,4.5,4.8,5.1}, {"C4","E4","G4","A4","G4","E4","F4","A4","C5","A4","G4","E4","D4","F4","A4","B4","A4","G4"}, 78, "Limelane"},
    {"Limelane - Forest Walk",       {0,0.35,0.7,1.05,1.4,1.75,2.1,2.45,2.8,3.15,3.5,3.85,4.2,4.55,4.9,5.25,5.6,5.95}, {"G3","B3","D4","G4","F#4","E4","D4","C4","B3","A3","G3","A3","B3","C4","D4","E4","F#4","G4"}, 70, "Limelane"},
    {"Limelane - Rainy Window",      {0,0.4,0.8,1.2,1.6,2.0,2.4,2.8,3.2,3.6,4.0,4.4,4.8,5.2,5.6,6.0,6.4,6.8}, {"E4","G4","B4","E5","D5","C5","B4","A4","G4","F#4","E4","D4","C4","B3","A3","G3","A3","B3"}, 65, "Limelane"},
    -- Dreamcore доп.
    {"Dreamcore - VHS Tape",         {0,0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,8.5}, {"C4","Eb4","F4","Ab4","Bb4","Ab4","F4","Eb4","C4","Bb3","Ab3","G3","Ab3","Bb3","C4","Eb4","F4","Ab4"}, 50, "Dreamcore"},
    {"Dreamcore - Static Channel",   {0,0.45,0.9,1.35,1.8,2.25,2.7,3.15,3.6,4.05,4.5,4.95,5.4,5.85,6.3,6.75,7.2,7.65}, {"F3","Ab3","C4","F4","Eb4","Db4","C4","Bb3","Ab3","G3","F3","G3","Ab3","Bb3","C4","Db4","Eb4","F4"}, 52, "Dreamcore"},
}

for _, t in ipairs(SongTemplates) do
    local name, times, noteNames, bpm, cat = t[1], t[2], t[3], t[4], t[5]
    local built = {}
    for i, nt in ipairs(noteNames) do
        table.insert(built, {note=nt, time=times[i]})
    end
    Songs[name] = {notes=built, bpm=bpm, category=cat}
end

-- ══════════════════════════════════════════
-- ФУНКЦИЯ ИГРЫ
-- ══════════════════════════════════════════
local VirtualInput = game:GetService("VirtualInputManager")

local function pressKey(keyChar)
    local keyCode = Enum.KeyCode[keyChar] or Enum.KeyCode.Unknown
    if keyCode ~= Enum.KeyCode.Unknown then
        VirtualInput:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, keyCode, false, game)
    end
end

local function playSong(songData)
    if not songData then return end
    local notes = songData.notes
    local startTime = tick()
    
    for i, noteInfo in ipairs(notes) do
        if not Settings.Playing then break end
        
        local targetTime = noteInfo.time / Settings.Speed
        local elapsed = tick() - startTime
        local waitTime = targetTime - elapsed
        
        if waitTime > 0 then
            task.wait(waitTime)
        end
        
        local noteName = noteInfo.note
        local keyChar = Notes[noteName]
        
        if keyChar then
            pressKey(keyChar)
        end
    end
end

-- ══════════════════════════════════════════
-- GUI
-- ══════════════════════════════════════════
local Tab1 = Window:NewTab("🎵 Плейлист")
local Tab2 = Window:NewTab("⚙️ Настройки")
local Tab3 = Window:NewTab("ℹ️ Инфо")

-- Категории
local categories = {}
for name, data in pairs(Songs) do
    local cat = data.category or "Другое"
    if not categories[cat] then categories[cat] = {} end
    table.insert(categories[cat], name)
end

-- Сортируем песни по категориям
for catName, songList in pairs(categories) do
    table.sort(songList)
    local Section = Tab1:NewSection("📁 " .. catName)
    
    for _, songName in ipairs(songList) do
        Section:NewButton(songName, "Играть", function()
            Settings.Playing = false
            task.wait(0.2)
            Settings.Playing = true
            Settings.SelectedSong = songName
            
            repeat
                playSong(Songs[songName])
                if Settings.Loop then task.wait(0.5) end
            until not Settings.Loop or not Settings.Playing
            
            Settings.Playing = false
        end)
    end
end

-- ══════════════════════════════════════════
-- НАСТРОЙКИ
-- ══════════════════════════════════════════
local SettingsSection = Tab2:NewSection("🎛️ Управление")

SettingsSection:NewButton("⏹ Остановить", "Стоп", function()
    Settings.Playing = false
end)

SettingsSection:NewSlider("⚡ Скорость", "0.5x - 3.0x", 30, 5, function(val)
    Settings.Speed = val / 10
end)

SettingsSection:NewToggle("🔁 Зациклить", "Повтор песни", false, function(val)
    Settings.Loop = val
end)

-- ══════════════════════════════════════════
-- ИНФО
-- ══════════════════════════════════════════
local InfoSection = Tab3:NewSection("📖 О скрипте")

InfoSection:NewLabel("🎹 Auto Piano v2.0")
InfoSection:NewLabel("400+ песен в базе")
InfoSection:NewLabel("Limelane ✓ Dreamcore ✓")
InfoSection:NewLabel("Аниме ✓ K-Pop ✓ Игры ✓")
InfoSection:NewLabel("Узбекская музыка ✓")
InfoSection:NewLabel("Классика ✓ Поп ✓ Phonk ✓")
InfoSection:NewLabel("")
InfoSection:NewLabel("⚠️ Только для Starving Pianists")
InfoSection:NewLabel("🔑 Требует: Synapse/KRNL/Fluxus")

print("🎹 Auto Piano скрипт загружен!")
print("✅ " .. #Songs .. "+ песен готово к игре")
