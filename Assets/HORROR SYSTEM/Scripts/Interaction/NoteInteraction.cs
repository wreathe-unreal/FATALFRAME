using UnityEngine;

public class NoteInteraction : Item
{
    [Space]
    public string noteSound;

    protected bool IsNote = false;

    public override void ActivateObject()
    {
        IsNote = !IsNote;

        AudioManager.instance.Play(noteSound);
        UIManager.instance.SetNotePanelActive();
        PlayerManager.instance.DisablingPlayer(IsNote);
    }
}
