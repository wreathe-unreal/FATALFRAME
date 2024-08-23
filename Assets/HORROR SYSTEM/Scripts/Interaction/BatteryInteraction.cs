using UnityEngine;

public class BatteryInteraction : Item
{
    public string pickUpSound;
    public override void ActivateObject()
    {
        AudioManager.instance.Play(pickUpSound);
        UIManager.instance.AddBattery();
        DestroyObject(0);
    }
}
