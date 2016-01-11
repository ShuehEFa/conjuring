using UnityEngine ;
using System ;
using System.IO ;
using System.Collections ;
using System.Collections.Generic ;

public class Main : MonoBehaviour 
{	
	enum LogPeriod : int
	{
		Day ,
		Week ,
		Month ,
		Season ,
		Year ,
		TwoYears ,
	}

	enum LogType : int
	{
		Nono ,
		Account ,
		Password ,
		Ip ,
		Port ,
		Devices ,
		/// dislpay time judge 
		/// above are display permenent until error solve
		/// following are display while seconds
		Wait ,			
		EmptyDevices ,
		Connect ,
		ReadTimeOut ,
		Done ,
	}

	const string DATA_ACCOUNT = "account" ;
	const string DATA_PASSWORD = "password" ;
	const string DATA_IP0 = "ip0" ;
	const string DATA_IP1 = "ip1" ;
	const string DATA_IP2 = "ip2" ;
	const string DATA_IP3 = "ip3" ;
	const string DATA_PORT = "port" ;
	const string DATA_DEVICES = "devices" ;

	const int READ_TIMEOUT_SEC = 10 ;
	const int LOG_DISPLAY_SEC = 2 ;

	const int LABEL_WIDTH = 70 ;
	const int STRING_WIDTH = 100 ;
	const int INT_WIDTH = 50 ;
	const int DOT_WIDTH = 5 ;
	
	readonly string[] NORMAL_SEPERATOR = new string[]{ "," };
	readonly string[] POWER_DATA_SEPERATOR = new string[]{ "],[" };

	string m_account = "" ;
	string m_passWord = "" ;
	string[] m_ip = new string[]{ "0" , "0" , "0" , "0" } ;
	string m_port = "0" ;
	string m_deviceIds = "" ;
	LogPeriod m_logPeriod = LogPeriod.TwoYears ;

	int m_timeZoneOffsetHour = 0 ;

	LogType m_logType = LogType.Nono ;
	float m_logTimer = 0 ;
	string m_connectErr = "";

	string PeriodSecString
	{
		get 
		{ 
			switch( m_logPeriod )
			{
			case LogPeriod.Day :
				return "86400" ;		//< 1 day = 24 hours * 60 mins * 60 secs = 86400 secs
			case LogPeriod.Week :
				return "604800" ;		//< 1 week = 7 days = 7 * 86400 secs = 604800 secs 
			case LogPeriod.Month :
				return "2592000" ;	//< 1 month = 30 days = 30 * 86400 secs = 2592000 secs
			case LogPeriod.Season :
				return "7776000" ;	//< 1 season = 3 months = 3 * 2592000 secs = 7776000 secs
			case LogPeriod.Year :
				return "31536000" ;	//< 1 year = 365 days = 365 * 86400 secs = 31536000 secs
			case LogPeriod.TwoYears :
				return "63072000" ;	//< 2 years = 2 * 1 year = 2 * 31536000 secs = 63072000 secs
			}
			return "0" ;
		}
	}

	LogType Log 
	{
		get { return m_logType ; }
		set { m_logType = value ; m_logTimer = LOG_DISPLAY_SEC ; }
	}

	string Url
	{
		get
		{
			string ret = "http://" 
				;
			if( string.IsNullOrEmpty( m_account ) == false )
			{
				ret += m_account ;
				if( string.IsNullOrEmpty( m_passWord ) == false )
					ret += ":" + m_passWord ;
				ret += "@" ;
			}
			
			for( int i = 0 , length = m_ip.Length ; i < length ; ++i )
				ret += m_ip[ i ] + "." ;
			ret = ret.Substring( 0 , ret.Length - 1 );
			
			string endTime = "now-" +  PeriodSecString ;
			
			ret += "/api/energy/now/" + endTime + "/summary-graph/devices/power/" ;
			
			return ret ;
		}
	}

	bool CheckUrl()
	{
		if ( Log == LogType.Nono)
		{
			if( string.IsNullOrEmpty( m_deviceIds ) == false )
				Log = LogType.Wait ;
			else
				Log = LogType.EmptyDevices ;
		}

		return Log == LogType.Wait ;
	}

	string TransUnixTime2CurrentTimeZoneDate( int _unixTime )
	{
		DateTime dt = new DateTime( 1970 , 1 , 1 , 0 , 0 , 0 , DateTimeKind.Utc );
		dt = dt.AddSeconds( _unixTime );
		dt = dt.AddHours( m_timeZoneOffsetHour );
		return dt.ToString();
	}

