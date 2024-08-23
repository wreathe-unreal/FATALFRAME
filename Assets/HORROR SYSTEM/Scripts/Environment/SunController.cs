using System.Collections;
using UnityEngine;

public class SunController : MonoBehaviour
{
    public Light directionalLight;

    [Space]
    public Vector3 targetRotation = new Vector3(120f, 30f, 0f);
    private Vector3 initialRotation;

    [Space]
    public float rotationSpeed = 2f;

    private bool isChangingTime = false;
    private float initialIntensity;

    private InputManager input;

    void Start()
    {
        input = InputManager.instance;

        initialRotation = directionalLight.transform.rotation.eulerAngles;
        initialIntensity = directionalLight.intensity;
    }

    void Update()
    {
        if (input.sunAction.WasPressedThisFrame())
        {
            ChangeSun();
        }
    }

    public void ChangeSun()
    {
        isChangingTime = !isChangingTime;

        if (isChangingTime)
        {
            StartCoroutine(ChangeDayNight(targetRotation, 0f));
        }
        else
        {
            StartCoroutine(ChangeDayNight(initialRotation, initialIntensity));
        }
    }

    IEnumerator ChangeDayNight(Vector3 targetRotation, float targetIntensity)
    {
        Quaternion currentRotation = directionalLight.transform.rotation;
        Quaternion targetQuat = Quaternion.Euler(targetRotation);

        float currentIntensity = directionalLight.intensity;

        float t = 0f;
        while (t < 1f)
        {
            t += Time.deltaTime * rotationSpeed;

            directionalLight.transform.rotation = Quaternion.Slerp(currentRotation, targetQuat, t);
            directionalLight.intensity = Mathf.Lerp(currentIntensity, targetIntensity, t);

            yield return null;
        }
    }
}
