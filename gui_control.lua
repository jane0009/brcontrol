-- load requires
os.loadAPI('button')



-- variables
local is_shell = false

local has_modem = false
local wireless_modem

local monitor
-- end variables



-- monitor detection
monitor = peripheral.find('monitor')

if not monitor then
  print('ERROR! no monitor was detected. gui control cannot run. defaulting to shell mode...')
  is_shell = true
end
-- end monitor detection



-- wireless modem detection
local modems = {peripheral.find('modem')}
for _, side in pairs(modems) do
  if not temp_wrap.isWireless() and not wireless_modem and not has_modem then
      has_modem = true
      wireless_modem = peripheral.wrap(side)
  end
end

if not wireless_modem then
  print('WARNING! no wireless modem was detected! this means that the remote control program will not work.')
end
-- end modem detection



-- communicate with remote computers (pocket comp, op glasses)



-- spawn gui on monitor



-- menu functions

-- end menu functions



-- reactor control submenu functions

-- turbine control submenu functions

-- end submenu functions