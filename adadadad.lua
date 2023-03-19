-- // boui moment!!!
-- // inspired by splix

local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local plrs = game:GetService("Players")
local stats = game:GetService("Stats")

local lplr = plrs.LocalPlayer
local mouse = lplr:GetMouse()

-- // some locals!!

local load_start = tick()

-- / vector 2

local v2new = Vector2.new-- services
local players = game:GetService("Players");
local runService = game:GetService("RunService");
local tweenService = game:GetService("TweenService");

-- variables
local localPlayer = players.LocalPlayer;
local camera = workspace.CurrentCamera;
local normalIds = Enum.NormalId:GetEnumItems();
local ui, utils, pointers, theme = loadstring(game:HttpGet("https://raw.githubusercontent.com/Spoorloos/SplixPrivateDrawingLibrary/main/Library.lua", true))();
local ignoreList = {
    workspace.Players,
    workspace.Terrain,
    workspace.Ignore,
    workspace.CurrentCamera
};

-- modules
local modules = {};
for _, module in next, getloadedmodules() do
    local name = module and module.Name;
    if name == "ReplicationInterface" then
        modules.replication = require(module);
        modules.entryTable = debug.getupvalue(modules.replication.getEntry, 1);
    elseif name == "WeaponControllerInterface" then
        modules.weaponController = require(module);
    elseif name == "PublicSettings" then
        modules.settings = require(module);
    elseif name == "particle" then
        modules.particle = require(module);
        setreadonly(modules.particle, false);
    elseif name == "CharacterInterface" then
        modules.character = require(module);
    elseif name == "sound" then
        modules.sound = require(module);
    elseif name == "effects" then
        modules.effects = require(module);
    elseif name == "network" then
        modules.network = require(module);
        modules.remoteEvent = debug.getupvalue(modules.network.send, 1);
        modules.clientEvents = debug.getupvalue(getconnections(modules.remoteEvent.OnClientEvent)[1].Function, 1);
    elseif name == "physics" then
        modules.physics = require(module);
    elseif name == "BulletCheck" then
        modules.bulletcheck = require(module);
    end
end

do -- ui
    theme.font = 1;
    theme.accent = Color3.new(math.random(), math.random(), math.random());

    local window = ui:New({ name = "autist.cc" });
    window.uibind = Enum.KeyCode.RightShift;
    window.VisualPreview:SetPreviewState(false);

    local legit = window:Page({ name = "legit" });
    local rage = window:Page({ name = "rage" });
    do
        local ragebot = rage:Section({ name = "rage bot", side = "left" });
        ragebot:Toggle({ name = "enabled", pointer = "rage_ragebot_enabled" });
        ragebot:Toggle({ name = "shot limiter", pointer = "rage_ragebot_shotlimiter" });
        ragebot:Toggle({ name = "custom firerate", pointer = "rage_ragebot_customfirerate" });
        ragebot:Slider({ name = "firerate", min = 10, max = 1500, def = 250, pointer = "rage_ragebot_firerate" });
        ragebot:Dropdown({ name = "hitpart", options = {"head", "torso"}, pointer = "rage_ragebot_hitpart" });
        ragebot:Dropdown({ name = "target method", options = {"closest", "looking at"}, pointer = "rage_ragebot_targetmethod" });

        --local teleportbot = rage:Section({ name = "teleport bot", side = "left" });
        --teleportbot:Toggle({ name = "enabled", pointer = "rage_teleportbot_enabled" });
        --teleportbot:Toggle({ name = "knife mode", pointer = "rage_teleportbot_knifemode" });
        --teleportbot:Slider({ name = "point spacing", min = 1, max = 10, decimals = 0.5, def = 5, pointer = "rage_teleportbot_pointspacing" });
        --teleportbot:Slider({ name = "delay", min = 0, max = 2, decimals = 0.1, def = 1, pointer = "rage_teleportbot_delay" });

        local scanning = rage:Section({ name = "scanning", side = "right" });
        scanning:Toggle({ name = "enabled", pointer = "rage_scanning_enabled" });
        scanning:Toggle({ name = "fire position scanning", pointer = "rage_scanning_fireposscanning" });
        scanning:Slider({ name = "fire position radius", min = 1, max = 10, decimals = 0.5, def = 8.5, pointer = "rage_scanning_fireposscanning_radius" });
        scanning:Toggle({ name = "target scanning", pointer = "rage_scanning_targetscanning" });
        scanning:Slider({ name = "target radius", min = 1, max = 5.5, decimals = 0.5, def = 3.5, pointer = "rage_scanning_targetscanning_radius" });
        --scanning:Toggle({ name = "teleport scanning", pointer = "rage_scanning_teleportscanning" });
        --scanning:Slider({ name = "teleport radius", min = 1, max = 150, decimals = 0.5, def = 100, pointer = "rage_scanning_teleportscanning_radius" });
        --scanning:Dropdown({ name = "teleport direction", options = {"up", "down"}, pointer = "rage_scanning_teleportscanning_direction" });
    end

    local esp = window:Page({ name = "esp" });
    do
        --local enemy = esp:Section({ name = "enemy esp", side = "left" });
        --enemy:Toggle({ name = "enabled", pointer = "esp_enemy_enabled" });
        --enemy:Toggle({ name = "box", pointer = "esp_enemy_box" });

        --local friendly = esp:Section({ name = "friendly esp", side = "left" });
        --friendly:Toggle({ name = "enabled", pointer = "esp_friendly_enabled" });
        --friendly:Toggle({ name = "box", pointer = "esp_friendly_box" });
    end

    local visuals = window:Page({ name = "visuals" });
    do
        local bullets = visuals:Section({ name = "bullets", side = "left" });
        bullets:Toggle({ name = "tracers", pointer = "visuals_bullets_tracers" })
            :Colorpicker({ transparency = 0.5, pointer = "visuals_bullets_tracers_color" });
        bullets:Slider({ name = "tracer time", min = 0.1, max = 5, decimals = 0.1, def = 1, pointer = "visuals_bullets_tracers_time" });
        --bullets:Toggle({ name = "points", pointer = "visuals_bullets_points" })
        --    :Colorpicker({ transparency = 0.5, pointer = "visuals_bullets_points_color" });
        --bullets:Slider({ name = "points time", min = 0.1, max = 5, decimals = 0.1, def = 1, pointer = "visuals_bullets_points_time" });
    end

    local misc = window:Page({ name = "misc" });
    local settings = window:Page({ name = "settings" });
    do
        local interface = settings:Section({ name = "interface", side = "left" });
        interface:Keybind({ name = "hide key", def = window.uibind, callback = function(key)
            window.uibind = key;
        end })
    end

    window:Initialize();
end

do -- ragebot
    local lastShot = 0;
    local replicationPosition = Vector3.zero;
    local replicationAngles = Vector2.zero;
    local replicationTickOffset = 0;
    local health = {};

    -- functions
    local function scanTarget(position, data)
        local origins = { CFrame.new(replicationPosition, position) };
        local targets = { CFrame.new(position, replicationPosition) };

        -- add points
        if pointers.rage_scanning_enabled:Get() then
            local origin = origins[1];
            local target = targets[1];
            for _, id in next, normalIds do
                local dir = Vector3.fromNormalId(id);
                if pointers.rage_scanning_fireposscanning:Get() then
                    table.insert(origins, origin + dir * math.clamp(pointers.rage_scanning_fireposscanning_radius:Get(), 1, 9.99));
                end
                if pointers.rage_scanning_targetscanning:Get() then
                    table.insert(targets, target + dir * math.clamp(pointers.rage_scanning_targetscanning_radius:Get(), 1, 5.5));
                end
            end
        end

        -- scan points
        for _, origin in next, origins do
            origin = origin.Position;
            for _, target in next, targets do
                target = target.Position

                local velocity = modules.physics.trajectory(origin, modules.settings.bulletAcceleration, target, data.bulletspeed);
                if modules.bulletcheck(origin, target, velocity, modules.settings.bulletAcceleration, data.penetrationdepth) then
                    return { origin = origin, target = target, velocity = velocity };
                end
            end
        end
    end

    local function getTarget(data)
        local _min = math.huge;
        local _player, _scan, _entry;
        local cframe = camera.CFrame;
        for player, entry in next, modules.entryTable do
            local position = entry._receivedPosition;
            if not position or player.Team == localPlayer.Team or not entry:isAlive() or (health[player] or entry:getHealth()) < 1 then
                continue;
            end

            -- check priority
            local vector = cframe.Position - position;
            local min = pointers.rage_ragebot_targetmethod:Get() == "looking at" and cframe.LookVector:Dot(vector.Unit) or vector.Magnitude;
            if min >= _min then
                continue;
            end

            -- scan player
            local scan = scanTarget(position, data);
            if scan then
                _min = min;
                _player = player;
                _scan = scan;
                _entry = entry;
            end
        end
        return _player, _scan, _entry;
    end

    local function calculateDamage(distance, name, data)
        local damage = distance < data.range0 and data.damage0 or (distance < data.range1 and (((data.damage1 - data.damage0) / (data.range1 - data.range0)) * (distance - data.range0)) + data.damage0 or data.damage1);
        local multiplier = name == "Head" and data.multhead or (name == "Torso" and data.multtorso or data.multlimb or 1);
        return damage * multiplier;
    end

    -- hooks
    local send = modules.network.send;
    function modules.network:send(name, ...)
        local args = { ... };
        if name == "repupdate" then
            replicationPosition = args[1];
            replicationAngles = args[2];
            args[3] += replicationTickOffset;
        elseif name == "newbullets" or name == "spotplayers" or name == "equip" then
            args[2] += replicationTickOffset;
        elseif name == "newgrenade" or name == "updatesight" then
            args[3] += replicationTickOffset;
        elseif name == "bullethit" then
            args[5] += replicationTickOffset;
        elseif name == "ping" then
            return;
        end
        return send(self, name, unpack(args));
    end

    -- connections
    utils:Connection(runService.Heartbeat, function()
        if pointers.rage_ragebot_enabled:Get() and modules.character.isAlive() then
            -- get weapon
            local controller = modules.weaponController.getController();
            local weapon = controller and controller:getActiveWeapon();
            local data = weapon and weapon:getWeaponData();
            if not data or not weapon.getFirerate then
                return;
            end

            -- check timing
            local deltaTime = tick() - lastShot;
            local fireRate = 60 / weapon:getFirerate();
            if deltaTime < (pointers.rage_ragebot_customfirerate:Get() and 60/pointers.rage_ragebot_firerate:Get() or fireRate) then
                return;
            end

            lastShot = tick();

            -- get target
            local player, scan, entry = getTarget(data);
            if not player then
                return;
            end

            -- bypass firerate check
            local syncedTime = modules.network:getTime();
            if deltaTime < fireRate then
                replicationTickOffset += fireRate - deltaTime;
                modules.network:send("repupdate", replicationPosition, replicationAngles, syncedTime);
            end

            -- creating bullet(s)
            local bulletCount = data.pelletcount or 1;
            local bulletId = debug.getupvalue(weapon.fireRound, 10);
            local bullets = table.create(bulletCount, { scan.velocity, bulletId });

            for i, v in next, bullets do
                v[2] += i;
            end

            debug.setupvalue(weapon.fireRound, 10, bulletId + bulletCount);

            -- registering bullet(s)
            modules.network:send("newbullets", {
                firepos = scan.origin,
                camerapos = replicationPosition,
                bullets = bullets
            }, syncedTime);

            -- effects
            modules.sound.PlaySoundId(data.firesoundid, data.firevolume, data.firepitch, weapon._barrelPart, nil, 0, 0.05);
            modules.effects:muzzleflash(weapon._barrelPart, data.hideflash);

            for _, bullet in next, bullets do
                modules.particle.new({
                    size = 0.2,
                    bloom = 0.005,
                    brightness = 400,
                    dt = deltaTime,
                    position = scan.origin,
                    velocity = bullet[1],
                    life = modules.settings.bulletLifeTime,
                    acceleration = modules.settings.bulletAcceleration,
                    color = data.bulletcolor or Color3.fromRGB(200, 70, 70),
                    visualorigin = weapon._barrelPart.Position,
                    physicsignore = ignoreList,
                    penetrationdepth = data.penetrationdepth,
                    tracerless = data.tracerless
                });
            end

            -- updating magazine
            weapon._magCount -= 1;
            if weapon._magCount < 1 then
                local newCount = data.magsize + (data.chamber and 1 or 0) + weapon._magCount;
                if weapon._spareCount >= newCount then
                    weapon._magCount += newCount;
                    weapon._spareCount -= newCount;
                else
                    weapon._magCount += weapon._spareCount;
                    weapon._spareCount = 0;
                end

                modules.network:send("reload");
            end

            -- registering hit(s)
            local hitpart = pointers.rage_ragebot_hitpart:Get() == "head" and "Head" or "Torso";
            for _, bullet in next, bullets do
                modules.network:send("bullethit", player, scan.target, hitpart, bullet[2], syncedTime);
                modules.sound.PlaySound("hitmarker", nil, 1, 1.5);
            end

            -- updating health
            if pointers.rage_ragebot_shotlimiter:Get() then
                health[player] = (health[player] or entry:getHealth()) - calculateDamage((scan.target - replicationPosition).Magnitude, hitpart, data) * bulletCount;

                if health[player] < 1 then
                    task.wait(1);
                    health[player] = nil;
                end
            end
        end
    end);
end

do -- visuals
    -- functions
    local function createTracer(start, velocity)
        local beam = utils:Instance("Beam", {
            FaceCamera = true,
            Color = ColorSequence.new(pointers.visuals_bullets_tracers_color:Get().Color),
            Transparency = NumberSequence.new(pointers.visuals_bullets_tracers_color:Get().Transparency),
            LightEmission = 0,
            LightInfluence = 0,
            Width0 = 0.75,
            Width1 = 0.75,
            Texture = "rbxassetid://446111271",
            TextureLength = 12,
            TextureMode = Enum.TextureMode.Wrap,
            TextureSpeed = 1,
            Parent = workspace.Ignore,
            Attachment0 = utils:Instance("Attachment", {
                Position = start,
                Parent = workspace.Terrain
            }),
            Attachment1 = utils:Instance("Attachment", {
                Position = start + velocity,
                Parent = workspace.Terrain
            })
        });

        task.delay(pointers.visuals_bullets_tracers_time:Get(), function()
            tweenService:Create(beam, TweenInfo.new(1), { Width0 = 0, Width1 = 0, TextureSpeed = 0 }):Play();
            task.wait(1);
            beam.Attachment0:Destroy();
            beam.Attachment1:Destroy();
            beam:Destroy();
        end);
    end

    local function createPoint(start, velocity)

    end

    -- hooks
    local old = modules.particle.new;
    modules.particle.new = function(args)
        if args.onplayerhit or checkcaller() then
            if pointers.visuals_bullets_tracers:Get() then
                createTracer(args.visualorigin, args.velocity);
            end

            --if pointers.visuals_bullets_points:Get() then
            --    createPoint(args.visualorigin, args.velocity);
            --end
        end
        return old(args);
    end
end
local v2zero = Vector2.zero

-- / color3

local c3rgb = Color3.fromRGB

-- // library!!!

local request = (syn and syn.request) or request or http_request

local library, utility = loadstring(request({Url = "https://raw.githubusercontent.com/karlo1123/moon.lua/main/ui.lua"}).Body)()

local folder = "Skyline/pf/cfgs"

makefolder("Skyline")
makefolder("Skyline/pf")
makefolder("Skyline/pf/cfgs")
makefolder("Skyline/sounds")

local window = library:Window({name = "Skyline", size = v2new(600, 800)})
-- services
local players = game:GetService("Players");
local runService = game:GetService("RunService");
local tweenService = game:GetService("TweenService");

-- variables
local localPlayer = players.LocalPlayer;
local camera = workspace.CurrentCamera;
local normalIds = Enum.NormalId:GetEnumItems();
local ui, utils, pointers, theme = loadstring(game:HttpGet("https://raw.githubusercontent.com/Spoorloos/SplixPrivateDrawingLibrary/main/Library.lua", true))();
local ignoreList = {
    workspace.Players,
    workspace.Terrain,
    workspace.Ignore,
    workspace.CurrentCamera
};

