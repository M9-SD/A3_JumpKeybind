comment "Jump/Parkour Script by M9-SD";

M9SD_canJump = true;
M9SD_keyCode_V = 47;
M9SD_fnc_handleJumpKeybind = {
    params["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
    comment "KEY = 47 (V)";
    private _replaceVault = false;
    if !((_key == M9SD_keyCode_V) && _shift) exitWith {
        _replaceVault
    };
    if (player != vehicle player) exitWith {
        _replaceVault
    };
    if !(isTouchingGround player) exitWith {
        _replaceVault
    };
    if !(missionNamespace getVariable['M9SD_canJump', true]) exitWith {
        _replaceVault
    };
    private _speed = speed player;
    if (speed player < 3.5) exitWith {
        _replaceVault
    };
    _replaceVault = true;
    M9SD_canJump = false;
    private _allowJump = [] spawn {
        uiSleep 0.8;
        M9SD_canJump = true;
    };
    comment "
    Player load factor can play a role in jump height and distance,
    but
    this feature is disabled
    for consistency.
    private _max_height = 4.3;
    private _height = 6 - ((load player) * 10);
    if (_height > _max_height) then {
        _height = _max_height;
    };
    ";
    private _dir = direction player;
    private _vel = velocity player;
    private _vertVel_a = _vel select 2;
    private _speedFactor_a = 0.07;
    private _speedFactor_b = _speedFactor_a * _speed;
    comment "check if player has sufficient stamina";
    private _currentFatigue = getFatigue player;
    private _staminaLoss = 0.1;
    private _fatigueGain = _staminaLoss;
    private _minStamina = _staminaLoss;
    private _maxFatigue = 1 - _staminaLoss;
    if (_currentFatigue <= _maxFatigue) then {
        comment "start jump animation";
        private _weapons_a = weapons player;
        private _noWeapon = '';
        private _currentWeapon = currentWeapon player;
        private _primaryWeapon = primaryWeapon player;
        private _secondaryWeapon = secondaryWeapon player;
        private _handgunWeapon = handgunWeapon player;
        private _handheldBinocular = binocular player;
        private _weapons_b = [_primaryWeapon, _secondaryWeapon, _handgunWeapon, _handheldBinocular];
        [_weapons_a, _weapons_b];
        comment "determine which animation sequence to use";
        private _animationFactor =
            switch _currentWeapon do {
                case _noWeapon:{
                        comment "unarmed";
                        "AsdvPercMstpSnonWnonDnon_goup";
                        "AswmPercMstpSnonWnonDnon_goup";
                        "afalpercmstpsnonwnondnon";
                        [] spawn {
                            [player, "afalpercmstpsnonwnondnon"] remoteExec['switchMove'];
                            waitUntil {
                                isTouchingGround player
                            };
                            _ANIM = SELECTRANDOM['AcrgPknlMstpSnonWnonDnon_AmovPercMstpSnonWnonDnon_getOutLow', 'ChopperLight_L_Out_H', 'GetOutAssaultBoat', 'GetOutMRAP_01'];
                            [player, _ANIM] remoteExec['switchMove'];
                        };
                        _animFactor_hori = 0.7;
                        _animFactor_verti = 1.6;
                        [_animFactor_verti, _animFactor_hori];
                    };
                case _primaryWeapon:{
                        comment "rifle";
                        [player, 'AovrPercMrunSrasWrflDf'] remoteExec['switchMove'];
                        _animFactor_hori = 1;
                        _animFactor_verti = 1;
                        [_animFactor_verti, _animFactor_hori];
                    };
                case _secondaryWeapon:{
                        comment "launcher";
                        [] spawn {
                            [player, "afalpercmstpsraswlnrdnon"] remoteExec['switchMove'];
                            waitUntil {
                                isTouchingGround player
                            };
                            COMMENT "TODO: Find an animation to fit here.";
                        };
                        _animFactor_hori = 0.7;
                        _animFactor_verti = 1.6;
                        [_animFactor_verti, _animFactor_hori];
                    };
                case _handgunWeapon:{
                        comment "pistol";
                        [] spawn {
                            COMMENT "PLAYER SETPOS [(GETPOS PLAYER # 0), (GETPOS PLAYER) # 1, 20];";
                            comment "afalpercmstpsraswpstdnon";
                            comment "AmovPercMsprSlowWpstDf_AmovPpneMstpSrasWpstDnon";
                            comment "[player, 'afalpercmstpsraswpstdnon'] remoteExec ['switchMove'];";
                            comment "player playMoveNow 'afalpercmstpsraswpstdnon';";
                            comment "[player, 'AmovPercMstpSrasWpstDnon_AadjPercMstpSrasWpstDdown'] remoteExec ['switchMove'];";
                            comment "[player, 'AmovPercMstpSrasWpstDnon_AadjPercMstpSrasWpstDup'] remoteExec ['switchMove'];";
                            comment "waitUntil {!isTouchingGround player};";
                            player playMoveNow 'afalpercmstpsraswpstdnon';
                            waitUntil {
                                isTouchingGround player
                            };
                            comment "[player, 'AcrgPknlMstpSnonWnonDnon_AmovPercMstpSrasWpstDnon_getOutLow'] remoteExec ['switchMove'];";
                            comment "amovpknlmrunsraswpstdf";
                            comment "amovpercmevasraswpstdf";
                            comment "player playActionNow 'Crouch';";
                            comment "afalpercmstpsraswpstdnon";
                            [player, 'afalpercmstpsraswpstdnon'] remoteExec['switchMove'];
                        };
                        _animFactor_hori = 0.77;
                        _animFactor_verti = 1.6;
                        [_animFactor_verti, _animFactor_hori];
                    };
                case _handheldBinocular:{
                        comment "binos/rangefinder";
                        player PlayActionNow 'GetOver';
                        _animFactor_hori = 0.7;
                        _animFactor_verti = 1.6;
                        [_animFactor_verti, _animFactor_hori];
                    };
            };
            comment "apply stamina cost";
        private _newFatigue = _currentFatigue + _fatigueGain;
        player setFatigue _newFatigue;
        comment "set vertical velocity caps";
        private _vectorSpeedCap_V = 7;
        private _vertVel_boost =
            if (_vertVel_a <= 0) then {
                3
            } else {
                if (_vertVel_a >= _vectorSpeedCap_V) then {
                    _vectorSpeedCap_V
                } else {
                    _vertVel_a + 2;
                };
            };
        comment "cap speed to stop launching when turning fast";
        private _vectorSpeedCap_H = 14;
        comment "apply pre-defined speed boost factor";
        private _speed_x = (_vel select 0) + (sin _dir * _speedFactor_b);
        private _speed_y = (_vel select 1) + (cos _dir * _speedFactor_b);
        comment "check if speed is over max and then set cap";
        private _absoluteValue_x =
            if (_speed_x < 0) then {
                _speed_x * -1
            } else {
                _speed_x
            };
        private _absoluteValue_y =
            if (_speed_y < 0) then {
                _speed_y * -1
            } else {
                _speed_y
            };
        _speed_x =
            if (_absoluteValue_x > _vectorSpeedCap_H) then {
                if (_speed_x < 0) then {
                    -_vectorSpeedCap_H
                } else {
                    _vectorSpeedCap_H
                };
            } else {
                _speed_x
            };
        _speed_y =
            if (_absoluteValue_y > _vectorSpeedCap_H) then {
                if (_speed_y < 0) then {
                    -_vectorSpeedCap_H
                } else {
                    _vectorSpeedCap_H
                };
            } else {
                _speed_y
            };
        comment "factor in animation type";
        _vertVel_boost = _vertVel_boost * (_animationFactor# 0);
        _speed_x = _speed_x * (_animationFactor# 1);
        _speed_y = _speed_y * (_animationFactor# 1);
        comment "apply jump velocity";
        player setVelocity
            [
                _speed_x,
                _speed_y,
                _vertVel_boost
            ];
    } else {
        playSound['addItemFailed', true];
        0 = [] spawn {
            comment "call BIS_fnc_fatigueEffect;";
            _text = format["<t font='puristaMedium' shadow='2' size='1.2' color='#ff3333'>- Insufficient Stamina -</t>"];
            M9SD_layerStamina = "M9SD_layerStamina"
            cutText[_text, 'PLAIN DOWN', 0.5, false, true];
            uiSleep 1;
            M9SD_layerStamina = "M9SD_layerStamina"
            cutFadeOut 1;
        };
    };
    _replaceVault;
};

_removeThenAddJumpKeybind = [] spawn {
    waitUntil {
        !isNull(findDisplay 46)
    };
    if (!isNil "M9SD_keybind_jumpVault") then {
        (findDisplay 46) displayRemoveEventHandler["keyDown", M9SD_keybind_jumpVault];
    };
    M9SD_keybind_jumpVault = (FindDisplay 46) displayAddEventHandler["keydown", M9SD_fnc_handleJumpKeybind];
};