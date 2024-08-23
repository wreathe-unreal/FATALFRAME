using UnityEngine;

public class TriggerInteraction : MonoBehaviour
{
    public GameObject[] interactiveObjects;

    [Space]
    public GameObject[] iconPoint;

    [Space]
    public bool destroyTrigger;

    private int currentObjectIndex = 0;
    private bool allowInteraction;
    private bool isInteracting = false;

    private InputManager input;

    private void Start()
    {
        input = InputManager.instance;
    }

    void Update()
    {
        Interaction();
    }

    public void Interaction()
    {
        if (input.interactionAction.WasPressedThisFrame() && allowInteraction)
        {
            if (!isInteracting)
            {
                if (currentObjectIndex < interactiveObjects.Length)
                {
                    GameObject currentObject = interactiveObjects[currentObjectIndex];
                    currentObject?.GetComponent<Item>()?.ActivateObject();

                    if (currentObjectIndex == interactiveObjects.Length - 1)
                    {
                        UIManager.instance.SetCurrentObject(null);

                        if (destroyTrigger)
                        {
                            Destroy(gameObject);
                        }
                    }
                    else
                    {
                        currentObjectIndex++;
                        UIManager.instance.SetCurrentObject(iconPoint[currentObjectIndex]);
                    }
                }
                isInteracting = true;
            }
        }
        else
        {
            isInteracting = false;
        }
    }

    public void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            allowInteraction = true;
            UIManager.instance.SetCurrentObject(iconPoint[currentObjectIndex]);
        }
    }

    public void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            allowInteraction = false;
            UIManager.instance.SetCurrentObject(null);
            currentObjectIndex = 0;
        }
    }
}
