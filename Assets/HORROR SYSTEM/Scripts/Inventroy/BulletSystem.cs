using UnityEngine;

public class Bullet : MonoBehaviour
{
    public GameObject decalPrefab;

    [Space]
    public float decalLifetime = 5f;

    private void OnCollisionEnter(Collision collision)
    {
        ContactPoint contactPoint = collision.GetContact(0);
        GameObject decal = Instantiate(decalPrefab, contactPoint.point, Quaternion.LookRotation(contactPoint.normal));

        Destroy(decal, decalLifetime);
        Destroy(gameObject);
    }
}