using UnityEngine ;
using System.IO ;
using System.Collections.Generic ;

public class Main : MonoBehaviour 
{
	const string GIT_NAME = "vfibGit" ;
	const string VFIB_NAME = "vfib" ;
	const string JSON_NAME = "json" ;

	const string GIT_FOLDER = GIT_NAME + "/" ;
	const string VFIB_FOLDER = VFIB_NAME + "/" ;

	const string GIT_FILE = "." + GIT_NAME ;
	const string VFIB_FILE = "." + VFIB_NAME ;
	const string JSON_FILE = "." + JSON_NAME ;
	
	const string MAIN_LOOP_STRING = "\"mainLoop\":\"" ;
	const string MSG_STRING = "\"msg\":\"" ;
	const string LUA_END_STRING = "\",\"" ;

	struct LuaRange
	{
		public int begin ;
		public int end ;
	}
	
	int FindLuaEndIdx( string _source , int _beginIdx = 0 )
	{
		int ret ;
		while( true )
		{
			ret = _source.IndexOf( LUA_END_STRING , _beginIdx ) ;
			if( ret < 0 )
			{
				Debug.LogWarning( "Dont find String end scope charater" );
				return _source.Length ;
			}
			else
			{
				if( _source[ ret - 1 ] == '\\' )
					_beginIdx = ret + LUA_END_STRING.Length ;
				else
					return ret ;
			}
		}
	}

	string FillTabSpace( int _count )
	{
		string tab = "\t" ;
		string ret = "" ;
		while( _count-- > 0 )
			ret += tab ;

		return ret ;
	}

	void CheckAndAddLine( List< string > _list , string _text , int _tabNumber )
	{
		if( string.IsNullOrEmpty( _text ) == false )
			_list.Add( FillTabSpace( _tabNumber ) + _text );
	}

	void Write2git( string _filePath )
	{
		string text = File.ReadAllText( _filePath );
		_filePath = _filePath.Replace( VFIB_FILE , "" );
		_filePath = _filePath.Replace( JSON_FILE , "" );
		
		List< LuaRange > msgs = new List< LuaRange >();
		LuaRange mainLoop = new LuaRange();
		mainLoop.begin = text.IndexOf( MAIN_LOOP_STRING ) + MAIN_LOOP_STRING.Length ;
		mainLoop.end = FindLuaEndIdx( text , mainLoop.begin );
		Debug.Log( "main loop: " + mainLoop.begin + " / " + mainLoop.end );
		Debug.Log( text.Substring( mainLoop.begin , mainLoop.end - mainLoop.begin ) );
		msgs.Add( mainLoop );
		
		int findIdx = mainLoop.end ;
		while( true )
		{
			findIdx = text.IndexOf( MSG_STRING , findIdx );
			if( findIdx < 0 )
			{
				Debug.Log( "serch completed" );
				break ;
			}
			
			LuaRange msg = new LuaRange();
			msg.begin = findIdx + MSG_STRING.Length ;
			msg.end = FindLuaEndIdx( text , msg.begin );
			findIdx = msg.end ;
			Debug.Log( "msg: " + msg.begin + " / " + msg.end );
			Debug.Log( text.Substring( msg.begin , msg.end - msg.begin ) );
			msgs.Add( msg );
		}
		
		List< string > lines = new List< string >();
		bool inLua = false ;
		int lineBegin = 0 , msgIdx = 0 , tabNumber = 0 ;
		for( int i = 0 , length = text.Length ; i < length ; ++i )
		{
			if( inLua )
			{
				if( i == msgs[ msgIdx ].end )
				{
					CheckAndAddLine( lines , text.Substring( lineBegin , i - lineBegin + 2 ) , tabNumber + 1 );
					lineBegin = i + 2 ;
					++msgIdx ;
					inLua = false ;
				}
				else if( text[ i ] == '\\' && text[ i + 1 ] == 'n' )
				{
					CheckAndAddLine( lines , text.Substring( lineBegin , i - lineBegin ) , tabNumber + 1 );
					lineBegin = i++ ;
				}
			}
			else
			{
				if( msgIdx < msgs.Count && i == msgs[ msgIdx ].begin )
				{
					inLua = true ;
				}
				else if( text[ i ] == '{' || text[ i ] == '[' )
				{
					CheckAndAddLine( lines , text.Substring( lineBegin , i - lineBegin ) , tabNumber );
					CheckAndAddLine( lines , text[ i ].ToString() , tabNumber );
					lineBegin = i + 1 ;
					++tabNumber ;
				}
				else if( text[ i ] == '}' || text[ i ] == ']' )
				{
					CheckAndAddLine( lines , text.Substring( lineBegin , i - lineBegin ) , tabNumber );
					lineBegin = i ;
					--tabNumber ;
				}
				else if( text[ i ] == ',' )
				{
					CheckAndAddLine( lines , text.Substring( lineBegin , i - lineBegin + 1 ) , tabNumber );
					lineBegin = i + 1 ;
				}
			}
		}
		lines.Add( FillTabSpace( tabNumber ) + text.Substring( lineBegin , text.Length - lineBegin ) );
		
		for( int i = 0 , count = lines.Count ; i < count ; ++i )
			Debug.Log( lines[ i ] );
		
		File.WriteAllLines( GIT_FOLDER + _filePath + GIT_FILE , lines.ToArray() );
	}

