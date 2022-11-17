-- loading

repeat wait() until game.IsLoaded
repeat wait() until game.Players.LocalPlayer

-- services

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- locales

local Settings = {["BagHook"] = nil, ["BackpackHook"] = nil, ["RogueCookie"] = nil}
local Artifacts = loadstring(game:HttpGet("https://pastebin.com/raw/ey87P8zZ"))()
local Client = Players.LocalPlayer
local Thrown = workspace:WaitForChild("Thrown")

Artifacts["Old Amulet"] = "https://static.wikia.nocookie.net/rogue-lineage/images/9/90/C85927ceef630bbba8e1f49d5035ec7a.png"
Settings["BagHook"] = "https://discord.com/api/webhooks/1042577106611224667/AYcGtlbE9CdrI8ZXuNxUx9Wm_0GyIVyttCCUt75LhzA-UxmOlcjYodW4yZwmE-e6sawZ"
Settings["RogueCookie"] = "erewtweygdfhfdhdrryereftgretg"
-- functions

local GetPhotoByText = function(Text)
   for i, v in pairs(Artifacts) do
      if Text == i then
         return v
      end
   end
   
   return "https://cdn.writermag.com/2019/03/question-marks.jpg"
end

local GetNearestBanker = function(Object)
   return "Desert 4 [DEFAULT]"
end

local JoinCheck = function(UserID)
    local JoinRequest;
      
    pcall(function() JoinRequest = syn.request({
          Url = "https://api.roblox.com/Users/" .. tostring(UserID) .. "/OnlineStatus",
          Method = "GET",
          Headers = {
           ["Cookie"] = ".ROBLOSECURITY=" .. Settings["RogueCookie"]
          }
    }) end)
  
    if JoinRequest ~= nil then
       if JoinRequest.GameId ~= nil then
          return true,"yup"
       else
          return false,"[ERROR?](https://www.roblox.com/home)"
       end
    else
       return false,"[INVALID COOKIE](https://www.roblox.com/login"
    end
end

local GetPlayers = function()
   local Player_Log = { }
   local Fix_Player = function(Name, ID)
      return ("[" .. Name .. "](https://www.roblox.com/users/" .. tostring(ID) .. ")")
   end
   
   if Settings["RogueCookie"] ~= nil then
       for i, v in pairs(Players:GetPlayers()) do
          local Check,Msg = JoinCheck(v.UserId)
          if Check == true then
             table.insert(Player_Log, Fix_Player(v.Name, v.UserId))
          end
       end
   else
       for i, v in pairs(Players:GetPlayers()) do
          table.insert(Player_Log, Fix_Player(v.Name, v.UserId))
       end      
   end
   
   if #Player_Log ~= 0 then
      return table.concat(Player_Log, ", ")
   else
      if Settings["RogueCookie"] == nil then
          return "[ERROR](https://www.roblox.com/home)"
      else
          return "[INVALID COOKIE](https://www.roblox.com/login)"
      end
   end
end

local CreateTag = function(Name, Parent)
   local Tag = Instance.new("Folder")
   Tag.Name = Name
   Tag.Parent = Parent
   
   return Tag
end

local CreateEmbed = function(Type, Artifact, Location, Player)
   local contentbody = { }
   local contentphoto = GetPhotoByText(Artifact)
   if Type:lower() == "bag" then
      contentbody = {
       content = nil,
       embeds = {{
         ["title"] = ("[BAG DROP]"),
         ["description"] = ("[PLAYERS]\n\n" .. GetPlayers()),
         ["color"] = 62975,
         ["fields"] = {
          {name = "ARTIFACT", value = Artifact, inline = false},
          {name = "LOCATION", value = Location, inline = false}
         },
         ["thumbnail"] = {
          ["url"] = contentphoto
         }
       }}
      }   
   elseif Type:lower() == "backpack" then
      contentbody = {
       content = nil,
       embeds = {{
         ["title"] = ("[BACKPACK LOG]"),
         ["description"] = ("[PLAYERS]\n\n" .. GetPlayers()),
         ["color"] = 62975,
         ["fields"] = {
          {name = "ARTIFACT", value = Artifact, inline = false},
          {name = "HOLDER", value = tostring(Player.Name), inline = false},
          {name = "FOUND BY", value = tostring(Client.Name), inline = false}
         },
         ["thumbnail"] = {
          ["url"] = contentphoto
         }
       }}
      }
   else
      contentbody = {
       content = "@here an error occured!?"
      }
   end
   
   return HttpService:JSONEncode(contentbody)
end

local SendHook = function(Hook, Data)
   syn.request({Url = Hook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = Data})
   return true
end

local BackpackConnection = function(Player)
   if Player:FindFirstChild("Backpack") then
      local Backpack = Player:FindFirstChild("Backpack")
      local IdentifyAndLog = function(Tool)
          for i, v in pairs(Artifacts) do
             if tostring(Tool.Name) == i and not Tool:FindFirstChild("Logged") then
                
                local Create_Tag = CreateTag("Logged", Tool)
                local Embed_Backpack = CreateEmbed("backpack", i, nil, Player)
                
                if Settings["BackpackHook"] ~= nil then
                
                   local Hook = Settings["BackpackHook"]
                   
                   SendHook(Hook, Embed_Backpack)
                end
             end
          end          
      end
      Backpack.ChildAdded:Connect(function(Tool)
          IdentifyAndLog(Tool)
      end)
      for i, Tool in pairs(Backpack:GetChildren()) do
          IdentifyAndLog(Tool)
      end
   end
end

local CharacterConnection = function(Player)
   if Player.Character then
      local Character = Player.Character
      local IdentifyAndLog = function(Tool)
          for i, v in pairs(Artifacts) do
             if tostring(Tool.Name) == i and not Tool:FindFirstChild("Logged") then
                
                local Create_Tag = CreateTag("Logged", Tool)
                local Embed_Backpack = CreateEmbed("backpack", i, nil, Player)
                
                if Settings["BackpackHook"] ~= nil then
                
                   local Hook = Settings["BackpackHook"]
                   
                   SendHook(Hook, Embed_Backpack)
                end
             end
          end
      end
      Character.ChildAdded:Connect(function(Tool)
          IdentifyAndLog(Tool)
      end)
      for i, Tool in pairs(Character:GetChildren()) do
          IdentifyAndLog(Tool)
      end
   end
end

local BagConnection = function(Object)
   if Object.Name == "ToolBag" then
      local ItemDropped = nil
      
      pcall(function(...)
          repeat wait() ItemDropped = Object.BillboardGui.Tool.Text until ItemDropped ~= nil
      end) 
      
      for i, v in pairs(Artifacts) do
         if i == ItemDropped then
            local Bag_Embed = CreateEmbed("bag", i, GetNearestBanker(Object), nil)
            
            if Settings["BagHook"] ~= nil then
               local Hook = Settings["BagHook"]
               
               SendHook(Hook, Bag_Embed)
            end
         end
      end 
   end
end

local SetupPlayer = function(Player)
   if Player ~= Client and not Player:FindFirstChild("Connected") or true then
      local Tag = CreateTag("Connected", Player)
      
      repeat wait() until Player.Character or Player == nil
      
      Player.CharacterAdded:Connect(function(Character)
          CharacterConnection(Player)
      end)
      
      CharacterConnection(Player)
      BackpackConnection(Player)
   end
end

-- finalization

Players.PlayerAdded:Connect(SetupPlayer)
Thrown.ChildAdded:Connect(BagConnection)

for i, Player in pairs(Players:GetPlayers()) do
   SetupPlayer(Player)
end
