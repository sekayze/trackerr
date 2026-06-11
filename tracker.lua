-- SCRIPT UTAMA TRACKER GROW A GARDEN
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1514649283503329491/TJIrLO5n-OBvzSIBv7PooEfykg3hJQtoTwMTkI5v_nhHUm7dFPL0vxw-RNUnGH2MpaoH"

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
    
    local payload = {
        content = dataText
    }
    
    pcall(function()
        HttpService:PostAsync(
            DISCORD_WEBHOOK_URL,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

local inventoryFolder = dapatkanFolderInventory()

if inventoryFolder then
    kirimDataKeDiscord(inventoryFolder)
    inventoryFolder.DescendantAdded:Connect(function(descendant)
        task.defer(function()
            local nama = string.lower(descendant.Name)
            if string.find(nama, "bronto") or string.find(nama, "trex") or string.find(nama, "t-rex") then
                kirimDataKeDiscord(inventoryFolder)
            end
        end)
    end)
    inventoryFolder.DescendantRemoving:Connect(function(descendant)
        task.defer(function()
            local nama = string.lower(descendant.Name)
            if string.find(nama, "bronto") or string.find(nama, "trex") or string.find(nama, "t-rex") then
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