	void Write2vfib( string _filePath )
	{
		string[] texts = File.ReadAllLines( _filePath );
		_filePath = _filePath.Replace( GIT_FILE , "" );

		string fileText = "" ;
		for( int i = 0 , length = texts.Length ; i < length ; ++i )
			fileText += texts[ i ].Replace( "\t" , "" ) ;
		
		File.WriteAllText( VFIB_FOLDER + _filePath + VFIB_FILE , fileText );
	}

	void Excute()
	{
		if( Directory.Exists( GIT_NAME ) == false )
			Directory.CreateDirectory( GIT_NAME );
		if( Directory.Exists( VFIB_FOLDER ) == false )
			Directory.CreateDirectory( VFIB_FOLDER );

		string path = Application.dataPath ;
#if UNITY_EDITOR
		path = path.Substring( 0 , path.LastIndexOf( "/" ) );	// remove "/Assets"
#elif UNITY_STANDALONE_OSX
		path = path.Substring( 0 , path.LastIndexOf( "/" ) );	// remove "/Contens"
		path = path.Substring( 0 , path.LastIndexOf( "/" ) );	// remove [product name]
#else
		path = path.Substring( 0 , path.LastIndexOf( "/" ) );	// remove [product name]
#endif
		if( path.Contains( "/" ) == false )
			path += "/" ;

		DirectoryInfo di = new DirectoryInfo( path );

		FileInfo[] files = di.GetFiles();
		for( int i = 0 , length = files.Length ; i < length ; ++i )
		{
			string extension = files[ i ].Extension ;
			if( extension == GIT_FILE )
				Write2vfib( files[ i ].Name );
			else if( extension == VFIB_FILE || extension == JSON_FILE )
				Write2git( files[ i ].Name );
		}
	}

	// Use this for initialization
	void Start () 
	{
		Excute();
		Application.Quit();
	}

	void OnGUI()
	{
		string path = Application.dataPath ;
#if UNITY_EDITOR
		path = path.Substring( 0 , path.LastIndexOf( "/" ) );	// remove "/Assets"
#elif UNITY_STANDALONE_OSX
		path = path.Substring( 0 , path.LastIndexOf( "/" ) );	// remove "/Contens"
		path = path.Substring( 0 , path.LastIndexOf( "/" ) );	// remove [product name]
#else
		path = path.Substring( 0 , path.LastIndexOf( "/" ) );	// remove [product name]
#endif
		if( path.Contains( "/" ) == false )
			path += "/" ;
		GUILayout.Label( path );
	}
}