-- modules
local modules = {};
for _, module in next, getloadedmodules() do
    local name = module and module.Name;
    if name == "ReplicationInterface" then
        modules.replication = require(module);
        modules.entryTable = debug.getupvalue(modules.replication.getEntry, 1);
    elseif name == "WeaponControllerInterface" then
        modules.weaponController = require(module);
    elseif name == "PublicSettings" then
        modules.settings = require(module);
    elseif name == "particle" then
        modules.particle = require(module);
        setreadonly(modules.particle, false);
    elseif name == "CharacterInterface" then
        modules.character = require(module);
    elseif name == "sound" then
        modules.sound = require(module);
    elseif name == "effects" then
        modules.effects = require(module);
    elseif name == "network" then
        modules.network = require(module);
        modules.remoteEvent = debug.getupvalue(modules.network.send, 1);
        modules.clientEvents = debug.getupvalue(getconnections(modules.remoteEvent.OnClientEvent)[1].Function, 1);
    elseif name == "physics" then
        modules.physics = require(module);
    elseif name == "BulletCheck" then
        modules.bulletcheck = require(module);
    end
end

do -- ui
    theme.font = 1;
    theme.accent = Color3.new(math.random(), math.random(), math.random());

    local window = ui:New({ name = "autist.cc" });
    window.uibind = Enum.KeyCode.RightShift;
    window.VisualPreview:SetPreviewState(false);

    local legit = window:Page({ name = "legit" });
    local rage = window:Page({ name = "rage" });
    do
        local ragebot = rage:Section({ name = "rage bot", side = "left" });
        ragebot:Toggle({ name = "enabled", pointer = "rage_ragebot_enabled" });
        ragebot:Toggle({ name = "shot limiter", pointer = "rage_ragebot_shotlimiter" });
        ragebot:Toggle({ name = "custom firerate", pointer = "rage_ragebot_customfirerate" });
        ragebot:Slider({ name = "firerate", min = 10, max = 1500, def = 250, pointer = "rage_ragebot_firerate" });
        ragebot:Dropdown({ name = "hitpart", options = {"head", "torso"}, pointer = "rage_ragebot_hitpart" });
        ragebot:Dropdown({ name = "target method", options = {"closest", "looking at"}, pointer = "rage_ragebot_targetmethod" });

        --local teleportbot = rage:Section({ name = "teleport bot", side = "left" });
        --teleportbot:Toggle({ name = "enabled", pointer = "rage_teleportbot_enabled" });
        --teleportbot:Toggle({ name = "knife mode", pointer = "rage_teleportbot_knifemode" });
        --teleportbot:Slider({ name = "point spacing", min = 1, max = 10, decimals = 0.5, def = 5, pointer = "rage_teleportbot_pointspacing" });
        --teleportbot:Slider({ name = "delay", min = 0, max = 2, decimals = 0.1, def = 1, pointer = "rage_teleportbot_delay" });

        local scanning = rage:Section({ name = "scanning", side = "right" });
        scanning:Toggle({ name = "enabled", pointer = "rage_scanning_enabled" });
        scanning:Toggle({ name = "fire position scanning", pointer = "rage_scanning_fireposscanning" });
        scanning:Slider({ name = "fire position radius", min = 1, max = 10, decimals = 0.5, def = 8.5, pointer = "rage_scanning_fireposscanning_radius" });
        scanning:Toggle({ name = "target scanning", pointer = "rage_scanning_targetscanning" });
        scanning:Slider({ name = "target radius", min = 1, max = 5.5, decimals = 0.5, def = 3.5, pointer = "rage_scanning_targetscanning_radius" });
        --scanning:Toggle({ name = "teleport scanning", pointer = "rage_scanning_teleportscanning" });
        --scanning:Slider({ name = "teleport radius", min = 1, max = 150, decimals = 0.5, def = 100, pointer = "rage_scanning_teleportscanning_radius" });
        --scanning:Dropdown({ name = "teleport direction", options = {"up", "down"}, pointer = "rage_scanning_teleportscanning_direction" });
    end

    local esp = window:Page({ name = "esp" });
    do
        --local enemy = esp:Section({ name = "enemy esp", side = "left" });
        --enemy:Toggle({ name = "enabled", pointer = "esp_enemy_enabled" });
        --enemy:Toggle({ name = "box", pointer = "esp_enemy_box" });

        --local friendly = esp:Section({ name = "friendly esp", side = "left" });
        --friendly:Toggle({ name = "enabled", pointer = "esp_friendly_enabled" });
        --friendly:Toggle({ name = "box", pointer = "esp_friendly_box" });
    end

    local visuals = window:Page({ name = "visuals" });
    do
        local bullets = visuals:Section({ name = "bullets", side = "left" });
        bullets:Toggle({ name = "tracers", pointer = "visuals_bullets_tracers" })
            :Colorpicker({ transparency = 0.5, pointer = "visuals_bullets_tracers_color" });
        bullets:Slider({ name = "tracer time", min = 0.1, max = 5, decimals = 0.1, def = 1, pointer = "visuals_bullets_tracers_time" });
        --bullets:Toggle({ name = "points", pointer = "visuals_bullets_points" })
        --    :Colorpicker({ transparency = 0.5, pointer = "visuals_bullets_points_color" });
        --bullets:Slider({ name = "points time", min = 0.1, max = 5, decimals = 0.1, def = 1, pointer = "visuals_bullets_points_time" });
    end

    local misc = window:Page({ name = "misc" });
    local settings = window:Page({ name = "settings" });
    do
        local interface = settings:Section({ name = "interface", side = "left" });
        interface:Keybind({ name = "hide key", def = window.uibind, callback = function(key)
            window.uibind = key;
        end })
    end

    window:Initialize();
end

do -- ragebot
    local lastShot = 0;
    local replicationPosition = Vector3.zero;
    local replicationAngles = Vector2.zero;
    local replicationTickOffset = 0;
    local health = {};

    -- functions
    local function scanTarget(position, data)
        local origins = { CFrame.new(replicationPosition, position) };
        local targets = { CFrame.new(position, replicationPosition) };

        -- add points
        if pointers.rage_scanning_enabled:Get() then
            local origin = origins[1];
            local target = targets[1];
            for _, id in next, normalIds do
                local dir = Vector3.fromNormalId(id);
                if pointers.rage_scanning_fireposscanning:Get() then
                    table.insert(origins, origin + dir * math.clamp(pointers.rage_scanning_fireposscanning_radius:Get(), 1, 9.99));
                end
                if pointers.rage_scanning_targetscanning:Get() then
                    table.insert(targets, target + dir * math.clamp(pointers.rage_scanning_targetscanning_radius:Get(), 1, 5.5));
                end
            end
        end

        -- scan points
        for _, origin in next, origins do
            origin = origin.Position;
            for _, target in next, targets do
                target = target.Position

                local velocity = modules.physics.trajectory(origin, modules.settings.bulletAcceleration, target, data.bulletspeed);
                if modules.bulletcheck(origin, target, velocity, modules.settings.bulletAcceleration, data.penetrationdepth) then
                    return { origin = origin, target = target, velocity = velocity };
                end
            end
        end
    end

    local function getTarget(data)
        local _min = math.huge;
        local _player, _scan, _entry;
        local cframe = camera.CFrame;
        for player, entry in next, modules.entryTable do
            local position = entry._receivedPosition;
            if not position or player.Team == localPlayer.Team or not entry:isAlive() or (health[player] or entry:getHealth()) < 1 then
                continue;
            end

            -- check priority
            local vector = cframe.Position - position;
            local min = pointers.rage_ragebot_targetmethod:Get() == "looking at" and cframe.LookVector:Dot(vector.Unit) or vector.Magnitude;
            if min >= _min then
                continue;
            end

            -- scan player
            local scan = scanTarget(position, data);
            if scan then
                _min = min;
                _player = player;
                _scan = scan;
                _entry = entry;
            end
        end
        return _player, _scan, _entry;
    end

    local function calculateDamage(distance, name, data)
        local damage = distance < data.range0 and data.damage0 or (distance < data.range1 and (((data.damage1 - data.damage0) / (data.range1 - data.range0)) * (distance - data.range0)) + data.damage0 or data.damage1);
        local multiplier = name == "Head" and data.multhead or (name == "Torso" and data.multtorso or data.multlimb or 1);
        return damage * multiplier;
    end

    -- hooks
    local send = modules.network.send;
    function modules.network:send(name, ...)
        local args = { ... };
        if name == "repupdate" then
            replicationPosition = args[1];
            replicationAngles = args[2];
            args[3] += replicationTickOffset;
        elseif name == "newbullets" or name == "spotplayers" or name == "equip" then
            args[2] += replicationTickOffset;
        elseif name == "newgrenade" or name == "updatesight" then
            args[3] += replicationTickOffset;
        elseif name == "bullethit" then
            args[5] += replicationTickOffset;
        elseif name == "ping" then
            return;
        end
        return send(self, name, unpack(args));
    end

    -- connections
    utils:Connection(runService.Heartbeat, function()
        if pointers.rage_ragebot_enabled:Get() and modules.character.isAlive() then
            -- get weapon
            local controller = modules.weaponController.getController();
            local weapon = controller and controller:getActiveWeapon();
            local data = weapon and weapon:getWeaponData();
            if not data or not weapon.getFirerate then
                return;
            end

            -- check timing
            local deltaTime = tick() - lastShot;
            local fireRate = 60 / weapon:getFirerate();
            if deltaTime < (pointers.rage_ragebot_customfirerate:Get() and 60/pointers.rage_ragebot_firerate:Get() or fireRate) then
                return;
            end

            lastShot = tick();

            -- get target
            local player, scan, entry = getTarget(data);
            if not player then
                return;
            end

            -- bypass firerate check
            local syncedTime = modules.network:getTime();
            if deltaTime < fireRate then
                replicationTickOffset += fireRate - deltaTime;
                modules.network:send("repupdate", replicationPosition, replicationAngles, syncedTime);
            end

            -- creating bullet(s)
            local bulletCount = data.pelletcount or 1;
            local bulletId = debug.getupvalue(weapon.fireRound, 10);
            local bullets = table.create(bulletCount, { scan.velocity, bulletId });

            for i, v in next, bullets do
                v[2] += i;
            end

            debug.setupvalue(weapon.fireRound, 10, bulletId + bulletCount);

            -- registering bullet(s)
            modules.network:send("newbullets", {
                firepos = scan.origin,
                camerapos = replicationPosition,
                bullets = bullets
            }, syncedTime);

            -- effects
            modules.sound.PlaySoundId(data.firesoundid, data.firevolume, data.firepitch, weapon._barrelPart, nil, 0, 0.05);
            modules.effects:muzzleflash(weapon._barrelPart, data.hideflash);

            for _, bullet in next, bullets do
                modules.particle.new({
                    size = 0.2,
                    bloom = 0.005,
                    brightness = 400,
                    dt = deltaTime,
                    position = scan.origin,
                    velocity = bullet[1],
                    life = modules.settings.bulletLifeTime,
                    acceleration = modules.settings.bulletAcceleration,
                    color = data.bulletcolor or Color3.fromRGB(200, 70, 70),
                    visualorigin = weapon._barrelPart.Position,
                    physicsignore = ignoreList,
                    penetrationdepth = data.penetrationdepth,
                    tracerless = data.tracerless
                });
            end

            -- updating magazine
            weapon._magCount -= 1;
            if weapon._magCount < 1 then
                local newCount = data.magsize + (data.chamber and 1 or 0) + weapon._magCount;
                if weapon._spareCount >= newCount then
                    weapon._magCount += newCount;
                    weapon._spareCount -= newCount;
                else
                    weapon._magCount += weapon._spareCount;
                    weapon._spareCount = 0;
                end

                modules.network:send("reload");
            end

            -- registering hit(s)
            local hitpart = pointers.rage_ragebot_hitpart:Get() == "head" and "Head" or "Torso";
            for _, bullet in next, bullets do
                modules.network:send("bullethit", player, scan.target, hitpart, bullet[2], syncedTime);
                modules.sound.PlaySound("hitmarker", nil, 1, 1.5);
            end

            -- updating health
            if pointers.rage_ragebot_shotlimiter:Get() then
                health[player] = (health[player] or entry:getHealth()) - calculateDamage((scan.target - replicationPosition).Magnitude, hitpart, data) * bulletCount;

                if health[player] < 1 then
                    task.wait(1);
                    health[player] = nil;
                end
            end
        end
    end);
end

do -- visuals
    -- functions
    local function createTracer(start, velocity)
        local beam = utils:Instance("Beam", {
            FaceCamera = true,
            Color = ColorSequence.new(pointers.visuals_bullets_tracers_color:Get().Color),
            Transparency = NumberSequence.new(pointers.visuals_bullets_tracers_color:Get().Transparency),
            LightEmission = 0,
            LightInfluence = 0,
            Width0 = 0.75,
            Width1 = 0.75,
            Texture = "rbxassetid://446111271",
            TextureLength = 12,
            TextureMode = Enum.TextureMode.Wrap,
            TextureSpeed = 1,
            Parent = workspace.Ignore,
            Attachment0 = utils:Instance("Attachment", {
                Position = start,
                Parent = workspace.Terrain
            }),
            Attachment1 = utils:Instance("Attachment", {
                Position = start + velocity,
                Parent = workspace.Terrain
            })
        });

        task.delay(pointers.visuals_bullets_tracers_time:Get(), function()
            tweenService:Create(beam, TweenInfo.new(1), { Width0 = 0, Width1 = 0, TextureSpeed = 0 }):Play();
            task.wait(1);
            beam.Attachment0:Destroy();
            beam.Attachment1:Destroy();
            beam:Destroy();
        end);
    end

    local function createPoint(start, velocity)

    end

    -- hooks
    local old = modules.particle.new;
    modules.particle.new = function(args)
        if args.onplayerhit or checkcaller() then
            if pointers.visuals_bullets_tracers:Get() then
                createTracer(args.visualorigin, args.velocity);
            end

            --if pointers.visuals_bullets_points:Get() then
            --    createPoint(args.visualorigin, args.velocity);
            --end
        end
        return old(args);
    end
end
local esp_preview = {instances = {}}

do
    local preview_frame = utility:Draw("Square", v2new(window.frame.Size.X + 20, 0), {
        Size = v2new(200, 250),
        Color = window.theme.cont,
        Group = "cont",
        Parent = window.frame
    }, true)

    local preview_frame_inline = utility:Draw("Square", v2new(-1, -1), {
        Size = preview_frame.Size + v2new(2, 2),
        Color = window.theme.dcont,
        Group = "dcont",
        Filled = false,
        Parent = preview_frame
    }, true)

    local preview_frame_outline = utility:Draw("Square", v2new(-2, -2), {
        Size = preview_frame.Size + v2new(4, 4),
        Color = window.accent,
        Group = "accent",
        Filled = false,
        Parent = preview_frame
    }, true)

    local plr_name = utility:Draw("Text", v2new(95, 2), {
        Font = 2,
        Size = 13,
        Color = Color3.new(1, 1, 1),
        Outline = true,
        Center = true,
        Text = "Username",
        Parent = preview_frame
    }, true)

    local plr_box_outline = utility:Draw("Square", v2new(20, 17), {
        Size = preview_frame.Size - v2new(42, 33),
        Color = c3rgb(),
        Thickness = 3,
        Filled = false,
        Parent = preview_frame
    }, true)

    local plr_box = utility:Draw("Square", v2zero, {
        Size = plr_box_outline.Size,
        Color = c3rgb(255, 255, 255),
        Filled = false,
        Parent = plr_box_outline
    }, true)

    local plr_weapon = utility:Draw("Text", v2new(95, preview_frame.Size.Y - 15), {
        Font = 2,
        Size = 13,
        Color = Color3.new(1, 1, 1),
        Outline = true,
        Center = true,
        Text = "Weapon",
        Parent = preview_frame
    }, true)

    local plr_hbar_outline = utility:Draw("Square", v2new(10, 16), {
        Color = c3rgb(),
        Size = v2new(3, preview_frame.Size.Y - 31),
        Parent = preview_frame
    })

    local plr_hbar = utility:Draw("Square", v2new(1, 1), {
        Color = c3rgb(0, 255, 0),
        Size = v2new(1, preview_frame.Size.Y - 33),
        Parent = plr_hbar_outline
    })

    local chams_head = utility:Draw("Square", v2new(95 - 16, 26), {
        Size = v2new(40, 35),
        Color = Color3.new(255, 0, 0),
        Transparency = 0.4,
        Parent = preview_frame
    }, true)

    local chams_torso = utility:Draw("Square", v2new(95 - 31, 63), {
        Size = v2new(70, 80),
        Color = Color3.new(255, 0, 0),
        Group = "chams_outline",
        Transparency = 0.4,
        Parent = preview_frame
    }, true)

    local chams_larm = utility:Draw("Square", v2new(-36, 0), {
        Size = v2new(34, 80),
        Color = Color3.new(255, 0, 0),
        Group = "chams_outline",
        Transparency = 0.4,
        Parent = chams_torso
    }, true)

    local chams_rarm = utility:Draw("Square", v2new(72, 0), {
        Size = v2new(34, 80),
        Color = Color3.new(255, 0, 0),
        Group = "chams_outline",
        Transparency = 0.4,
        Parent = chams_torso
    }, true)

    local chams_lleg = utility:Draw("Square", v2new(0, 82), {
        Size = v2new(34, 80),
        Color = Color3.new(255, 0, 0),
        Group = "chams_outline",
        Transparency = 0.4,
        Parent = chams_torso
    }, true)

    local chams_rleg = utility:Draw("Square", v2new(36, 82), {
        Size = v2new(34, 80),
        Color = Color3.new(255, 0, 0),
        Group = "chams_outline",
        Transparency = 0.4,
        Parent = chams_torso
    }, true)

    esp_preview.instances = {
        preview_frame, preview_frame_inline, preview_frame_outline, plr_name, plr_box, plr_box_outline, plr_weapon,
        chams_head, chams_torso, chams_larm, chams_rarm, chams_lleg, chams_rleg, plr_hbar, plr_hbar_outline
    }
