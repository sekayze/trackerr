-- SCRIPT TRACKER GROW A GARDEN (VERSION CLEAN)
local DISCORD_WEBHOOK_URL = _G.WebhookURL

if not DISCORD_WEBHOOK_URL then
    warn("⚠️ [ERROR]: _G.WebhookURL belum diatur!")
    return
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function dapatkanFolderInventory()
    return LocalPlayer:FindFirstChild("PlayerData") 
        or LocalPlayer:FindFirstChild("Inventory") 
        or (LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer)
end

local function dapatkanJumlahPet(folder)
    local jumlahBronto = 0
    local jumlahTrex = 0
    
    if folder then
        for _, object in pairs(folder:GetDescendants()) do
            local namaObjek = string.lower(object.Name)
            local nilaiObjek = (object:IsA("StringValue") or object:IsA("ObjectValue")) and string.lower(tostring(object.Value)) or ""
            
            if string.find(namaObjek, "brontosaurus") or string.find(nilaiObjek, "brontosaurus") then
                jumlahBronto = jumlahBronto + 1
            elseif string.find(namaObjek, "t-rex") or string.find(namaObjek, "trex") or string.find(nilaiObjek, "t-rex") or string.find(nilaiObjek, "trex") then
                jumlahTrex = jumlahTrex + 1
            end
        end
    end
    
    return jumlahBronto, jumlahTrex
end

local function kirimDataKeDiscord(folder)
    local bronto, trex = dapatkanJumlahPet(folder)
    local username = LocalPlayer.Name
    local dataText = string.format("DATA_UPDATE | User: %s | Bronto: %d | Trex: %d", username, bronto, trex)
    
    local payload = { content = dataText }
    pcall(function()
        HttpService:PostAsync(DISCORD_WEBHOOK_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
end

local inventoryFolder = dapatkanFolderInventory()
if inventoryFolder then
    kirimDataKeDiscord(inventoryFolder)
    inventoryFolder.DescendantAdded:Connect(function(descendant)
        task.defer(function()
            if string.find(string.lower(descendant.Name), "bronto") or string.find(string.lower(descendant.Name), "trex") then
                kirimDataKeDiscord(inventoryFolder)
            end
        end)
    end)
    inventoryFolder.DescendantRemoving:Connect(function(descendant)
        task.defer(function()
            if string.find(string.lower(descendant.Name), "bronto") or string.find(string.lower(descendant.Name), "trex") then
                kirimDataKeDiscord(inventoryFolder)
            end
        end)
    end)
else
    while true do
        kirimDataKeDiscord(LocalPlayer)
        task.wait(20)
    end
end
