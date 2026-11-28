using Unity.VisualScripting;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class Balloon : MonoBehaviour
{
    public float width = 0.15f;
    public float height = 0.20f;
    public int segments = 64;
    public float taper = 0.25f;
    private PolygonCollider2D polygonCollider2D;
    private MeshFilter meshFilter;
    private Vector3[] animatedVertices;
    private float elapsedTime = 0f;
    private bool isPopped = false;
    private float popDuration = 3f;
    private Fragment[] fragments;
    private struct Fragment
    {
        public Vector3 center;
        public Vector3 velocity;
        public float angularVelocity;
        public float shrinkRate;

        public Fragment(Vector3 center, Vector3 velocity, float angularVelocity, float shrinkRate)
        {
            this.center = center;
            this.velocity = velocity;
            this.angularVelocity = angularVelocity;
            this.shrinkRate = shrinkRate;
        }
    }

    void Start()
    {
        polygonCollider2D = GetComponent<PolygonCollider2D>();
        meshFilter = GetComponent<MeshFilter>();
        MeshRenderer rend = GetComponent<MeshRenderer>();
        Color color = new Color(
            Random.Range(0.0f, 1f),
            Random.Range(0.0f, 1f),
            Random.Range(0.0f, 1f),
            1.0f
        );
        rend.material.SetColor("_BaseColor", color);
        GenerateBalloon();   
        

    }

    void Update()
    {
        if (!isPopped)
            return;
        
        elapsedTime += Time.deltaTime;
        float t = elapsedTime;
        Mesh mesh = meshFilter.mesh;
        Vector3[] originalVertices = mesh.vertices;

        for (int i = 0; i < fragments.Length; i++)
        {
            Fragment fragment = fragments[i];
            int start = i * 3;

            float angle = fragment.angularVelocity * t;

            float scale = Mathf.Exp(
                -fragment.shrinkRate * t
            );

            Quaternion rotation =
                Quaternion.Euler(0f, 0f, angle);

            Vector3 displacement = fragment.velocity * t;

            for (int j = 0; j < 3; j++)
            {
                int index = start + j;

                Vector3 offset = originalVertices[index] - fragment.center;

                animatedVertices[index] =
                    fragment.center +
                    displacement +
                    rotation * (offset * scale);
            }
        }

        mesh.vertices = animatedVertices;
        mesh.RecalculateBounds();

        if (elapsedTime >= popDuration)
        {
            Destroy(gameObject);
        }
    }

    private void GenerateBalloon()
    {
        Mesh mesh = new Mesh();
        
        Vector3[] vertices = new Vector3[segments + 1];
        int[] triangles = new int[segments * 3];

        // Center vertex
        vertices[0] = Vector2.zero;

        // Outline vertices
        for (int i = 0; i < segments; i++)
        {
            float angle = i * Mathf.PI * 2f / segments;

            float x = width * Mathf.Sin(angle) * (1f + taper * Mathf.Cos(angle));;
            float y = height * Mathf.Cos(angle);

            vertices[i + 1] = new Vector3(x, y, 0);
        }

        // Triangulate
        for (int i = 0; i < segments; i++)
        {
            int current = i + 1;
            int next = (i + 1) % segments + 1;

            triangles[i * 3] = 0;
            triangles[i * 3 + 1] = current;
            triangles[i * 3 + 2] = next;
        }

        Vector2[] uv = new Vector2[vertices.Length];

        for (int i = 0; i < vertices.Length; i++)
        {
            uv[i] = new Vector2(
                vertices[i].x / (width * 2f) + 0.5f,
                vertices[i].y / (height * 2f) + 0.5f
            );
        }

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uv;
        mesh.RecalculateNormals();
        
        GenerateCollider(vertices);

        meshFilter.mesh = mesh;
    }

    private void GenerateCollider(Vector3[] vertices)
    {
        Vector2[] points = new Vector2[vertices.Length - 1];

        for (int i = 0; i < vertices.Length - 1; i++)
        {
            points[i] = new Vector2(vertices[i + 1].x, vertices[i + 1].y);
        }

        polygonCollider2D.pathCount = 1;
        polygonCollider2D.SetPath(0, points);
    }

    public void OnTapPop()
    {
        if (isPopped)
            return;
        
        Rigidbody2D rigidbody2D = GetComponent<Rigidbody2D>();
        AudioSource audioSource = GetComponent<AudioSource>();
        rigidbody2D.simulated = false;
        polygonCollider2D.enabled = false;

        SplitMesh();
        AnimateFragments();
        audioSource.Play();
        isPopped = true;
    }

    private void SplitMesh()
    {
        Mesh mesh = meshFilter.mesh;

        Vector3[] oldVertices = mesh.vertices;
        int[] oldTriangles = mesh.triangles;
        Vector2[] oldUV = mesh.uv;

        int count = oldTriangles.Length;

        Vector3[] newVertices = new Vector3[count];
        int[] newTriangles = new int[count];
        Vector2[] newUV = new Vector2[count];


        for (int i = 0; i < count; i++)
        {
            int oldIndex = oldTriangles[i];
            
            newVertices[i] = oldVertices[oldIndex];
            newUV[i] = oldUV[oldIndex];
            newTriangles[i] = i;
        }

        mesh.Clear();

        mesh.vertices = newVertices;
        mesh.triangles = newTriangles;
        mesh.uv = newUV;

        mesh.RecalculateBounds();
    }

    private void AnimateFragments()
    {
        Mesh mesh = meshFilter.mesh;
        animatedVertices = new Vector3[mesh.vertices.Length];

        Vector3[] vertices = mesh.vertices;

        int fragmentCount = mesh.vertices.Length / 3;

        fragments = new Fragment[fragmentCount];

        for (int i = 0; i < fragmentCount; i++)
        {
            Vector3 direction = vertices[i].normalized;
            Vector3 velocity = Random.Range(-2f, 2f) * direction;
            Vector3 center = (vertices[i] + vertices[i + 1] + vertices[i + 2]) / 3f;
            float angularVelocity = Random.Range(-220f, 220f);
            // float shrinkRate = Random.Range(8f, 15f);
            float shrinkRate = 2f;
            Fragment fragment = new Fragment(center, velocity, angularVelocity, shrinkRate);
            
            fragments[i] = fragment;
        }

        mesh.MarkDynamic();
    }
}