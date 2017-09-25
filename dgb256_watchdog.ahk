;=================================== dgb256 Watchdog By NoProblem ==================================================
json(ByRef js, s, v = "") 
{
	j = %js%
	loop, Parse, s, .
	{
		p = 2
		RegExMatch(A_LoopField, "([+\-]?)([^[]+)(?:\[(\d+)\])?", q), q3 := q3 ? q3 : 0
		loop 
		{
			if (!p := RegExMatch(j, "(""|')([^\1]+?)\1\s*:\s*((""|')?[^\4]*?\4|(\{(?:[^{}]*+|(?5))*\})|[+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:,|$|\})", x, p))
				Return
			else if (-1 == q3 -= x2 == q2 or q2 == "*") 
			{
				j = %x3%
				z += p + StrLen(x2) - 2
				Break
			}
			else p += StrLen(x)
		}
	}

	return, x3 == "false" ? 0 : x3 == "true" ? 1 : x3 == "null" or x3 == "nul" ? "" : SubStr(x3, 1, 1) == "" ? SubStr(x3, 2, -1) : x3
}

Menu, Tray, add
Menu, Tray, add, Run dgb256 Watchdog, RunWD
Menu, Tray, add, Settings dgb256 Watchdog v0.3.17b, SettingsWD 
Menu, Tray, add, Stop/Reload dgb256 Watchdog, StopWD
Menu, Tray, Tip, dgb256 Watchdog Paused
Menu, Tray, Icon, Images\pause_wd.bmp
Menu, Tray, Disable, Stop/Reload dgb256 Watchdog

IniRead, User , dgb256_watchdog.ini, dgb256Settings, User
IniRead, APIkey, dgb256_watchdog.ini, dgb256Settings, APIkey
IniRead, SecretKey, dgb256_watchdog.ini, dgb256Settings, SecretKey
IniRead, CoinType, dgb256_watchdog.ini, dgb256Settings, CoinType
IniRead, WorkerWarnSpeed, dgb256_watchdog.ini, dgb256Settings, WorkerWarnSpeed
IniRead, WorkerErrorSpeed, dgb256_watchdog.ini, dgb256Settings, WorkerErrorSpeed
IniRead, WorkerCount, dgb256_watchdog.ini, dgb256Settings, WorkerCount
IniRead, SkipWorkers, dgb256_watchdog.ini, dgb256Settings, SkipWorkers
IniRead, SleepTime, dgb256_watchdog.ini, dgb256Settings, SleepTime
IniRead, SleepAfterError, dgb256_watchdog.ini, dgb256Settings, SleepAfterError
IniRead, MustSendSMS, dgb256_watchdog.ini, dgb256Settings, MustSendSMS
IniRead, SMS_RU_api_id, dgb256_watchdog.ini, dgb256Settings, SMS_RU_api_id
IniRead, Phones, dgb256_watchdog.ini, dgb256Settings, Phones

startTime := " " . A_DD . " " . A_MMM . " " . A_Hour . ":" . A_Min . ":" . A_Sec
textLog := "Started:" . startTime . chr(10) . chr(13)
textErrorLog := "Started: " . startTime . chr(10) . chr(13)
checkCounter := 0
totalWarn := 0
totalErr := 0
SetFormat, float, 0.1

Gui, Add, Tab3, , Settings|Log|Readme
Gui, Tab, 1
Gui, Add, Edit, w600 r37 -wrap vEditSettings
Gui, Add, Button, gSaveSettings, Save and Reload
Gui, Tab, 2
Gui, Add, text,, Log:
Gui, Add, Edit, w600 r20 vEditLog
Gui, Add, text,, Error Log:
Gui, Add, Edit, w600 r15 vEditErrorLog
Gui, Tab, 3
Gui, Add, Edit, w600 r39 vEditReadme
return

