using UnityEngine;
using UnityEngine.Animations.Rigging;

public class PlayerController : MonoBehaviour
{
    [Header("Camera")]
    public PlayerCameraController playerCamera;

    [Header("Player Move")]
    public Transform targetLook;
    [Range(0.0f, 0.3f)]
    public float playerRotationSmooth;

    float luft = 1f;
    private float rotationVelocity;

    private float move = 0f;
    private float strafe = 0f;

    public bool playerMovement;
    public bool playerRunning;
    public bool playerCrouch;

    [Header("Player IK")]
    public Rig flashlightRig;
    public Rig pistolRig;

    public float lerpSpeed = 5f;

    [Header("Player Footsteps")]
    public AudioClip[] FootstepAudioClips;
    [Range(0, 1)] public float FootstepAudioVolume = 0.5f;

    [Header("Player Health")]
    public float healthAmount;
    public float healthChange;
    float maxHealthAmount;
    public string treatmentSound;

    [Header("Flashlight")]
    public FlashlightController flashlightController;
    public string clickSound;

    [Header("Player Weapon")]
    public KnifeController knifeController;
    public PistolController pistolController;
    public bool isHand = false;
    public bool isKnife = false;
    public bool isPistol = false;

    #region Private
    private bool isKnifeAiming = false;
    private bool isPistolAiming = false;

    private bool isKnifeActive = false;
    private bool isPistolActive = false;
    private bool isFlashlightActive = false;
    private bool isPauseActive = false;
    private bool isCrouchActive = false;
    
    private bool isKnifeAttack = false;

    private bool isDead = false;

    private CharacterController controller;
    private AnimationManager playerAnimations;

    private InputManager input;
    private UIManager ui;
    private InventoryManager inventory;
    private PlayerManager player;
    #endregion

    private void Start()
    {
        controller = GetComponent<CharacterController>();
        playerAnimations = GetComponent<AnimationManager>();
        input = InputManager.instance;
        ui = UIManager.instance;
        inventory = InventoryManager.instance;
        player = PlayerManager.instance;

        flashlightRig.weight = 0f;
        pistolRig.weight = 0f;

        playerMovement = true;
        playerRunning = false;
        playerCrouch = false;

        maxHealthAmount = healthAmount;
    }

    private void Update()
    {
        Movement();

        PauseMenuEnable();

        HealthUIUpdate();
        Treatment();
        Death();

        ReloadFlashlightBattery();

        KnifeAttack();
        PistolAttack();

        ToggleFlashlight();


        if (input.knifeAction.WasPressedThisFrame())
        {
            ToggleKnife();
        }
        else if (input.pistolAction.WasPressedThisFrame())
        {
            TogglePistol();
        }
    }

    #region Movement
    private void Movement()
    {
        if (isDead) return;

        if (!playerMovement)
        {
            return;
        }

        float targetMove = input.MoveInput.y;
        float targetStrafe = input.MoveInput.x;

        if (Mathf.Abs(targetMove) > Mathf.Abs(targetStrafe))
        {
            targetStrafe = 0f;
        }
        else
        {
            targetMove = 0f;
        }

        float transitionSpeed = 5f;
        move = Mathf.Lerp(move, targetMove, Time.deltaTime * transitionSpeed);
        strafe = Mathf.Lerp(strafe, targetStrafe, Time.deltaTime * transitionSpeed);

        float threshold = 0.01f;
        move = Mathf.Abs(move) < threshold ? 0f : move;
        strafe = Mathf.Abs(strafe) < threshold ? 0f : strafe;

        playerAnimations.MovementParameters(move, strafe);

        Vector3 inputDirection = new Vector3(input.MoveInput.x, 0.0f, input.MoveInput.y).normalized;

        if (move != 0 || strafe != 0)
        {
            playerRunning = input.runningAction.IsPressed();
            playerAnimations.SetRunningAnimation(playerRunning);

            Rotation();
        }

        if (!isPistolAiming && !playerRunning)
        {
            if (input.crouchAction.WasPressedThisFrame())
            {
                isCrouchActive = !isCrouchActive;
            }

            playerCrouch = isCrouchActive;
            playerAnimations.SetCrouchAnimation(playerCrouch);
            playerCamera.CameraCrouch(playerCrouch);
        }
    }

