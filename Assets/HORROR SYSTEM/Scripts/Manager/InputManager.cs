using UnityEngine;
using UnityEngine.InputSystem;

public class InputManager : MonoBehaviour
{
    [Header("Input Action Asset")]
    [SerializeField] private InputActionAsset inputControls;

    [Header("Action Map Name References")]
    [SerializeField] private string actionMapName = "Player";

    [Header("Action Name References")]
    [SerializeField] private string move = "Move";
    [SerializeField] private string look = "Look";
    [SerializeField] private string running = "Running";
    [SerializeField] private string crouch = "Crouch";
    
    [SerializeField] private string iteraction = "Interaction";

    [SerializeField] private string treatment = "Treatment";

    [SerializeField] private string pause = "Pause";

    [SerializeField] private string flashlight = "Flashlight";
    [SerializeField] private string battery = "Battery";

    [SerializeField] private string aiming = "Aiming";
    [SerializeField] private string attack = "Attack";

    [SerializeField] private string knife = "Knife";
    [SerializeField] private string pistol = "Pistol";
    [SerializeField] private string reload = "Reload";
    
    [SerializeField] private string sun = "Sun";

    #region Input Action
    [HideInInspector] public InputAction moveAction;
    [HideInInspector] public InputAction lookAction;
    [HideInInspector] public InputAction runningAction;
    [HideInInspector] public InputAction crouchAction;
    
    [HideInInspector] public InputAction interactionAction;

    [HideInInspector] public InputAction treatmentAction;

    [HideInInspector] public InputAction pauseAction;
    
    [HideInInspector] public InputAction flashlightAction;
    [HideInInspector] public InputAction batteryAction;

    [HideInInspector] public InputAction aimingAction;
    [HideInInspector] public InputAction attackAction;

    [HideInInspector] public InputAction knifeAction;
    [HideInInspector] public InputAction pistolAction;
    [HideInInspector] public InputAction reloadPistolAction;
    
    [HideInInspector] public InputAction sunAction;
    #endregion

    public Vector2 MoveInput {  get; private set; }
    public Vector2 LookInput {  get; private set; }

    public static InputManager instance;

    private void Awake()
    {
        if(instance == null)
        {
            instance = this;
        }
        else
        {
            Destroy(gameObject);
        }

        #region Movement Action
        moveAction = inputControls.FindActionMap(actionMapName).FindAction(move);
        lookAction = inputControls.FindActionMap(actionMapName).FindAction(look);
        runningAction = inputControls.FindActionMap(actionMapName).FindAction(running);
        crouchAction = inputControls.FindActionMap(actionMapName).FindAction(crouch);
        #endregion

        #region Interaction Action
        interactionAction = inputControls.FindActionMap(actionMapName).FindAction(iteraction);
        #endregion

        #region Treatment Action
        treatmentAction = inputControls.FindActionMap(actionMapName).FindAction(treatment);
        #endregion

        #region Pause Action
        pauseAction = inputControls.FindActionMap(actionMapName).FindAction(pause);
        #endregion

        #region Flashlight Action
        flashlightAction = inputControls.FindActionMap(actionMapName).FindAction(flashlight);
        batteryAction = inputControls.FindActionMap(actionMapName).FindAction(battery);
        #endregion

        #region Attack Action
        aimingAction = inputControls.FindActionMap(actionMapName).FindAction(aiming);
        attackAction = inputControls.FindActionMap(actionMapName).FindAction(attack);
        #endregion

        #region Weapon Action
        knifeAction = inputControls.FindActionMap(actionMapName).FindAction(knife);
        pistolAction = inputControls.FindActionMap(actionMapName).FindAction(pistol);
        reloadPistolAction = inputControls.FindActionMap(actionMapName).FindAction(reload);
        #endregion

        #region Sun Action
        sunAction = inputControls.FindActionMap(actionMapName).FindAction(sun);
        #endregion

        RegisterInputActions();
    }

    void RegisterInputActions()
    {
        moveAction.performed += context => MoveInput = context.ReadValue<Vector2>();
        moveAction.canceled += context => MoveInput = Vector2.zero;

        lookAction.performed += context => LookInput = context.ReadValue<Vector2>();
        lookAction.canceled += context => LookInput = Vector2.zero;
    }

    private void OnEnable()
    {
        #region Movement Enable
        moveAction.Enable();
        lookAction.Enable();
        runningAction.Enable();
        crouchAction.Enable();
        #endregion

        #region Interaction Enable
        interactionAction.Enable();
        #endregion

        #region Treatment Enable
        treatmentAction.Enable();
        #endregion

        #region Pause Enable
        pauseAction.Enable();
        #endregion

        #region Flashlight Enable
        flashlightAction.Enable();
        batteryAction.Enable();
        #endregion

        #region Attack Enable
        aimingAction.Enable();
        attackAction.Enable();
        #endregion

        #region Weapon Enable
        knifeAction.Enable();
        pistolAction.Enable();
        reloadPistolAction.Enable();
        #endregion

        #region Sun Enable
        sunAction.Enable();
        #endregion
    }

    private void OnDisable()
    {
        #region Movement Disable
        moveAction.Disable();
        lookAction.Disable();
        runningAction.Disable();
        crouchAction.Disable();
        #endregion

        #region Interaction Disable
        interactionAction.Disable();
        #endregion

        #region Treatment Disable
        treatmentAction.Disable();
        #endregion

        #region Pause Disable
        pauseAction.Disable();
        #endregion

        #region Flashlight Disable
        flashlightAction.Disable();
        batteryAction.Disable();
        #endregion

        #region Attack Disable
        aimingAction.Disable();
        attackAction.Disable();
        #endregion

        #region Weapon Disable
        knifeAction.Disable();
        pistolAction.Disable();
        reloadPistolAction.Disable();
        #endregion

        #region Sun Disable
        sunAction.Disable();
        #endregion
    }
}
