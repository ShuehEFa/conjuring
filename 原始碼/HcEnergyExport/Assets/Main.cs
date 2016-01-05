using UnityEngine ;
using System.Collections ;

public class Main : MonoBehaviour 
{	
	enum ErrorType
	{
		Nono ,
		Account ,
		Password ,
		Ip ,
		Port ,
		Devices ,
	}

	string m_account = "" ;
	string m_passWord = "" ;
	string[] m_ip = new string[] { "0" , "0" , "0" , "0" } ;
	string m_port = "0" ;
	string m_deviceIds = "" ;
	ErrorType m_err = ErrorType.Nono ;
	
	string ApiUrl
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

	// Use this for initialization
//	IEnumerator Start () 
//	{
//		WWW www = new WWW( ApiUrl );
//		yield return www ;
//
//		Debug.Log( www.text );
//	}

	void OnAccountGUI()
	{
		GUILayout.BeginHorizontal();
		GUILayout.Label( "Account: " , GUILayout.Width( 60 ) );
		m_account = GUILayout.TextField( m_account , GUILayout.Width( 100 ) );
		if( m_account.Contains( " " ) )
		{
			m_account = m_account.Trim( ' ' );
			m_err = ErrorType.Account ;
		}
		GUILayout.Label( " Password: " );
		if( m_passWord.Contains( " " ) )
		{
			m_passWord = m_passWord.Trim( ' ' );
			m_err = ErrorType.Password ;
		}
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
			if( int.TryParse( m_ip[ i ] , out temp ) == false )
			{
				m_err = ErrorType.Ip ;
				m_ip[ i ] = "0" ;
			}
			GUILayout.Label( "." , GUILayout.Width( 5 ) );
		}
		GUILayout.Label( " Port: " );
		m_port = GUILayout.TextField( m_port , GUILayout.Width( 30 ) );
		if( int.TryParse( m_port , out temp ) == false )
		{
			m_err = ErrorType.Port ;
			m_port = "0" ;
		}
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
			if( int.TryParse( devices[ i ] , out temp ) == false )
				m_err = ErrorType.Devices ;
		GUILayout.EndHorizontal();

		GUILayout.BeginHorizontal();
		GUILayout.Label( "" , GUILayout.Width( 60 ) );
		GUILayout.Label( "Use \",\" to seperate the device ID" );
		GUILayout.EndHorizontal();
	}

	void OnGUI()
	{
		OnAccountGUI();
		OnIpGUI();
		OnDeviceGUI();


	}
}
