using UnityEngine ;
using System.Collections ;

public class Page : MonoBehaviour 
{
	enum PageState
	{
		Normal ,
		Approach ,
		Disapproach ,
	}

	PageState m_state = PageState.Normal ;
	Transform m_trans ;
	UnityEngine.UI.Button[] m_buttons ;

	float TransformX 
	{ 
		get { return m_trans.position.x ; } 
		set { Vector3 temp = m_trans.position ; temp.x = value ; m_trans.position = temp ; } 
	} 

	bool ButtonEnable 
	{ 
		set 
		{
			for( int i = 0 , length = m_buttons.Length ; i < length ; ++i )
				m_buttons[ i ].interactable = value ;
		} 
	}

	void Awake()
	{
		m_trans = transform;
		m_buttons = GetComponentsInChildren< UnityEngine.UI.Button >( true );
		ButtonEnable = false ;
		enabled = false ;
	}

	void Start()
	{
		TransformX = -Screen.width ;
	}

	void Update()
	{
		if( m_state == PageState.Approach )
		{
			TransformX = Mathf.Lerp( TransformX , 0 , Time.deltaTime * 5 );
			if( Mathf.Abs( TransformX - 0 ) < 1 )
			{
				TransformX = 0 ;
				m_state = PageState.Normal ;
				enabled = false ;
				ButtonEnable = true ;
			}
		}
		else if( m_state == PageState.Disapproach )
		{
			TransformX = Mathf.Lerp( TransformX , Screen.width , Time.deltaTime * 5 );
			if( Mathf.Abs( TransformX - Screen.width ) < 1 )
			{
				TransformX = Screen.currentResolution.width ;
				m_state = PageState.Normal ;
				enabled = false ;
				ButtonEnable = false ;
			}
		}
	}

	public void Approach()
	{
		TransformX = -Screen.width ;
		m_state = PageState.Approach ;
		enabled = true ;
		ButtonEnable = false ;
	}

	public void Disapproach()
	{
		m_state = PageState.Disapproach ;
		enabled = true ;
		ButtonEnable = false ;
		ButtonEnable = false ;
	}


}
