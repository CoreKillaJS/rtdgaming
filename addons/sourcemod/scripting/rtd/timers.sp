#pragma semicolon 1

#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#include <rtd_rollinfo>
#include <tf2>

public Action:Timer_RunRTDonBots(Handle:Timer, any:client)
{
	for(new i=1; i <= MaxClients; i++)
	{
		// Check to make sure the player is on the same team
		if(IsClientInGame(i) && IsPlayerAlive(i) && IsFakeClient(i))
		{
			//following command is found in commands.sp
			FakeClientCommand(i, "say rtd");
			//SetFakeSkin(i);
		}
	}
}

public Action:Timer_Check_DatabaseOnClient(Handle:Timer)
{
	if(!g_BCONNECTED)
	{
		openDatabaseConnection();
	}else{
		for(new i=1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsClientAuthorized(i) && !areStatsLoaded[i] && g_BCONNECTED && !IsFakeClient(i))
			{
				
				SetHudTextParams(0.42, 0.22, 15.0, 250, 250, 210, 255);
				ShowHudText(i, HudMsg3, "Connecting to Database...");
				
				updateplayername(i);
				InitializeClientonDB(i);
			}
		}
	}
}

public Toxic(client)
{
	//this is called from the Timer_Rolls
	
	new Float:vec[3];
	GetClientEyePosition(client, vec);   
	new damageAmount;
	new Float:randomVec[3];
	new Float:pos[3];
	new cond;
	new Float:distance;
	
	for (new i = 1; i <= MaxClients ; i++)
	{
		if(!IsClientInGame(i) || i == client || !IsPlayerAlive(i))
			continue;
		
		if(GetClientTeam(i) == GetClientTeam(client))
			continue;
        
		GetClientEyePosition(i, pos);
		distance = GetVectorDistance(vec, pos);
		
		cond = GetEntData(i, m_nPlayerCond);
		
		if(client_rolls[i][AWARD_G_GODMODE][0])
			continue;
		
		if(cond == 32 || cond == 327712)
			continue;
		
			
		if(distance < 600.0)
		{
			SetHudTextParams(0.405, 0.82, 1.0, 255, 50, 50, 255);
			ShowHudText(i, HudMsg3, "Warning: Toxic Nearby");
		}
		
		if(distance > 500.0)
			continue;
		
		damageAmount = RoundFloat(-0.04*distance + 20.0);
		
		SetHudTextParams(0.385, 0.82, 5.0, 255, 50, 50, 255);
		
		if((GetClientHealth(i) - damageAmount) <= 2)
		{
			randomVec[0]=GetRandomFloat(100.0, 300.0)*GetRandomInt(-2,2);
			randomVec[1]=GetRandomFloat(100.0, 300.0)*GetRandomInt(-2,2);
			randomVec[2]=GetConVarFloat(g_Cvar_DiscoHeight)*90.0;
			SetEntDataVector(i,BaseVelocityOffset,randomVec,true);
			
			damageAmount = 9999;
			//ShowHudText(i, HudMsg3, "You were killed by toxic.");
		}
			
		ShowHudText(i, HudMsg3, "You were hurt by toxic.");
		
		
		if(RTD_Perks[i][9] > 0 )
		{
			damageAmount = RoundFloat(float(damageAmount) * float(100-RTD_Perks[i][9]) / 100.0);
			
			DealDamage(i,damageAmount, client, 4226, "toxic");
			
		}else{
			DealDamage(i,damageAmount, client, 4226, "toxic");
		}
		
		
	}
	
	return;
}
	
