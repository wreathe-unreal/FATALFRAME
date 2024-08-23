using UnityEngine;

public class KeyInteraction : Item
{
    public string keyName;

    [Space]
    public string keySound;

    public override void ActivateObject()
    {
        AddKey();
    }

    private void AddKey()
    {
        KeyManager.instance.AddKey(keyName);
        AudioManager.instance.Play(keySound);

        DestroyObject(0);
    }

    public string GetKeyPass()
    {
        return keyName;
    }
}
