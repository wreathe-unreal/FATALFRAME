using System.Collections;
using UnityEngine;

public class PistolController : MonoBehaviour
{
    public Transform shotPoint;
    public GameObject bulletPrefab;

    [Space]
    public float bulletSpeed = 100f;
    public float fireRate = 0.2f;

    public float reloadTime = 2f;

    [Space]
    public float bulletLifetime = 2f;

    [Space]
    public ParticleSystem muzzleFlash;
    public ParticleSystem shell;

    [Space]
    public string shootSound;
    public string reloadSound;

    private bool canShoot = true;

    public void PistolShoot()
    {
        if (canShoot)
        {
            StartCoroutine(Shoot());
        }
    }

    public void PistolReloading()
    {
        if (UIManager.instance.ammoCountValue > 0 && canShoot)
        {
            StartCoroutine(Reload());
        }
    }

    private IEnumerator Shoot()
    {
        if (UIManager.instance.currentAmmo > 0)
        {
            canShoot = false;

            Ray ray = new Ray(shotPoint.position, shotPoint.forward);

            Quaternion bulletRotation = Quaternion.LookRotation(ray.direction);

            GameObject bullet = Instantiate(bulletPrefab, shotPoint.position, bulletRotation);
            Rigidbody bulletRigidbody = bullet.GetComponent<Rigidbody>();
            bulletRigidbody.AddForce(ray.direction * bulletSpeed, ForceMode.Impulse);
            Destroy(bullet, bulletLifetime);

            muzzleFlash.Play();
            shell.Play();
            UIManager.instance.ShootAmmo();
            AudioManager.instance.Play(shootSound);

            yield return new WaitForSeconds(fireRate);
            canShoot = true;
        }
    }

    public IEnumerator Reload()
    {
        yield return new WaitForSeconds(reloadTime);
        UIManager.instance.ReloadAmmo();
        AudioManager.instance.Play(reloadSound);
    }
}
