repeat wait() until game.IsLoaded
repeat wait() until game.Players.LocalPlayer

if game.PlaceId == (5208655184) then
   
   -- Services

   local VirtualUser = game:GetService("VirtualUser")
   local HttpService = game:GetService("HttpService")
   local RunService = game:GetService("RunService")
   local Workspace = game:GetService("Workspace")
   local Players = game:GetService("Players")
   
   -- Locales

   local Client = Players.LocalPlayer
   local Active = true
   
   local AssociatedBankerPart = nil
   local Thrown = Workspace:WaitForChild("Thrown")
   local Hook = ""
   
   local Artifacts = {
    ["Lannis's Amulet"] = false,
    ["Amulet of the White King"] = false, 
    ["Rift Gem"] = false, 
    ["Mysterious Artifact"] = false, 
    ["Philosopher's Stone"] = false,
    ["Spider Cloak"] = false,
    ["Fairfrozen"] = false,
    ["Phoenix Clown"] = false,
    ["Scroom Key"] = false  
   }
   
   local Bankers = { 
       
   }

   -- Functions
   
   local FindBankerPart = function(Position, NewName)
      local NPCS = Workspace:WaitForChild("NPCs")
      local Yield = 0
      local Returns = nil
      
      repeat wait()
      for i, x in pairs(NPCS:GetChildren()) do
        if x:FindFirstChild("HumanoidRootPart") and x.Name == "Banker" then
            local Root = x:FindFirstChild("HumanoidRootPart")
            local RealPos = Vector3.new(math.floor(Position.X), math.floor(Position.Y), math.floor(Position.Z))
            local RootPos = Vector3.new(math.floor(Root.Position.X), math.floor(Root.Position.Y), math.floor(Root.Position.Z))
            if RootPos == RealPos then
                Returns = Root
            end
        end
      end
      until Returns ~= nil 
      
      if _G.Settings ~= nil then
         if not table.find(_G.Settings["Blacklist"], Client.UserId) then
            if Returns == nil then 
               warn("FAILED TO FIND", NewName:upper()) 
            else 
               warn("FOUND", NewName:upper()) 
            end
         end
      end
         
  
      return Returns
   end
   
   local FindAssociatedBanker = function()
      for i, v in pairs(Bankers) do
         if table.find(v.Assigned, Client.UserId) then
            AssociatedBankerPart = v.HumanoidRootPart
            print("Associated Custom:", i)
            return AssociatedBankerPart
         end
      end
      
      AssociatedBankerPart = Bankers.Desert.HumanoidRootPart
      warn("associate:", Bankers.Desert.HumanoidRootPart.Name)
      print("Associated Default: Desert")
      return AssociatedBankerPart
   end
   
   local InDanger = function()
      local Danger = false
      
      if Client.Character then
         if Client.Character:FindFirstChild("Danger") then
            Danger = true
         end
      end
      
      return Danger
   end
   
   local ValidAndSelected = function(Item_Tip)
      for i, x in pairs(Artifacts) do
         if i == Item_Tip then
            if x then
               return true
            end
         end
      end
      
      return false
   end
   
   local DistanceCheck = function(PartOne, PartTwo, Distance)
     if Distance == nil then
        Distance = 100
     end
     
     if (PartOne.Position - PartTwo.Position).magnitude < Distance then
         return true,(PartOne.Position - PartTwo.Position).magnitude
      else
         return false
      end
   end
   
   local LoadCharacter = function()
      if Client.PlayerGui:FindFirstChild("StartMenu") then
         Client.PlayerGui:FindFirstChild("StartMenu").Finish:FireServer()
      end
   end
   
   local PostEmbed = function(Webhook, Embed_Data)
      pcall(function(...)
          syn.request({
              Url = Webhook, 
              Headers = {["Content-Type"] = "application/json"}, 
              Method = "POST", 
              Body = Embed_Data
          })
      end)
   end
   
   local CreateEmbed = function(Status, Account, Artifact, DropLocation)
      if DropLocation == nil then
         DropLocation = "NON-BANKER"
      end     
      
      local Embed_Data = {
       content = nil,
       embeds = {{
         title = ("META LOGGER [" .. Status:upper() .. "]"),
         description = ("====================================\nSOME LOSER JUST GOT HIS ARTIFACT STOLEN\n===================================="),
         color = 1,
         fields = {
          {name = "ACCOUNT:", value = Account, inline = true},{name = "ARTIFACT:", value = Artifact, inline = true}
         }
       }}
      }
      
      if Status == "ERROR" then
         Embed_Data.embeds[1].description = ("====================================\nALMOST GOT IT THIS TIME!\n====================================")
      end
  
      return HttpService:JSONEncode(Embed_Data)
   end
   
   local CollectItem = function(Object, Item)
      local Collecting_Tag = Instance.new("Folder")
      Collecting_Tag.Name = "Collection"
      Collecting_Tag.Parent = Object
      
      local ObjectPosition = Object.Position
      
      repeat wait()
        if Client.Character then
           if Client.Character:FindFirstChild("HumanoidRootPart") then
              local HRP = Client.Character:FindFirstChild("HumanoidRootPart")

              firetouchinterest(Object, HRP, 0)
              firetouchinterest(Object, HRP, 1)
           end
        end
      until Object.Parent ~= Thrown or Object == nil 
      
      local Embed,Sniped = '[content:"ERROR OCCURED!"]'
      local Nearest = nil
      
      for i, v in pairs(Bankers) do
         if v.HumanoidRootPart ~= nil then
            local Check = DistanceCheck(Object, v.HumanoidRootPart, 150)
            
            Nearest = i
         end
      end
      
      if Client.Backpack:FindFirstChild(Item) then
          Embed = CreateEmbed("SUCCESS", Client.Name, Item, Nearest)
          Sniped = true
     else
          Embed = CreateEmbed("ERROR", Client.Name, Item, Nearest)
          Sniped = false
      end
      
      PostEmbed(Hook, Embed)
      
      repeat wait() until not InDanger()
      
      Client:Kick("SNIPE OCCURED, RESULT: " .. tostring(Sniped):upper())
      
      if not Sniped then
         game:GetService("TeleportService"):Teleport(3016661674)
      end
   end
   
   local RunSnakerBot = function()
      local Function = function(i, x)
         if x.Name == "ToolBag" and not x:FindFirstChild("Collection") then
            local Valid = ValidAndSelected(x.BillboardGui.Tool.Text)
            local DCheck,Distance = DistanceCheck(x, AssociatedBankerPart, 150)

            if Valid and Active then
               if DCheck then
                  LoadCharacter()
                  CollectItem(x, x.BillboardGui.Tool.Text)
               end
            end
         end    
      end
      
      for i, x in pairs(Thrown:GetChildren()) do
         local Success,Error = pcall(Function, i, x)
         if not Success then print("ERROR:", Error) end
      end
   end
   
   local SetupGlobalSettings = function()
      if _G.Settings ~= nil then
         if table.find(_G.Settings["Blacklist"], Client.UserId) then
            return false
         end
         if table.find(_G.Settings["Desert"], Client.UserId) then
            table.insert(Bankers["Desert"].Assigned, Client.UserId)
         end
         if table.find(_G.Settings["Tundra"], Client.UserId) then
            table.insert(Bankers["Tundra"].Assigned, Client.UserId)
         end
         if table.find(_G.Settings["Ores"], Client.UserId) then
            table.insert(Bankers["Ores"].Assigned, Client.UserId)
         end
         if table.find(_G.Settings["Mage"], Client.UserId) then
            table.insert(Bankers["Mage"].Assigned, Client.UserId)
         end
         if table.find(_G.Settings["Eth"], Client.UserId) then
            table.insert(Bankers["Eth"].Assigned, Client.UserId)
         end
         if table.find(_G.Settings["Shore"], Client.UserId) then
            table.insert(Bankers["Shore"].Assigned, Client.UserId)
         end
         if _G.Settings["Artifacts"] ~= nil then
            for i, v in pairs(_G.Settings["Artifacts"]) do
               Artifacts[i] = v
               warn("Custom Artifact:", i, "\nSet:", tostring(v))
            end
         end
         if _G.Settings["Hook"] ~= nil then
            Hook = tostring(_G.Settings["Hook"])    
         end
         if _G.Settings["Script"] ~= nil then
            pcall(function(...)
                loadstring( _G.Settings["Script"])()
            end)
         end
         if _G.Settings["LowGFX"] == true then
            local Thread = coroutine.create(function()
                local LowGFX_Yield = 0
                
                repeat wait()
                  LowGFX_Yield = LowGFX_Yield + 1
                  settings().Rendering.QualityLevel = "Level01"
                until LowGFX_Yield > 99
            end)
            coroutine.resume(Thread)
            warn("Attempting LOW GFX", "Level-01")
         end
         if _G.Settings["GameVolume"] ~= nil then
            local Thread = coroutine.create(function()
                local GameVolume_Yield = 0
                
                if _G.Settings["GameVolume"] > 10 then
                   _G.Settings["GameVolume"] = 10
                end
                
                if _G.Settings["GameVolume"] < 0 then
                   _G.Settings["GameVolume"] = 0
                end
                
                _G.Settings["GameVolume"] = (_G.Settings["GameVolume"] / 10)
                
                repeat wait()
                  GameVolume_Yield = GameVolume_Yield + 1
                  UserSettings():GetService("UserGameSettings").MasterVolume = _G.Settings["GameVolume"]
                until GameVolume_Yield > 99
            end)
            coroutine.resume(Thread)
            warn("Attempting Game Volume", _G.Settings["GameVolume"])
         end
      end
      return true
   end
   
   local ToggleChat = function(self)
      if self:lower() == "/e dance" then Active = not Active end
      print("Enabled:", tostring(Active))
   end
   
   local SetupScript = function()
      if SetupGlobalSettings() ~= false then
         FindAssociatedBanker()
         RunService.Stepped:Connect(RunSnakerBot)
         Client.Chatted:Connect(ToggleChat)
      end
   end

   -- Setup
   
   Bankers = {
    ["Desert"] = {
     HumanoidRootPart = FindBankerPart(Vector3.new(-447.12, 334.094, 282.152), "Desert"),
     Assigned = {
         
     }
    },
    ["Tundra"] = {
     HumanoidRootPart = FindBankerPart(Vector3.new(6093.23, 1351.29, 148.178), "Tundra"),
     Assigned = {
         
     }
    },
    ["Eth"] = {
     HumanoidRootPart = FindBankerPart(Vector3.new(-64.3541, 205.495, 2363.51), "Isle Of Eth"),
     Assigned = {
         
     }
    },
    ["Mage"] = {
     HumanoidRootPart = FindBankerPart(Vector3.new(-410.59, 270.5, 994.757), "Mage Hideout"),
     Assigned = {
         
     }
    },
    ["Ores"] = {
     HumanoidRootPart = FindBankerPart(Vector3.new(2913.54, 303.75, -88.6681), "Oresfall"),
     Assigned = {
         
     }
    },
    ["Shore"] = {
     HumanoidRootPart = FindBankerPart(Vector3.new(1365.25, 423.197, 2814.2), "Shore"),
     Assigned = {
         
     }
    }
   }
   
   -- Final
   
   SetupScript()
end

wait(10)

Client = game.Players.LocalPlayer

if getconnections then
    for _, v in next, getconnections(Client.Idled) do
        v:Disable()
    end
end

Client.Idled:connect(function()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
