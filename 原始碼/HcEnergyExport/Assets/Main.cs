using UnityEngine ;
using System ;
using System.IO ;
using System.Collections ;
using System.Collections.Generic ;

public class Main : MonoBehaviour 
{	
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

	const int READ_TIMEOUT_SEC = 10 ;
	const int LOG_DISPLAY_SEC = 2 ;

	const int LABEL_WIDTH = 70 ;
	const int STRING_WIDTH = 100 ;
	const int INT_WIDTH = 50 ;
	const int DOT_WIDTH = 5 ;
	
	readonly string[] NORMAL_SEPERATOR = new string[]{ "," };
	readonly string[] POWER_DATA_SEPERATOR = new string[]{ "],[" };

	[ SerializeField ] AccountScriptableObject m_data ;

	string m_account = "" ;
	string m_passWord = "" ;
	string[] m_ip = new string[]{ "0" , "0" , "0" , "0" } ;
	string m_port = "0" ;
	string m_deviceIds = "" ;

	int m_timePeriodSec = 60 * 60 * 24 * 365 ;
	int m_timeZoneOffsetHour = 0 ;

	LogType m_logType = LogType.Nono ;
	float m_logTimer = 0 ;
	string m_connectErr = "";
	
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

			string endTime = "now-" +  m_timePeriodSec.ToString();

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
		GUILayout.Space( Screen.width - LABEL_WIDTH );
		if( GUILayout.Button( "GO" , GUILayout.Width( LABEL_WIDTH ) ) )
			if( CheckUrl() )
				StartCoroutine( Export() );
		GUILayout.EndHorizontal();
	}

	void Start()
	{
		m_timeZoneOffsetHour = TimeZone.CurrentTimeZone.GetUtcOffset( DateTime.Now ).Hours ;
//		Debug.Log( m_timeZoneOffsetHour.ToString() );
		if( m_data != null )
		{
			m_account = m_data.Account ;
			m_passWord = m_data.Password ;
			m_ip = m_data.IP ;
			m_port = m_data.Port ;
			m_deviceIds = m_data.Devices ;
		}
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
		if( m_data != null )
		{
			m_data.Account = m_account ;
			m_data.Password = m_passWord ;
			m_data.IP = m_ip ;
			m_data.Port = m_port ;
			m_data.Devices = m_deviceIds ;
		}
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
