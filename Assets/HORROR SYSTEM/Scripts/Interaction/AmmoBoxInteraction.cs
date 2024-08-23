using UnityEngine;

public class AmmoBoxInteraction : Item
{
    public string pickUpSound;
    public override void ActivateObject()
    {
        AudioManager.instance.Play(pickUpSound);
        UIManager.instance.AddAmmo();
        DestroyObject(0);
    }
}