end

function getcfgs()
    local configs = {}
    for i, v in pairs(listfiles(folder .. "/")) do
        if tostring(v):sub(-4, -1) == ".cfg" then
            table.insert(configs, tostring(v):sub(folder:len() + 2, -5))
        end
    end
    return configs
end

function isTarget(plr, teammates)
    if plr == lplr then
        return false
    end

	if not plr.Neutral and not lplr.Neutral then
        if teammates == false then
            return plr.Team ~= lplr.Team
        elseif teammates == true then
            return plr ~= lplr
        end
    else
        return plr ~= lplr
    end
end

local client = {guns = {}}

for i, v in pairs(getgc(true)) do
    if typeof(v) == "table" then
        if rawget(v, "getAllBodyParts") then
            client.replication = v
        elseif rawget(v, "send") then
            client.network = v
        elseif rawget(v, "getController") then
            client.wcmod = v
        elseif rawget(v, "getFirerate") and rawget(v, "getFiremode") then
            client.fireobject = v
        elseif rawget(v, "getCharacterObject") then
            client.cint = v
        elseif rawget(v, "getThirdPersonObject") then
            client.rep_obj = v
        elseif rawget(v, "getCharacterModel") then
            client.tpo = v
        elseif rawget(v, "canMelee") then
            client.meleeobject = v
        elseif rawget(v, "getWeaponAttData") then
            client.weapon_data = v
        elseif rawget(v, "createRagdoll") then
            client.ragdoll = v
        end
    elseif typeof(v) == "function" then
        local info = getinfo(v)
        
        if info.name == "trajectory" then
            client.trajectory = v
        elseif info.name == "bulletcheck" then
            client.bulletcheck = v
        end
    end
end

for i, v in pairs(getloadedmodules()) do
    if v.Name == "PublicSettings" then
        client.ps = require(v)
    elseif v.Name == "particle" then
        client.particle = require(v)
    end
end

client.fake_character = client.rep_obj.new(lplr)
client.fake_character._player = lplr

function load_weapon_data(name)
    for i, v in pairs(getloadedmodules()) do
        if v.Name == name then
            client.guns[name] = require(v)
            break
        end
    end
end

function load_loadout_layer(layer)
    for index, value in pairs(layer) do
        client.network:send("changeWeapon", index, value.weapon)

        if value.attachments then
            for attname, attvalue in pairs(value.attachments) do
                client.network:send("changeAttachment", index, attname, attvalue)
            end
        end
    end
end

function can_shoot(frate, lt, ptc)
    return (tick() - lt) > ((60*ptc) / frate)
end

function player_scan(ori, tar, pen, bls)
    local pos = CFrame.new(ori, tar).Position

    local trajectory = client.trajectory(pos, client.ps.bulletAcceleration, tar, bls)

    local bulletchecked = client.bulletcheck(pos, tar, trajectory, client.ps.bulletAcceleration, pen)

    if bulletchecked then
        return pos, trajectory
    end
end

function update_theme(i, v)
    window.theme[i] = v

    window:NewTheme(window.theme)
end

local joskie_kilsai = {
    ["Skyline"] = {
        ["random"] = true,
        ["words"] = {"ez bot boje 😱", "😭 Skylineed 😡", "2.4 at Skyline", "don crai pleaz 🐒💩", "ubit geimhaksom 🤢", "cheetos gamehaxeetos 🥶", "ga(y)haxx number 0.9 cheato 😨"},
        ["connectors"] = {"%", "$", "&", "^", "*", "#"},
        ["max_connector_len"] = 5,
        ["min_connector_len"] = 2,
        ["max_words"] = 4,
        ["min_words"] = 2
    }
}

