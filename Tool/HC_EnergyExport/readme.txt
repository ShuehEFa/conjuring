取得Fibaro Home Center設備用電紀錄，會匯出csv檔，依據匯出的日期及時間作為檔名（EX: YYYYMMDD_hhmm_EnergyExport.csv）

介面說明：
	Accout: 	HC帳號
	Password:	HC帳號的密碼
	IP:			HC的TCP/IP位置
	Port:		HC的TCP/IP阜
	Devices:	欲抓取哪些設備ID的用電量
	Period:		抓取的時間範圍
		1. day 		= 到現在為止的一天電量
		2. week 	= 到現在為止的一週電量 (7 days)
		3. month 	= 到現在為止的一月電量 (30 days)
		4. season 	= 到現在為止的一季電量 (90 days)
		5. years 	= 到現在為止的一年電量 (365 days)
		6. 2 years	= 到現在為止的兩年電量 (730 days)
	EXPORT:		csv檔匯出