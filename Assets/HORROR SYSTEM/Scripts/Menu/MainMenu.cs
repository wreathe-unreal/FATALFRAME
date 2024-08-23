using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    public void PlayGame(string levelToLoad)
    {
        PlayerPrefs.SetString("LevelToLoad", levelToLoad);
        SceneManager.LoadScene("SceneLoader");
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
