using UnityEngine ;
using System.Collections ;
#if UNITY_EDITOR
using UnityEditor ;
using System.IO ;
#endif

public class AccountScriptableObject : ScriptableObject
{
	[ SerializeField ] string m_account = "" ;
	[ SerializeField ] string m_password = "" ;
	[ SerializeField ] string[] m_ip = new string[]{ "192" , "168" , "0" , "0" };
	[ SerializeField ] string m_port = "80" ;
	[ SerializeField ] string m_devices = "" ;

	public string Account { set { m_account = value ; } get { return m_account ; } }
	public string Password { set { m_password = value ; } get { return m_password ; } }
	public string[] IP { set { m_ip = value ; } get { return m_ip ; } }
	public string Port { set { m_port = value ; } get { return m_port ; } }
	public string Devices { set { m_devices = value ; } get { return m_devices ; } }

#if UNITY_EDITOR
	[ MenuItem( "Assets/Create/Account Data" ) ]
	public static void CreateAsset()
	{
		AccountScriptableObject asset = ScriptableObject.CreateInstance< AccountScriptableObject >();
		
		string path = AssetDatabase.GetAssetPath( Selection.activeObject );
		if ( path == "" ) 
			path = "Assets" ;
		else if ( Path.GetExtension( path ) != "" ) 
			path = path.Replace (Path.GetFileName (AssetDatabase.GetAssetPath (Selection.activeObject)), "");

		string assetPathAndName = AssetDatabase.GenerateUniqueAssetPath (path + "/New " + typeof( AccountScriptableObject ).ToString().Replace( "ScriptableObject" , "" ) + ".asset" );
		
		AssetDatabase.CreateAsset ( asset , assetPathAndName );
		
		AssetDatabase.SaveAssets ();
		AssetDatabase.Refresh();
		EditorUtility.FocusProjectWindow ();
		Selection.activeObject = asset ;
	}
#endif
}
