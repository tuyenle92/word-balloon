using UnityEngine;
using System.Collections;
using TMPro;
using System.Text;

public class BalloonSpawner : MonoBehaviour
{
    [SerializeField] private GameObject balloonPrefab;
    private Camera mainCam;
    private char[] alphabet =
    {
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l',
        'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
        'y', 'z'
    };

    void Awake()
    {
        mainCam = Camera.main;
    }

    public void Spawn(string word)
    {
        StartCoroutine(SpawnBalloons(word));
    }

    IEnumerator SpawnBalloons(string word)
    {
        for (int i = 0; i < word.Length; i++)
        {
            float maxY = mainCam.transform.position.y - mainCam.orthographicSize - 1;
            float minY = mainCam.transform.position.y - mainCam.orthographicSize - 4;
            float x = Random.Range(-2f, 2f);
            float y = Random.Range(maxY, minY);

            Vector3 position = new Vector3(x, y, 0);
            GameObject balloon = Instantiate(balloonPrefab, position, Quaternion.identity);
            TextMeshPro textMeshPro = balloon.transform.Find("Text").GetComponent<TextMeshPro>();
            StringBuilder sb = new StringBuilder(word);

            textMeshPro.text = sb[i].ToString();
            balloon.name = "Balloon " + sb[i];
        }
        
        yield return new WaitForSeconds(1);   
    }
}
