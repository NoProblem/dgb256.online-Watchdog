Opensource and free script for ASIC monitoring on dgb256.online pool. Created by NoProblem :)
DGB (Digibyte) SHA256 https://dgb256.online/ welcome to pool! (AntMiner S4+, AntMiner S5, AntMiner S7, AntMiner R4, AntMiner S9, Avalon4, Avalon6, SP35 Yukon and other SHA256 devices)
Forum: https://forum.bits.media/index.php?/topic/49439-dgb-sha256-pplns-50nd-dgb256online-digibyte-пул/& 

English is not my native language, sorry for mistakes.

This script running in tray and checking ASIC state every 2 min. If a single ASIC hashrate less than value "WorkerErrorSpeed" script will send SMS.
Usage:
1. Download and install Autohotkey https://www.autohotkey.com/
2. (skip if not need SMS) Register on site sms.ru (may be other) using my ref link https://noproblem.sms.ru/ discount 10%. 
3. Dowload script: https://github.com/NoProblem/dgb256.online-Watchdog/raw/master/dgb256.online-Watchdog.zip
4. Change values in file dgb256_watchdog.ini

[dgb256Settings]
User=NoProblem ------------------------------------- Your login.
APIkey=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX --------------- "Your current API Key" https://dgb256.online/index.php?k=userset
SecretKey= ----------------------------------------- not used
CoinType=DGB --------------------------------------- not used
WorkerWarnSpeed=12.00 ------------------------------ Speed in Th (warning) If workes speed less than this value than warning message will apears in tray and log.
WorkerErrorSpeed=9.00 ------------------------------ Speed in Th (error) If workes speed less than this value than error message will apears in tray and log and SMS will be send. 
WorkerCount=8 -------------------------------------- Your total worker quantity.
SkipWorkers=NoProblem.worker7,NoProblem.worker8 ---- Skip workers if you dont need check them.
SleepTime=120000 ----------------------------------- Time between checks in milliseconds (120000 = 2 min)
SleepAfterError=1800000 ---------------------------- Time after error (1800000 = 30 min). For prevent SMS spamming.
MustSendSMS=1 -------------------------------------- Send SMS if error appears or not (yes:1 no:0)
SMS_RU_api_id=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX - Your api_id from sms.ru https://sms.ru/?panel=api
Phones=79001234567,79001234568 --------------------- Phone numbers for SMS.

5. Run script (dbl click dgb256_watchdog.ahk), in tray will appes "pause" icon, right click on it and choose "Run dgb256 Watchdog"
6. Have fun!

You can edit this script with any text editor like notepad, script not need to compile, after update it you must choose "Reload This Script" or "Exit" and run script again.
If you like it you can buy some c2h5oh for me :) Bitcoin: 17cQT8GjQyYg9QKt2b42PFXRTifxENdMHT

links:
Download last version: https://github.com/NoProblem/dgb256.online-Watchdog/raw/master/dgb256.online-Watchdog.zip
GitHub: https://github.com/NoProblem/dgb256.online-Watchdog

You can run script multiple times with different settings from different directories.
Script mem usage ~2.8MB, CPU usage ~0.0%