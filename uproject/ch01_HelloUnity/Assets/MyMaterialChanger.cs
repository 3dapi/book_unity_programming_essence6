using UnityEngine;

public class CubeController : MonoBehaviour
{
    [SerializeField]
    private Color materialColor = Color.gray;

	private Renderer cachedRenderer;

	void Start()
    {
		SetColor(materialColor);
	}

	public void SetColor(Color newColor)
	{
		materialColor = newColor;
		if (cachedRenderer == null)
		{
			TryGetComponent(out cachedRenderer);
		}
		if (cachedRenderer != null)
		{
			cachedRenderer.material.color = materialColor;
		}
	}
}
