using System;
using UnityEngine;

[RequireComponent(typeof(Rigidbody2D))]
public class BalloonBuoyancy : MonoBehaviour
{
    [SerializeField] private float airDensity = 1.225f;
    private float volume = 0.0141f;
    [SerializeField] private float dragCoefficient = 0.47f;

    [SerializeField] private WindField windField;
    private float crossSectionalArea = 0.0707f;

    private Balloon balloon;

    private Rigidbody2D rb;

    void Awake()
    {
        balloon = GetComponent<Balloon>();
        volume = (4f / 3f) * Mathf.PI * balloon.width * balloon.width * balloon.height;
        crossSectionalArea = Mathf.PI * balloon.width * balloon.width;
        rb = GetComponent<Rigidbody2D>();
    }

    void FixedUpdate()
    {

        Vector2 buoyancyForce = -Physics2D.gravity * airDensity * volume;
        Vector2 windVelocity = windField.GetVelocity(rb.position);
        Vector2 velocity = rb.linearVelocity - windVelocity;

        Vector2 dragForce =
            -0.5f
            * airDensity
            * dragCoefficient
            * crossSectionalArea
            * velocity.magnitude
            * velocity;

        rb.AddForce(dragForce);
        rb.AddForce(buoyancyForce);
    }
}
