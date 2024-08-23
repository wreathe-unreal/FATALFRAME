using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using TMPro;

public class SceneLoader : MonoBehaviour
{
    public Image loadingImage;

    [Space]
    public TMP_Text loadingSceneNameText;
    public TMP_Text pressAnyKeyText;

    [Space]
    public float loadingSpeed = 0.5f;

    private AsyncOperation loadingOperation;

    private void Start()
    {
        loadingImage.fillAmount = 0f;
        pressAnyKeyText.gameObject.SetActive(false);
        StartCoroutine(LoadSceneAsync(PlayerPrefs.GetString("LevelToLoad")));
    }

    private IEnumerator LoadSceneAsync(string sceneName)
    {
        loadingSceneNameText.text = "LOADING: " + sceneName;

        loadingOperation = SceneManager.LoadSceneAsync(sceneName);
        loadingOperation.allowSceneActivation = false;

        while (!loadingOperation.isDone)
        {
            float progress = Mathf.Clamp01(loadingOperation.progress / 0.9f);
            loadingImage.fillAmount = Mathf.Lerp(loadingImage.fillAmount, progress, loadingSpeed * Time.deltaTime);

            if (loadingImage.fillAmount >= 0.99f)
            {
                pressAnyKeyText.gameObject.SetActive(true);

                if (Input.anyKeyDown)
                {
                    loadingOperation.allowSceneActivation = true;
                }
            }

            yield return null;
        }
    }
}