; Settings ================================================================================
SettingsWD:
Menu, Tray, Tip, dgb256 Watchdog Paused
Menu, Tray, Icon, Images\pause_wd.bmp

Menu, Tray, Disable, Stop/Reload dgb256 Watchdog
Menu, Tray, Enable, Run dgb256 Watchdog

GuiControl,, EditLog, %textLog%
GuiControl,, EditErrorLog, %textErrorLog%
FileRead, FileContents, dgb256_watchdog.ini
GuiControl, , EditSettings, %FileContents%
FileRead, FileContents, readme_ru.txt
GuiControl, , EditReadme, %FileContents%

Gui, +AlwaysOnTop 
Gui, Tab, 1
Gui, Show
return

SaveSettings:
Gui, Submit
FileDelete, dgb256_watchdog.ini
FileAppend, %EditSettings%, dgb256_watchdog.ini
reload
return

;RUN function ========================================================================
RunWD:

Menu, Tray, Disable, Run dgb256 Watchdog
Menu, Tray, Enable, Stop/Reload dgb256 Watchdog
Menu, Tray, Tip, dgb256 Watchdog Starting...
Menu, Tray, Icon, Images\play_wd_start.bmp

;main loop ==============================================================================
Loop 
{
checkCounter++

POSTData := "&username=" . User
	  . "&api=" . APIkey
	  . "&json=y&work=y"

URL      := "https://dgb256.online/index.php?k=api" . POSTData

WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
try 
{
	WebRequest.Open("POST", URL, false)
	WebRequest.SetRequestHeader("Content-Type", "application/json")
	WebRequest.Send("")
}
catch e 
{
	tipStr := "dgb256 Watchdog Connection Error! " . A_Hour . ":" . A_Min . ":" . A_Sec . chr(13) . URL
	Menu, Tray, Tip, %tipStr%
	Menu, Tray, Icon, Images\play_wd_err.bmp	

	textLog .= "dgb256 Connection Error! " .  A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13) . URL . chr(10) . chr(13)
	textErrorLog .= "dgb256 Connection Error! " .  A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13) . URL . chr(10) . chr(13)
 	totalWarn++
	Sleep, %SleepTime% 
	continue
}

if (WebRequest.StatusText = "OK")
{
	html := WebRequest.responseText
	textLog .= "" . A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13)	

	i := 0
	Warn := 0
	Err := 0
	total_w_hashrate5m := 0.0
	total_w_hashrate1hr := 0.0
	total_w_hashrate24hr := 0.0
	warningText := ""
	errorText := ""

	totalRecord := strreplace(json(html, "rows"), chr(34))

	if (totalRecord != WorkerCount)
	{
		errorText .= "Worker count Error: " . totalRecord . "(" . WorkerCount . ") "
		err++
	}	

