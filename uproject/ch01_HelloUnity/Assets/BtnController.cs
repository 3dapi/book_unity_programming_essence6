using UnityEngine;

public class BtnController : MonoBehaviour
{
	public void OnClickHello()
	{
		Debug.Log("Hello Unity!");
	}


	private bool showPopup = false;
	public void OpenPopup()
	{
		showPopup = true;
	}
	// 참고.
	/*
	private void OnGUI()
	{
		if (!showPopup)
			return;

		// 2.5배 크기 (750 x 375)
		float width = 750f;
		float height = 375f;
		Rect boxRect = new Rect((Screen.width - width) / 2f, (Screen.height - height) / 2f, width, height);

		// 글자 크기도 비례해서 확대
		GUIStyle boxStyle = new GUIStyle(GUI.skin.box) { fontSize = 64 };
		GUIStyle labelStyle = new GUIStyle(GUI.skin.label) { fontSize = 48, alignment = TextAnchor.MiddleCenter };
		GUIStyle buttonStyle = new GUIStyle(GUI.skin.button) { fontSize = 48 };

		GUI.Box(boxRect, "알림", boxStyle);
		GUI.Label(new Rect(boxRect.x + 40, boxRect.y + 110, width - 80, 100), "버튼이 클릭되었습니다.", labelStyle);

		// 확인 버튼 (250 x 75)
		float btnW = 250f;
		float btnH = 75f;
		if (GUI.Button(new Rect(boxRect.x + (width - btnW) / 2f, boxRect.y + height - btnH - 35, btnW, btnH), "확인", buttonStyle))
		{
			showPopup = false;
		}
	}
	*/
}