	IEnumerator Export()
	{
		m_connectErr = "" ;
		List< string > fileTextLine = new List<string>();
		fileTextLine.Add( "ID,TIME,POWER" );
		string[] devices = m_deviceIds.Split( NORMAL_SEPERATOR , System.StringSplitOptions.RemoveEmptyEntries );
		for( int i = 0 , length = devices.Length ; i < length ; ++i )
		{
			WWW www = new WWW( Url + devices[ i ] );
//			Debug.Log( www.url );

			float ts = Time.realtimeSinceStartup ;
			while( www.isDone == false )
			{
				yield return null ;
				if( Time.realtimeSinceStartup - ts > READ_TIMEOUT_SEC )
				{

					Log = LogType.ReadTimeOut ;
					m_connectErr = "Socket Connect Read Timeout" ;
					break ;
				}
			}

			if( www.isDone )
			{
				if( string.IsNullOrEmpty( www.error ) == false )
				{
					m_logType = LogType.Connect ;
					m_connectErr += www.error + "\n" ;
				}
				else
				{
					string[] datas = www.text.Substring( 2 , www.text.Length - 4 ).Split( POWER_DATA_SEPERATOR , System.StringSplitOptions.RemoveEmptyEntries );
					for( int j = 0 , dataLength = datas.Length ; j < dataLength ; ++j )
					{
						string[] timeAndPower = datas[ j ].Split( NORMAL_SEPERATOR , System.StringSplitOptions.RemoveEmptyEntries );
						timeAndPower[ 0 ] = timeAndPower[ 0 ].Remove( timeAndPower[ 0 ].Length - 3 );
						timeAndPower[ 0 ] = TransUnixTime2CurrentTimeZoneDate( int.Parse( timeAndPower[ 0 ] ) );
						fileTextLine.Add( devices[ i ] + "," + timeAndPower[ 0 ] + "," + timeAndPower[ 1 ] );
					}
				}
			}
			www.Dispose();
		}

		string filePath = DateTime.Now.ToString( "yyyyMMdd_HHmm" ) + "_EnergyExport.csv" ;
		File.WriteAllLines( filePath , fileTextLine.ToArray() );

		if( Log == LogType.Wait )
			Log = LogType.Done ;
	}

	void OnAccountGUI()
	{
		GUILayout.BeginHorizontal();
		GUILayout.Label( "Account: " , GUILayout.Width( LABEL_WIDTH ) );
		m_account = GUILayout.TextField( m_account , GUILayout.Width( STRING_WIDTH ) );
		if( m_account.Contains( " " ) )
			Log = LogType.Account ;
		GUILayout.Label( " Password: " , GUILayout.Width( LABEL_WIDTH )  );
		if( m_passWord.Contains( " " ) )
			Log = LogType.Password ;
		m_passWord = GUILayout.PasswordField( m_passWord , '*' , GUILayout.Width( STRING_WIDTH ) );
		GUILayout.EndHorizontal();
	}

	void OnIpGUI()
	{
		int temp = 0 ;
		GUILayout.BeginHorizontal();
		GUILayout.Label( "IP: " , GUILayout.Width( LABEL_WIDTH ) );
		for( int i = 0 , length = m_ip.Length ; i < length ; ++i )
		{
			m_ip[ i ] = GUILayout.TextField( m_ip[ i ] , GUILayout.Width( INT_WIDTH ) );
			if( int.TryParse( m_ip[ i ] , out temp ) == false || temp > 255 || temp < 0 )
				Log = LogType.Ip ;
			GUILayout.Label( "." , GUILayout.Width( DOT_WIDTH ) );
		}
		GUILayout.Label( " Port: " , GUILayout.Width( LABEL_WIDTH ) );
		m_port = GUILayout.TextField( m_port , GUILayout.Width( INT_WIDTH ) );
		if( int.TryParse( m_port , out temp ) == false || temp < 0 )
			Log = LogType.Port ;
		GUILayout.EndHorizontal();
	}

	void OnDeviceGUI()
	{
		GUILayout.BeginHorizontal();
		GUILayout.Label( "Device: " , GUILayout.Width( LABEL_WIDTH ) );
		m_deviceIds = GUILayout.TextField( m_deviceIds , Screen.width - LABEL_WIDTH );
		string[] devices = m_deviceIds.Split( NORMAL_SEPERATOR , System.StringSplitOptions.RemoveEmptyEntries );
		int temp = 0 ;
		for( int i = 0 , length = devices.Length ; i < length ; ++i )
			if( int.TryParse( devices[ i ] , out temp ) == false || temp < 1 )
				Log = LogType.Devices ;
		GUILayout.EndHorizontal();

		GUILayout.BeginHorizontal();
		GUILayout.Label( "" , GUILayout.Width( LABEL_WIDTH ) );
		GUI.color = Color.gray ;
		GUILayout.Label( "Use \",\" to seperate the device ID" );
		GUI.color = Color.white ;
		GUILayout.EndHorizontal();
	}

