using UnityEngine;

public class LampInteraction : Item
{
    public MeshRenderer lampEmissionObj;
    public Light lampPointLight;

    [Space]
    public string emissionKeyword = "_EMISSION";
    public string emissionString = "_EmissionColor";

    [Space]
    public string lampSound;

    protected bool isLmap = false;

    private void Start()
    {
        lampPointLight.enabled = isLmap;
    }
    public override void ActivateObject()
    {
        isLmap = !isLmap;
        AudioManager.instance.Play(lampSound);

        UpdateLampState();
    }

    private void UpdateLampState()
    {
        lampPointLight.enabled = isLmap;

        if (lampPointLight.enabled)
        {
            lampEmissionObj.material.EnableKeyword(emissionKeyword);
            lampEmissionObj.material.SetColor(emissionString, new Color(1f, 1f, 1f));
        }
        else
        {
            lampEmissionObj.material.SetColor(emissionString, new Color(0f, 0f, 0f));
        }
    }
}
