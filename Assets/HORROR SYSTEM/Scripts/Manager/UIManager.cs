using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class UIManager : MonoBehaviour
{
    [Header("Interaction Icon")]
    public Image interactionIcon;
    private RectTransform iconRectTransform;

    public Vector3 interactionIconOffset;
    private GameObject currentObject;

    [Header("Note Interaction")]
    public GameObject notePanel;
    private bool isNotePanelActive = false;

    [Header("Health UI")]
    public Image healthBar = null;
    public Image bloodEffect = null;
    public TMP_Text medKitCount;
    public int medKitCountValue = 0;

    [Header("Battery UI")]
    public GameObject batteryPanel;
    public Image batteryBar = null;
    public TMP_Text batteryCount;
    public int batteryCountValue = 0;

    [Header("Ammo UI")]
    public GameObject ammoPanel;
    public TMP_Text ammoCount;
    public int ammoCountValue = 0;
    public int currentAmmo;

    [Space]
    public int magazineCapacity = 20;
    public int startAmmo = 100;

    [Header("Key Names")]
    public TMP_Text keyNamesText;

    [Header("Pause Menu")]
    public GameObject pauseMenu;

    public static UIManager instance;

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

    void Start()
    {
        interactionIcon.gameObject.SetActive(false);
        iconRectTransform = interactionIcon.GetComponent<RectTransform>();
        
        notePanel.SetActive(isNotePanelActive);
        
        pauseMenu.SetActive(false);
        batteryPanel.SetActive(false);
        ammoPanel.SetActive(false);

        keyNamesText.gameObject.SetActive(false);

        medKitCount.text = "x" + medKitCountValue;
        batteryCount.text = "x" + batteryCountValue;

        ammoCountValue = startAmmo;
        currentAmmo = magazineCapacity;
        UpdateAmmoCountUI();
    }

    void LateUpdate()
    {
        if (currentObject != null)
        {
            Vector3 screenPos = Camera.main.WorldToScreenPoint(currentObject.transform.position + interactionIconOffset);
            iconRectTransform.position = screenPos;
        }
    }

    #region Interaction Icon
    public void SetCurrentObject(GameObject obj)
    {
        currentObject = obj;
        interactionIcon.gameObject.SetActive(currentObject != null);
    }
    #endregion

    #region Health UI
    public void HealthUIChange(float currentHealth, float maxHealth)
    {
        float healthPercentage = currentHealth / maxHealth;
        healthBar.fillAmount = healthPercentage;

        float alpha = 1f - healthPercentage;
        Color newColor = bloodEffect.color;
        newColor.a = Mathf.MoveTowards(newColor.a, alpha, Time.deltaTime);
        bloodEffect.color = newColor;
    }

    public void AddMedKit(int amount = 1)
    {
        medKitCountValue += amount;
        UpdateMedKitCountUI();
    }

    private void UpdateMedKitCountUI()
    {
        medKitCount.text = "x" + medKitCountValue;
    }
    #endregion

    #region Battery UI
    public void BatteryUIChange(float currentSpotLightIntensity, float maxSpotLightIntensity)
    {
        float batteryPercentage = currentSpotLightIntensity / maxSpotLightIntensity;
        batteryBar.fillAmount = batteryPercentage;
    }

    public void AddBattery(int amount = 1)
    {
        batteryCountValue += amount;
        UpdateBatteryCountUI();
    }

    private void UpdateBatteryCountUI()
    {
        batteryCount.text = "x" + batteryCountValue;
    }
    #endregion

    #region Ammo UI
    public void AddAmmo(int amount = 20)
    {
        ammoCountValue = ammoCountValue + amount;
        UpdateAmmoCountUI();
    }

    public void UpdateAmmoCountUI()
    {
        ammoCount.text = $"{currentAmmo}/{ammoCountValue}";
    }

    public void ShootAmmo()
    {
        if (currentAmmo > 0)
        {
            currentAmmo--;
            UpdateAmmoCountUI();
        }
    }

    public void ReloadAmmo()
    {
        if (ammoCountValue > 0 && currentAmmo < magazineCapacity)
        {
            int ammoToLoad = Mathf.Min(magazineCapacity - currentAmmo, ammoCountValue);
            currentAmmo += ammoToLoad;
            ammoCountValue -= ammoToLoad;
            UpdateAmmoCountUI();
        }
    }
    #endregion

    #region Note UI
    public void SetNotePanelActive()
    {
        isNotePanelActive = !isNotePanelActive;
        notePanel.SetActive(isNotePanelActive);
    }
    #endregion

    #region Key UI Text
    public void UpdateKeyNamesText()
    {
        if (KeyManager.instance.allKeyName.Count > 0)
        {
            keyNamesText.gameObject.SetActive(true);

            string keyNamesString = "";
            foreach (string keyName in KeyManager.instance.allKeyName)
            {
                keyNamesString += keyName + "\n";
            }
            keyNamesText.text = keyNamesString;
        }
        else
        {
            keyNamesText.text = "";
            keyNamesText.gameObject.SetActive(false);
        }
    }
    #endregion
}
