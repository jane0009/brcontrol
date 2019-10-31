local button_url = '4cQceyM6'
local button_name = 'button'

local gui_url = ''
local gui_name = 'gui_control'

local reactor_url = ''
local reactor_name = 'reactor_control'

local tab_max

-- make sure that everything is installed...
if not fs.exists(button_name) then
  shell.run('pastebin get ' .. button_url .. ' ' .. button_name)
end

if not fs.exists(gui_name) then
  shell.run('pastebin get ' .. gui_url .. ' ' .. gui_name)
end

if not fs.exists(reactor_name) then
  shell.run('pastebin get ' .. reactor_url .. ' ' .. reactor_name)
end

-- let's hope we can run some programs in parallel! otherwise we're fucked.
if not parallel then
  print('error! you are running an older version of ComputerCraft that doesn\'t support parallel processes. please update the mod to use this program.')
end

local function gui()
  shell.run(gui_name)
end

local function control()
  shell.run(reactor_name)
end

-- here comes the fun part
parallel.waitForAny(gui, control)


--- TODO LIST ---
--- connect to reactors and turbines
--- create gui
--- monitor coolant/power output & control rotors/rods individually
--- add option for manual management
--- OpenPeriphs glasses?
--- Pocket Computer
--- make a better manager