-- variables

local has_modem = false
local modem

reactors = {}
turbines = {}

-- end variables



-- modem detection

local modems = {peripheral.find('modem')}
for _, side in pairs(modems) do
  if not modem and not has_modem then
      has_modem = true
      modem = peripheral.wrap(side)
  end
end

if not modem then
  error('ERROR! no modem, wired or wireless could be detected. please attach one to the computer and to any reactor/turbine computer port that you want to be controlled.')
end

-- end modem detection



-- reactor and turbine detection
reactors = {peripheral.find('BigReactors-Reactor')}
turbines = {peripheral.find('BigReactors-Turbine')}
-- end reactor and turbine detection



--- all reactor functions should take a reactor object as a parameter
--- the same applies to turbines
--- for this reason, reactor and turbine functions should either be 
--- separated or documented as supporting both



-- begin reactor functions

-- end reactor functions



-- begin turbine functions

-- end turbine functions