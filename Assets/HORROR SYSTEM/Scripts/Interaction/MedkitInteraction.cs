using UnityEngine;

public class MedkitInteraction : Item
{
    public string pickUpSound;
    public override void ActivateObject()
    {
        AudioManager.instance.Play(pickUpSound);
        UIManager.instance.AddMedKit();
        DestroyObject(0);
    }
}
