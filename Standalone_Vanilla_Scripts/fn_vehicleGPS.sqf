#include "..\..\script_macros.hpp"
/*
	File: fn_vehicleGPS.sqf
	Author: DomT602 (domt602@gmail.com)
	Description: Allows you to put a GPS tracker on a car, not the greatest way to do it but it keeps it simple
	To-do: Place file where you want (default core/vehicle), add to functions.hpp,
	Add button to fn_vInteractionMenu.sqf:
	_Btn3 ctrlSetText "GPS Tracker";
	_Btn3 buttonSetAction "[life_vInact_curTarget] spawn life_fnc_vehicleGPS; closeDialog 0;";
*/
params [
	["_vehicle",objNull,[objNull]]
];

if (isNull _vehicle || {player distance _vehicle > 3}) exitWith {};
//if !("ItemGPS" in (items player)) exitWith {hint "You need a GPS."}; uncomment if you want player to need a GPS to track vehicle

life_action_inUse = true;
private _displayName = FETCH_CONFIG2(getText,"CfgVehicles",(typeOf _veh),"displayName");
private _upp = format ["Attaching GPS to %1.",_displayName];

disableSerialization;
"progressBar" cutRsc ["life_progress","PLAIN"];
private _ui = uiNamespace getVariable "life_progress";
private _progress = _ui displayCtrl 38201;
private _pgText = _ui displayCtrl 38202;
_pgText ctrlSetText format ["%2 (1%1)...","%",_upp];
_progress progressSetPosition 0.01;
private _cP = 0.01;

for "_i" from 0 to 1 step 0 do {
    if (animationState player != "AinvPknlMstpSnonWnonDnon_medic_1") then {
        [player,"AinvPknlMstpSnonWnonDnon_medic_1",true] remoteExecCall ["life_fnc_animSync",RCLIENT];
        player switchMove "AinvPknlMstpSnonWnonDnon_medic_1";
        player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
    };
    uiSleep 0.27;
    _cP = _cP + 0.02;
    _progress progressSetPosition _cP;
    _pgText ctrlSetText format ["%3 (%1%2)...",round(_cP * 100),"%",_upp];
    if (_cP >= 1 || {!alive player} || {!isNull objectParent player} || {life_interrupted}) exitWith {};
};

life_action_inUse = false;
"progressBar" cutText ["","PLAIN"];
player playActionNow "stop";
if (isNull _vehicle) exitWith {};
if (life_interrupted) exitWith {life_interrupted = false; titleText[localize "STR_NOTF_ActionCancel","PLAIN"]};
if !(isNull objectParent player) exitWith {titleText[localize "STR_NOTF_ActionInVehicle","PLAIN"]};
//player removeItem "ItemGPS"; uncomment if you want player to use a GPS to track vehicle

hint format["You attached the GPS Tracker to the %1.",_displayName];

[_vehicle,_displayName] spawn {
	params [
		["_vehicle",objNull,[objNull]],
		["_displayName","",[""]]
	];
	private _marker = createMarkerLocal [format["%1_GPS_Tracker",_vehicle],visiblePositionASL _vehicle];
	_marker setMarkerColorLocal "ColorBlack";
	_marker setMarkerTypeLocal "Mil_dot";
	_marker setMarkerTextLocal "GPS Tracker " + _displayName;
	for "_i" from 0 to 1 step 0 do {
		if (isNull _vehicle) exitWith {deleteMarkerLocal _marker};
		_marker setMarkerPosLocal visiblePositionASL _vehicle;
		uiSleep 2;
	};
};
