using UnityEngine;

public class Sky : MonoBehaviour
{
    [SerializeField] private Camera mainCamera;
    void LateUpdate()
    {
        float height = mainCamera.orthographicSize * 2f;
        float width = height * mainCamera.aspect;

        transform.localScale = new Vector3(width, height, 1f);

        transform.position = mainCamera.transform.position + mainCamera.transform.forward * 20f;

        transform.rotation = mainCamera.transform.rotation;
    }
}