;worker main loop =====================================================================================================
	While (i < totalRecord)
	{
		worker := strreplace(json(html, "workername:" . i), chr(34))
		
		StringGetPos, pos, SkipWorkers, %worker%
		if (pos >= 0)
		{
			comma := SubStr(SkipWorkers, pos + StrLen(worker) + 1, 1)	
			if (comma = "," or comma = "" or comma = " ")
			{
				i++
				continue		
			}
		}

		w_hashrate5m := strreplace(json(html, "w_hashrate5m:" . i), chr(34))/1000000000000 
		w_hashrate1hr := strreplace(json(html, "w_hashrate1hr:" . i), chr(34))/1000000000000 
		w_hashrate24hr := strreplace(json(html, "w_hashrate24hr:" . i), chr(34))/1000000000000 
			
		rateStr := worker . " 5m:" . w_hashrate5m . " 1hr:" . w_hashrate1hr . " 24h:" . w_hashrate24hr
		textLog .= rateStr . chr(10) . chr(13)	 

		total_w_hashrate5m += w_hashrate5m
		total_w_hashrate1hr += w_hashrate1hr
		total_w_hashrate24hr += w_hashrate24hr

		if (w_hashrate5m < WorkerWarnSpeed) and (w_hashrate1hr < WorkerWarnSpeed) 
		{
			warningText .= rateStr . "; "
			Warn++
		}

		if (w_hashrate5m < WorkerErrorSpeed) and (w_hashrate1hr < WorkerErrorSpeed) 
		{
			errorText .= rateStr . "; "
			err++
		}

		if (totalRecord != WorkerCount)
			errorText .= worker . " "	
		
		i++
	} ;end worker loop ========================================

	if (warn > 0)
	{
		textLog .= "Warning! " . A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13) . warningText . chr(10) . chr(13)
		textErrorLog .= "Warning! " . A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13) . warningText . chr(10) . chr(13)
	}
	if (err > 0)
	{
		textLog .= "Error! " . A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13) . errorText . chr(10) . chr(13)
		textErrorLog .= "Error! " . A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13) . errorText . chr(10) . chr(13)

		try 
		{
			URL := "SMS disabled"
			if (MustSendSMS != 0)
			{
				URL := "https://sms.ru/sms/send?api_id=" . SMS_RU_api_id
					. "&to=" . Phones . "&msg=" . errorText . "&json=1"  
	
				;WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
				;WebRequest.Open("POST", URL, false)
				;WebRequest.SetRequestHeader("Content-Type", "application/json")
				;WebRequest.Send("")
			}

			textErrorLog .= "SMS send " . A_Hour . ":" . A_Min . ":" . A_Sec . " " . URL . chr(10) . chr(13)
		}
		catch e 
		{
			textLog .= "SMS send Error! " . A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13) . URL . chr(10) . chr(13)
			textErrorLog .= "SMS send Error! " . A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13) . URL . chr(10) . chr(13)
			totalWarn++
		}	
	}

	totalWarn += Warn
	totalErr += Err
	totalRateStr := "5m: " . total_w_hashrate5m . "  1h: " . total_w_hashrate1hr . "  24h: " . total_w_hashrate24hr 

	tipStr := chr(34) . User . chr(34) . " dgb256 Watchdog Running" . startTime . chr(13) 
		. "Errors:   " . totalErr . "   " . errorText . " Warnings:   " . totalWarn . " " . warningText . chr(13)
		. A_Hour . ":" . A_Min . ":" . A_Sec . " (" . checkCounter . ")" .  chr(13) 
		. totalRateStr 

	textLog .= totalRateStr . chr(10) . chr(13)	 
	Menu, Tray, Tip, %tipStr%

	if (err > 0) and (warn > 0)
		Menu, Tray, Icon, Images\play_wd_err_warn.bmp	
	else if (err > 0)
		Menu, Tray, Icon, Images\play_wd_err.bmp	
	else if (warn > 0)
		Menu, Tray, Icon, Images\play_wd_warn.bmp	
	else
		Menu, Tray, Icon, Images\play_wd.bmp	
}
else 
{
	tipStr := "dgb256 Watchdog dgb256 Request Status Error! " . A_Hour . ":" . A_Min . ":" . A_Sec . chr(13) . WebRequest.StatusText
	Menu, Tray, Tip, %tipStr%
	Menu, Tray, Icon, Images\play_wd_err.bmp	

	textLog .= "dgb256 Watchdog dgb256 Request Status Error! " . A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13) . WebRequest.StatusText . chr(10) . chr(13) 
	textErrorLog .= "dgb256 Watchdog dgb256 Request Status Error! " . A_Hour . ":" . A_Min . ":" . A_Sec . chr(10) . chr(13) . WebRequest.StatusText . chr(10) . chr(13) 
}
;end web request ==========================================================

	if (err > 0)
		Sleep, %SleepAfterError%

	Sleep, %SleepTime%
}
; end main loop =======================================================
return

Done:
gui,submit,nohide
gui,destroy
return

StopWD:
Reload

