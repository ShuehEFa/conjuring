using UnityEngine ;
using System.Collections ;

public class Main : MonoBehaviour 
{
	[ SerializeField ] Page m_firstPage ;

	void Start()
	{
		m_firstPage.Approach();
	}
}
