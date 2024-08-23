using UnityEngine;

public class InventoryManager : MonoBehaviour
{
    [Header("Flashlight")]
    [Space]
    public GameObject flashlightObject;
    public Transform flashlightHandPoint;
    public Transform flashlightInventoryPoint;
    public bool flashlightInInventory;

    [Header("Knife")]
    [Space]
    public GameObject knifeObject;
    public Transform knifeHandPoint;
    public Transform knifeInventoryPoint;
    public bool knifeInInventory;

    [Header("Pistol")]
    [Space]
    public GameObject pistolObject;
    public Transform pistolHandPoint;
    public Transform pistolInventoryPoint;
    public bool pistolInInventory;

    public static InventoryManager instance;

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
        flashlightObject.SetActive(false);
        knifeObject.SetActive(false);
        pistolObject.SetActive(false);
    }

    private void MoveItem(GameObject item, Transform targetPoint)
    {
        item.transform.SetPositionAndRotation(targetPoint.position, targetPoint.rotation);
        item.transform.SetParent(targetPoint);
    }

    #region Flashlight
    public void FlashlightInInventory()
    {
        flashlightObject.SetActive(true);
        flashlightInInventory = true;
        MoveItem(flashlightObject, flashlightInventoryPoint);
    }

    public void FlashlightHandPosition()
    {
        MoveItem(flashlightObject, flashlightHandPoint);
    }
    #endregion

    #region Knife
    public void KnifeInInventory()
    {
        knifeObject.SetActive(true);
        knifeInInventory = true;
        MoveItem(knifeObject, knifeInventoryPoint);
    }

    public void KnifeHandPosition()
    {
        MoveItem(knifeObject, knifeHandPoint);
    }
    #endregion

    #region Pistol
    public void PistolInInventory()
    {
        pistolObject.SetActive(true);
        pistolInInventory = true;
        MoveItem(pistolObject, pistolInventoryPoint);
    }

    public void PistolHandPosition()
    {
        MoveItem(pistolObject, pistolHandPoint);
    }
    #endregion
}