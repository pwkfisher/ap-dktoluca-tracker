function HasDixie()
    return has("dixie")
end

function HasKiddy()
    return has("kiddy")
end

function CanClimb()
    return has("climb")
end

function CanCarry()
    return has("carry")
end

function CanSpin()
    return has("spin")
end

function CanHover()
    return has("helicopterspin")
end

function CanSwim()
    return has("swim")
end

function HasEllie()
    return has("ellie")
end

function HasEnguarde()
    return has("enguarde")
end

function HasSquitter()
    return has("squitter")
end

function HasParry()
    return has("parry")
end

function HasSquawks()
    return has("squawks")
end

function HasBarrelCannon()
    return has("barrelcannon")
end

function HasBarrelRocket()
    return has("rocketbarrel")
end

function HasBarrelGhost()
    return has("ghostbarrel")
end

function HasBarrelTracker()
    return has("trackerbarrel")
end

function HasBarrelWarp()
    return has("warpbarrel")
end

function HasBarrelInvincible()
    return has("invincibilitybarrel")
end

function HasBarrelSwitch()
    return has("barrelswitch")
end

function HasBarrelShield()
    return has("barrelshield")
end

function HasBarrelWaterfall()
    return has("waterfallbarrel")
end

function HasBothKongs()
    return has("kiddy") and has("dixie")
end

function CanTeamAttack()
    return has("kiddy") and has("dixie") and has("teamattack")
end

function CanWaterBounce()
    return has("kiddy") and has("roll") and has("waterbounce")
end

function CanTeamAttack()
    return has("kiddy") and has("dixie") and has("teamattack")
end

function HasHovercraft()
    return has("progressivevehicle_stage1")
end

function HasTurboSki()
    return has("progressivevehicle_stage2")
end

function HasGyrocopter()
    return has("progressivevehicle_stage3")
end

function ActualCottonTopCoveAccess()
    return (
        has("progressivevehicle_stage1") or
        has("progressivevehicle_stage2") or
        has("progressivevehicle_stage3")
        ) and has("cotton-topcoveaccess")
end

function ActualMekanosAccess()
    return (
        has("progressivevehicle_stage1") or
        has("progressivevehicle_stage2") or
        has("progressivevehicle_stage3")
        ) and has("mekanosaccess")
end

function ActualK3Access()
    return (
        has("progressivevehicle_stage2") or
        has("progressivevehicle_stage3")
        ) and has("k3access")
end

function ActualRazorRidgeAccess()
    return (
        has("progressivevehicle_stage2") or
        has("progressivevehicle_stage3")
        ) and has("razorridgeaccess")
end

function ActualKaosCoreAccess()
    return (
        has("progressivevehicle_stage2") or
        has("progressivevehicle_stage3")
        ) and has("kaoscoreaccess")
end

function ActualKrematoaAccess()
    return (
        has("progressivevehicle_stage2") or
        has("progressivevehicle_stage3")
        ) and has("kaoscoreaccess")
end


function genericvisibility(mapCode)
    local mapstage = Tracker:FindObjectForCode(mapCode).CurrentStage
    if mapstage == 1 then
        return has("lakeorangatangaaccess")
    elseif mapstage == 2 then
        return has("kremwoodforestaccess")
    elseif mapstage == 3 then
        return ActualCottonTopCoveAccess()
    elseif mapstage == 4 then
        return ActualMekanosAccess()
    elseif mapstage == 5 then
        return ActualK3Access()
    elseif mapstage == 6 then
        return ActualRazorRidgeAccess()
    elseif mapstage == 7 then
        return ActualKaosCoreAccess()
    elseif mapstage == 8 then
        return ActualKrematoaAccess()
    end
end


function bossvisibility(mapCode)
    local mapstage = Tracker:FindObjectForCode(mapCode).CurrentStage
    if mapstage == 1 then
        return has("lakeorangatangaaccess")
    elseif mapstage == 2 then
        return has("kremwoodforestaccess")
    elseif mapstage == 3 then
        return ActualCottonTopCoveAccess()
    elseif mapstage == 4 then
        return ActualMekanosAccess()
    elseif mapstage == 5 then
        return ActualK3Access()
    elseif mapstage == 6 then
        return ActualRazorRidgeAccess()
    end
