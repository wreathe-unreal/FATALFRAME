using System.Collections.Generic;
using UnityEngine;

public class KeyManager : MonoBehaviour
{
    public List<string> allKeyName = new List<string>();

    public static KeyManager instance;

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Destroy(gameObject);
            return;
        }
    }

    public void AddKey(string newKeyName)
    {
        allKeyName.Add(newKeyName);
        UIManager.instance.UpdateKeyNamesText();
    }


    public string GetKeyWithPath(string keyName)
    {
        foreach (var key in allKeyName)
        {
            if (key == keyName)
            {
                return key;
            }
        }
        return null;
    }

    public void RemoveKey(string keyNameToRemove)
    {
        allKeyName.Remove(keyNameToRemove);
    }
}
