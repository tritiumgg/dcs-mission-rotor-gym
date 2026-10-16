-- Player helicopter types for Rotor Gym, in display (slot list) order.
--
-- To add a helicopter, append ONE entry to the table below:
--   type        DCS unit type id (db.Units.Helicopters.Helicopter[i].type)
--   displayName shown in slot/group names (the DB DisplayName)
--   fuel        internal fuel in kg (DB MaxFuelWeight = full tank)
--   flare/chaff DB passivCounterm defaults
--   gun         gun ammo percent (100 = full)
--   frequency/modulation  group radio default (me_db_api.getDefaultRadioFor; 0 = AM)
--   livery      optional livery_id override (omit to let DCS pick its default)
--   addProps    optional AddPropAircraft (DB defaults; ED missions always write these)
--   radio       optional unit Radio presets (omit: the aircraft uses its own defaults)
--   size        footprint in metres: the larger of DB rotor_diameter and length.
--               Spaces the slots and sizes practice areas.
--   callsign    optional callsign name (default "Enfield"); some types use their own list
-- Values read from DCS 2.9.30.28738. Data only: no logic in this file.

return {
	{
		type = "Mi-8MT", displayName = "Mi-8MTV2", size = 25.9,
		fuel = 1929, flare = 128, chaff = 0, gun = 100,
		frequency = 127.5, modulation = 0,
		livery = "USA_AFG",
		addProps = {
			ExhaustScreen = true, LeftEngineResource = 90, RightEngineResource = 90,
			AdditionalArmor = true, CargoHalfdoor = true, GunnersAISkill = 90,
			NetCrewControlPriority = 0, HumanOrchestra = false, NS430allow = true,
		},
	},
	{
		type = "UH-1H", displayName = "UH-1H", size = 17.6,
		fuel = 631, flare = 60, chaff = 0, gun = 100,
		frequency = 251, modulation = 0,
		livery = "Army Standard",
		addProps = {
			ExhaustScreen = true, GunnersAISkill = 90, EngineResource = 90,
			SoloFlight = false, NetCrewControlPriority = 0,
		},
	},
	{
		type = "AH-64D_BLK_II", displayName = "AH-64D BLK.II", size = 17.9,
		fuel = 1140, flare = 60, chaff = 30, gun = 100,
		frequency = 225, modulation = 0,
		livery = "default",
		addProps = {
			PltNVG = true, CpgNVG = true,
			FlareBurstCount = 1, FlareBurstInterval = 0, FlareSalvoCount = 0,
			FlareSalvoInterval = 0, FlareProgramDelay = 3,
			OverrideIFF = 0, TrackAirTargets = true,
			NetCrewControlPriority = 0, AIDisabled = false, HumanOrchestra = false,
		},
	},
	{
		type = "CH-47Fbl1", displayName = "CH-47F", size = 28.3,
		fuel = 3054.592, flare = 120, chaff = 120, gun = 100,
		frequency = 251, modulation = 0,
		livery = "us army dark green",
		addProps = {
			DustProtectionDevices = false, NetCrewControlPriority = 0,
		},
	},
	{
		type = "Ka-50_3", displayName = "Ka-50 III", size = 15.8,
		fuel = 1450, flare = 128, chaff = 0, gun = 100,
		frequency = 124, modulation = 0,
		livery = "default",
		addProps = {
			modification = "Ka-50_3", ["Helmet-mounted device"] = 0, ExhaustScreen = true,
			["Realistic INS"] = 1, ["IMU alignment type"] = 3,
		},
	},
	{
		type = "Mi-24P", displayName = "Mi-24P", size = 21.0,
		fuel = 1701, flare = 192, chaff = 0, gun = 100,
		frequency = 127.5, modulation = 0,
		livery = "russian air force",
		addProps = {
			LeftEngineResource = 90, RightEngineResource = 90, ExhaustScreen = true,
			NS430allow = true, PilotNVG = true, OperatorNVG = true, R60equipment = true,
			OverrideIFF = 0, GunnersAISkill = 90, SimplifiedAI = false,
			HideAngleBoxes = false, TrackAirTargets = true,
			NetCrewControlPriority = 0, HumanOrchestra = false,
		},
	},
	{
		type = "OH58D", displayName = "OH-58D(R)", size = 10.7, callsign = "Anvil",
		fuel = 333.69, flare = 30, chaff = 0, gun = 100,
		frequency = 116, modulation = 0,
		livery = "default",
		addProps = {
			NetCrewControlPriority = 0, ["Remove doors"] = true, PDU = false,
			AllowHidePDU = true, Rifles = true, ["MMS removal"] = false,
			["Rapid Deployment Gear"] = false, ALQ144 = false,
			importDrawings = true, tacNet = 1,
		},
	},
	{
		type = "SA342M", displayName = "SA342M", size = 12.0,
		fuel = 416.33, flare = 32, chaff = 0, gun = 100,
		frequency = 124, modulation = 0,
		livery = "nato_drab_us",
		addProps = { NS430allow = true, RemoveTablet = false },
	},
	{
		type = "SA342L", displayName = "SA342L", size = 12.0,
		fuel = 416.33, flare = 32, chaff = 0, gun = 100,
		frequency = 124, modulation = 0,
		livery = "nato_drab_us",
		addProps = { NS430allow = true, SA342RemoveDoors = false, RemoveTablet = false },
	},
	{
		type = "SA342Minigun", displayName = "SA342Minigun", size = 12.0,
		fuel = 416.33, flare = 32, chaff = 0, gun = 100,
		frequency = 124, modulation = 0,
		livery = "nato_drab_us",
		addProps = { NS430allow = true, RemoveTablet = false },
	},
}
