using UnityEngine;

public class FlashlightInteraction : Item
{
    public string pickUpSound;
    public override void ActivateObject()
    {
        AudioManager.instance.Play(pickUpSound);
        InventoryManager.instance.FlashlightInInventory();
        DestroyObject(0);
    }
}
