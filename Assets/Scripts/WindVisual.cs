using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class WindVisual : MonoBehaviour
{
    [SerializeField]
    private WindField windField;
    
    private ParticleSystem particles;

    void Awake()
    {
        particles = GetComponent<ParticleSystem>();
    }

    void Update()
    {   
        var windVelocity = windField.GetVelocity(transform.position);
        var velocity = particles.velocityOverLifetime;

        velocity.enabled = true;
        velocity.space = ParticleSystemSimulationSpace.World;

        velocity.x = windVelocity.x;
        velocity.y = windVelocity.y;
        velocity.z = 0f;
    }
}
