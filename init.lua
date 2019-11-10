local button_url = '4cQceyM6'
local button_name = 'button'
local json_url = '4nRg9CHU'
local json_name = 'json'

local gui_name = 'gui_control.lua'
local reactor_name = 'reactor_control.lua'

local git_owner = 'janeptrv'
local git_repo = 'brcontrol'
local repo_cache
local commits
local commit_cache = {}
local latest_files = {}


local parse_timestamp
local api_request
local download_git_index
local download_git_file
local sync_repo
local check_version
local compare_timestamp
local get_file_stamp
local save_data
local load_data

-- make sure that everything is installed...

-- button api
if not fs.exists(button_name) then
  shell.run('pastebin get ' .. button_url .. ' ' .. button_name)
end

-- json api
if not fs.exists(json_name) then
  shell.run('pastebin get ' .. json_url .. ' ' .. json_name)
end

-- load json api
os.loadAPI('json')

-- git functions

parse_timestamp = function(timestamp)
  if not timestamp then return 0 end 
  local year,month,day,hour,minute,second = string.match(timestamp, '(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z')
  local integer_time = (tonumber(year) * 31556926) + (tonumber(month) * 2629743) + (tonumber(day) * 86400) + (tonumber(hour) * 3600) + (tonumber(minute) * 60) + tonumber(second)
  return tonumber(integer_time)
end

get_repo_val = function(type)
  if not repo_cache then
    request_str =  api_request('https://api.github.com/repos/' .. git_owner .. '/' .. git_repo)
    repo_cache = json.decode(request_str) 
  end

  if repo_cache[type] then
    return repo_cache[type]
  else
    return nil
  end
end

api_request = function(url, headers, params)

  local requesting = true
  local resp_text = nil

  if not http then error('http is not enabled!') end
  
  if not headers then
    headers = {}
  end
  if not params then
    print('requesting ' .. url .. ' for download...')
    http.request(url, nil, headers) -- this is a get request  
  else
    print('WARNING! passing parameters to api_request will result in a PUT or PATCH request! you probably don\'t have authentication, so don\'t do that!')
    http.request(url, params, headers) -- this is a put request (we should never need this!)
  end

  while requesting do
    local event, url, text = os.pullEvent()

    if event == 'http_success' then
      local response = text.readAll()
      text.close()
      resp_text = response
      requesting = false
    elseif event == 'http_failure' then
      print('failure: ' .. tostring(text))
      error('git request failed. ')
    else
      --print(event)
    end
  end
  return resp_text
end

download_git_index = function()
  if not commits then
    local url = get_repo_val('commits_url') 
    if url == nil then error('url was nil') end
    local formatted_url = string.sub(url,1,string.len(url) - 6)
    commits = json.decode(api_request(formatted_url))
    for _, c in pairs(commits) do
      if c then
        if c.sha and commit_cache and not commit_cache[c.sha] then 
          commit_cache[c.sha] = {}
          commit_cache[c.sha].date = parse_timestamp(c.commit.author.date)
          local temp_table = json.decode(api_request(formatted_url .. "/" .. c.sha))
          commit_cache[c.sha].files = {}
          for _, file in pairs(temp_table.files) do
            if file.status == 'added' or file.status == 'modified' then
              commit_cache[c.sha].files[file.sha] = file.filename
              local ts = parse_timestamp(c.commit.author.date)
              if not latest_files[file.filename] or compare_timestamp(ts, latest_files[file.filename]) then
                latest_files[file.filename] = ts
              end
            end
          end
        end
      end
    end
  end
  return latest_files
end

download_git_file = function(file_path, timestamp)
  if not timestamp then 
    if latest_files[file_path] then 
      timestamp = tonumber(latest_files[file_path])
    else
      timestamp = 0
    end
  end
  local data = api_request('https://raw.githubusercontent.com/' .. git_owner .. '/' .. git_repo .. '/master/' .. file_path)
  -- save file ...
  if fs.exists(file_path) then fs.delete(file_path) end
  local file = fs.open(file_path, 'w')
  file.writeLine('--' .. timestamp)
  file.write(data)
  file.close()
end

sync_repo = function()
  load_data()
    local index = download_git_index()
    for filename, timestamp in pairs(index) do
      if not fs.exists(filename) or not check_version(filename) then
        print('sync_repo check' .. filename .. " " .. tostring(fs.exists(filename)) .. " " .. tostring(check_version(filename)))
        --download_git_file(filename)
      end
    end
end

check_version = function(local_file)
  local is_up_to_date = false
  for _,commit in pairs(commit_cache) do
    if commit.files[local_file] then
      local t = compare_timestamp(parse_timestamp(commit.commit.date), get_file_stamp(local_file))
      print('timestamp checking' .. tostring(is_up_to_date) .. " " .. tostring(t))
      is_up_to_date = is_up_to_date or t
    end
  end
  return is_up_to_date
end

compare_timestamp = function(stamp1, stamp2)
  print(stamp1 .. "stamp" .. stamp2)
  if tonumber(stamp1) > tonumber(stamp2) then
    return true
  else
    return false
  end
end

get_file_stamp = function(file)
  local timestamp = 0
  if fs.exists(file) then
    local file = fs.open(file, 'r')
    local data = file.readLine()
    timestamp = tonumber(string.match(data, '--(%d+)'))
  end
  return timestamp
end

save_data = function()
  local data = textutils.serializeJSON(commit_cache)
  if fs.exists('commits.sav') then fs.delete('commits.sav') end
  local file = fs.open('commits.sav', 'w')
  file.write(data)
  file.close()

  local data = textutils.serializeJSON(latest_files)
  if fs.exists('files.sav') then fs.delete('files.sav') end
  local file = fs.open('files.sav', 'w')
  file.write(data)
  file.close()
end

load_data = function()
  if fs.exists('commits.sav') then
    local file = fs.open('commits.sav', 'r')
    local data = json.decode(file.readAll())
    if data then commit_cache = data end 
    file.close()
  end
  if fs.exists('files.sav') then
    local file = fs.open('files.sav', 'r')
    local data = json.decode(file.readAll())
    if data then latest_files = data end
    file.close()
  end
end
-- end git functions

--git files
sync_repo()
save_data()

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
--- NEED!! fix commit timestamps always being 0
--- connect to reactors and turbines
--- create gui
--- monitor coolant/power output & control rotors/rods individually
--- add option for manual management
--- OpenPeriphs glasses?
--- Pocket Computer