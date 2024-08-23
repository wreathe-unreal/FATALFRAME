using System.Collections;
using UnityEngine;

public class KnifeController : MonoBehaviour
{
    public float timeKnifeAttack = 0.2f;

    [Space]
    public string knifeSound;

    private bool canAttack = true;

    public void KnifeAttack()
    {
        if (canAttack)
        {
            StartCoroutine(Attack());
        }
    }

    private IEnumerator Attack()
    {
        canAttack = false;

        AudioManager.instance.Play(knifeSound);

        yield return new WaitForSeconds(timeKnifeAttack);
        canAttack = true;
    }
}
