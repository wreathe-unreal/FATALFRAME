using UnityEngine;

public class RadioInteraction : Item
{
    public AudioSource radioAudioSource;
    public string radioSound;

    protected bool isRadio = false;

    private void Start()
    {
        radioAudioSource.Stop();
    }

    public override void ActivateObject()
    {
        isRadio = !isRadio;
        AudioManager.instance.Play(radioSound);

        UpdateRadioState();
    }

    private void UpdateRadioState()
    {
        if (isRadio)
        {
            radioAudioSource.Play();
        }
        else
        {
            radioAudioSource.Stop();
        }
    }
}