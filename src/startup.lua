-- startup.lua
-- Required Startup File for AetherOS
-- Copyright (c) 2026 Pancakse
-- SPDX-License-Identifier: MPL-2.0

local ENTRY = "boot/pxboot.lua"
local FALLBACK = "recovery.lua"

-- os.sleep() uses os.pullEvent, which dies on Ctrl+T. Use the raw version.
local function sleep(seconds)
  local t = os.startTimer(seconds)
  while true do
    local ev, id = os.pullEventRaw()
    if ev == "timer" and id == t then return end
  end
end

local function panic(msg)
  term.setBackgroundColour(colors.black)
  term.setTextColour(colors.white)
  term.clear(); term.setCursorPos(1, 1)
  print("pxboot: fatal error\n")
  print(tostring(msg) .. "\n")
  print("Rebooting in 5 seconds...")
  sleep(5)
  os.reboot()
end

local function run(path, ...)
  if not fs.exists(path) then return false, path .. " not found" end
  local fn, err = loadfile(path, nil, _G)
  if not fn then return false, err end
  return pcall(fn, ...)
end

local ok, err = run(ENTRY, ...)
if not ok then
  -- pxboot failed or is missing: try the recovery shell before giving up
  local rok, rerr = run(FALLBACK, err)
  if not rok then panic(err .. "\n" .. tostring(rerr)) end
end

-- Never fall through to the stock shell.
os.shutdown()