end

function lakesidelimbovisibility() return genericvisibility("LakesideLimboMap") end
function doorstopdashvisibility() return genericvisibility("DoorstopDashMap") end
function tidaltroublevisibility() return genericvisibility("TidalTroubleMap") end
function skiddasrowvisibility() return genericvisibility("SkiddasRowMap") end
function murkymillvisibility() return genericvisibility("MurkyMillMap") end
function barrelshieldbustupvisibility() return genericvisibility("BarrelShieldBustUpMap") end
function riversideracevisibility() return genericvisibility("RiversideRaceMap") end
function squealsonwheelsvisibility() return genericvisibility("SquealsonWheelsMap") end
function springinspidersvisibility() return genericvisibility("SpringinSpidersMap") end
function bobbingbarrelbrawlvisibility() return genericvisibility("BobbingBarrelBrawlMap") end
function bazzasblockadevisibility() return genericvisibility("BazzasBlockadeMap") end
function rocketbarrelridevisibility() return genericvisibility("RocketBarrelRideMap") end
function kreepingklaspsvisibility() return genericvisibility("KreepingKlaspsMap") end
function trackerbarreltrekvisibility() return genericvisibility("TrackerBarrelTrekMap") end
function fishfoodfrenzyvisibility() return genericvisibility("FishFoodFrenzyMap") end
function fireballfrenzyvisibility() return genericvisibility("FireBallFrenzyMap") end
function demolitiondrainpipevisibility() return genericvisibility("DemolitionDrainPipeMap") end
function ripsawragevisibility() return genericvisibility("RipsawRageMap") end
function blazingbazukasvisibility() return genericvisibility("BlazingBazukasMap") end
function lowglabyrinthvisibility() return genericvisibility("LowGLabyrinthMap") end
function krevicekreepersvisibility() return genericvisibility("KreviceKreepersMap") end
function tearawaytobogganvisibility() return genericvisibility("TearawayTobogganMap") end
function barreldropbouncevisibility() return genericvisibility("BarrelDropBounceMap") end
function krackshotkrockvisibility() return genericvisibility("KrackshotKrockMap") end
function lemguinlungevisibility() return genericvisibility("LemguinLungeMap") end
function buzzerbarragevisibility() return genericvisibility("BuzzerBarrageMap") end
function kongfusedcliffsvisibility() return genericvisibility("KongFusedCliffsMap") end
function floodlitfishvisibility() return genericvisibility("FloodlitFishMap") end
function potholepanicvisibility() return genericvisibility("PotHolePanicMap") end
function ropeyrumpusvisibility() return genericvisibility("RopeyRumpusMap") end
function konveyorropeklashvisibility() return genericvisibility("KonveyorRopeKlashMap") end
function creepycavernsvisibility() return genericvisibility("CreepyCavernsMap") end
function lightninglookoutvisibility() return genericvisibility("LightningLookOutMap") end
function koindozerklambervisibility() return genericvisibility("KoindozerKlamberMap") end
function poisonouspipelinevisibility() return genericvisibility("PoisonousPipelineMap") end
function stampedesprintvisibility() return genericvisibility("StampedeSprintMap") end
function crisskrosscliffsvisibility() return genericvisibility("CrissKrossCliffsMap") end
function tyranttwintusslevisibility() return genericvisibility("TyrantTwinTussleMap") end
function swoopysalvovisibility() return genericvisibility("SwoopySalvoMap") end
function rocketrushvisibility() return genericvisibility("RocketRushMap") end

function belchasbarnvisibility() return bossvisibility("BelchasBarnMap") end
function arichsambushvisibility() return bossvisibility("ArichsAmbushMap") end
function squirtsshowdownvisibility() return bossvisibility("SquirtsShowdownMap") end
function kaoskarnagevisibility() return bossvisibility("KAOSKarnageMap") end
function bleakshousevisibility() return bossvisibility("BleaksHouseMap") end
function barbossbarriervisibility() return bossvisibility("BarbosBarrierMap") end