using UnityEngine;
using UnityEngine.SceneManagement;

public class PauseMenu : MonoBehaviour
{
    public void Restart()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    public void MainMenu(string levelToLoad)
    {
        PlayerPrefs.SetString("LevelToLoad", levelToLoad);
        SceneManager.LoadScene("SceneLoader");
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
