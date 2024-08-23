using UnityEngine;

public class DoorInteraction : Item
{
    public Animator doorAnimator;

    [Space]
    public bool needKey;
    public string keyName;

    [Space]
    public string doorLockedSound;
    public string doorOpenSound;
    public string doorCloseSound;

    protected bool isDoorOpen = false;

    private bool isFirstInteraction = true;

    public override void ActivateObject()
    {
        if (needKey && isFirstInteraction)
            CheckKeyPass();
        else
            OpenClose();
    }

    private void CheckKeyPass()
    {
        var key = KeyManager.instance.GetKeyWithPath(keyName);

        if (key == keyName)
        {
            OpenClose();
            isFirstInteraction = false;
        }
        else
            Locked();
    }

    private void OpenClose()
    {
        isDoorOpen = !isDoorOpen;

        doorAnimator.SetBool("DoorOpen", isDoorOpen);
        doorAnimator.SetBool("DoorClose", !isDoorOpen);

        if (isDoorOpen)
        {
            AudioManager.instance.Play(doorOpenSound);
        }
        else
        {
            AudioManager.instance.Play(doorCloseSound);
        }

        if (needKey)
        {
            KeyManager.instance.RemoveKey(keyName);
            UIManager.instance.UpdateKeyNamesText();
        }
    }

    private void Locked()
    {
        AudioManager.instance.Play(doorLockedSound);
        doorAnimator.SetTrigger("DoorLocked");
    }
}