	void OnLogGUI()
	{
		string logStr = "" ;
		Color c = new Color();
		switch( Log )
		{
		case LogType.Account :
			logStr = "Account Error: maybe cotain space" ;
			c = Color.yellow ;
			break ;
		case LogType.Password :
			logStr = "Password Error: maybe cotain space" ;
			c = Color.yellow ;
			break ;
		case LogType.Ip :
			logStr = "IP Error: not interger or out of range" ;
			c = Color.yellow ;
			break ;
		case LogType.Port :
			logStr = "Port Error: not interger or out of range" ;
			c = Color.yellow ;
			break ;
		case LogType.Devices :
			logStr = "Devices Error: maybe cotain space, not interger or out of range" ;
			c = Color.yellow ;
			break ;
		case LogType.Wait :
			logStr = "please wait" ;
			c = Color.white ;
			break ;
		case LogType.EmptyDevices :
			logStr = "Devices Error: It is empty" ;
			c = Color.yellow ;
			break ;
		case LogType.Connect :
		case LogType.ReadTimeOut :
			logStr = m_connectErr ;
			c = Color.red ;
			break ;
		case LogType.Done :
			logStr = "Done" ;
			c = Color.cyan ;
			break ;
		}
		GUI.color = c ;
		GUILayout.Label( logStr );
		GUI.color = Color.white ;
	}

	void OnButtonGUI()
	{
		GUILayout.BeginHorizontal();
		int length = Enum.GetValues( typeof( LogPeriod ) ).Length ;
		int width = ( Screen.width - LABEL_WIDTH - 20 ) / length ;
		GUILayout.Label( "Period: " , GUILayout.Width( LABEL_WIDTH ) );
		for( int i = 0 ; i < length ; ++i )
		{
			GUI.contentColor = ( int )m_logPeriod == i ? Color.yellow : Color.white ;
			if( GUILayout.Button( ( ( LogPeriod )i ).ToString() , GUILayout.Width( width ) ) )
				m_logPeriod = ( LogPeriod )i ;
		}
		GUILayout.Label( "" , GUILayout.Width( width ) );
		GUILayout.EndHorizontal();

		GUI.contentColor = Color.cyan ;

		GUILayout.BeginHorizontal();
		GUILayout.Label( "" , GUILayout.Width( LABEL_WIDTH ) );
		if( GUILayout.Button( "EXPORT" , GUILayout.Width( Screen.width - LABEL_WIDTH - 10 ) ) )
			if( CheckUrl() )
				StartCoroutine( Export() );
		GUILayout.EndHorizontal();

		GUI.contentColor = Color.white ;
	}

	void Start()
	{
		m_timeZoneOffsetHour = TimeZone.CurrentTimeZone.GetUtcOffset( DateTime.Now ).Hours ;
//		Debug.Log( m_timeZoneOffsetHour.ToString() );

		m_account = PlayerPrefs.GetString( DATA_ACCOUNT );
		m_passWord = PlayerPrefs.GetString( DATA_PASSWORD );
		m_ip[ 0 ] = PlayerPrefs.GetString( DATA_IP0 );
		m_ip[ 1 ] = PlayerPrefs.GetString( DATA_IP1 );
		m_ip[ 2 ] = PlayerPrefs.GetString( DATA_IP2 );
		m_ip[ 3 ] = PlayerPrefs.GetString( DATA_IP3 );
		m_port = PlayerPrefs.GetString( DATA_PORT );
		m_deviceIds = PlayerPrefs.GetString( DATA_DEVICES );
	}

	void Update()
	{
		if( Log > LogType.Wait )
		{
			m_logTimer -= Time.unscaledDeltaTime ;
			if( m_logTimer <= 0 )
				Log = LogType.Nono ;
		}
	}

	void OnDisable()
	{
		PlayerPrefs.SetString( DATA_ACCOUNT , m_account );
		PlayerPrefs.SetString( DATA_PASSWORD , m_passWord );
		PlayerPrefs.SetString( DATA_IP0 , m_ip[ 0 ] );
		PlayerPrefs.SetString( DATA_IP1 , m_ip[ 1 ] );
		PlayerPrefs.SetString( DATA_IP2 , m_ip[ 2 ] );
		PlayerPrefs.SetString( DATA_IP3 , m_ip[ 3 ] );
		PlayerPrefs.SetString( DATA_PORT , m_port );
		PlayerPrefs.SetString( DATA_DEVICES , m_deviceIds );

		PlayerPrefs.Save();
	}

	void OnGUI()
	{
		if( Log != LogType.Nono && Log < LogType.Wait )
			Log = LogType.Nono ;

		GUI.enabled = Log != LogType.Wait ;

		GUILayout.Space( 10 );
		OnAccountGUI();
		OnIpGUI();
		OnDeviceGUI();
		OnButtonGUI();
		OnLogGUI();
	}
}
