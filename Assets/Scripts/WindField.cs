using UnityEngine;

public class WindField : MonoBehaviour
{
    [SerializeField]
    private Vector2 windVelocity = new Vector2(0.5f, 0f);

    public Vector2 GetVelocity(Vector2 position)
    {
        return windVelocity;
    }
}
