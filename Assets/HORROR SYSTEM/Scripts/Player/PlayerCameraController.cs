using UnityEngine;

public class PlayerCameraController : MonoBehaviour
{
    public Transform player;
    public Transform playerCamera;
    public Transform pivot;
    public Transform cameraHolder;
    public Transform targetLook;

    [Space]
    public float normalZ;
    public float normalY;
    public float normalX;

    [Space]
    public float aimingHeightOffset = -0.2f;
    public float crouchHeightOffset = -0.5f;

    [Space]
    public float crouchTargetLookOffset = -5f;

    [Space]
    public float minAngle;
    public float maxAngle;

    [Space]
    public float rotatinSpeedY;
    public float rotatinSpeedX;

    [Space]
    public float turnSmooth;
    public float pivotSpeed;

    [Space]
    [Range(10, 60)]
    public int aimingZoom = 30;

    [HideInInspector] public bool isCameraRotation;

    #region Private
    private int smoothZoom = 10;
    private int normal = 60;
    private float isZoomed = 0;

    private float delta;

    private float mouseX;
    private float mouseY;

    private float smoothX;
    private float smoothY;

    private float smoothXVelocity;
    private float smoothYVelocity;

    private float lookAngle;
    private float titlAngle;

    private bool isCameraLowered = false;
    private float loweredCameraY;

    private InputManager input;
    #endregion

    void Start()
    {
        input = InputManager.instance;

        isCameraRotation = true;

        transform.position = playerCamera.position;
        transform.forward = targetLook.forward;
    }

    void LateUpdate()
    {
        Tick();
    }

    void Tick()
    {
        delta = Time.deltaTime;

        HandlePosition();
        HandleRotation();

        Vector3 targetPosition = Vector3.Lerp(cameraHolder.position, player.position, 1);
        cameraHolder.position = targetPosition;
    }

    #region Position
    void HandlePosition()
    {
        float targetX = normalX;
        float targetY = isCameraLowered ? loweredCameraY : normalY;
        float targetZ = normalZ;

        Vector3 newPivotPosition = pivot.localPosition;
        newPivotPosition.x = targetX;

        Vector3 newCameraPosition = playerCamera.localPosition;
        newCameraPosition.z = targetZ;

        float t = delta * pivotSpeed;
        newPivotPosition.y = Mathf.Lerp(pivot.localPosition.y, targetY, t);
        pivot.localPosition = newPivotPosition;
        playerCamera.localPosition = Vector3.Lerp(playerCamera.localPosition, newCameraPosition, t);
    }
    #endregion

    #region Rotation
    void HandleRotation()
    {
        if (isCameraRotation)
        {
            mouseX = input.LookInput.x;
            mouseY = input.LookInput.y;
        }

        if (turnSmooth > 0)
        {
            smoothX = Mathf.SmoothDamp(smoothX, mouseX, ref smoothXVelocity, turnSmooth);
            smoothY = Mathf.SmoothDamp(smoothY, mouseY, ref smoothYVelocity, turnSmooth);
        }
        else
        {
            smoothX = mouseX;
            smoothY = mouseY;
        }

        lookAngle += smoothX * rotatinSpeedY;
        Quaternion targetRot = Quaternion.Euler(0, lookAngle, 0);

        cameraHolder.rotation = targetRot;

        titlAngle -= smoothY * rotatinSpeedX;
        titlAngle = Mathf.Clamp(titlAngle, minAngle, maxAngle);

        pivot.localRotation = Quaternion.Euler(titlAngle, 0, 0);
    }
    #endregion

    #region Crouch
    public void CameraCrouch(bool isCrouchCamera)
    {
        if (isCrouchCamera)
        {
            Vector3 newCameraLocalPos = playerCamera.localPosition;
            newCameraLocalPos.y = Mathf.Lerp(playerCamera.localPosition.y, crouchHeightOffset, Time.deltaTime * smoothZoom);
            playerCamera.localPosition = newCameraLocalPos;

            Vector3 newTargetLookLocalPos = targetLook.localPosition;
            newTargetLookLocalPos.y = Mathf.Lerp(targetLook.localPosition.y, crouchTargetLookOffset, Time.deltaTime * smoothZoom);
            targetLook.localPosition = newTargetLookLocalPos;
        }
        else
        {
            Vector3 newCameraLocalPos = playerCamera.localPosition;
            newCameraLocalPos.y = Mathf.Lerp(playerCamera.localPosition.y, 0, Time.deltaTime * smoothZoom);
            playerCamera.localPosition = newCameraLocalPos;

            Vector3 newTargetLookLocalPos = targetLook.localPosition;
            newTargetLookLocalPos.y = Mathf.Lerp(targetLook.localPosition.y, 0, Time.deltaTime * smoothZoom);

            if (Mathf.Abs(newTargetLookLocalPos.y) < 0.01f)
            {
                newTargetLookLocalPos.y = 0;
            }

            targetLook.localPosition = newTargetLookLocalPos;
        }
    }
    #endregion

    #region Aiming
    public void CameraAiming(bool isAimingCamera)
    {
        isZoomed = isAimingCamera ? 1f : 0f;

        if (isZoomed == 1)
        {
            playerCamera.GetComponent<Camera>().fieldOfView = Mathf.Lerp(playerCamera.GetComponent<Camera>().fieldOfView, aimingZoom, Time.deltaTime * smoothZoom);

            Vector3 newCameraLocalPos = playerCamera.localPosition;
            newCameraLocalPos.y = Mathf.Lerp(playerCamera.localPosition.y, aimingHeightOffset, Time.deltaTime * smoothZoom);
            playerCamera.localPosition = newCameraLocalPos;
        }
        else
        {
            isZoomed = 0;
            playerCamera.GetComponent<Camera>().fieldOfView = Mathf.Lerp(playerCamera.GetComponent<Camera>().fieldOfView, normal, Time.deltaTime * smoothZoom);

            Vector3 newCameraLocalPos = playerCamera.localPosition;
            newCameraLocalPos.y = Mathf.Lerp(playerCamera.localPosition.y, 0, Time.deltaTime * smoothZoom);
            playerCamera.localPosition = newCameraLocalPos;
        }
    }

    public void ResetCamera()
    {
        playerCamera.GetComponent<Camera>().fieldOfView = normal;

        Vector3 newCameraLocalPos = playerCamera.localPosition;
        newCameraLocalPos.y = 0;
        playerCamera.localPosition = newCameraLocalPos;
    }
    #endregion
}