    public void Rotation()
    {
        Vector3 directionToTarget = targetLook.position - transform.position;
        directionToTarget.y = 0f;
        float targetRotation = Mathf.Atan2(directionToTarget.x, directionToTarget.z) * Mathf.Rad2Deg;

        if (isPistolAiming || isKnifeAiming)
        {
            transform.rotation = Quaternion.Euler(0.0f, targetRotation, 0.0f);
        }
        else
        {
            float angleBetween = Mathf.DeltaAngle(transform.eulerAngles.y, targetRotation);
            if (Mathf.Abs(angleBetween) > luft || strafe != 0)
            {
                float rotation = Mathf.SmoothDampAngle(transform.eulerAngles.y, targetRotation, ref rotationVelocity, playerRotationSmooth);
                transform.rotation = Quaternion.Euler(0.0f, rotation, 0.0f);
            }
        }
    }
    #endregion

    #region Health
    public void HealthChange()
    {
        healthAmount -= healthChange * Time.deltaTime;
        healthAmount = Mathf.Max(healthAmount, 0);
    }

    public void HealthUIUpdate()
    {
        ui.HealthUIChange(healthAmount, maxHealthAmount);
    }

    public void Treatment()
    {
        if (input.treatmentAction.WasPressedThisFrame())
        {
            if (healthAmount < maxHealthAmount)
            {
                if (ui.medKitCountValue > 0)
                {
                    healthAmount = maxHealthAmount;
                    ui.AddMedKit(-1);
                    AudioManager.instance.Play(treatmentSound);
                }
            }
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.tag == "DamageTrigger" && !isDead)
        {
            HealthChange();
        }
    }

    public void Death()
    {
        if (healthAmount <= 0 && !isDead)
        {
            playerAnimations.PlayerDeath();
            isDead = true;

            if (isFlashlightActive)
            {
                flashlightRig.weight = 0f;
            }

            if (isPistolAiming)
            {
                pistolRig.weight = 0f;
                playerCamera.ResetCamera();
            }

        }
    }
    #endregion

    #region Footstep
    private void OnFootstep(AnimationEvent animationEvent)
    {
        if (animationEvent.animatorClipInfo.weight > 0.5f)
        {
            if (FootstepAudioClips.Length > 0)
            {
                var index = Random.Range(0, FootstepAudioClips.Length);
                AudioSource.PlayClipAtPoint(FootstepAudioClips[index], transform.TransformPoint(controller.center), FootstepAudioVolume);
            }
        }
    }
    #endregion

    #region Pause Menu
    public void PauseMenuEnable()
    {
        if (input.pauseAction.WasPressedThisFrame())
        {
            isPauseActive = !isPauseActive;

            player.DisablingPlayer(isPauseActive);
        }

        bool isPauseMenuEnable = isPauseActive;
        ui.pauseMenu.SetActive(isPauseMenuEnable);
    }
    #endregion

    #region Flashlight
    public void ToggleFlashlight()
    {
        if (isDead) return;

        if (inventory.flashlightInInventory)
        {
            if (input.flashlightAction.WasPressedThisFrame())
            {
                isFlashlightActive = !isFlashlightActive;
                AudioManager.instance.Play(clickSound);
            }

            bool isFlashlightEnable = isFlashlightActive;

            float targetFlashlightWeight = isFlashlightEnable ? 1f : 0f;
            flashlightRig.weight = Mathf.Lerp(flashlightRig.weight, targetFlashlightWeight, lerpSpeed * Time.deltaTime);

            playerAnimations.LeftHandAnimation(isFlashlightEnable);
            flashlightController.ManageFlashlight(isFlashlightEnable);
            ui.batteryPanel.SetActive(isFlashlightEnable);

            if (isFlashlightEnable)
            {
                inventory.FlashlightHandPosition();
                Rotation();
            }
            else
            {
                inventory.FlashlightInInventory();
            }
        }
    }

