using UnityEngine;

public class PistolInteraction : Item
{
    public string pickUpSound;
    public override void ActivateObject()
    {
        AudioManager.instance.Play(pickUpSound);
        InventoryManager.instance.PistolInInventory();
        DestroyObject(0);
    }
}
