using UnityEngine;

public class PlayerManager : MonoBehaviour
{
    public PlayerController playerController;
    public PlayerCameraController playerCameraController;
    public AnimationManager animationManager;

    public static PlayerManager instance;

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

    public void DisablingPlayer(bool isDisabling)
    {
        playerController.playerMovement = !isDisabling;
        playerCameraController.isCameraRotation = !isDisabling;
        animationManager.StopAnimation(isDisabling);
    }
}