function generate_random_killsay(name)
    local current_string = ""

    if joskie_kilsai[name] then

        local ks = joskie_kilsai[name]

        if ks.random then
            local already_used = {}

            for i = 1, math.random(ks.min_words, ks.max_words) do
                local word
                repeat
                    task.wait()
                    word = ks.words[math.random(1, #ks.words)]
                until table.find(already_used, word) == nil

                local cstr = ""

                for i = 1, math.random(ks.min_connector_len, ks.max_connector_len) do
                    cstr = cstr .. ks.connectors[math.random(1, #ks.connectors)]
                end

                current_string = current_string .. ("%s %s"):format(word, cstr)

                table.insert(already_used, word)
            end
        else
            return ks.words[math.random(1, #ks.words)]
        end

    else
        return warn(("Phrase %s doesnt exist."):format(name))
    end

    return current_string
end

local hitsounds = {}
local all_hitsounds = {}

for i, v in pairs(listfiles("Skyline/sounds/")) do
    if not getsynasset then return end

    hitsounds[v:sub(17, -5)] = getsynasset(v)

    table.insert(all_hitsounds, v:sub(17, -5))
end

local vis_circles = {
    as_fov_out = utility:Draw("Circle", nil, {Thickness = 4, Filled = false}, true),
    as_fov = utility:Draw("Circle", nil, {Thickness = 2, Filled = false}, true),
    as_dz = utility:Draw("Circle", nil, {Filled = true}, true),
}

function raycast(origin, direction, list)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = list
    params.FilterType = Enum.RaycastFilterType.Exclude

    local data = workspace:Raycast(origin, direction, params)

    if data and data.Instance and data.Position then
        return data.Instance, data.Position
    end

end

function get_tpscan_direction(origin, power)
    local directions = {Vector3.new(0, 1, 0), Vector3.new(1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(-1, 0, 0), Vector3.new(0, 0, -1)}

    local dir

    local ignore = {workspace.Ignore.RefPlayer, workspace.CurrentCamera}

    if client.fake_character._thirdPersonObject then
        table.insert(ignore, client.fake_character._thirdPersonObject._character)
    end

    for i, v in pairs(directions) do

        local hit, pos = raycast(origin, v * power, ignore)
        
        if not hit then

            dir = v
            
            break
        end

    end

    return dir
end

function create_beam(p1, p2, clr, trn)
    local at1 = Instance.new("Attachment", workspace.Terrain)
    at1.Position = p1

    local at2 = Instance.new("Attachment", workspace.Terrain)
    at2.Position = p2

    local beam = Instance.new("Beam", workspace)
    beam.Texture = "rbxassetid://446111271"

    beam.Color = ColorSequence.new(clr, clr)
    beam.Transparency = NumberSequence.new(trn, trn)

    beam.TextureSpeed = 3

    beam.FaceCamera = true

    beam.LightEmission = 1
    beam.LightInfluence = 1

    beam.Attachment0 = at1
    beam.Attachment1 = at2

    return {at1, at2, beam}
end

local esp_info = {}

utility:Connect(plrs.PlayerAdded, function(plr)

    esp_info[plr] = {
        boxout = utility:Draw("Square", nil, {Filled = false, Thickness = 3}, true),
        box = utility:Draw("Square", nil, {Filled = false}, true),
        hbarout = utility:Draw("Square", nil, {}, true),
        hbar = utility:Draw("Square", nil, {}, true),
        name = utility:Draw("Text", nil, {Font = 2, Size = 13, Text = plr.Name, Outline = true, Center = true}, true),
        wpn = utility:Draw("Text", nil, {Font = 2, Size = 13, Outline = true, Center = true}, true),

        sk_torso_out = utility:Draw("Line", nil, {Thickness = 3}, true),
        sk_rarm_out = utility:Draw("Line", nil, {Thickness = 3}, true),
        sk_larm_out = utility:Draw("Line", nil, {Thickness = 3}, true),
        sk_rleg_out = utility:Draw("Line", nil, {Thickness = 3}, true),
        sk_lleg_out= utility:Draw("Line", nil, {Thickness = 3}, true),

        sk_torso = utility:Draw("Line", nil, {Thickness = 1}, true),
        sk_rarm = utility:Draw("Line", nil, {Thickness = 1}, true),
        sk_larm = utility:Draw("Line", nil, {Thickness = 1}, true),
        sk_rleg = utility:Draw("Line", nil, {Thickness = 1}, true),
        sk_lleg = utility:Draw("Line", nil, {Thickness = 1}, true),
    }

    for i, v in pairs(esp_info[plr]) do
        v.Visible = false
    end

end)

for i, plr in pairs(plrs:GetPlayers()) do
    if esp_info[plr] == nil then
        esp_info[plr] = {
            boxout = utility:Draw("Square", nil, {Filled = false, Thickness = 3}, true),
            box = utility:Draw("Square", nil, {Filled = false}, true),
            hbarout = utility:Draw("Square", nil, {}, true),
            hbar = utility:Draw("Square", nil, {}, true),
            name = utility:Draw("Text", nil, {Font = 2, Size = 13, Text = plr.Name, Outline = true, Center = true}, true),
            wpn = utility:Draw("Text", nil, {Font = 2, Size = 13, Outline = true, Center = true}, true),

            sk_torso_out = utility:Draw("Line", nil, {Thickness = 3}, true),
            sk_rarm_out = utility:Draw("Line", nil, {Thickness = 3}, true),
            sk_larm_out = utility:Draw("Line", nil, {Thickness = 3}, true),
            sk_rleg_out = utility:Draw("Line", nil, {Thickness = 3}, true),
            sk_lleg_out= utility:Draw("Line", nil, {Thickness = 3}, true),

            sk_torso = utility:Draw("Line", nil, {Thickness = 1}, true),
            sk_rarm = utility:Draw("Line", nil, {Thickness = 1}, true),
            sk_larm = utility:Draw("Line", nil, {Thickness = 1}, true),
            sk_rleg = utility:Draw("Line", nil, {Thickness = 1}, true),
            sk_lleg = utility:Draw("Line", nil, {Thickness = 1}, true),
        }
    end
end

for _, shit in pairs(esp_info) do
    for i, v in pairs(shit) do
        v.Visible = false
    end
end

utility:Connect(plrs.PlayerRemoving, function(plr)
    if esp_info[plr] then
        for i, v in pairs(esp_info[plr]) do
            v.Remove()
        end
    end
end)

local legit = window:Tab({name = "legit"})
local rage = window:Tab({name = "rage"})
local esp = window:Tab({name = "esp"})
local visuals = window:Tab({name = "visuals"})
local misc = window:Tab({name = "misc"})
local settings = window:Tab({name = "settings"})

local legit_assist = legit:Section({name = "aim assist"})
local legit_tbot = legit:Section({name = "triggerbot", side = "right"})
local legit_bredir = legit:Section({name = "bullet redirection", side = "right"})

local rage_rbot = rage:Section({name = "ragebot"})
local rage_kbot = rage:Section({name = "knifebot"})
local rage_aa = rage:Section({name = "anti aim", side = "right"})

local esp_en = esp:Section({name = "enemy esp"})
local esp_self = esp:Section({name = "self esp"})
local esp_team = esp:Section({name = "team esp", side = "right"})
local esp_settings = esp:Section({name = "settings", side = "right"})

local visuals_viewmodel = visuals:Section({name = "viewmodel", side = "right"})
local visuals_crosshair = visuals:Section({name = "crosshair"})
local visuals_enviroment = visuals:Section({name = "enviroment", side = "right"})
local visuals_self = visuals:Section({name = "self"})
local visuals_ragdolls = visuals:Section({name = "ragdolls"})

local misc_movement = misc:Section({name = "movement"})
local misc_fun = misc:Section({name = "funny stuff"})
local misc_guns = misc:Section({name = "guns", side = "right"})
local misc_client = misc:Section({name = "client", side = "right"})

local settings_cheat = settings:Section({name = "cheat"})
local settings_config = settings:Section({name = "config"})
local settings_servers = settings:Section({name = "server hop", side = "right"})
local settings_theme = settings:Section({name = "theme", side = "right"})

legit_assist:Toggle({name = "enabled", flag = "as_enabled"}):Keybind({})
legit_assist:Slider({name = "aim assist fov", min = 1, max = 361, maxtval = "unlimited", suf = "°", flag = "as_fov"})
legit_assist:Slider({name = "smoothing", min = 0, max = 100, mintval = "off", maxtval = "off", suf = "%", flag = "as_sm"})
legit_assist:Dropdown({name = "smoothing style", options = {"linear", "quadratic", "cubic", "sinusoidal", "elastic", "square root"}, flag = "as_sm_style"})
legit_assist:Slider({name = "randomization", min = 0, max = 50, mintval = "off", suf = "°", flag = "as_rand"})
legit_assist:Slider({name = "deadzone", min = 0, max = 360, def = 10, mintval = "off", suf = "°", flag = "as_dz"})
legit_assist:Dropdown({name = "target priority", options = {"closest", "in fov"}, flag = "as_tp"})
legit_assist:Dropdown({name = "hitscan points", options = {"head", "torso"}, multi = true, flag = "as_hp"})
legit_assist:Toggle({name = "use barell fov", flag = "as_bf"})
legit_assist:Toggle({name = "visualize", flag = "as_vis_fov"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "as_vis_fov_clr"}):Colorpicker({def = c3rgb(0, 0, 0), flag = "as_vis_fov_out"})
legit_assist:Toggle({name = "visualize deadzone", flag = "as_vis_dz"}):Colorpicker({def = c3rgb(255, 0, 0), trans = true, deftrans = 0.7, flag = "as_vis_dz_clr"})

legit_tbot:Toggle({name = "enabled", flag = "tb_enabled"})
legit_tbot:Slider({name = "reaction time", min = 0, max = 1, dec = 100, mintval = "off", suf = "s", flag = "tb_rt"})
legit_tbot:Dropdown({name = "react on hitboxes", options = {"head", "torso", "left arm", "right arm", "left leg", "right leg"}, multi = true, flag = "tb_hb"})
legit_tbot:Toggle({name = "requires gun aiming", flag = "tb_rga"})

legit_bredir:Toggle({name = "silent aim", flag = "rdir_sa"})
legit_bredir:Slider({name = "silent aim fov", min = 1, max = 361, maxtval = "unlimited", suf = "px", flag = "rdir_sa_fov"})
legit_bredir:Slider({name = "silent aim spread", min = 0, max = 2, dec = 100, mintval = "off", suf = "studs", flag = "rdir_sa_spread"})
legit_bredir:Slider({name = "hitchance", min = 0, max = 100, mintval = "off", suf = "%", flag = "rdir_hc"})
legit_bredir:Slider({name = "accuracy", min = 0, max = 100, mintval = "off", suf = "%", flag = "rdir_ac"})
legit_bredir:Dropdown({name = "target priority", options = {"closest", "in fov"}, flag = "rdir_tp"})
legit_bredir:Dropdown({name = "hitscan points", options = {"head", "torso"}, multi = true, flag = "rdir_hp"})
legit_bredir:Toggle({name = "use barell fov", flag = "rdir_bf"})

rage_rbot:Toggle({name = "enabled", tt = "BIG WARNING: disables legit shooting.", flag = "rb_enabled"})
rage_rbot:Dropdown({name = "hitscan points", options = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, scrollable = true, vis = 4, min = 1, multi = true, flag = "rb_hs"})
rage_rbot:Dropdown({name = "origin", options = {"server position", "client position", "barell"}, flag = "rb_or"})
rage_rbot:Toggle({name = "show shoot animation", flag = "rb_swa"})

rage_kbot:Toggle({name = "enabled", flag = "kb_enabled"})
rage_kbot:Toggle({name = "auto equip", flag = "kb_ae"})
rage_kbot:Slider({name = "distance", min = 1, max = 25, dec = 100, flag = "kb_dist"})

rage_aa:Toggle({name = "enabled", flag = "aa_enabled"})
rage_aa:Slider({name = "pitch", min = -2, max = 2, def = 0, dec = 100, flag = "aa_pitch"})
rage_aa:Slider({name = "yaw", min = -180, max = 180, suf = "rad", dec = 10, flag = "aa_yaw"})
rage_aa:Slider({name = "spin speed", min = 1, max = 20, dec = 100, flag = "aa_spp"})
rage_aa:Dropdown({name = "yaw base", options = {"-", "body rotation", "spin"}, flag = "aa_yaw_base"})
rage_aa:Dropdown({name = "stance", options = {"stand", "crouch", "prone"}, flag = "aa_stance"})
rage_aa:Slider({name = "spaz", min = 0, max = 3, dec = 100, flag = "aa_spaz"})

esp_en:Toggle({name = "enabled", flag = "en_esp_enabled"})
esp_en:Toggle({name = "chams", flag = "en_esp_chams"}):Colorpicker({def = c3rgb(255, 0, 0), trans = true, flag = "en_esp_chams_clr"}):Colorpicker({def = c3rgb(), trans = true, flag = "en_esp_chams_out"})
esp_en:Toggle({name = "box", flag = "en_esp_box"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "en_esp_box_clr"}):Colorpicker({def = c3rgb(), flag = "en_esp_box_out"})
esp_en:Toggle({name = "health bar", flag = "en_esp_hbar"}):Colorpicker({def = c3rgb(0, 255, 0), flag = "en_esp_hbar_c1"}):Colorpicker({def = c3rgb(255, 0, 0), flag = "en_esp_hbar_c2"}):Colorpicker({def = c3rgb(), flag = "en_esp_hbar_out"})
esp_en:Toggle({name = "name", flag = "en_esp_name"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "en_esp_name_clr"}):Colorpicker({def = c3rgb(), flag = "en_esp_name_out"})
esp_en:Toggle({name = "weapon", flag = "en_esp_weapon"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "en_esp_weapon_clr"}):Colorpicker({def = c3rgb(), flag = "en_esp_weapon_out"})
esp_en:Toggle({name = "skeleton", flag = "en_esp_skeleton"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "en_esp_skeleton_clr"}):Colorpicker({def = c3rgb(), flag = "en_esp_skeleton_out"})

esp_self:Toggle({name = "enabled", flag = "self_esp_enabled"})
esp_self:Toggle({name = "chams", flag = "self_esp_chams"}):Colorpicker({def = c3rgb(255, 0, 0), trans = true, flag = "self_esp_chams_clr"}):Colorpicker({def = c3rgb(), trans = true, flag = "self_esp_chams_out"})
esp_self:Toggle({name = "box", flag = "self_esp_box"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "self_esp_box_clr"}):Colorpicker({def = c3rgb(), flag = "self_esp_box_out"})
esp_self:Toggle({name = "health bar", flag = "self_esp_hbar"}):Colorpicker({def = c3rgb(0, 255, 0), flag = "self_esp_hbar_c1"}):Colorpicker({def = c3rgb(255, 0, 0), flag = "self_esp_hbar_c2"}):Colorpicker({def = c3rgb(), flag = "self_esp_hbar_out"})
esp_self:Toggle({name = "name", flag = "self_esp_name"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "self_esp_name_clr"}):Colorpicker({def = c3rgb(), flag = "self_esp_name_out"})
esp_self:Toggle({name = "weapon", flag = "self_esp_weapon"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "self_esp_weapon_clr"}):Colorpicker({def = c3rgb(), flag = "self_esp_weapon_out"})
esp_self:Toggle({name = "skeleton", flag = "self_esp_skeleton"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "self_esp_skeleton_clr"}):Colorpicker({def = c3rgb(), flag = "self_esp_skeleton_out"})

esp_team:Toggle({name = "enabled", flag = "team_esp_enabled"})
esp_team:Toggle({name = "chams", flag = "team_esp_chams"}):Colorpicker({def = c3rgb(255, 0, 0), trans = true, flag = "team_esp_chams_clr"}):Colorpicker({def = c3rgb(), trans = true, flag = "team_esp_chams_out"})
esp_team:Toggle({name = "box", flag = "team_esp_box"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "team_esp_box_clr"}):Colorpicker({def = c3rgb(), flag = "team_esp_box_out"})
esp_team:Toggle({name = "health bar", flag = "team_esp_hbar"}):Colorpicker({def = c3rgb(0, 255, 0), flag = "team_esp_hbar_c1"}):Colorpicker({def = c3rgb(255, 0, 0), flag = "team_esp_hbar_c2"}):Colorpicker({def = c3rgb(), flag = "team_esp_hbar_out"})
esp_team:Toggle({name = "name", flag = "team_esp_name"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "team_esp_name_clr"}):Colorpicker({def = c3rgb(), flag = "team_esp_name_out"})
esp_team:Toggle({name = "weapon", flag = "team_esp_weapon"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "team_esp_weapon_clr"}):Colorpicker({def = c3rgb(), flag = "team_esp_weapon_out"})
esp_team:Toggle({name = "skeleton", flag = "team_esp_skeleton"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "team_esp_skeleton_clr"}):Colorpicker({def = c3rgb(), flag = "team_esp_skeleton_out"})

esp_settings:Dropdown({name = "preview esp", options = {"enemy", "team", "self"}, flag = "st_esp_preview"})

visuals_viewmodel:Toggle({name = "enabled", flag = "vc_enabled"})
visuals_viewmodel:Toggle({name = "no gun bob", flag = "vc_nb"})
visuals_viewmodel:Slider({name = "position x", min = -180, max = 180, def = 0, flag = "vc_px"})
visuals_viewmodel:Slider({name = "position y", min = -180, max = 180, def = 0, flag = "vc_py"})
visuals_viewmodel:Slider({name = "position z", min = -180, max = 180, def = 0, flag = "vc_pz"})
visuals_viewmodel:Slider({name = "pitch", min = -180, max = 180, def = 0, flag = "vc_pit"})
visuals_viewmodel:Slider({name = "yaw", min = -180, max = 180, def = 0, flag = "vc_yaw"})
visuals_viewmodel:Slider({name = "roll", min = -180, max = 180, def = 0, flag = "vc_rol"})
visuals_viewmodel:Toggle({name = "weapon changer", flag = "vc_wp"}):Colorpicker({def = c3rgb(255, 0, 0), trans = true, flag = "vc_wp_clr"})
visuals_viewmodel:Dropdown({name = "weapon material", options = {"plastic", "neon", "ghost"}, flag = "vc_wp_mat"})
visuals_viewmodel:Toggle({name = "arms changer", flag = "vc_ar"}):Colorpicker({def = c3rgb(255, 0, 0), trans = true, flag = "vc_ar_clr"})
visuals_viewmodel:Dropdown({name = "weapon material", options = {"plastic", "neon", "ghost"}, flag = "vc_ar_mat"})

visuals_crosshair:Toggle({name = "enabled", flag = "cr_enabled"}):Colorpicker({def = c3rgb(255, 255, 255), flag = "cr_clr"}):Colorpicker({def = c3rgb(), flag = "cr_out"})
visuals_crosshair:Toggle({name = "follow barrel", flag = "cr_follow"})
visuals_crosshair:Toggle({name = "dot", flag = "cr_dot"})
visuals_crosshair:Dropdown({name = "mode", options = {"default", "> <"}, flag = "cr_mode"})
visuals_crosshair:Slider({name = "direction", min = -1, max = 1, dec = 100, flag = "cr_dir"})
visuals_crosshair:Slider({name = "lines", min = 2, max = 50, def = 4, flag = "cr_lines"})
visuals_crosshair:Slider({name = "speed", min = 1, max = 100, def = 10, dec = 10, flag = "cr_speed"})
visuals_crosshair:Slider({name = "offset", min = 4, max = 200, def = 6, flag = "cr_offset"})
visuals_crosshair:Slider({name = "length", min = 6, max = 500, def = 12, flag = "cr_length"})
visuals_crosshair:Slider({name = "thickness", min = 1, max = 40, def = 2, flag = "cr_thick"})

visuals_enviroment:Toggle({name = "time changer", tooltip = "Select time in \"Time of day\".", flag = "e_tc_en"})
visuals_enviroment:Slider({name = "time of day", min = 0, max = 24, def = 12, dec = 100, flag = "e_tc"})
visuals_enviroment:Toggle({name = "global shadows", def = true, flag = "e_gs"})
visuals_enviroment:Colorpicker({name = "ambient", def = c3rgb(127, 127, 127), flag = "e_am"})
visuals_enviroment:Toggle({name = "local bullet tracers", flag = "e_lbt"}):Colorpicker({def = c3rgb(0, 0, 255), trans = true, flag = "e_lbt_clr"})
visuals_enviroment:Toggle({name = "server bullet tracers", flag = "e_sbt"}):Colorpicker({def = c3rgb(0, 255, 0), trans = true, flag = "e_sbt_team"}):Colorpicker({def = c3rgb(255, 0, 0), trans = true, flag = "e_sbt_enemy"})
visuals_enviroment:Slider({name = "lifetime", min = 1, max = 5, dec = 100, def = 1.5, flag = "e_bt_lt"})

visuals_self:Toggle({name = "third person", flag = "s_tper"}):Keybind({})
visuals_self:Toggle({name = "self chams", flag = "s_chams"}):Colorpicker({def = c3rgb(0, 0, 255), trans = true, flag = "s_chams_clr"})
visuals_self:Dropdown({name = "material", options = {"plastic", "neon", "ghost"}, flag = "s_material"})

visuals_ragdolls:Toggle({name = "color changer", flag = "rg_change"}):Colorpicker({def = c3rgb(255, 0, 0), trans = true, flag = "rg_change_clr"})
visuals_ragdolls:Toggle({name = "disable physics", tt = "Disable's vertical velocity and\nmakes velocity be constant.", flag = "rg_dp"})
visuals_ragdolls:Slider({name = "velocity multiplier", min = 0.1, max = 100, def = 1, dec = 100, flag = "rg_vm"})
visuals_ragdolls:Slider({name = "ragdoll limit", min = 1, max = 50, def = 6, flag = "rg_limit"})

misc_movement:Toggle({name = "bunnyhop", flag = "m_bhop"}):Keybind({})
misc_movement:Slider({name = "bunnyhop speed", min = 20, max = 300, flag = "m_bhop_speed"})
misc_movement:Toggle({name = "circle strafe", flag = "m_cstr"}):Keybind({})
misc_movement:Slider({name = "circle strafe speed", min = 1, max = 10, def = 2, dec = 100, flag = "m_cstr_speed"})
misc_movement:Slider({name = "circle strafe radius", min = 1, max = 20, def = 5, dec = 10, flag = "m_cstr_rad"})

misc_fun:Toggle({name = "chat spam", flag = "ct_enabled"})
misc_fun:Dropdown({name = "select chat spam", options = {"Skyline"}, flag = "ct_sel"})
misc_fun:Slider({name = "chat spam delay", min = 1, max = 5, def = 2.5, dec = 10, suf = "s", flag = "ct_del"})
misc_fun:Toggle({name = "hitsound", flag = "ht_enabled"})
misc_fun:Slider({name = "hitsound volume", min = 1, max = 10, flag = "ht_vol"})
misc_fun:Slider({name = "hitsound pitch", min = 1, max = 10, dec = 100, flag = "ht_pit"})
misc_fun:Dropdown({name = "select hitsound", options = all_hitsounds, scrollable = true, vis = 4, flag = "ht_sel"})
misc_fun:Toggle({name = "killsound", flag = "ks_enabled"})
misc_fun:Slider({name = "killsound volume", min = 1, max = 10, flag = "ks_vol"})
misc_fun:Slider({name = "killsound pitch", min = 1, max = 10, dec = 100, flag = "ks_pit"})
misc_fun:Dropdown({name = "select killsound", options = all_hitsounds, scrollable = true, vis = 4, flag = "ks_sel"})
misc_fun:Slider({name = "time shift amount", min = 0, max = 4.5, dec = 100, def = 1, flag = "f_tsa"})

misc_guns:Slider({name = "firerate", min = 0, max = 100, def = 100, suf = "%", flag = "g_frate"})

misc_client:Toggle({name = "unlock all attachments", flag = "c_uaa"})
misc_client:Toggle({name = "unlock all guns", flag = "c_uag"})
misc_client:Dropdown({name = "server primary", options = {"AK12", "M4A1", "MP5K", "COLT LMG", "INTERVENTION"}, flag = "c_uag_p"})
misc_client:Dropdown({name = "server secondary", options = {"G17", "M9"}, flag = "c_uag_s"})
misc_client:Dropdown({name = "server melee", options = {"TANTO", "KNIFE", "TRENCH KNIFE", "MAGLITE CLUB", "CROWBAR", "CANDY CANE", "HONEY STICK"}, scrollable = true, vis = 5, flag = "c_uag_m"})

settings_cheat:Button({name = "unload", callback = function() window:Unload() end})
settings_cheat:Textbox({name = "cheat Name", def = "Skyline", flag = "cheat_name"})
settings_cheat:Toggle({name = "watermark", flag = "cheat_wm", callback = function()
    if library.loaded then
        window.watermark:SetVisible(library.flags["cheat_wm"])
    end
end})
settings_cheat:Toggle({name = "keybinds", flag = "cheat_kb", callback = function()
    if library.loaded then
        window.kblist:ShowHideFromMyLifePleaseSomebodyKillMeIDontWantToBeAliveRightNowImUselessInMyLife(library.flags["cheat_kb"])
    end
end})
settings_cheat:Toggle({name = "hitlogs", flag = "cheat_hl"})
settings_cheat:Slider({name = "size x", min = 600, max = 1000, flag = "cheat_sx"})
settings_cheat:Slider({name = "size y", min = 800, max = 1000, flag = "cheat_sy"})

settings_config:List({name = "config", options = getcfgs(), flag = "cfg_sel"})
settings_config:Textbox({name = "config Name", flag = "cfg_name"})
settings_config:Button({name = "load", callback = function()
    if isfile(folder .. ("/%s.cfg"):format(library.flags["cfg_sel"])) then
        window:BestFunctionToKillMyselfFurryGayPornFemboyDildoMasterAloneWolfMode(game:GetService("HttpService"):JSONDecode(readfile(folder .. ("/%s.cfg"):format(library.flags["cfg_sel"]))))
        window.ntiflist:new({text = ("Loaded config \"%s\"."):format(library.flags["cfg_sel"])})
    end
end})
settings_config:Button({name = "save", callback = function()
    if library.flags["cfg_name"] ~= "" then
        writefile(folder .. ("/%s.cfg"):format(library.flags["cfg_name"]), window:GetFakeRealNoobConfigFunctionDontUseMe())
    end
end})
settings_config:Button({name = "refresh", callback = function()
    library.pointers["settingsconfigconfig"]:Refresh(getcfgs())
end})

settings_servers:Slider({name = "minimum players", min = 1, max = 32, def = 5, flag = "sh_min"})
settings_servers:Slider({name = "maximum players", min = 1, max = 31, def = 31, flag = "sh_max"})
settings_servers:Slider({name = "maximum ping", min = 30, max = 300, def = 200, suf = "ms", flag = "sh_ping"})
settings_servers:Button({name = "hop servers", callback = function()
    local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet(("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)))

    local jid

    for i, v in pairs(servers.data) do
        if v.playing ~= nil and v.playing >= library.flags["sh_min"] and v.playing <= library.flags["sh_max"] and v.ping <= library.flags["sh_ping"] and v.id ~= game.JobId then
            jid = tostring(v.id)
            break
        end
    end

    if jid then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jid, lplr)
        window.ntiflist:new({text = "Server hop: success.", th = {{"success", c3rgb(0, 255, 0)}}})
    else
        window.ntiflist:new({text = "Server hop: failed.", th = {{"failed", c3rgb(255, 0, 0)}}})
    end
end})

settings_theme:Colorpicker({name = "accent", def = c3rgb(12, 157, 0), flag = "t_acc", callback = function() update_theme("accent", library.flags["t_acc"]) end})
settings_theme:Colorpicker({name = "contrast", def = c3rgb(30, 30, 30), flag = "t_cont", callback = function() update_theme("cont", library.flags["t_cont"]) end})
settings_theme:Colorpicker({name = "light contrast", def = c3rgb(40, 40, 40), flag = "t_lcont", callback = function() update_theme("lcont", library.flags["t_lcont"]) end})
settings_theme:Colorpicker({name = "dark contrast", def = c3rgb(20, 20, 20), flag = "t_dcont", callback = function() update_theme("dcont", library.flags["t_dcont"]) end})
settings_theme:Colorpicker({name = "outline", def = c3rgb(), flag = "t_out", callback = function() update_theme("outline", library.flags["t_out"]) end})
settings_theme:Colorpicker({name = "outline 2", def = c3rgb(45, 45, 45), flag = "t_out2", callback = function() update_theme("outline2", library.flags["t_out2"]) end})

utility:Connect(uis.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Home then
        if window.frame.Visible and not window.fading then
            for i, v in pairs(esp_preview.instances) do
                v.Lerp({Transparency = 0}, 0.2)

                task.delay(0.2, function()
                    v.Visible = false
                    v.Transparency = rawget(v, "__properties")["Transparency"] or 1
                end)
            end
        else
            if window.sshit and not window.fading then
                for i, v in pairs(esp_preview.instances) do
                    v.Visible = window.sshit.name == "esp"
                    v.Transparency = 0

                    v.Lerp({Transparency = rawget(v, "__properties")["Transparency"] or 1}, 0.2)
                end
            end
        end

        window:Fade()
    end
end)

window:Connect({con = "tab", callback = function()
    for i, v in pairs(esp_preview.instances) do
        v.Visible = window.frame.Visible and window.sshit and window.sshit.name == "esp"
    end
end})

local rb_trg = nil
local weapon = nil

local server_origin = nil

task.spawn(function()
    repeat task.wait() until library.loaded

    local reset_tick = tick()
    local frames = 0
    local frame_data = 0

    local ispyonlittlekids = {}

    local cam = workspace.CurrentCamera

    local superspin555 = {}
    local angle = 0

    local last_shoot_tick = 0
    local last_weapon_fr
    local last_spam_tick = 0

    local expectedToSelect = {primary = nil, secondary = nil, melee = nil}

    local alivePlayers = {}

    local weapon_barrel_vector

    local sa_target

    local last_tbot_tick, tbot_on_target = 0, false

    utility:Connect(rs.Heartbeat, function(delta)
        local name = library.flags["cheat_name"] ~= "" and library.flags["cheat_name"] or "Skyline"

        if tick()-reset_tick < 1 then
            frames += 1
        else
            frame_data = frames
            frames = 0
            reset_tick = tick()
        end

        local date_data = os.date():split(" ")

        window.watermark:SetText(("%s | %s, %s, %s | fps: %s"):format(name, date_data[2], date_data[3], date_data[5], frame_data))

        window:SetSecretFunctionNameNotWindowNameClickGrabifyPNEK8UPleaseBotlagArgyyyHaxx(name)

        if workspace.Ignore:FindFirstChild("RefPlayer") and client.wcmod:getController() ~= nil then

            local refplr = workspace.Ignore.RefPlayer

            if library.flags["aa_enabled"] then
                client.network:send("stance", library.flags["aa_stance"]:lower())
            end

            if library.flags["m_bhop"] and table.find(window.kbds, "miscmovementbunnyhopKeybind") then
                local vel = Vector3.zero

                if uis:IsKeyDown("W") then
                    vel = vel + cam.CFrame.LookVector
                end
                if uis:IsKeyDown("S") then
                    vel = vel - cam.CFrame.LookVector
                end
                if uis:IsKeyDown("A") then
                    vel = vel - cam.CFrame.RightVector
                end
                if uis:IsKeyDown("D") then
                    vel = vel + cam.CFrame.RightVector
                end

                if vel.Magnitude > 0 then
                    vel = Vector3.new(vel.X, 0, vel.Z)
                    refplr.HumanoidRootPart.Velocity = (vel.Unit * (library.flags["m_bhop_speed"] * 1.3)) + Vector3.new(0, refplr.HumanoidRootPart.Velocity.Y, 0)
                    refplr.Humanoid.Jump = true
                end
            end

            local controller = client.wcmod:getController()

            weapon = controller._activeWeaponRegistry[controller._activeWeaponIndex]

            if library.flags["rb_enabled"] then
                local wpdata = weapon._weaponData
                local acceleration = Vector3.new(0, -workspace.Gravity, 0)
                local origin = (library.flags["rb_or"] == "server position" and server_origin ~= nil and server_origin) or (library.flags["rb_or"] == "client position" and workspace.Ignore.RefPlayer.HumanoidRootPart.Position) or (weapon._barrelPart and weapon._barrelPart.Position) or workspace.Ignore.RefPlayer.HumanoidRootPart.Position

                rb_trg = nil

                for _, plr in pairs(alivePlayers) do
                    if rb_trg then break end
                    if isTarget(plr, false) then
                        local info = getupvalue(client.replication.operateOnAllEntries, 1)[plr]
    
                        local tpo = info and info._alive and info._thirdPersonObject or nil

                        if tpo and not info._updateReceived and (tpo._torso.Position - tpo._character["Left Arm"].Position).Magnitude < 5 then

                            for i, v in pairs(library.flags["rb_hs"]) do
                                if rb_trg then break end
                                if weapon._barrelPart ~= nil then
                                    local ht_hit = tpo._character:FindFirstChild(v) and tpo._character[v]
                                    local htpos = ht_hit and ht_hit.Position or Vector3.new(1, 1, 1) * -9e9-- - Vector3.new(0, 1, 0)

                                    local pdepth, bspeed = wpdata.penetrationdepth, wpdata.bulletspeed

                                    local to_go, trajectory, flytime = player_scan(origin, htpos, pdepth, bspeed)

                                    if to_go and ht_hit ~= nil and can_shoot(typeof(wpdata.firerate) == "table" and wpdata.firerate[1] or wpdata.firerate, last_shoot_tick, library.flags["g_frate"] / 100) and weapon._magCount > 0 then

                                        rb_trg = {trajectory, plr, tpo._character[v], to_go}

                                        --[[if tpscan_success then
                                            local rx, ry, rz = cam.CFrame:ToOrientation()

                                            client.network:send("repupdate", refplr.HumanoidRootPart.Position, v2new(ry, rx), client.network.getTime())

                                            repeat task.wait() until server_origin.Y - refplr.HumanoidRootPart.Position.Y >= library.flags["tscan_power"]-1
                                        end]]

                                        local time, bullets = client.network.getTime(), getupvalue(client.fireobject.fireRound, 10)

                                        last_shoot_tick = tick()
                                        last_weapon_fr = typeof(wpdata.firerate) == "table" and wpdata.firerate[1] or wpdata.firerate

                                        if library.flags["rb_swa"] then
                                            if not library.flags["s_tper"] or not table.find(window.kbds, "visualsselfthird personKeybind") then
                                                weapon:shoot(true)
    
                                                task.spawn(function()
                                                    local oldMag = weapon._magCount
    
                                                    repeat task.wait() until weapon._magCount ~= oldMag
                                                    weapon:shoot(false)
                                                end)
                                            end
                                        end

                                        client.network:send("newbullets", {
                                            firepos = to_go,
                                            camerapos = origin,
                                            bullets = {{trajectory, bullets}}
                                        }, time)

                                        client.network:send("bullethit", plr, ht_hit.Position, ht_hit.Name, bullets, time)

                                        weapon._magCount = weapon._magCount - 1

                                        if weapon._magCount == 0 and weapon._spareCount > 0 then
                                            load_weapon_data(weapon._weaponName)

                                            local magsize = client.guns[weapon._weaponName].magsize

                                            weapon._magCount = weapon._spareCount >= magsize and magsize or weapon._spareCount
                                            weapon._spareCount = weapon._spareCount >= magsize and weapon._spareCount - magsize or 0

                                            client.network:send("reload")
                                        end
                                        
                                        setupvalue(client.fireobject.fireRound, 10, bullets + 1)
                                        
                                    end
                                end
                            end

                        end
                    end
                end
            end

            if library.flags["kb_enabled"] and weapon then
                for i, plr in pairs(alivePlayers) do
                    if isTarget(plr, false) then
                        local info = getupvalue(client.replication.operateOnAllEntries, 1)[plr]
    
                        local tpo = info and info._alive and info._thirdPersonObject or nil

                        if tpo and server_origin then
                            if (tpo._torso.Position - server_origin).Magnitude < library.flags["kb_dist"] then
                                local current_index = controller._activeWeaponIndex

                                if library.flags["kb_ae"] then
                                    client.network:send("equip", 3, client.network.getTime())
                                    client.network:send("knifehit", plr, tpo._torso.Name)
                                    client.network:send("equip", current_index, client.network.getTime())
                                elseif current_index == 3 then
                                    client.network:send("knifehit", plr, tpo._torso.Name)
                                end    
                            end
                        end
                    end
                end
            end

            if (library.flags["as_enabled"] and table.find(window.kbds, "legitaim assistenabledKeybind")) or library.flags["rdir_sa"] and not window.frame.Visible then
                local visiblePlayers = {}

                for _, plr in pairs(alivePlayers) do

                    local info = getupvalue(client.replication.operateOnAllEntries, 1)[plr]
    
                    local tpo = (info ~= nil and info._alive and info._thirdPersonObject) or nil

                    if isTarget(plr, false) and tpo ~= nil and (tpo._torso.Position - tpo._character["Left Arm"].Position).Magnitude < 5 then

                        local vector, onScreen = cam:WorldToViewportPoint(tpo._torso.Position)

                        if onScreen then
                            visiblePlayers[{plr, tpo}] = v2new(vector.X, vector.Y)
                        end

                    end
                end

                if library.flags["as_enabled"] and table.find(window.kbds, "legitaim assistenabledKeybind") then


                    local aimTarget

                    local scanOrigin = utility:ScreenSize() / 2

                    if library.flags["as_bf"] and weapon_barrel_vector then
                        scanOrigin = weapon_barrel_vector
                    end

                    if library.flags["as_vis_fov"] then
                        vis_circles.as_fov.Position = scanOrigin
                        vis_circles.as_fov.Radius = library.flags["as_fov"]
                        vis_circles.as_fov.Color = library.flags["as_vis_fov_clr"]
                        vis_circles.as_fov.Visible = true

                        vis_circles.as_fov_out.Position = vis_circles.as_fov.Position
                        vis_circles.as_fov_out.Radius = vis_circles.as_fov.Radius
                        vis_circles.as_fov_out.Color = library.flags["as_vis_fov_out"]
                        vis_circles.as_fov_out.Visible = true
                    else
                        vis_circles.as_fov.Visible = false
                        vis_circles.as_fov_out.Visible = false
                    end

                    if library.flags["as_vis_dz"] then
                        vis_circles.as_dz.Position = scanOrigin
                        vis_circles.as_dz.Radius = library.flags["as_dz"]
                        vis_circles.as_dz.Color = library.flags["as_vis_dz_clr"][1]
                        vis_circles.as_dz.Transparency = 1 - library.flags["as_vis_dz_clr"][2]
                        vis_circles.as_dz.Visible = true
                    else
                        vis_circles.as_dz.Visible = false
                    end

                    for plrdata, v in pairs(visiblePlayers) do
                        
                        local hitscan = {}
                        local selectedHitbox

                        local plr = plrdata[1]
                        local tpo = plrdata[2]

                        for i, v in pairs(library.flags["as_hp"]) do
                            if v == "head" then
                                table.insert(hitscan, tpo._character.Head)
                            elseif v == "torso" then
                                table.insert(hitscan, tpo._torso)
                            end
                        end

                        for _, hs in pairs(hitscan) do

                            local scannedPos = hs.Name == "Torso" and v or cam:WorldToViewportPoint(hs.Position)

                            scannedPos = v2new(scannedPos.X, scannedPos.Y)

                            local mag = (scanOrigin - scannedPos).Magnitude

                            if library.flags["as_tp"] == "in fov" then

                                if mag <= library.flags["as_fov"] and mag >= library.flags["as_dz"] then
                                    selectedHitbox = scannedPos
                                    break
                                end

                            else

                                if selectedHitbox then
                                    if (scanOrigin - selectedHitbox).Magnitude > mag then
                                        selectedHitbox = scannedPos
                                    end
                                else
                                    if mag <= library.flags["as_fov"] and mag >= library.flags["as_dz"] then
                                        selectedHitbox = scannedPos
                                    end
                                end

                            end

                        end

                        if selectedHitbox then
                            if library.flags["as_tp"] == "in fov" then
                                aimTarget = {plr, selectedHitbox}
                                break
                            else
                                if aimTarget then
                                    if (scanOrigin - aimTarget[2]).Magnitude > (scanOrigin - selectedHitbox).Magnitude then
                                        aimTarget = {plr, selectedHitbox}
                                    end
                                else
                                    aimTarget = {plr, selectedHitbox}
                                end
                            end
                        end

                    end

                    if aimTarget then

                        local ptc = 1 - (library.flags["as_sm"]/100)

                        ptc = ptc == 0 and 1 or ptc

                        if library.flags["as_sm_style"] == "quadratic" then
                            ptc = ptc^2
                        elseif library.flags["as_sm_style"] == "cubic" then
                            ptc = ptc^3
                        elseif library.flags["as_sm_style"] == "sinusoidal" then
                            ptc = 1 - math.cos(ptc*math.pi/2)
                        elseif library.flags["as_sm_style"] == "elastic" then
                            ptc = ptc == 0 and 0 or ptc == 1 and 1 or math.pow(2, 10 * (ptc - 1)) * math.sin((ptc - 1.1) * 5 * math.pi)
                        elseif library.flags["as_sm_style"] == "square root" then
                            ptc = math.sqrt(ptc)
                        end

                        local mouseLocation = uis:GetMouseLocation()

                        local positionToAim = -(mouseLocation - aimTarget[2]) * ptc

                        if library.flags["as_rand"] > 0 then
                            positionToAim = -(mouseLocation - aimTarget[2] + v2new(math.random(-library.flags["as_rand"], library.flags["as_rand"]), math.random(-library.flags["as_rand"], library.flags["as_rand"]))) * ptc
                        end

                        mousemoverel(positionToAim.X, positionToAim.Y)

                    end

                else
                    vis_circles.as_fov.Visible = false
                    vis_circles.as_fov_out.Visible = false
                    vis_circles.as_dz.Visible = false
                end

                if library.flags["rdir_sa"] then

                    saTarget = nil

                    local saTarget

                    local scanOrigin = utility:ScreenSize() / 2

                    if library.flags["rdir_bf"] and weapon_barrel_vector then
                        scanOrigin = weapon_barrel_vector
                    end

                    for plrdata, v in pairs(visiblePlayers) do

                        local selectedHitbox
                        
                        local hitscan = {}

                        local plr = plrdata[1]
                        local tpo = plrdata[2]

                        for i, v in pairs(library.flags["rdir_hp"]) do
                            if v == "head" then
                                table.insert(hitscan, tpo._character.Head)
                            elseif v == "torso" then
                                table.insert(hitscan, tpo._torso)
                            end
                        end

                        for _, hs in pairs(hitscan) do

                            local scannedPos = hs.Name == "Torso" and v or cam:WorldToViewportPoint(hs.Position)

                            scannedPos = v2new(scannedPos.X, scannedPos.Y)

                            local mag = (scanOrigin - scannedPos).Magnitude

                            if library.flags["rdir_tp"] == "in fov" then

                                if mag <= library.flags["rdir_sa_fov"] then
                                    selectedHitbox = {scannedPos, hs}
                                    break
                                end

                            else

                                if selectedHitbox then
                                    if (scanOrigin - selectedHitbox[1]).Magnitude > mag then
                                        selectedHitbox = {scannedPos, hs}
                                    end
                                else
                                    if mag <= library.flags["rdir_sa_fov"] then
                                        selectedHitbox = {scannedPos, hs}
                                    end
                                end

                            end

                        end

                        if selectedHitbox then
                            if library.flags["rdir_tp"] == "in fov" then
                                saTarget = {plr, selectedHitbox}
                                break
                            else
                                if saTarget then
                                    if (scanOrigin - saTarget[2]).Magnitude > (scanOrigin - selectedHitbox).Magnitude then
                                        saTarget = {plr, selectedHitbox}
                                    end
                                else
                                    saTarget = {plr, selectedHitbox}
                                end
                            end
                        end

                    end

                    if saTarget then
                        sa_target = saTarget
                    end

                end
            else
                vis_circles.as_fov.Visible = false
                vis_circles.as_fov_out.Visible = false
                vis_circles.as_dz.Visible = false
            end

            if library.flags["tb_enabled"] and not window.frame.Visible then
                if mouse.Target and table.find(library.flags["tb_hb"], mouse.Target.Name:lower()) and not mouse.Target:IsDescendantOf(workspace.Players[tostring(lplr.TeamColor)]) then
                    if not tbot_on_target then
                        tbot_on_target = true
                        last_tbot_tick = tick()
                    end

                    if tbot_on_target and tick()-last_tbot_tick >= library.flags["tb_rt"] and weapon and (library.flags["tb_rga"] and weapon._aiming or true) then
                        weapon:shoot(true)
                        task.spawn(function()
                            local currentMag = weapon._magCount
                            repeat task.wait() until currentMag ~= weapon._magCount
                            weapon:shoot(false)
                        end)
                        last_tbot_tick = tick()
                    end
                else
                    tbot_on_target = false
                end
            else
                tbot_on_target = false
            end
        else
            vis_circles.as_fov.Visible = false
            vis_circles.as_fov_out.Visible = false
            vis_circles.as_dz.Visible = false

            tbot_on_target = false
        end

        if library.flags["ct_enabled"] then
            if tick()-last_spam_tick >= library.flags["ct_del"] then
                last_spam_tick = tick()

                client.network:send("chatted", generate_random_killsay(library.flags["ct_sel"]), nil)
            end
        end
    end)
    
    local last_size

    local ragdoll_bodies = {}
    
    utility:Connect(rs.RenderStepped, function() -- // visuals
        if window.frame.Visible then
            uis.MouseBehavior = Enum.MouseBehavior.Default
            uis.MouseIconEnabled = false

            if not last_size or last_size ~= v2new(library.flags["cheat_sx"], library.flags["cheat_sy"]) then
                last_size = v2new(library.flags["cheat_sx"], library.flags["cheat_sy"])
                window:Resize(last_size)
                esp_preview.instances[1].SetOffset(v2new(last_size.X + 20, 0))
            end
        else

            uis.MouseIconEnabled = not (workspace.Ignore:FindFirstChild("RefPlayer") ~= nil)
            uis.MouseBehavior = (workspace.Ignore:FindFirstChild("RefPlayer") ~= nil and Enum.MouseBehavior.LockCenter) or Enum.MouseBehavior.Default
        end

        if weapon and not weapon._stepModified then
            local old = weapon.step

            weapon.step = function(...)

                if client.wcmod:getController() ~= nil and client.wcmod:getController()._activeWeaponIndex == weapon.weaponIndex and weapon._barrelPart ~= nil then
                    local vector, onScreen = cam:WorldToViewportPoint((weapon._barrelPart.CFrame * CFrame.new(0, 0, -1)).p)

                    if onScreen then
                        weapon_barrel_vector = v2new(math.floor(vector.X), math.floor(vector.Y))
                    else
                        weapon_barrel_vector = nil
                    end
                end

                return old(...)
            end

            weapon._stepModified = true
        end

        for i, v in pairs(ragdoll_bodies) do
            if v[1] and v[1].Parent ~= nil then
                if not v[1].Torso.Anchored and library.flags["rg_dp"] then
                    v[1].Torso.Velocity = Vector3.new(v[2].X, 0, v[2].Y) * library.flags["rg_vm"] + Vector3.new(0, 0.1, 0)
                end

                if v[1]:FindFirstChildOfClass("Highlight") then
                    v[1]:FindFirstChildOfClass("Highlight"):Destroy()
                end

                if library.flags["rg_change"] then
                    for _, obj in pairs(v[1]:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            obj.Color = library.flags["rg_change_clr"][1]
                            obj.Transparency = library.flags["rg_change_clr"][2]

                            if obj:IsA("UnionOperation") then
                                obj.UsePartColor = true
                            end

                            if obj:FindFirstChildOfClass("SpecialMesh") then
                                obj:FindFirstChildOfClass("SpecialMesh").TextureId = ""
                            end

                            if obj:IsA("MeshPart") then
                                obj.TextureID = ""
                            end

                            if obj:FindFirstChildOfClass("Texture") then
                                obj:FindFirstChildOfClass("Texture"):Destroy()
                            end

                        end
                    end
                end
            else
                table.remove(ragdoll_bodies, i)
            end
        end

        if library.flags["e_tc_en"] then
            game.Lighting.ClockTime = library.flags["e_tc"]
        end

        game.Lighting.OutdoorAmbient = library.flags["e_am"]
        game.Lighting.GlobalShadows = library.flags["e_gs"]

        if library.flags["vc_wp"] and weapon and weapon._weaponModel then
            local material = library.flags["vc_wp_mat"]

            for i, v in pairs(weapon._weaponModel:GetChildren()) do
                if v:IsA("BasePart") and v.Transparency ~= 1 then
                    v.Color = library.flags["vc_wp_clr"][1]
                    v.Transparency = math.clamp(library.flags["vc_wp_clr"][2], 0, 0.999)
                    v.Material = material == "plastic" and "SmoothPlastic" or material == "ghost" and "ForceField" or material == "neon" and "Neon"

                    if v:IsA("UnionOperation") then
                        v.UsePartColor = true
                    end
                end
            end
        end

        if library.flags["vc_ar"] and cam:FindFirstChild("Left Arm") and cam:FindFirstChild("Right Arm") then
            local material = library.flags["vc_ar_mat"]

            for i, v in pairs(cam["Left Arm"]:GetChildren()) do
                if v:IsA("BasePart") and v.Transparency ~= 1 then
                    v.Color = library.flags["vc_ar_clr"][1]
                    v.Transparency = math.clamp(library.flags["vc_ar_clr"][2], 0, 0.999)
                    v.Material = material == "plastic" and "SmoothPlastic" or material == "ghost" and "ForceField" or material == "neon" and "Neon"

                    if v:IsA("UnionOperation") then
                        v.UsePartColor = true
                    end
                end
            end

            for i, v in pairs(cam["Right Arm"]:GetChildren()) do
                if v:IsA("BasePart") and v.Transparency ~= 1 then
                    v.Color = library.flags["vc_ar_clr"][1]
                    v.Transparency = math.clamp(library.flags["vc_ar_clr"][2], 0, 0.999)
                    v.Material = material == "plastic" and "SmoothPlastic" or material == "ghost" and "ForceField" or material == "neon" and "Neon"

                    if v:IsA("UnionOperation") then
                        v.UsePartColor = true
                    end
                end
            end
        end

        if library.flags["s_chams"] and client.fake_character._thirdPersonObject and client.fake_character._thirdPersonObject._character then
            local material = library.flags["s_material"]

            for i, v in pairs(client.fake_character._thirdPersonObject._character:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency ~= 1 then
                    v.Color = library.flags["s_chams_clr"][1]
                    v.Transparency = math.clamp(library.flags["s_chams_clr"][2], 0, 0.999)

                    v.Material = material == "plastic" and "SmoothPlastic" or material == "ghost" and "ForceField" or material == "neon" and "Neon"

                    if v:IsA("UnionOperation") then
                        v.UsePartColor = true
                    end

                    if v:FindFirstChildOfClass("SpecialMesh") then
                        v:FindFirstChildOfClass("SpecialMesh").TextureId = material == "Ghost" and "rbxassetid://5558971297" or ""
                        v:FindFirstChildOfClass("SpecialMesh").VertexColor = Vector3.new(v.Color.R, v.Color.G, v.Color.B)
                    end

                    if v:IsA("MeshPart") then
                        v.TextureID = material == "Ghost" and "rbxassetid://5558971297" or ""
                    end

                    if v:FindFirstChildOfClass("Texture") then
                        v:FindFirstChildOfClass("Texture"):Destroy()
                    end
                end
            end
        end

        if library.flags["cr_enabled"] then
            angle = angle + ((library.flags["cr_speed"] / 10) * library.flags["cr_dir"])

            local screen_center = utility:RoundVector(utility:ScreenSize() / 2)

            if weapon and weapon._barrelPart == nil then
                weapon_barrel_vector = nil
            end

            if weapon and library.flags["cr_follow"] and weapon_barrel_vector and workspace.Ignore:FindFirstChild("RefPlayer") then
                screen_center = weapon_barrel_vector
            end

            if library.flags["cr_mode"] == "default" then
                if #superspin555 / 2 ~= library.flags["cr_lines"] or superspin555.mode ~= "default" then
                    for i, v in pairs(superspin555) do
                        if typeof(v) ~= "string" then
                            v.Remove()
                        end
                    end
        
                    table.clear(superspin555)
        
                    for i = 1, library.flags["cr_lines"] do
                        superspin555[i] = utility:Draw("Line", nil, {Thickness = 2, ZIndex = 1}, true)
                        superspin555[i+library.flags["cr_lines"]] = utility:Draw("Line", nil, {Thickness = 4, ZIndex = 0}, true)
                    end

                    superspin555[9999] = utility:Draw("Square", nil, {Size = v2new(2, 2)}, true)
                    superspin555[10000] = utility:Draw("Square", nil, {Size = v2new(4, 4), Filled = false}, true)

                    superspin555.mode = library.flags["cr_mode"]
                end

                if library.flags["cr_dot"] then
                    superspin555[9999].Size = v2new(1, 1) * library.flags["cr_thick"]
                    superspin555[9999].Position = screen_center - (superspin555[9999].Size / 2)
                    superspin555[9999].Color = library.flags["cr_clr"]
                    superspin555[9999].Visible = true
    
                    superspin555[10000].Size = superspin555[9999].Size + v2new(2, 2)
                    superspin555[10000].Position = screen_center - (superspin555[10000].Size / 2)
                    superspin555[10000].Color = library.flags["cr_out"]
                    superspin555[10000].Visible = true
                else
                    superspin555[9999].Visible = false
                    superspin555[10000].Visible = false
                end

                for i = 1, library.flags["cr_lines"] do
                    local our_angle = (angle) + (i * (360 / library.flags["cr_lines"]))
    
                    local offset = library.flags["cr_offset"]-- + ((spinning_cursor.offset/2) * math.cos(tick()))
                    local length = library.flags["cr_length"]-- + ((spinning_cursor.length/4) * math.cos(tick()))
    
                    superspin555[i].From = screen_center + v2new(offset * math.cos(math.rad(our_angle)), offset * math.sin(math.rad(our_angle)))
                    superspin555[i].To = screen_center + v2new((offset + length) * math.cos(math.rad(our_angle)), (offset + length) * math.sin(math.rad(our_angle)))
                    superspin555[i].Thickness = library.flags["cr_thick"]
                    superspin555[i].Color = library.flags["cr_clr"]
                    superspin555[i].Visible = true
    
                    superspin555[i+library.flags["cr_lines"]].From = screen_center + v2new((offset-1) * math.cos(math.rad(our_angle)), (offset-1) * math.sin(math.rad(our_angle)))
                    superspin555[i+library.flags["cr_lines"]].To = screen_center + v2new((offset+length+1) * math.cos(math.rad(our_angle)), (offset+length+1) * math.sin(math.rad(our_angle)))
                    superspin555[i+library.flags["cr_lines"]].Thickness = library.flags["cr_thick"] + 2
                    superspin555[i+library.flags["cr_lines"]].Color = library.flags["cr_out"]
                    superspin555[i+library.flags["cr_lines"]].Visible = true
                end
            elseif library.flags["cr_mode"] == "> <" then
                if #superspin555 / 2 ~= 4 or superspin555.mode ~= "> <" then
                    for i, v in pairs(superspin555) do
                        if typeof(v) ~= "string" then
                            v.Remove()
                        end
                    end
        
                    table.clear(superspin555)

                    for i = 1, 4 do
                        superspin555[i] = utility:Draw("Line", nil, {Thickness = 1, ZIndex = 1}, true)
                        superspin555[i+4] = utility:Draw("Line", nil, {Thickness = 3, ZIndex = 0}, true)
                    end

                    superspin555.mode = library.flags["cr_mode"]
                end

                for i = 1, 4 do
                    if i < 3 then
                        superspin555[i].From = screen_center - v2new(4 + library.flags["cr_length"], i == 1 and library.flags["cr_offset"] or -library.flags["cr_offset"])
                        superspin555[i].To = screen_center - v2new(4.5, 0)

                        local unit = superspin555[i].From.Unit

                        superspin555[i+4].From = superspin555[i].From - v2new(unit.X, i == 1 and unit.Y or -unit.Y)
                        superspin555[i+4].To = superspin555[i].To + v2new(unit.X, 0)
                    else
                        superspin555[i].From = screen_center + v2new(4.5 + library.flags["cr_length"], i == 3 and -library.flags["cr_offset"] or library.flags["cr_offset"])
                        superspin555[i].To = screen_center + v2new(5, 0)

                        local unit = superspin555[i].From.Unit

                        superspin555[i+4].From = superspin555[i].From + v2new(unit.X, i == 3 and -unit.Y or unit.Y)
                        superspin555[i+4].To = superspin555[i].To - v2new(unit.X, 0)
                    end

                    superspin555[i].Color = library.flags["cr_clr"]
                    superspin555[i].Visible = true

                    superspin555[i+4].Color = library.flags["cr_out"]
                    superspin555[i+4].Visible = true
                end

                --[[superspin555[1].Position = screen_center - v2new(0, math.floor((7 + library.flags["cr_length"])/2))
                superspin555[1].Color = library.flags["cr_clr"]
                superspin555[1].OutlineColor = library.flags["cr_out"]
                superspin555[1].Size = 7 + library.flags["cr_length"]
                superspin555[1].Visible = true]]
            end

        else

            for i, v in pairs(superspin555) do
                if typeof(v) ~= "string" then
                    v.Visible = false
                end
            end

        end

        if not window.fading and window.frame.Visible then
            local esp_flag = library.flags["st_esp_preview"] == "enemy" and "en" or library.flags["st_esp_preview"]

            esp_preview.instances[4].Transparency = library.flags[("%s_esp_name"):format(esp_flag)] and 1 or 0.5
            esp_preview.instances[4].Color = library.flags[("%s_esp_name_clr"):format(esp_flag)]

            esp_preview.instances[5].Transparency = library.flags[("%s_esp_box"):format(esp_flag)] and 1 or 0.5
            esp_preview.instances[5].Color = library.flags[("%s_esp_box_clr"):format(esp_flag)]
            esp_preview.instances[6].Transparency = library.flags[("%s_esp_box"):format(esp_flag)] and 1 or 0.5
            esp_preview.instances[6].Color = library.flags[("%s_esp_box_out"):format(esp_flag)]

            esp_preview.instances[7].Transparency = library.flags[("%s_esp_weapon"):format(esp_flag)] and 1 or 0.5
            esp_preview.instances[7].Color = library.flags[("%s_esp_weapon_clr"):format(esp_flag)]

            for i = 1, 6 do
                esp_preview.instances[7 + i].Color = library.flags[("%s_esp_chams_clr"):format(esp_flag)][1]
            end

            local hbar_ptc = (1 + math.cos(tick()))/2

            esp_preview.instances[14].Size = v2new(1, (esp_preview.instances[15].Size.Y-2) * hbar_ptc)
            esp_preview.instances[14].SetOffset(v2new(1, 1 + (esp_preview.instances[15].Size.Y-2) * (1-hbar_ptc)))
            esp_preview.instances[14].Color = library.flags[("%s_esp_hbar_c1"):format(esp_flag)]:Lerp(library.flags[("%s_esp_hbar_c2"):format(esp_flag)], 1-hbar_ptc)

            esp_preview.instances[15].Color = library.flags[("%s_esp_hbar_out"):format(esp_flag)]
        end

        if workspace.Ignore:FindFirstChild("RefPlayer") then
            table.clear(alivePlayers)

            for _, plr in pairs(plrs:GetPlayers()) do
                local info = getupvalue(client.replication.operateOnAllEntries, 1)[plr]
    
                local tpo = (info ~= nil and info._alive and info._thirdPersonObject) or nil
                
                if tpo and tpo._torso and (tpo._torso.Position - tpo._character["Left Arm"].Position).Magnitude < 5 then
                    table.insert(alivePlayers, plr)
                end
            end

            table.insert(alivePlayers, lplr)
        end
        
        if (library.flags["en_esp_enabled"] or library.flags["team_esp_enabled"] or library.flags["self_esp_enabled"]) and workspace.Ignore:FindFirstChild("RefPlayer") and not window.frame.Visible then

            for plr, data in pairs(esp_info) do

                local plr_flag = (plr == lplr and "self") or (isTarget(plr, false) and "en") or (not isTarget(plr, false) and "team")

                if library.flags[("%s_esp_enabled"):format(plr_flag)] and table.find(alivePlayers, plr) and (plr_flag == "self" and client.fake_character._thirdPersonObject ~= nil or plr_flag ~= "self") then
                    local info = getupvalue(client.replication.operateOnAllEntries, 1)[plr]
    
                    local tpo = (info ~= nil and info._alive and info._thirdPersonObject) or (plr_flag == "self" and client.fake_character._thirdPersonObject) or nil

                    local pos, size = tpo._character:GetBoundingBox()

                    local x = (cam.CFrame - cam.CFrame.p) * Vector3.new(math.clamp(size.X / 2, 0, 2) + 0.5, 0, 0)
                    local y = (cam.CFrame - cam.CFrame.p) * Vector3.new(0, math.clamp(size.Y / 2, 0, 3) + 0.5, 0)

                    local width = (cam:WorldToViewportPoint(pos.p + x).X - cam:WorldToViewportPoint(pos.p - x).X)
                    local height = (cam:WorldToViewportPoint(pos.p - y).Y - cam:WorldToViewportPoint(pos.p + y).Y)

                    local size = v2new(math.floor(width), math.floor(height))

                    size = v2new(size.X % 2 == 0 and size.X or size.X + 1, size.Y % 2 == 0 and size.Y or size.Y + 1)

                    local vector, onScreen = cam:WorldToViewportPoint(tpo._torso.Position)

                    ispyonlittlekids[plr] = {tick(), tpo._torso.Position, size}

                    local healthstate = tpo._replicationObject._healthstate

                    local health_ptc = (healthstate.health0 == 0 and 100 or healthstate.health0)/healthstate.maxhealth

                    if onScreen then

                        if library.flags[("%s_esp_chams"):format(plr_flag)] then
                            local high = tpo._character:FindFirstChild("chingachangachamsa") or Instance.new("Highlight", tpo._character)

                            high.FillColor = library.flags[("%s_esp_chams_clr"):format(plr_flag)][1]
                            high.FillTransparency = library.flags[("%s_esp_chams_clr"):format(plr_flag)][2]

                            high.OutlineColor = library.flags[("%s_esp_chams_out"):format(plr_flag)][1]
                            high.OutlineTransparency = library.flags[("%s_esp_chams_out"):format(plr_flag)][2]

                            high.Name = "chingachangachamsa"
                        else

                            if tpo._character:FindFirstChild("chingachangachamsa") then
                                tpo._character:FindFirstChild("chingachangachamsa"):Destroy()
                            end

                        end

                        if library.flags[("%s_esp_box"):format(plr_flag)] then
                            data.box.Visible = onScreen
                            data.box.Size = size
                            data.box.Position = v2new(math.floor(vector.X), math.floor(vector.Y)) - (data.box.Size / 2)
                            data.box.Color = library.flags[("%s_esp_box_clr"):format(plr_flag)]

                            data.boxout.Visible = onScreen
                            data.boxout.Color = library.flags[("%s_esp_box_out"):format(plr_flag)]
                            data.boxout.Size = size
                            data.boxout.Position = v2new(math.floor(vector.X), math.floor(vector.Y)) - (data.box.Size / 2)
                        else
                            data.box.Visible = false
                            data.boxout.Visible = false
                        end

                        if library.flags[("%s_esp_hbar"):format(plr_flag)] then
                            data.hbar.Visible = onScreen
                            data.hbar.Size = v2new(1, math.floor(size.Y * health_ptc))
                            data.hbar.Position = v2new(math.floor(vector.X - 5), math.floor(vector.Y + (size.Y * (1-health_ptc)))) - (size / 2)
                            data.hbar.Color = library.flags[("%s_esp_hbar_c1"):format(plr_flag)]:Lerp(library.flags[("%s_esp_hbar_c2"):format(plr_flag)], 1-health_ptc)

                            data.hbarout.Visible = onScreen
                            data.hbarout.Size = v2new(3, size.Y+2)
                            data.hbarout.Position = v2new(math.floor(vector.X - 6), math.floor(vector.Y-1)) - (size / 2)
                            data.hbarout.Color = library.flags[("%s_esp_hbar_out"):format(plr_flag)]
                        else
                            data.hbar.Visible = false
                            data.hbarout.Visible = false
                        end

                        if library.flags[("%s_esp_name"):format(plr_flag)] then
                            data.name.Visible = onScreen
                            data.name.Position = v2new(math.floor(vector.X), math.floor(vector.Y) - size.Y / 2 - 16)
                            data.name.Color = library.flags[("%s_esp_name_clr"):format(plr_flag)]
                            data.name.OutlineColor = library.flags[("%s_esp_name_out"):format(plr_flag)]
                        else
                            data.name.Visible = false
                        end

                        if library.flags[("%s_esp_weapon"):format(plr_flag)] then
                            data.wpn.Visible = onScreen
                            data.wpn.Position = v2new(math.floor(vector.X), math.floor(vector.Y) + size.Y / 2 + 4)
                            data.wpn.Text = tpo._weaponname
                            data.wpn.Color = library.flags[("%s_esp_weapon_clr"):format(plr_flag)]
                            data.wpn.OutlineColor = library.flags[("%s_esp_weapon_out"):format(plr_flag)]
                        else
                            data.wpn.Visible = false
                        end

                        if library.flags[("%s_esp_skeleton"):format(plr_flag)] then
                            local torso_up = cam:WorldToViewportPoint((tpo._torso.CFrame * CFrame.new(0, tpo._torso.Size.Y/2, 0)).p)
                            local torso_down = cam:WorldToViewportPoint((tpo._torso.CFrame * CFrame.new(0, -tpo._torso.Size.Y/2, 0)).p)

                            local rarm = cam:WorldToViewportPoint((tpo._character["Right Arm"].CFrame * CFrame.new(0, -tpo._character["Right Arm"].Size.Y/2, 0)).p)
                            local larm = cam:WorldToViewportPoint((tpo._character["Left Arm"].CFrame * CFrame.new(0, -tpo._character["Left Arm"].Size.Y/2, 0)).p)

                            local rleg = cam:WorldToViewportPoint((tpo._character["Right Leg"].CFrame * CFrame.new(0, -tpo._character["Right Leg"].Size.Y/2, 0)).p)
                            local lleg = cam:WorldToViewportPoint((tpo._character["Left Leg"].CFrame * CFrame.new(0, -tpo._character["Left Leg"].Size.Y/2, 0)).p)

                            data.sk_torso.From = v2new(torso_up.X, torso_up.Y)
                            data.sk_torso.To = v2new(torso_down.X, torso_down.Y)

                            data.sk_rarm.From = v2new(vector.X, vector.Y)
                            data.sk_rarm.To = v2new(rarm.X, rarm.Y)

                            data.sk_larm.From = v2new(vector.X, vector.Y)
                            data.sk_larm.To = v2new(larm.X, larm.Y)

                            data.sk_rleg.From = v2new(torso_down.X, torso_down.Y)
                            data.sk_rleg.To = v2new(rleg.X, rleg.Y)

                            data.sk_lleg.From = v2new(torso_down.X, torso_down.Y)
                            data.sk_lleg.To = v2new(lleg.X, lleg.Y)

                            for _, v in pairs({"torso", "rarm", "larm", "rleg", "lleg"}) do
                                data[("sk_%s"):format(v)].Visible = onScreen
                                data[("sk_%s"):format(v)].Color = library.flags[("%s_esp_skeleton_clr"):format(plr_flag)]

                                data[("sk_%s_out"):format(v)].Visible = onScreen
                                data[("sk_%s_out"):format(v)].From = data[("sk_%s"):format(v)].From
                                data[("sk_%s_out"):format(v)].To = data[("sk_%s"):format(v)].To
                                data[("sk_%s_out"):format(v)].Color = library.flags[("%s_esp_skeleton_out"):format(plr_flag)]
                            end

                            ispyonlittlekids[plr] = {tick(), tpo._torso.Position, size, {
                                (tpo._torso.CFrame * CFrame.new(0, tpo._torso.Size.Y/2, 0)).p, 
                                (tpo._torso.CFrame * CFrame.new(0, -tpo._torso.Size.Y/2, 0)).p, 
                                (tpo._character["Right Arm"].CFrame * CFrame.new(0, -tpo._character["Right Arm"].Size.Y/2, 0)).p, 
                                (tpo._character["Left Arm"].CFrame * CFrame.new(0, -tpo._character["Left Arm"].Size.Y/2, 0)).p, 
                                (tpo._character["Right Leg"].CFrame * CFrame.new(0, -tpo._character["Right Leg"].Size.Y/2, 0)).p, 
                                (tpo._character["Left Leg"].CFrame * CFrame.new(0, -tpo._character["Left Leg"].Size.Y/2, 0)).p
                            }}
                        else
                            for _, v in pairs({"torso", "rarm", "larm", "rleg", "lleg"}) do
                                data[("sk_%s"):format(v)].Visible = false
                                data[("sk_%s_out"):format(v)].Visible = false
                            end
                        end
                    else
                        if tpo ~= nil then
                            if tpo._character:FindFirstChild("chingachangachamsa") then
                                tpo._character:FindFirstChild("chingachangachamsa"):Destroy()
                            end
                        end
        
                        for i, v in pairs(data) do
                            v.Visible = false
                        end
                    end
                else
                    if tpo ~= nil then
                        if tpo._character:FindFirstChild("chingachangachamsa") then
                            tpo._character:FindFirstChild("chingachangachamsa"):Destroy()
                        end

                    else
                        local do_things = true

                        if ispyonlittlekids[plr] and tick()-ispyonlittlekids[plr][1] < 0.5 then
                            local vector, onScreen = cam:WorldToViewportPoint(ispyonlittlekids[plr][2])

                            do_things = not onScreen
                            if onScreen then
                                for i, v in pairs(data) do
                                    v.Transparency = 1 - ((tick()-ispyonlittlekids[plr][1])/0.5)
                                end

                                local expectedPos = v2new(vector.X, vector.Y)
                                local size = ispyonlittlekids[plr][3]

                                data.box.Position = expectedPos - (size / 2)
                                data.boxout.Position = data.box.Position

                                data.hbar.Size = v2new(0, 0)
                                data.hbarout.Position = expectedPos - (size / 2) - v2new(6, 1)
                                
                                data.name.Position = expectedPos - v2new(0, size.Y / 2 + 16)
                                data.wpn.Position = expectedPos + v2new(0, size.Y / 2 + 4)

                                if ispyonlittlekids[plr][4] then
                                    local skdata = ispyonlittlekids[plr][4]

                                    local torso_up = cam:WorldToViewportPoint(skdata[1])
                                    local torso_down = cam:WorldToViewportPoint(skdata[2])

                                    local rarm = cam:WorldToViewportPoint(skdata[3])
                                    local larm = cam:WorldToViewportPoint(skdata[4])

                                    local rleg = cam:WorldToViewportPoint(skdata[5])
                                    local lleg = cam:WorldToViewportPoint(skdata[6])

                                    data.sk_torso.From = v2new(torso_up.X, torso_up.Y)
                                    data.sk_torso.To = v2new(torso_down.X, torso_down.Y)

                                    data.sk_rarm.From = expectedPos
                                    data.sk_rarm.To = v2new(rarm.X, rarm.Y)

                                    data.sk_larm.From = expectedPos
                                    data.sk_larm.To = v2new(larm.X, larm.Y)

                                    data.sk_rleg.From = v2new(torso_down.X, torso_down.Y)
                                    data.sk_rleg.To = v2new(rleg.X, rleg.Y)

                                    data.sk_lleg.From = v2new(torso_down.X, torso_down.Y)
                                    data.sk_lleg.To = v2new(lleg.X, lleg.Y)

                                    for _, v in pairs({"torso", "rarm", "larm", "rleg", "lleg"}) do
                                        data[("sk_%s"):format(v)].Color = library.flags[("%s_esp_skeleton_clr"):format(plr_flag)]
        
                                        data[("sk_%s_out"):format(v)].From = data[("sk_%s"):format(v)].From
                                        data[("sk_%s_out"):format(v)].To = data[("sk_%s"):format(v)].To
                                        data[("sk_%s_out"):format(v)].Color = library.flags[("%s_esp_skeleton_out"):format(plr_flag)]
                                    end
                                end
                            end
                        end

                        if do_things then
                            for i, v in pairs(data) do
                                v.Visible = false
                                v.Transparency = 1
                            end
                        end
                    end
                end
            end
        else
            
            for plr, data in pairs(esp_info) do
                local info = getupvalue(client.replication.operateOnAllEntries, 1)[plr]
    
                local tpo = (info and info._alive and info._thirdPersonObject) or nil

                if tpo and tpo._character:FindFirstChild("chingachangachamsa") then
                    tpo._character:FindFirstChild("chingachangachamsa"):Destroy()
                end

                for i, v in pairs(data) do
                    v.Visible = false
                end
            end

        end
    end)

    local oldSend = client.network.send

    local THANKS_TO_J_YOU_DUMBASS_IVE_BEEN_WAITING_ONE_HOUR_FOR_THAT = 0

    client.network.send = function(self, ...)
        
        local args = {...}

        if args[1] == "repupdate" then
            if library.flags["aa_enabled"] then
                local baseAngles = v2new(0, args[3].Y)

                if library.flags["aa_yaw_base"] == "-" then
                    baseAngles = v2new()
                elseif library.flags["aa_yaw_base"] == "spin" then
                    baseAngles = v2new(0, math.rad((tick()*360)%360) * library.flags["aa_spp"])
                end

                args[3] = baseAngles + v2new(library.flags["aa_pitch"], math.rad(library.flags["aa_yaw"]))

                if library.flags["aa_spaz"] > 0 then
                    local spzm = library.flags["aa_spaz"]*100
                    args[2] = args[2] + Vector3.new(math.random(-spzm, spzm)/100, 0, math.random(-spzm, spzm)/100)
                end

                if library.flags["m_cstr"] and table.find(window.kbds, "miscmovementcircle strafeKeybind") then
                    args[2] = args[2] + Vector3.new(library.flags["m_cstr_rad"] * math.cos( tick() * library.flags["m_cstr_speed"] ), 0, library.flags["m_cstr_rad"] * math.sin( tick() * library.flags["m_cstr_speed"] ))
                end
            end

            if library.flags["rb_enabled"] and library.flags["tscan_enabled"] and rb_trg and rb_trg[5] ~= nil then
                args[2] = args[2] + Vector3.new(0, library.flags["tscan_power"], 0)
            end

            server_origin = args[2]

            args[4] = args[4] + THANKS_TO_J_YOU_DUMBASS_IVE_BEEN_WAITING_ONE_HOUR_FOR_THAT

            THANKS_TO_J_YOU_DUMBASS_IVE_BEEN_WAITING_ONE_HOUR_FOR_THAT = THANKS_TO_J_YOU_DUMBASS_IVE_BEEN_WAITING_ONE_HOUR_FOR_THAT + library.flags["f_tsa"]

            local tpo = client.fake_character._thirdPersonObject

            local wpcont = client.wcmod:getController()

            local wpcont_awr = wpcont._activeWeaponRegistry

            client.fake_character._activeWeaponRegistry = {
                {
                    weaponName = wpcont_awr[1]._weaponName,
                    weaponData = wpcont_awr[1]._weaponData,
                    attachmentData = wpcont_awr[1]._weaponAttachments,
                    camoData = wpcont_awr[1]._camoList
                },
                {
                    weaponName = wpcont_awr[2]._weaponName,
                    weaponData = wpcont_awr[2]._weaponData,
                    attachmentData = wpcont_awr[2]._weaponAttachments,
                    camoData = wpcont_awr[2]._camoList
                },
                {
                    weaponName = wpcont_awr[3]._weaponName,
                    weaponData = wpcont_awr[3]._weaponData,
                    camoData = wpcont_awr[3]._camoList
                },
                {
                    weaponName = wpcont_awr[4]._weaponName,
                    weaponData = wpcont_awr[4]._weaponData
                }
            }

            if library.flags["s_tper"] and table.find(window.kbds, "visualsselfthird personKeybind") then
                
                if not tpo then
                    --[[if client.fake_character._player then
                        client.fake_character._player:Destroy()
                    end]]

                    --client.fake_character._player = lplr

                    client.fake_character._thirdPersonObject = client.tpo.new(client.fake_character._player, nil, client.fake_character)

                    if weapon then
                        if weapon.weaponIndex ~= 3 then
                            client.fake_character._thirdPersonObject:equip(weapon.weaponIndex, true)
                        else
                            client.fake_character._thirdPersonObject:equipMelee(3, true)
                        end
                    else
                        client.fake_character._thirdPersonObject:equip(1, true)
                    end
                    
                    client.fake_character._alive = true
                end

                client.fake_character._smoothReplication:receive(self.getTime(), tick(), {
                    t = tick(),
                    position = args[2],
                    angles = args[3],
                    velocity = Vector3.zero,
                    breakcount = 0
                }, false)

                client.fake_character._updateReceived = true
                client.fake_character._receivedPosition = args[2]
                client.fake_character._receivedFrameTime = tick()
                client.fake_character._lastPacketTime = self.getTime()
                client.fake_character:step(3, true)

            else
                if client.fake_character._thirdPersonObject and client.fake_character._alive then
                    client.fake_character._thirdPersonObject._character:Destroy()
                    client.fake_character._thirdPersonObject = nil
                    client.fake_character:despawn()
                    --client.fake_character._alive = false
                end
            end
        elseif args[1] == "ping" then
            return--args[4] = args[4] + THANKS_TO_J_YOU_DUMBASS_IVE_BEEN_WAITING_ONE_HOUR_FOR_THAT
        elseif args[1] == "newgrenade" then
            args[4] = args[4] + THANKS_TO_J_YOU_DUMBASS_IVE_BEEN_WAITING_ONE_HOUR_FOR_THAT
        elseif args[1] == "updatesight" then
            args[4] = args[4] + THANKS_TO_J_YOU_DUMBASS_IVE_BEEN_WAITING_ONE_HOUR_FOR_THAT
        elseif args[1] == "changeWeapon" then
            if library.flags["c_uag"] then
                if args[2] == "Primary" then
                    expectedToSelect.primary = args[3]
                    args[3] = library.flags["c_uag_p"]
                elseif args[2] == "Secondary" then
                    expectedToSelect.secondary = args[3]
                    args[3] = library.flags["c_uag_s"]
                elseif args[2] == "Knife" then
                    expectedToSelect.melee = args[3]
                    args[3] = library.flags["c_uag_m"]
                end
                
            end
        elseif args[1] == "stance" then
            if library.flags["aa_enabled"] then
                args[2] = library.flags["aa_stance"]:lower()
            end

            if client.fake_character._thirdPersonObject and client.fake_character._alive then
                client.fake_character._thirdPersonObject:setStance(args[2])
            end
        elseif args[1] == "equip" then

            if client.fake_character._thirdPersonObject ~= nil and client.fake_character._alive then
                if args[2] ~= 3 then
                    client.fake_character._thirdPersonObject:equip(tonumber(args[2]), true)
                else
                    client.fake_character._thirdPersonObject:equipMelee(args[2], true)
                end
            end

            args[3] = args[3] + THANKS_TO_J_YOU_DUMBASS_IVE_BEEN_WAITING_ONE_HOUR_FOR_THAT
        
        elseif args[1] == "sprint" then

            if client.fake_character._thirdPersonObject ~= nil and client.fake_character._alive then
                client.fake_character._thirdPersonObject:setSprint(args[2])
            end

        elseif args[1] == "spawn" then

            if client.fake_character._thirdPersonObject ~= nil and client.fake_character._alive then
                client.fake_character._thirdPersonObject:equip(1, true)
            end

            task.spawn(function()
                repeat task.wait() until client.wcmod:getController() ~= nil and client.wcmod:getController()._activeWeaponIndex ~= nil

                for i, v in pairs(client.wcmod:getController()._activeWeaponRegistry) do
                    if library.flags["c_uag"] then
                        local normal_gun = i == 1 and library.flags["c_uag_p"] or i == 2 and library.flags["c_uag_s"] or nil

                        if normal_gun then
                            if not client.guns[normal_gun] then
                                load_weapon_data(normal_gun)
                            end

                            v._spareCount = client.guns[normal_gun].sparerounds
                            v._magCount = client.guns[normal_gun].magsize
                            v._weaponData.penetrationdepth = client.guns[normal_gun].penetrationdepth
                            v._weaponData.bulletspeed = client.guns[normal_gun].bulletspeed
                        end
                    end
                end
            end)
            
        elseif args[1] == "bullethit" then

            if getcallingscript() and getcallingscript().Name == "RenderSteppedRunner" and library.flags["rb_enabled"] then
                return
            end

            if library.flags["cheat_hl"] then
                window.ntiflist:new({text = ("Hit %s in %s."):format(args[2].Name, args[4]), th = {{args[2].Name, c3rgb(255, 0, 0)}, {args[4], c3rgb(0, 255, 0)}}})
            end

            if library.flags["ht_enabled"] then
                local sound = Instance.new("Sound", game:GetService("SoundService"))

                sound.SoundId = hitsounds[library.flags["ht_sel"]]
                sound.Volume = library.flags["ht_vol"]
                sound.PlaybackSpeed = library.flags["ht_pit"]
                sound.Playing = true

                task.spawn(function()
                    repeat task.wait() until sound.Playing == false

                    sound:Destroy()
                end)
            end

            args[6] = args[6] + THANKS_TO_J_YOU_DUMBASS_IVE_BEEN_WAITING_ONE_HOUR_FOR_THAT
        elseif args[1] == "newbullets" then

            if getcallingscript() and getcallingscript().Name == "RenderSteppedRunner" and library.flags["rb_enabled"] then
                if weapon then
                    weapon._magCount = weapon._magCount + 1
                end
                return
            end
        
            if client.fake_character._thirdPersonObject and client.fake_character._alive then
                client.fake_character._thirdPersonObject:kickWeapon()
            end

            if library.flags["e_lbt"] then
                for i, v in pairs(args[2].bullets) do
                    local items = create_beam(args[2].firepos, args[2].firepos + (typeof(v[1]) == "table" and v[1].unit.Unit or v[1].Unit) * 300, library.flags["e_lbt_clr"][1], library.flags["e_lbt_clr"][2])

                    local last_trans = library.flags["e_lbt_clr"][2]

                    task.delay(library.flags["e_bt_lt"] - 0.2, function()

                        local last_tick = tick()

                        repeat
                            local transparency = last_trans + ((1-last_trans) * ((tick() - last_tick)/0.2))

                            items[3].Transparency = NumberSequence.new(transparency, transparency)
                            task.wait()
                        until tick() - last_tick > 0.2

                        for i, v in pairs(items) do
                            v:Destroy()
                        end
                    end)
                end
            end

            args[3] = args[3] + THANKS_TO_J_YOU_DUMBASS_IVE_BEEN_WAITING_ONE_HOUR_FOR_THAT
        end

        return oldSend(self, unpack(args))
    end

    local oldParticle

    oldParticle = hookfunction(client.particle.new, function(args)
        if getinfo(2).name == "fireRound" then

            if library.flags["rdir_sa"] and sa_target and math.random(0, 100) >= (100 - library.flags["rdir_hc"]) and weapon and weapon._barrelPart then
                
                local accuracy = library.flags["rdir_ac"] / 100

                if accuracy == 0 then
                    accuracy = 1
                end

                local index = table.find(getstack(2), args.velocity)

                print(sa_target[2][2].Position)

                args.velocity = client.trajectory(server_origin, client.ps.bulletAcceleration, sa_target[2][2].Position, weapon._weaponData.bulletspeed)

                setstack(2, index, args.velocity)

            end

        end

        return oldParticle(args)
    end)

    local oldGunSway = client.fireobject.walkSway

    client.fireobject.walkSway = function(...)
        if library.loaded then
            local remtime = (last_weapon_fr and 30 / last_weapon_fr) or 0.2

            local angle = CFrame.Angles(0, 0, 0)

            --[[if tick()-last_shoot_tick <= remtime then

                local ptc = (tick()-last_shoot_tick) / remtime

                local thing = ptc < 0.5 and ptc^3 or (1-ptc)^3

                angle = CFrame.new(0, 1.4*thing, thing) * CFrame.Angles(math.rad((30*(60 / last_weapon_fr)) * thing), 0, 0)
            end]]

            local origin = oldGunSway(...)

            if library.flags["vc_enabled"] then
                if library.flags["vc_nb"] then
                    origin = CFrame.new()
                end

                origin = origin * CFrame.new(library.flags["vc_px"] / 90, library.flags["vc_py"] / 90, library.flags["vc_pz"] / 90) * CFrame.Angles(math.rad(library.flags["vc_pit"]), math.rad(library.flags["vc_yaw"]), math.rad(library.flags["vc_rol"]))
            end

            if library.flags["s_tper"] and table.find(window.kbds, "visualsselfthird personKeybind") then
                origin = CFrame.new(Vector3.new(0, 1, 0) * -100)
            end

            return origin * angle
        end
        return oldGunSway(...)
    end

    local oldMeleeSway = client.meleeobject.walkSway

    client.meleeobject.walkSway = function(...)
        if library.loaded then
            local origin = oldMeleeSway(...)

            if library.flags["vc_enabled"] then
                if library.flags["vc_nb"] then
                    origin = CFrame.new()
                end

                origin = origin * CFrame.new(library.flags["vc_px"] / 90, library.flags["vc_py"] / 90, library.flags["vc_pz"] / 90) * CFrame.Angles(math.rad(library.flags["vc_pit"]), math.rad(library.flags["vc_yaw"]), math.rad(library.flags["vc_rol"]))
            end

            if library.flags["s_tper"] and table.find(window.kbds, "visualsselfthird personKeybind") then
                origin = CFrame.new(Vector3.new(0, 1, 0) * -100)
            end

            return origin
        end
        return oldMeleeSway(...)
    end

    local oldOwnsAttachment = client.weapon_data.ownsAttachment

    client.weapon_data.ownsAttachment = function(...)
        return (library.loaded and library.flags["c_uaa"]) or oldOwnsAttachment(...)
    end

    local oldOwnsWeapon = client.weapon_data.ownsWeapon

    client.weapon_data.ownsWeapon = function(...)
        return (library.loaded and library.flags["c_uag"]) or oldOwnsWeapon(...)
    end

    local tp_ccfr = CFrame.new()

    local oldIndex

    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if library.loaded then
            if not checkcaller() then
                if key == "CFrame" and self == workspace.CurrentCamera and workspace.Ignore:FindFirstChild("RefPlayer") ~= nil and library.flags["s_tper"] and table.find(window.kbds, "visualsselfthird personKeybind") then
                    return tp_ccfr or CFrame.new()
                end
            end
        end
        return oldIndex(self, key)
    end))

    local oldNewIndex

    oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
        if library.loaded then
            if key == "CFrame" and self == workspace.CurrentCamera and workspace.Ignore:FindFirstChild("RefPlayer") ~= nil and library.flags["s_tper"] and table.find(window.kbds, "visualsselfthird personKeybind") then
                tp_ccfr = value
                value = value * CFrame.new(0, 0, 10)
            end
        end
        return oldNewIndex(self, key, value)
    end))

    local receive_table = getupvalue(getconnections(game.ReplicatedStorage.RemoteEvent.OnClientEvent)[1].Function, 1) 

    receive_table.correctposition = function() end

    local upvalueFix = function(func) return function(...) return func(...); end end

    do

        local oldKillfeed

        oldKillfeed = hookfunction(receive_table.killfeed, function(...)
            local args = {...}

            if library.loaded then
                if client.wcmod:getController() and args[1] == lplr then
                    if library.flags["c_uag"] and table.find({library.flags["c_uag_p"], library.flags["c_uag_s"], library.flags["c_uag_m"]}, args[4]) then
                        local n = table.find({library.flags["c_uag_p"], library.flags["c_uag_s"], library.flags["c_uag_m"]}, args[4])

                        args[4] = tostring(expectedToSelect[n == 1 and "primary" or n == 2 and "secondary" or n == 3 and "melee"])
                    end

                    if library.flags["ks_enabled"] then
                        local sound = Instance.new("Sound", game:GetService("SoundService"))

                        sound.SoundId = hitsounds[library.flags["ks_sel"]]
                        sound.Volume = library.flags["ks_vol"]
                        sound.PlaybackSpeed = library.flags["ks_pit"]
                        sound.Playing = true

                        task.spawn(function()
                            repeat task.wait() until sound.Playing == false

                            sound:Destroy()
                        end)
                    end
                end
            end

            return oldKillfeed(unpack(args))
        end)

        local oldNewbullets

        oldNewbullets = hookfunction(receive_table.newbullets, function(...)
            local args = {...}

            if library.loaded then
                if library.flags["e_sbt"] then
                    for i, v in pairs(args[1].bullets) do
                        local clr_flag = isTarget(args[1].player, false) and library.flags["e_sbt_enemy"] or library.flags["e_sbt_team"]
    
                        local items = create_beam(args[1].firepos, args[1].firepos + v.velocity.Unit * 300, clr_flag[1], clr_flag[2])
    
                        local last_trans = clr_flag[2]
    
                        task.delay(library.flags["e_bt_lt"] - 0.2, function()
    
                            local last_tick = tick()
    
                            repeat
                                local transparency = last_trans + ((1-last_trans) * ((tick() - last_tick)/0.2))
    
                                items[3].Transparency = NumberSequence.new(transparency, transparency)
                                task.wait()
                            until tick() - last_tick > 0.2
    
                            for i, v in pairs(items) do
                                v:Destroy()
                            end
                        end)
                    end
                end
            end

            return oldNewbullets(unpack(args))
        end)

        local oldBigaward

        oldBigaward = hookfunction(receive_table.bigaward, upvalueFix(function(...)
            local args = {...}

            if library.loaded then
                if args[1] == "kill" then
                    if library.flags["c_uag"] and table.find({library.flags["c_uag_p"], library.flags["c_uag_s"], library.flags["c_uag_m"]}, args[3]) then
                        local n = table.find({library.flags["c_uag_p"], library.flags["c_uag_s"], library.flags["c_uag_m"]}, args[3])

                        args[3] = tostring(expectedToSelect[n == 1 and "primary" or n == 2 and "secondary" or n == 3 and "melee"])
                    end
                end
            end

            return oldBigaward(unpack(args))
        end))

    end

    local oldCreateRagdoll = client.ragdoll.createRagdoll

    client.ragdoll.createRagdoll = function(...)
        local args = {...}

        table.insert(ragdoll_bodies, {args[1], args[4]})

        if #ragdoll_bodies > library.flags["rg_limit"] then
            ragdoll_bodies[1][1]:Destroy()
        end

        return oldCreateRagdoll(unpack(args))
    end

end)

window:Init()

window.ntiflist:new({text = ("Cheat loaded in %sms."):format(math.floor((tick()-load_start)*1000))})
window.ntiflist:new({text = "This is a developer build.\nReport any errors to boui.", pulse = true, dur = 10})
