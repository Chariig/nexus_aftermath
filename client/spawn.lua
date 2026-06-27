NA.Client.Spawn = {}

function NA.Client.Spawn.Init()
    ShutdownLoadingScreen()
    DoScreenFadeOut(0)
    SetPlayerControl(PlayerId(), false, 0)

    local ped = PlayerPedId()
    SetEntityVisible(ped, false, false)
    FreezeEntityPosition(ped, true)

    TriggerServerEvent('na:requestCharacters')
end

RegisterNetEvent('na:characterList')
AddEventHandler('na:characterList', function(characters)
    NA.Client.Characters = characters

    if #characters == 0 then
        NA.Client.Spawn.OpenCreator()
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'showSelector', characters = characters })
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    TriggerServerEvent('na:selectCharacter', data.citizenId)
    cb({})
end)

RegisterNUICallback('newCharacter', function(_, cb)
    NA.Client.Spawn.OpenCreator()
    cb({})
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    TriggerServerEvent('na:deleteCharacter', data.citizenId)
    cb({})
end)

function NA.Client.Spawn.OpenCreator()
    NA.Debug('OpenCreator called')

    local ped = PlayerPedId()

    local model = joaat('mp_m_freemode_01')
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)

    Citizen.Wait(100)

    ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, true)

    local pos = vector3(0.0, 0.0, 200.0)
    SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, true)
    SetEntityHeading(ped, 0.0)
    SetFocusPosAndVec(pos.x, pos.y, pos.z, 0.0, 0.0, 0.0)

    Citizen.Wait(100)

    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, pos.x + 2.0, pos.y, pos.z + 0.3)
    SetCamRot(cam, 0.0, 0.0, 270.0, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, true)

    SendNUIMessage({ type = 'showCreator', editData = nil })

    NA.Client.CreatorCam = cam
    NA.Client.CreatorActive = true

    Citizen.CreateThread(function()
        while NA.Client.CreatorActive do
            if NA.Client.CreatorAppearance then
                NA.Client.Spawn.ApplyAppearance(NA.Client.CreatorAppearance)
            end
            Citizen.Wait(100)
        end
    end)
end

RegisterNUICallback('updateAppearance', function(data, cb)
    NA.Client.CreatorAppearance = data
    cb({})
end)

