using UnityEngine;

// 지정한 중심점을 바라보며 일정한 반경/높이로 천천히 공전하는 카메라.
// 플레이(실행) 중에 동작합니다.
public class OrbitCamera : MonoBehaviour
{
    [Header("Target")]
    [Tooltip("비워 두면 아래 center 좌표를 바라봅니다.")]
    public Transform target;
    public Vector3 center = new Vector3(0f, 0.5f, 0f);

    [Header("Orbit")]
    [Tooltip("중심에서 수평으로 떨어진 거리")]
    public float radius = 16f;
    [Tooltip("중심에서 위로 떨어진 높이")]
    public float height = 10f;
    [Tooltip("초당 회전 각도(도). 양수는 위에서 볼 때 시계 방향")]
    public float degreesPerSecond = 15f;
    [Tooltip("시작 각도(도)")]
    public float startAngle = 0f;

    private float angle;

    void Start()
    {
        angle = startAngle;
        UpdatePose();
    }

    void LateUpdate()
    {
        angle += degreesPerSecond * Time.deltaTime;
        UpdatePose();
    }

    void UpdatePose()
    {
        Vector3 c = target != null ? target.position : center;
        float rad = angle * Mathf.Deg2Rad;
        Vector3 offset = new Vector3(Mathf.Sin(rad) * radius, height, Mathf.Cos(rad) * radius);
        transform.position = c + offset;
        transform.LookAt(c);
    }
}
