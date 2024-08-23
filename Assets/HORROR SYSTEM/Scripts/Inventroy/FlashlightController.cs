using UnityEngine;

public enum EndlessBattery { Yes, No }
public class FlashlightController : MonoBehaviour
{
    public EndlessBattery endlessBattery = EndlessBattery.No;

    public bool IsFlashlightOn { get; private set; }

    [Space]
    public Light spotLight = null;
    public float spotLightIntensity;
    public float spotLightIntensityChange;

    private float maxSpotLightIntensity;

    [Space]
    public string batteryReloadSound;

    void Start()
    {
        spotLight.intensity = spotLightIntensity;
        maxSpotLightIntensity = spotLightIntensity;
        spotLight.enabled = false;
    }

    void Update()
    {
        BatteryUIUpdate();
    }

    public void ManageFlashlight(bool isFlashlight)
    {
        spotLight.enabled = isFlashlight;

        if (isFlashlight && endlessBattery == EndlessBattery.No)
        {
            DecreaseFlashlightIntensity();
        }
    }

    public void DecreaseFlashlightIntensity()
    {
        spotLightIntensity -= spotLightIntensityChange * Time.deltaTime;
        spotLight.intensity = spotLightIntensity;
        spotLightIntensity = Mathf.Max(spotLightIntensity, 0);
    }

    public void BatteryUIUpdate()
    {
        UIManager.instance.BatteryUIChange(spotLightIntensity, maxSpotLightIntensity); 
    }

    public void ReloadBattery()
    {
        if (spotLightIntensity < maxSpotLightIntensity)
        {
            if (UIManager.instance.batteryCountValue > 0)
            {
                spotLightIntensity = maxSpotLightIntensity;
                UIManager.instance.AddBattery(-1);
                AudioManager.instance.Play(batteryReloadSound);
            }
        }
    }
}