    public void ReloadFlashlightBattery()
    {
        if (isDead) return;

        if (input.batteryAction.WasPressedThisFrame() && flashlightController.spotLight.enabled)
        {
            flashlightController.ReloadBattery();
        }
    }
    #endregion

    #region Toggle Weapons
    private void ToggleKnife()
    {
        if (isDead) return;

        if (inventory.knifeInInventory)
        {
            if (isPistolAiming) return;
            if (isKnifeAiming) return;

            isKnifeActive = !isKnifeActive;

            if (isKnifeActive)
            {
                isHand = false;
                isKnife = true;
                inventory.KnifeHandPosition();

                if (isPistol)
                {
                    isPistol = false;
                    isPistolActive = false;
                    inventory.PistolInInventory();
                }
            }
            else
            {
                isKnife = false;
                isHand = true;
                inventory.KnifeInInventory();
            }

            playerAnimations.TriggerRightHandAction();
            playerAnimations.RightHandAnimation(!isHand);
        }
    }

    private void TogglePistol()
    {
        if (isDead) return;

        if (inventory.pistolInInventory)
        {
            if (isPistolAiming) return;
            if (isKnifeAiming) return;

            isPistolActive = !isPistolActive;

            ui.ammoPanel.SetActive(isPistolActive);

            if (isPistolActive)
            {
                isHand = false;
                isPistol = true;
                inventory.PistolHandPosition();

                if (isKnife)
                {
                    isKnife = false;
                    isKnifeActive = false;
                    inventory.KnifeInInventory();
                }
            }
            else
            {
                isPistol = false;
                isHand = true;
                inventory.PistolInInventory();
            }

            playerAnimations.TriggerRightHandAction();
            playerAnimations.RightHandAnimation(!isHand);
        }
    }
    #endregion

    #region Weapons Attack
    public void KnifeAttack()
    {
        if (isDead) return;

        if (isKnife)
        {
            isKnifeAiming = input.aimingAction.IsPressed();
            playerAnimations.KnifeAiming(isKnifeAiming);

            if (isKnifeAiming)
            {
                playerCrouch = false;
                playerAnimations.SetCrouchAnimation(playerCrouch);
                playerCamera.CameraCrouch(playerCrouch);
                Rotation();

                flashlightRig.weight = 0f;

                isKnifeAttack = input.attackAction.IsPressed();
                playerAnimations.TriggerKnifeAttack(isKnifeAttack);

                if (input.attackAction.IsPressed())
                {
                    knifeController.KnifeAttack();
                }
            }
        }
    }

    public void PistolAttack()
    {
        if (isDead) return;

        if (isPistol)
        {
            isPistolAiming = input.aimingAction.IsPressed();
            playerAnimations.PistolAiming(isPistolAiming);
            playerCamera.CameraAiming(isPistolAiming);

            if (isPistolAiming)
            {
                playerCrouch = false;
                playerAnimations.SetCrouchAnimation(playerCrouch);
                playerCamera.CameraCrouch(playerCrouch);
                Rotation();

                if (input.attackAction.IsPressed())
                {
                    pistolController.PistolShoot();
                }
            }

            if (input.reloadPistolAction.WasPressedThisFrame())
            {
                pistolController.PistolReloading();
            }

            float targetPistolWeight = isPistolAiming ? 1f : 0f;
            pistolRig.weight = Mathf.Lerp(pistolRig.weight, targetPistolWeight, lerpSpeed * Time.deltaTime);
        }
    }
    #endregion
}
