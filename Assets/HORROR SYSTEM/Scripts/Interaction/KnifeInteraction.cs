using UnityEngine;

public class KnifeInteraction : Item
{
    public string pickUpSound;
    public override void ActivateObject()
    {
        AudioManager.instance.Play(pickUpSound);
        InventoryManager.instance.KnifeInInventory();
        DestroyObject(0);
    }
}
