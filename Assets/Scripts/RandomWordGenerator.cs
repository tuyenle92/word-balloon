using System.Linq;
using TMPro;
using UnityEngine;

public class RandomWordGenerator : MonoBehaviour
{
    [SerializeField] BalloonSpawner balloonSpawner;
    private TextMeshPro textMeshPro;
    private string[] words =
    {
        "Randomness",
        "Relax",
        "Greatness",
        "Japan",
        "Retire",
        "Coffee",
        "Matcha",
        "Grand Theft Auto VI",
        "Vietnam",
        "United States of America"
    };
    
    void Start()
    {
        textMeshPro = gameObject.GetComponent<TextMeshPro>();
        textMeshPro.text = words[Random.Range(0, 6)];
        balloonSpawner.Spawn(textMeshPro.text);
    }

    // Update is called once per frame
    void Update()
    {
        if (!textMeshPro.text.Any(char.IsLetter))
        {
            textMeshPro.text = words[Random.Range(0, 6)];
            balloonSpawner.Spawn(textMeshPro.text);
        }
    }
}