RegisterNUICallback('saveCharacter', function(data, cb)
    if NA.Client.CreatorCam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(NA.Client.CreatorCam, false)
        NA.Client.CreatorCam = nil
    end
    NA.Client.CreatorActive = false
    SetNuiFocus(false, false)

    local ped = PlayerPedId()
    SetEntityVisible(ped, false, false)

    SetFocusPosAndVec(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

    TriggerServerEvent('na:saveCharacter', {
        firstname = data.firstname,
        lastname = data.lastname,
        gender = data.gender,
        dateofbirth = data.dateofbirth,
        appearance = NA.Client.CreatorAppearance or {},
    })

    cb({})
end)

RegisterNUICallback('cancelCharacter', function(_, cb)
    SetNuiFocus(false, false)

    if NA.Client.CreatorCam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(NA.Client.CreatorCam, false)
        NA.Client.CreatorCam = nil
        SetFocusPosAndVec(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    end
    NA.Client.CreatorActive = false

    local ped = PlayerPedId()
    SetEntityVisible(ped, false, false)

    NA.Client.Spawn.Init()

    cb({})
end)

function NA.Client.Spawn.ApplyAppearance(app)
    local ped = PlayerPedId()

    local gender = app.gender or 'male'
    local model = gender == 'female' and joaat('mp_f_freemode_01') or joaat('mp_m_freemode_01')
    if GetEntityModel(ped) ~= model then
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(0) end
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        Citizen.Wait(50)
        ped = PlayerPedId()
    end

    SetPedComponentVariation(ped, 0, 0, 0, 0)
    SetPedComponentVariation(ped, 2, 0, 0, 0)
    SetPedComponentVariation(ped, 4, 0, 0, 0)
    SetPedComponentVariation(ped, 6, 0, 0, 0)
    SetPedComponentVariation(ped, 11, gender == 'female' and 5 or 15, 0, 0)

    local features = app.features or {}
    for i = 0, 19 do
        SetPedFaceFeature(ped, i, features[tostring(i)] or 0.0)
    end

    local hair = app.hair or {}
    if hair.style ~= nil then SetPedComponentVariation(ped, 2, hair.style, hair.color or 0, hair.highlight or 0) end

    local eyebrows = app.eyebrows or {}
    if eyebrows.style ~= nil then SetPedHeadOverlay(ped, 2, eyebrows.style, eyebrows.opacity or 1.0) end
    if eyebrows.color ~= nil then SetPedHeadOverlayColor(ped, 2, 1, eyebrows.color, 0) end

    if app.eyeColor ~= nil then SetPedEyeColor(ped, app.eyeColor) end

    local beard = app.beard or {}
    if beard.style ~= nil then SetPedHeadOverlay(ped, 1, beard.style, 1.0) end
    if beard.color ~= nil then SetPedHeadOverlayColor(ped, 1, 1, beard.color, 0) end

    if app.blemishes ~= nil and app.blemishes > 0 then SetPedHeadOverlay(ped, 0, app.blemishes, 1.0) end
    if app.ageing ~= nil and app.ageing > 0 then SetPedHeadOverlay(ped, 3, app.ageing, 1.0) end
    if app.complexion ~= nil and app.complexion > 0 then SetPedHeadOverlay(ped, 6, app.complexion, 1.0) end
    if app.freckles ~= nil and app.freckles > 0 then SetPedHeadOverlay(ped, 9, app.freckles, 1.0) end
    if app.makeup ~= nil and app.makeup > 0 then SetPedHeadOverlay(ped, 4, app.makeup, 1.0) end
    if app.blush ~= nil and app.blush > 0 then SetPedHeadOverlay(ped, 5, app.blush, 1.0) end
    if app.lipstick ~= nil and app.lipstick > 0 then SetPedHeadOverlay(ped, 8, app.lipstick, 1.0) end
    if app.chest ~= nil and app.chest > 0 then SetPedHeadOverlay(ped, 10, app.chest, 1.0) end
    if app.bodyBlemishes ~= nil and app.bodyBlemishes > 0 then SetPedHeadOverlay(ped, 12, app.bodyBlemishes, 1.0) end
end

RegisterNetEvent('na:characterSpawn')
AddEventHandler('na:characterSpawn', function(data)
    NA.Client.PlayerData = data.charData
    NA.Client.Infection = data.infection or {}
    NA.Client.Stats = data.stats or {}
    NA.Client.Skills = data.skills or {}
    NA.Client.Reputation = data.reputation or {}
    NA.Client.Config = data.config
    NA.Client.WorldData = data.world
    NA.Client.IsLoaded = true

    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    SetPlayerControl(PlayerId(), true, 0)

    if NA.Client.PlayerData.appearance then
        NA.Client.Spawn.ApplyAppearance(NA.Client.PlayerData.appearance)
    end

    if NA.Client.PlayerData.position and NA.Client.PlayerData.position.x then
        SetEntityCoords(ped, NA.Client.PlayerData.position.x, NA.Client.PlayerData.position.y, NA.Client.PlayerData.position.z)
        if NA.Client.PlayerData.position.heading then
            SetEntityHeading(ped, NA.Client.PlayerData.position.heading)
        end
    end

    DoScreenFadeIn(1000)

    NA.Client.SetupKeybinds()
    NA.Debug('Player spawned:', NA.Client.PlayerData.citizenId)
    TriggerEvent('na:ready', NA.Client.PlayerData)

    Citizen.CreateThread(function()
        while NA.Client.IsLoaded do
            Citizen.Wait(3000)
            if NA.Client.PlayerData and NA.Client.PlayerData.citizenId then
                TriggerServerEvent('na:updatePosition', GetEntityCoords(ped), GetEntityHeading(ped))
            end
        end
    end)
end)