public Action:Timer_ShowInfo(Handle:timer) 
{
	new currentTeam;
	new CurrentScore ;
	new ScoreDiff ;
	new TimeDeduction ;
	new TFClassType:class;
	new alpha;
	new playerCond;
	new DisguiseTeam;
	new currIndex;
	new timeleft;
	new nextTimeMin;
	new String:nextTimeSec[3];
	new String:message02[64];
	
	new bool:b_InScore;
	
	timerMessage ++;
	
	if(timerMessage > 60)
		timerMessage = 0;
	
	for (new i = 1; i <= MaxClients ; i++) 
	{
		
		if (IsClientInGame(i) )
		{
			if(!IsPlayerAlive(i))
				continue;
			
			currentTeam = GetClientTeam(i);
			if(GetClientButtons(i) & IN_SCORE)
			{
				b_InScore = true;
			}else{
				b_InScore = false;
			}
			
			if(client_rolls[i][AWARD_G_BACKPACK][0] && !inTimerBasedRoll[i] && client_rolls[i][AWARD_G_SPIDER][1] == 0 && !b_InScore)
			{
				//that extra condition is so we don't override the text
				SetHudTextParams(0.35, 0.09, 3.0, 250, 250, 210, 255);
				ShowHudText(i, HudMsg4, "AmmoPacks: %i | Healthpacks:%i", client_rolls[i][AWARD_G_BACKPACK][2], client_rolls[i][AWARD_G_BACKPACK][3]);
			}
			
			class = TF2_GetPlayerClass(i);
			alpha = GetEntData(i, m_clrRender + 3, 1);
			playerCond = GetEntProp(i, Prop_Send, "m_nPlayerCond");
			
			DisguiseTeam  = GetEntData(i, m_nDisguiseTeam);
			
			if(alpha == 255 || client_rolls[i][AWARD_G_HORSEMANN][0])
			{
				if(client_rolls[i][AWARD_G_HORSEMANN][0])
				{
					if(yoshi_eaten[i][0] || hasInvisRolls(i))
					{
						DeleteParticle(i, "all");
					}else{
						if(GetClientTeam(i) == 2)
						{
							AttachRTDParticle(i, "ghost_pumpkin_red", true, true, 45.0);
						}else{
							AttachRTDParticle(i, "ghost_pumpkin", true, true, 45.0);
						}
					}
				}
				
				if(client_rolls[i][AWARD_G_UBERCHARGER][0])
				{
					if(class == TFClass_Spy)
					{	
						if(playerCond&16 || playerCond&24)
						{
							//Player is cloaked! Dont show particles
							DeleteParticle(i, "sapper_sentry1_fx");
						}else{
							AttachRTDParticle(i, "sapper_sentry1_fx", true, false, 45.0);
						}
					}else{
						AttachRTDParticle(i, "sapper_sentry1_fx", true, false, 45.0);
					}
				}
				
				if((client_rolls[i][AWARD_G_REGEN][0]))
				{
					
					if ((GetClientHealth(i) + 1) >= finalHealthAdjustments(i))
					{
						
						if(class == TFClass_Spy)
						{	
							if(playerCond&16 || playerCond&24)
							{
								//Player is cloaked! Dont show particles
								DeleteParticle(i, "all");
							}else{
								//Player is NOT cloaked! Show particles
								
								if(DisguiseTeam == BLUE_TEAM)
									AttachRTDParticle(i, "healhuff_blu", true, true, 0.0);
								
								if(DisguiseTeam == RED_TEAM)
									AttachRTDParticle(i, "healhuff_red", true, true, 0.0);
							
								if(DisguiseTeam == 0)
								{
									if(currentTeam == BLUE_TEAM)
										AttachRTDParticle(i, "healhuff_blu", true, true, 0.0);
									
									if(currentTeam == RED_TEAM)
										AttachRTDParticle(i, "healhuff_red", true, true, 0.0);
								}
							}
						}else{
							if(currentTeam == BLUE_TEAM)
								AttachRTDParticle(i, "healhuff_blu", true, true, 0.0);
							
							if(currentTeam == RED_TEAM)
								AttachRTDParticle(i, "healhuff_red", true, true, 0.0);
						}
					}else{
						if(TF2_GetPlayerClass(i) == TFClass_Spy)
						{
							if(playerCond&16 || playerCond&24)
							{
								//Player is cloaked! Dont show particles
								DeleteParticle(i, "healthgained_blu");
								DeleteParticle(i, "healthgained_red");
							}else{
								//Player is NOT cloaked! Show particles
								if(DisguiseTeam == BLUE_TEAM)
									AttachRTDParticle(i, "healthgained_blu", true, true, 0.0);
								
								if(DisguiseTeam == RED_TEAM)
									AttachRTDParticle(i, "healthgained_red", true, true, 0.0);
								
								if(DisguiseTeam == 0)
								{
									if(currentTeam == BLUE_TEAM)
									AttachRTDParticle(i, "healthgained_blu", true, true, 0.0);
									
									if(currentTeam == RED_TEAM)
										AttachRTDParticle(i, "healthgained_red", true, true, 0.0);
								}
							}
						}else{
							if(currentTeam == BLUE_TEAM)
								AttachRTDParticle(i, "healthgained_blu", true, true, 0.0);
						
							if(currentTeam == RED_TEAM)
								AttachRTDParticle(i, "healthgained_red", true, true, 0.0);
						}
					}
				}
				
				if(client_rolls[i][AWARD_G_ARMOR][0])
				{
					if(class == TFClass_Spy)
					{	
						if(playerCond&16 || playerCond&24)
						{
							//Player is cloaked! Dont show particles
							DeleteParticle(i, "armor_blue");
							DeleteParticle(i, "armor_red");
						}else{
							//Player is NOT cloaked! Show particles
							
							if(DisguiseTeam == BLUE_TEAM)
								AttachRTDParticle(i, "armor_blue", true, false, 10.0);
							
							if(DisguiseTeam == RED_TEAM)
								AttachRTDParticle(i, "armor_red", true, false, 10.0);
							
							if(DisguiseTeam == 0)
							{
								if(currentTeam == BLUE_TEAM)
									AttachRTDParticle(i, "armor_blue", true, false, 10.0);
								
								if(currentTeam == RED_TEAM)
									AttachRTDParticle(i, "armor_red", true, false, 10.0);
							}
						}
					}else{
						if(currentTeam == BLUE_TEAM)
							AttachRTDParticle(i, "armor_blue", true, false, 10.0);
						
						if(currentTeam == RED_TEAM)
							AttachRTDParticle(i, "armor_red", true, false, 10.0);
					}
				}
				
				
				if(client_rolls[i][AWARD_G_BLIZZARD][0] && client_rolls[i][AWARD_G_BLIZZARD][4] == 0)
				{
					if(class == TFClass_Spy)
					{	
						if(playerCond&16 || playerCond&24)
						{
							//Player is cloaked! Dont show particles
							DeleteParticle(i, "SnowBlower_Main_fix");
						}else{
							if(!HasParticle(i, "SnowBlower_Main_fix"))
								AttachRTDParticle(i, "SnowBlower_Main_fix", false, 2, 70.0);
						}
					}else{
						if(!HasParticle(i, "SnowBlower_Main_fix"))
							AttachRTDParticle(i, "SnowBlower_Main_fix", false, 2, 70.0);
					}
				}
				
				//alow sentry to target player
				if(hasSentryImmunity[i])
				{
					//new flags = GetEntityFlags(i)&~(1<<16);
					//SetEntProp(i, Prop_Data, "m_fFlags", flags);
					new flags = GetEntityFlags(i)&~FL_NOTARGET;
					SetEntityFlags(i, flags);
				}
				
				hasSentryImmunity[i] = false;
			}else{
				DeleteParticle(i, "all");
				
				//prevent sentries from targeting player
				if(!hasSentryImmunity[i])
				{
					if(hasInvisRolls(i))
					{
						//PrintToChat(i, "%i", GetEntityFlags(i));
						//new flags = GetEntityFlags(i)|(1<<16);
						//SetEntProp(i, Prop_Data, "m_fFlags", flags);
						new flags = GetEntityFlags(i)|FL_NOTARGET;
						SetEntityFlags(i, flags);
						
						hasSentryImmunity[i] = true;
					}
				}
				
			}
			
			if(ROFMult[i] == 1.8)
				ROFMult[i] = 0.0;
			
			//PrintToChat(i, "MaxSpeed: %f", GetEntDataFloat(i,m_flMaxspeed));
			
			if(GetEntDataFloat(i,m_flMaxspeed) == 1399.0)
				ResetClientSpeed(i);
			
			//Update Backpack alpha
			if((client_rolls[i][AWARD_G_BACKPACK][0] && class == TFClass_Spy))
			{
				if(IsValidEntity(client_rolls[i][AWARD_G_BACKPACK][1]))
				{
					currIndex = GetEntProp(client_rolls[i][AWARD_G_BACKPACK][1], Prop_Data, "m_nModelIndex");
					
					if(currIndex == backpackModelIndex[0] || currIndex == backpackModelIndex[1] || currIndex == backpackModelIndex[2] || currIndex == backpackModelIndex[3])
					{
						if(playerCond&16 || playerCond&24)
						{
							SetEntityRenderMode(client_rolls[i][AWARD_G_BACKPACK][1], RENDER_TRANSCOLOR);	
							SetEntityRenderColor(client_rolls[i][AWARD_G_BACKPACK][1], 255, 255,255, 0);
						}else{
							SetEntityRenderMode(client_rolls[i][AWARD_G_BACKPACK][1], RENDER_TRANSCOLOR);	
							SetEntityRenderColor(client_rolls[i][AWARD_G_BACKPACK][1], 255, 255,255, 255);
						}
					}
				}
			}
			
			ScoreDiff = 0;
			CurrentScore = TF2_GetPlayerResourceData(i, TFResource_TotalScore)  ;
			
			if (CurrentScore != OldScore[i] && OldScore[i] != -1)
				ScoreDiff = CurrentScore - OldScore[i];
			
			TimeDeduction = ScoreDiff * RTD_Perks[i][0];
			
			if( RTD_Timer[i] <= GetTime())
			{
				timeleft = GetConVarInt(c_Timelimit) - ( GetTime() - RTD_Timer[i]) ;
			}else{
				timeleft = RTD_Timer[i] +  GetConVarInt(c_Timelimit) - GetTime();
			}
			
			if(!inTimerBasedRoll[i]){
				if (timeleft > 0 && TimeDeduction != 0)
				{
					RTD_Timer[i] -= TimeDeduction;
					PrintHintText(i, "Time Reduction of %d seconds.", TimeDeduction);
				}
			}
			
			if(areStatsLoaded[i] && !b_InScore)
			{
				if(GetConVarInt(c_Enabled))
				{
					if(timeleft <= 0)
					{
						SetHudTextParams(HUDxPos[i][0], HUDyPos[i][0], 3.0, 0, 255, 0, 255);
						ShowHudText(i, HudMsg1, "Ready to RTD");
						
						if(timeleft == 0 && !inTimerBasedRoll[i])
							EmitSoundToClient(i, SOUND_RTDREADY, _, _, SNDLEVEL_GUNFIRE);
						
					}else{
						nextTimeMin = timeleft / 60; //Minutes Left
						
						IntToString((timeleft - (nextTimeMin * 60)), nextTimeSec, sizeof(nextTimeSec)); //Seconds Left
						if(strlen(nextTimeSec) == 1)
							Format(nextTimeSec, sizeof(nextTimeSec), "0%s", nextTimeSec);
						
						//          "Credits: 
						Format(message02, sizeof(message02), "Timer: %d:%s", nextTimeMin, nextTimeSec);
						
						
						SetHudTextParams(HUDxPos[i][0], HUDyPos[i][0], 3.0, 255, 255, 250, 255);
						ShowHudText(i, HudMsg1, message02);
					}
				}else{
					SetHudTextParams(HUDxPos[i][0], HUDyPos[i][0], 3.0, 255, 50, 50, 255);
					ShowHudText(i, HudMsg1, "RTD Disabled!");
				}
			}
			
			OldScore[i] = TF2_GetPlayerResourceData(i, TFResource_TotalScore) ;
			if(inTimerBasedRoll[i] && !b_InScore){
				SetHudTextParams(HUDxPos[i][0], HUDyPos[i][0], 3.0, 255, 250, 210, 255);
				ShowHudText(i, HudMsg1, "You are in RTD!");
			}
			
			if(client_rolls[i][AWARD_G_ARMOR][0] && !b_InScore)
			{
				SetHudTextParams(0.07, 1.0, 3.0, 250, 250, 210, 255);
				ShowHudText(i, HudMsg5, "ARMOR: %i", client_rolls[i][AWARD_G_ARMOR][1]);
			}
			
			if(client_rolls[i][AWARD_G_HULK][0]){
				StripToMelee(i);
			}
			
			
			if(currentTeam == 1){
				//ShowHudText(i, HudMsg2, "Credits: DISABLED");
			}else{
				if(!b_InScore)
				{
					if(areStatsLoaded[i])
					{
						SetHudTextParams(HUDxPos[i][1], HUDyPos[i][1], 3.0, 250, 250, 210, 255);
						ShowHudText(i, HudMsg2, "Credits: %i", RTDCredits[i]);
					}else{	
						SetHudTextParams(0.68, 0.97, 0.6, 250, 250, 210, 255, 2);
						ShowHudText(i, HudMsg2, "Loading...");
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:GenericTimer(Handle:timer)
{
	new String:redbulltext[128];
	
	for (new i = 1; i <= MaxClients; i++)
	{
		//ok let's make sure that the player really is in the game
		if(IsClientInGame(i))
		{
			if(!IsPlayerAlive(i))
				continue;
			
			new TFClassType:class = TF2_GetPlayerClass(i);
			
			if(client_rolls[i][AWARD_G_CLOAK][0] && class == TFClass_Spy)
				TF_AddCloak(i, 1.0);
			
			//Following is for Cow Speed
			if(client_rolls[i][AWARD_G_COW][1] > 0 && RTD_PerksLevel[i][44] == 0)
			{
				if(GetEntDataFloat(i, m_flMaxspeed) > 200.0)
					SetEntDataFloat(i, m_flMaxspeed, 200.0);
			}
			
			//Following is for Wings
			if(client_rolls[i][AWARD_G_WINGS][0])
			{
				//Don't apply to demoman charging
				if(TF2_GetPlayerConditionFlags(i) & TF_CONDFLAG_CHARGING)
					break;
				
				new Float:modifiedSpeed = GetClientBaseSpeed(i);
				if(modifiedSpeed < 60.0)
				{
					modifiedSpeed *= 1.8;
				}else{
					if(GetTime() < client_rolls[i][AWARD_G_WINGS][4] && client_rolls[i][AWARD_G_WINGS][4] != 0)
					{
						modifiedSpeed *= 1.5 + (float(RTD_Perks[i][24]) * 0.01);
					}else{
						modifiedSpeed *= (1.1 + (float(RTD_Perks[i][24]) * 0.01));
					}
				}
				
				SetEntDataFloat(i, m_flMaxspeed, modifiedSpeed);
				
				//Please leave for debugging purposes
				Format(redbulltext, sizeof(redbulltext), "Speed: %i", RoundFloat(GetEntDataFloat(i,m_flMaxspeed)));
				centerHudText(i, redbulltext, 0.0, 1.0, HudMsg3, 0.13); 
				//PrintToChat(i, "Cond:%i Speed:%f", TF2_GetPlayerConditionFlags(i), GetEntDataFloat(i,m_flMaxspeed));
			}
			
			//Following is for Speed
			if(client_rolls[i][AWARD_G_SPEED][0])
				SetEntDataFloat(i, m_flMaxspeed, 1400.0);
			
			if(client_rolls[i][AWARD_G_STONEWALL][0])
			{
				//adjust the gravity
				if(client_rolls[i][AWARD_G_STONEWALL][5] >= GetTime())
				{
					if(!(GetClientButtons(i) & IN_JUMP))
					{
						SetEntityGravity(i, 100.0);
					}else{
						SetEntityGravity(i, 1.1);
					}
					
				}else{
					if(RTD_PerksLevel[i][48] == 0)
					{
						SetEntityGravity(i, 1.2);
						
						//adjust the speed
						
						//Don't apply to demoman charging
						if(!(TF2_GetPlayerConditionFlags(i) & TF_CONDFLAG_CHARGING))
						{
							new Float:modifiedSpeed = GetClientBaseSpeed(i);
							modifiedSpeed *= 0.85;
							
							SetEntDataFloat(i, m_flMaxspeed, modifiedSpeed);
						}
					}
				}
				
			}
			
			//Following is for gravity
			if(client_rolls[i][AWARD_G_GRAVITY][0])
				SetEntityGravity(i, GetConVarFloat(c_Gravity));
			
			//Does the player have godmode?
			if(client_rolls[i][AWARD_G_GODMODE][0])
				TF2_AddCondition(i,TFCond_Ubercharged,2.0);
			
			if(client_rolls[i][AWARD_G_SCOUTJUMP][0])
				SetEntDataFloat(i, g_jumpOffset, 0.0);
			
			//This is designed to activate every 10th loop == 2.0
			if(client_rolls[i][AWARD_G_INFIAMMO][0])
			{
				if(client_rolls[i][AWARD_G_INFIAMMO][1] >= 9)
				{
					client_rolls[i][AWARD_G_INFIAMMO][1] = 0;
					GivePlayerInfiAmmo(i);
				}else
					client_rolls[i][AWARD_G_INFIAMMO][1] += 1;
			}
			
		}
	}
	
	return Plugin_Continue;
}

public Action:resetCredsUsed(Handle:timer, any:clientUserID)
{
	new client = GetClientOfUserId(clientUserID);
	
	if(client < 1)
		return Plugin_Stop;
	
	if(!IsClientInGame(client))
		return Plugin_Stop;
	
	credsUsed[client][0] = 0;
	credsUsed[client][1] = GetTime();
	
	return Plugin_Continue;
}

public Action:SaveStats_Timer(Handle:Timer)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsClientAuthorized(i))
		{	
			if(areStatsLoaded[i] && g_BCONNECTED)
			{
				saveStats(i);
			}
		}
	}
	return Plugin_Continue;
}

public Action:CreditsTimer(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		//ok let's make sure that the player really is in the game
		if(IsClientInGame(i))
		{
			if(GetClientTeam(i) == BLUE_TEAM || GetClientTeam(i) == RED_TEAM)
			{
				RTDCredits[i] += credits_rate;
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:delayInstaKill(Handle:timer, Handle:dataPackHandle)
{
	ResetPack(dataPackHandle);
	new client = ReadPackCell(dataPackHandle);
	new attacker = ReadPackCell(dataPackHandle);
	
	//client died
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Stop;
	
	//attacker is not here?!
	if (!IsClientInGame(attacker))
		attacker = client;
	
	//Do the damage
	//DealDamage(i,damageAmount, client, 4226, "toxic");
	DealDamage(client, 9999, attacker, 4226, "InstaKill");
	
	return Plugin_Stop;
}
