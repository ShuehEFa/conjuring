using UnityEngine ;
using System.Collections ;

public class Main : MonoBehaviour 
{	
	enum LogType
	{
		Nono ,
		Account ,
		Password ,
		Ip ,
		Port ,
		Devices ,
		Wait ,
		Done ,
	}

	const float LOG_DISPLAY_SEC = 2 ;

	string m_account = "" ;
	string m_passWord = "" ;
	string[] m_ip = new string[] { "0" , "0" , "0" , "0" } ;
	string m_port = "0" ;
	string m_deviceIds = "" ;
	LogType m_logType = LogType.Nono ;
	float m_logTimer = 0 ;
	
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
					ret += ":" + m_account ;
				ret += "@" ;
			}

			for( int i = 0 , length = m_ip.Length ; i < length ; ++i )
				ret += m_ip[ i ] + "." ;
			ret = ret.PadLeft( 1 );

			ret += "/api/energy/now/now-3153600/summary-graph/devices/power/" ;

			return ret ;
		}
	}

	LogType Log
	{
		set { m_logType = value ; m_logTimer = LOG_DISPLAY_SEC ; }
		get { return m_logType ; }
	}

	bool CheckUrl()
	{
		Log = LogType.Wait ;
		int temp = 0 ;
		if( m_account.Contains( " " ) )
			Log = LogType.Account ;
		if( m_passWord.Contains( " " ) )
			Log = LogType.Password ;
		for( int i = 0 , length = m_ip.Length ; i < length ; ++i )
			if( int.TryParse( m_ip[ i ] , out temp ) == false || temp > 255 || temp < 0 )
				Log = LogType.Ip ;
		if( int.TryParse( m_port , out temp ) == false || temp < 0 )
			Log = LogType.Port ;
		string[] devices = m_deviceIds.Split( ',' );
		if( devices.Length < 1 ) 
			Log = LogType.Devices ;
		for( int i = 0 , length = devices.Length ; i < length ; ++i )
			if( int.TryParse( devices[ i ] , out temp ) == false || temp < 1 )
				Log = LogType.Devices ;
		return Log == LogType.Wait ;
	}

	IEnumerator Export()
	{
		string[] devices = m_deviceIds.Split( ',' );
		for( int i = 0 , length = devices.Length ; i < length ; ++i )
		{
			WWW www = new WWW( Url + devices[ i ] );
			Debug.Log( www.url );
			yield return www ;

			Debug.Log( www.isDone );
			Debug.Log( www.error );
			Debug.Log( www.text );
		}
		Log = LogType.Done ;
	}

	void OnAccountGUI()
	{
		GUILayout.BeginHorizontal();
		GUILayout.Label( "Account: " , GUILayout.Width( 60 ) );
		m_account = GUILayout.TextField( m_account , GUILayout.Width( 100 ) );
		if( m_account.Contains( " " ) )
			Log = LogType.Account ;
		GUILayout.Label( " Password: " );
		if( m_passWord.Contains( " " ) )
			Log = LogType.Password ;
		m_passWord = GUILayout.PasswordField( m_passWord , '*' , GUILayout.Width( 100 ) );
		GUILayout.EndHorizontal();
	}

	void OnIpGUI()
	{
		int temp = 0 ;
		GUILayout.BeginHorizontal();
		GUILayout.Label( "IP: " , GUILayout.Width( 60 ) );
		for( int i = 0 , length = m_ip.Length ; i < length ; ++i )
		{
			m_ip[ i ] = GUILayout.TextField( m_ip[ i ] , GUILayout.Width( 30 ) );
			if( int.TryParse( m_ip[ i ] , out temp ) == false || temp > 255 || temp < 0 )
				Log = LogType.Ip ;
			GUILayout.Label( "." , GUILayout.Width( 5 ) );
		}
		GUILayout.Label( " Port: " );
		m_port = GUILayout.TextField( m_port , GUILayout.Width( 30 ) );
		if( int.TryParse( m_port , out temp ) == false || temp < 0 )
			Log = LogType.Port ;
		GUILayout.EndHorizontal();
	}

	void OnDeviceGUI()
	{
		GUILayout.BeginHorizontal();
		GUILayout.Label( "Device: " , GUILayout.Width( 60 ) );
		m_deviceIds = GUILayout.TextField( m_deviceIds , Screen.width - 60 );
		string[] devices = m_deviceIds.Split( ',' );
		int temp = 0 ;
		for( int i = 0 , length = devices.Length ; i < length ; ++i )
			if( int.TryParse( devices[ i ] , out temp ) == false || temp < 1 )
				Log = LogType.Devices ;
		GUILayout.EndHorizontal();

		GUILayout.BeginHorizontal();
		GUILayout.Label( "" , GUILayout.Width( 60 ) );
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
			c = Color.red ;
			break ;
		case LogType.Password :
			logStr = "Password Error: maybe cotain space" ;
			c = Color.red ;
			break ;
		case LogType.Ip :
			logStr = "IP Error: not interger or out of range" ;
			c = Color.red ;
			break ;
		case LogType.Port :
			logStr = "Port Error: not interger or out of range" ;
			c = Color.red ;
			break ;
		case LogType.Devices :
			logStr = "Devices Error: maybe cotain space, not interger or out of range" ;
			c = Color.red ;
			break ;
		case LogType.Wait :
			logStr = "please wait" ;
			c = Color.white ;
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
		GUILayout.Space( Screen.width - 60 );
		if( GUILayout.Button( "GO" , GUILayout.Width( 60 ) ) )
			if( CheckUrl() )
				StartCoroutine( Export() );
		GUILayout.EndHorizontal();
	}

	void Update()
	{
		if( Log != LogType.Nono && Log != LogType.Wait )
		{
			m_logTimer -= Time.unscaledDeltaTime ;
			if( m_logTimer <= 0 )
				Log = LogType.Nono ;
		}
	}

	void OnGUI()
	{
		OnAccountGUI();
		OnIpGUI();
		OnDeviceGUI();
		OnLogGUI();
		OnButtonGUI();
	}
}
