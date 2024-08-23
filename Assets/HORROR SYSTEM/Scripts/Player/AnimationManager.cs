using UnityEngine;

public class AnimationManager : MonoBehaviour
{
    private Animator playerAnimator;

    private void Start()
    {
        playerAnimator = GetComponent<Animator>();
    }

    public void MovementParameters(float move, float strafe)
    {
        playerAnimator.SetFloat("Strafe", strafe);
        playerAnimator.SetFloat("Move", move);
    }

    public void StopAnimation(bool isIdleActive)
    {
        playerAnimator.SetBool("StopPlayer", isIdleActive);
    }

    public void SetCrouchAnimation(bool isCrouching)
    {
        playerAnimator.SetBool("Crouch", isCrouching);
    }

    public void SetRunningAnimation(bool isRunning)
    {
        playerAnimator.SetBool("Running", isRunning);
    }

    public void LeftHandAnimation(bool isLeftHand)
    {
        playerAnimator.SetBool("LeftHand", isLeftHand);
    }

    public void RightHandAnimation(bool isRightHand)
    {
        playerAnimator.SetBool("RightHand", isRightHand);
    }

    public void TriggerRightHandAction()
    {
        playerAnimator.SetTrigger("RightHandAction");
    }

    public void PlayerDeath()
    {
        playerAnimator.SetTrigger("Death");
    }

    public void TriggerKnifeAttack(bool isKnifeAttack)
    {
        playerAnimator.SetBool("AttackKnife", isKnifeAttack);
    }

    public void PistolAiming(bool isPistolAiming)
    {
        playerAnimator.SetBool("Pistol", isPistolAiming);
    }

    public void KnifeAiming(bool isKnifeAiming)
    {
        playerAnimator.SetBool("Knife", isKnifeAiming);
    }
}
